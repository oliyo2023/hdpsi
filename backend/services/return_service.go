package services

import (
	"errors"
	"fmt"
	"strconv"
	"time"

	"hd_psi/backend/models"
	"hd_psi/backend/utils"

	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

// ReturnService handles business logic for return orders
type ReturnService struct {
	DB *gorm.DB
}

// NewReturnService creates a new ReturnService
func NewReturnService(db *gorm.DB) *ReturnService {
	return &ReturnService{DB: db}
}

// CreateReturnOrderInput defines the input for creating a return order
type CreateReturnOrderInput struct {
	OrderNo                 string                         `json:"orderNo" binding:"required"`
	Type                    string                         `json:"type" binding:"required,oneof=RETURN EXCHANGE"`
	CustomerName            string                         `json:"customerName"`
	CustomerPhone           string                         `json:"customerPhone"`
	Remarks                 string                         `json:"remarks"`
	Images                  []string                       `json:"images"` // Array of image URLs
	RefundAmount            *float64                       `json:"refundAmount,omitempty"`
	ExchangeShippingAddress string                         `json:"exchangeShippingAddress,omitempty"`
	ExchangeShippingContact string                         `json:"exchangeShippingContact,omitempty"`
	ExchangeShippingPhone   string                         `json:"exchangeShippingPhone,omitempty"`
	ReturnOrderItems        []CreateReturnOrderItemInput   `json:"returnOrderItems" binding:"required,dive"`
	ExchangeOrderItems      []CreateExchangeOrderItemInput `json:"exchangeOrderItems" binding:"dive"`
	UserID                  uint                           `json:"-"` // Operator ID from context
	UserName                string                         `json:"-"` // Operator Name from context
}

// CreateReturnOrderItemInput defines input for return items
type CreateReturnOrderItemInput struct {
	ProductID uint   `json:"productId" binding:"required"`
	Quantity  int    `json:"quantity" binding:"required,gt=0"`
	Reason    string `json:"reason,omitempty"`
	Remarks   string `json:"remarks,omitempty"`
}

// CreateExchangeOrderItemInput defines input for exchange items
type CreateExchangeOrderItemInput struct {
	ProductID uint `json:"productId" binding:"required"`
	Quantity  int  `json:"quantity" binding:"required,gt=0"`
}

// CreateReturnOrder creates a new return/exchange order
func (s *ReturnService) CreateReturnOrder(input CreateReturnOrderInput) (*models.ReturnOrder, error) {
	if input.Type == models.ReturnTypeReturn && len(input.ReturnOrderItems) == 0 {
		return nil, utils.NewValidationError("退货申请必须包含至少一个退货商品")
	}
	if input.Type == models.ReturnTypeExchange && len(input.ExchangeOrderItems) == 0 {
		return nil, utils.NewValidationError("换货申请必须包含至少一个换货商品")
	}

	returnOrder := models.ReturnOrder{
		OrderNo:                 input.OrderNo,
		Type:                    input.Type,
		Status:                  models.ReturnStatusPendingApproval,
		CustomerName:            input.CustomerName,
		CustomerPhone:           input.CustomerPhone,
		ApplyDate:               time.Now(),
		Remarks:                 input.Remarks,
		RefundAmount:            input.RefundAmount,
		ExchangeShippingAddress: input.ExchangeShippingAddress,
		ExchangeShippingContact: input.ExchangeShippingContact,
		ExchangeShippingPhone:   input.ExchangeShippingPhone,
	}

	if len(input.Images) > 0 {
		imagesJSON, err := utils.ConvertStringSliceToJSON(input.Images)
		if err != nil {
			return nil, fmt.Errorf("处理图片数据失败: %w", err)
		}
		returnOrder.Images = imagesJSON
	}

	// Generate ReturnNo (example: RT202310270001)
	// This should be a more robust unique ID generation in a real system
	// For simplicity, using timestamp based, but ensure uniqueness (e.g., using a sequence or distributed ID generator)
	// Or use a hook in the model BeforeCreate
	prefix := "RT"
	if input.Type == models.ReturnTypeExchange {
		prefix = "EX"
	}
	// A simple way to generate a somewhat unique ID, consider a dedicated sequence or UUID for production
	count := int64(0)
	dateStr := time.Now().Format("20060102")
	s.DB.Model(&models.ReturnOrder{}).Where("return_no LIKE ?", prefix+dateStr+"%").Count(&count)
	returnOrder.ReturnNo = fmt.Sprintf("%s%s%04d", prefix, dateStr, count+1)

	for _, itemInput := range input.ReturnOrderItems {
		// Fetch product details to denormalize name/sku
		var product models.Product
		if err := s.DB.First(&product, itemInput.ProductID).Error; err != nil {
			return nil, fmt.Errorf("查找退货商品失败 ID %d: %w", itemInput.ProductID, err)
		}
		returnOrder.ReturnOrderItems = append(returnOrder.ReturnOrderItems, models.ReturnOrderItem{
			ProductID:   itemInput.ProductID,
			ProductName: product.Name, // Denormalize
			ProductSKU:  product.SKU,  // Denormalize
			Quantity:    itemInput.Quantity,
			Reason:      itemInput.Reason,
			Remarks:     itemInput.Remarks,
		})
	}

	for _, itemInput := range input.ExchangeOrderItems {
		var product models.Product
		if err := s.DB.First(&product, itemInput.ProductID).Error; err != nil {
			return nil, fmt.Errorf("查找换货商品失败 ID %d: %w", itemInput.ProductID, err)
		}
		returnOrder.ExchangeOrderItems = append(returnOrder.ExchangeOrderItems, models.ExchangeOrderItem{
			ProductID:   itemInput.ProductID,
			ProductName: product.Name, // Denormalize
			ProductSKU:  product.SKU,  // Denormalize
			Quantity:    itemInput.Quantity,
		})
	}

	// Add initial log entry
	logAction := "创建退货申请"
	if input.Type == models.ReturnTypeExchange {
		logAction = "创建换货申请"
	}
	returnOrder.ReturnOrderLogs = append(returnOrder.ReturnOrderLogs, models.ReturnOrderLog{
		OperatorID:   &input.UserID,
		OperatorName: input.UserName,
		Action:       logAction,
		LogTime:      time.Now(),
	})

	err := s.DB.Create(&returnOrder).Error
	if err != nil {
		return nil, fmt.Errorf("创建退换货订单失败: %w", err)
	}

	return &returnOrder, nil
}

// GetReturnOrderListInput defines parameters for listing return orders
type GetReturnOrderListInput struct {
	Page          int    `form:"page,default=1"`
	PageSize      int    `form:"pageSize,default=10"`
	ReturnNo      string `form:"returnNo"`
	OrderNo       string `form:"orderNo"`
	Type          string `form:"type"`
	Status        string `form:"status"`
	CustomerName  string `form:"customerName"`
	CustomerPhone string `form:"customerPhone"`
	StartDate     string `form:"startDate"` // YYYY-MM-DD
	EndDate       string `form:"endDate"`   // YYYY-MM-DD
}

// GetReturnOrderListResponse defines the response for listing return orders
type GetReturnOrderListResponse struct {
	Items    []models.ReturnOrder `json:"items"`
	Total    int64                `json:"total"`
	Page     int                  `json:"page"`
	PageSize int                  `json:"pageSize"`
}

// GetReturnOrderList retrieves a paginated list of return orders
func (s *ReturnService) GetReturnOrderList(input GetReturnOrderListInput) (*GetReturnOrderListResponse, error) {
	db := s.DB.Model(&models.ReturnOrder{})

	if input.ReturnNo != "" {
		db = db.Where("return_no LIKE ?", "%"+input.ReturnNo+"%")
	}
	if input.OrderNo != "" {
		db = db.Where("order_no LIKE ?", "%"+input.OrderNo+"%")
	}
	if input.Type != "" {
		db = db.Where("type = ?", input.Type)
	}
	if input.Status != "" {
		db = db.Where("status = ?", input.Status)
	}
	if input.CustomerName != "" {
		db = db.Where("customer_name LIKE ?", "%"+input.CustomerName+"%")
	}
	if input.CustomerPhone != "" {
		db = db.Where("customer_phone LIKE ?", "%"+input.CustomerPhone+"%")
	}
	if input.StartDate != "" {
		db = db.Where("apply_date >= ?", input.StartDate)
	}
	if input.EndDate != "" {
		endDate, err := time.Parse("2006-01-02", input.EndDate)
		if err == nil {
			db = db.Where("apply_date <= ?", endDate.AddDate(0, 0, 1)) // Include the whole end day
		}
	}

	var total int64
	if err := db.Count(&total).Error; err != nil {
		return nil, fmt.Errorf("统计退换货订单数量失败: %w", err)
	}

	var items []models.ReturnOrder
	offset := (input.Page - 1) * input.PageSize
	if err := db.Order("apply_date DESC").Limit(input.PageSize).Offset(offset).Find(&items).Error; err != nil {
		return nil, fmt.Errorf("查询退换货订单列表失败: %w", err)
	}

	return &GetReturnOrderListResponse{
		Items:    items,
		Total:    total,
		Page:     input.Page,
		PageSize: input.PageSize,
	}, nil
}

// GetReturnOrderByID retrieves a single return order by its ID
func (s *ReturnService) GetReturnOrderByID(id uint) (*models.ReturnOrder, error) {
	var returnOrder models.ReturnOrder
	// Preload associated items and logs
	err := s.DB.Preload("ReturnOrderItems.Product").
		Preload("ExchangeOrderItems.Product").
		Preload("ReturnOrderLogs").
		Preload("Approver").
		Preload("Processor").
		First(&returnOrder, id).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, utils.NewNotFoundError("未找到指定的退换货订单")
		}
		return nil, fmt.Errorf("查询退换货订单详情失败: %w", err)
	}
	return &returnOrder, nil
}

// UpdateReturnOrderStatusInput defines input for updating status
type UpdateReturnOrderStatusInput struct {
	Status          string `json:"status" binding:"required"`
	RejectionReason string `json:"rejectionReason,omitempty"` // For REJECTED status
	Remarks         string `json:"remarks,omitempty"`         // General remarks for the log
	UserID          uint   `json:"-"`
	UserName        string `json:"-"`
	// Fields for specific status updates, e.g., shipping info for EXCHANGE_SHIPPED
	ActualRefundAmount *float64 `json:"actualRefundAmount,omitempty"`
	RefundMethod       *string  `json:"refundMethod,omitempty"`
	ExchangeShippingNo *string  `json:"exchangeShippingNo,omitempty"`
	// Fields for PENDING_SHIPMENT (if any specific needed, though often it's just a status change)

}

// UpdateReturnOrderStatus updates the status of a return order
func (s *ReturnService) UpdateReturnOrderStatus(id uint, input UpdateReturnOrderStatusInput) (*models.ReturnOrder, error) {
	var returnOrder models.ReturnOrder
	tx := s.DB.Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	if err := tx.Clauses(clause.Locking{Strength: "UPDATE"}).First(&returnOrder, id).Error; err != nil {
		tx.Rollback()
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, utils.NewNotFoundError("未找到指定的退换货订单")
		}
		return nil, fmt.Errorf("查询退换货订单失败 (for update): %w", err)
	}

	// Basic status transition validation (can be more complex)
	oldStatus := returnOrder.Status
	if !isValidStatusTransition(oldStatus, input.Status, returnOrder.Type) {
		tx.Rollback()
		return nil, utils.NewValidationError(fmt.Sprintf("无效的状态转换: 从 %s 到 %s", oldStatus, input.Status))
	}

	updateData := map[string]interface{}{"status": input.Status}
	logAction := fmt.Sprintf("更新状态为: %s", getStatusDescription(input.Status))

	switch input.Status {
	case models.ReturnStatusApproved:
		updateData["approved_by"] = &input.UserID
		updateData["approval_date"] = time.Now()
		logAction = "审批通过"
	case models.ReturnStatusRejected:
		updateData["approved_by"] = &input.UserID
		updateData["approval_date"] = time.Now()
		updateData["rejection_reason"] = input.RejectionReason
		logAction = "审批拒绝"
		if input.RejectionReason != "" {
			logAction += fmt.Sprintf(", 原因: %s", input.RejectionReason)
		}
	case models.ReturnStatusProcessing:
		updateData["processed_by"] = &input.UserID
		updateData["process_date"] = time.Now()
		logAction = "开始处理"
	case models.ReturnStatusGoodsReceived: // For RETURN type
		if returnOrder.Type != models.ReturnTypeReturn {
			tx.Rollback()
			return nil, utils.NewValidationError("只有退货类型的订单才能更新为'已收到退货'")
		}
		// Logic for updating received quantities on items might be needed here
		logAction = "已收到退货商品"
	case models.ReturnStatusExchangeShipped: // For EXCHANGE type
		if returnOrder.Type != models.ReturnTypeExchange {
			tx.Rollback()
			return nil, utils.NewValidationError("只有换货类型的订单才能更新为'已发出换货商品'")
		}
		if input.ExchangeShippingNo != nil {
			updateData["exchange_shipping_no"] = *input.ExchangeShippingNo
			logAction += fmt.Sprintf(", 物流单号: %s", *input.ExchangeShippingNo)
		}
		// Logic for updating shipped quantities on items might be needed here
	case models.ReturnStatusPendingShipment: // For EXCHANGE type
		if returnOrder.Type != models.ReturnTypeExchange {
			tx.Rollback()
			return nil, utils.NewValidationError("只有换货类型的订单才能更新为'待发货'")
		}
		logAction = "进入待发货状态"
	case models.ReturnStatusRefunded: // For RETURN type
		if returnOrder.Type != models.ReturnTypeReturn {
			tx.Rollback()
			return nil, utils.NewValidationError("只有退货类型的订单才能更新为'已退款'")
		}
		if input.ActualRefundAmount == nil || input.RefundMethod == nil {
			tx.Rollback()
			return nil, utils.NewValidationError("退款时必须提供实际退款金额和退款方式")
		}
		updateData["actual_refund_amount"] = *input.ActualRefundAmount
		updateData["refund_method"] = *input.RefundMethod
		updateData["refund_date"] = time.Now()
		logAction = fmt.Sprintf("已退款, 金额: %.2f, 方式: %s", *input.ActualRefundAmount, *input.RefundMethod)
	case models.ReturnStatusCompleted:
		updateData["completed_date"] = time.Now()
		if returnOrder.Status != models.ReturnStatusRefunded && returnOrder.Status != models.ReturnStatusExchangeShipped && returnOrder.Status != models.ReturnStatusProcessing {
			// Allow completion from processing if no specific refund/ship step is used
			// Or if it's a simple rejection that is now considered 'complete' in terms of workflow
			if returnOrder.Status != models.ReturnStatusRejected && returnOrder.Status != models.ReturnStatusApproved {
				// tx.Rollback()
				// return nil, fmt.Errorf("订单无法直接从未完成的中间状态 (%s) 更新为已完成", oldStatus)
			}
		}
		logAction = "订单处理完成"
	case models.ReturnStatusCancelled:
		// Add cancellation logic, e.g., only if not yet approved or processed too far.
		logAction = "订单已取消"
	default:
		tx.Rollback()
		return nil, utils.NewValidationError(fmt.Sprintf("不支持的状态更新: %s", input.Status))
	}

	if err := tx.Model(&returnOrder).Updates(updateData).Error; err != nil {
		tx.Rollback()
		return nil, fmt.Errorf("更新退换货订单状态失败: %w", err)
	}

	// Add log entry
	logEntry := models.ReturnOrderLog{
		ReturnOrderID: returnOrder.ID,
		OperatorID:    &input.UserID,
		OperatorName:  input.UserName,
		Action:        logAction,
		Details:       input.Remarks,
		LogTime:       time.Now(),
	}
	if err := tx.Create(&logEntry).Error; err != nil {
		tx.Rollback()
		return nil, fmt.Errorf("添加操作日志失败: %w", err)
	}

	if err := tx.Commit().Error; err != nil {
		return nil, fmt.Errorf("提交事务失败: %w", err)
	}

	// Re-fetch to get all updated fields and associations
	return s.GetReturnOrderByID(id)
}

// Helper function for status descriptions (can be moved to models or a helper package)
func getStatusDescription(status string) string {
	switch status {
	case models.ReturnStatusPendingApproval:
		return "待审批"
	case models.ReturnStatusApproved:
		return "已审批"
	case models.ReturnStatusPendingShipment:
		return "待发货"
	case models.ReturnStatusPendingGoodsReceipt:
		return "待收货"
	case models.ReturnStatusRejected:
		return "已拒绝"
	case models.ReturnStatusProcessing:
		return "处理中"
	case models.ReturnStatusGoodsReceived:
		return "已收到退货商品"
	case models.ReturnStatusExchangeShipped:
		return "已发出换货商品"
	case models.ReturnStatusRefunded:
		return "已退款"
	case models.ReturnStatusRefundProcessed:
		return "退款已处理"
	case models.ReturnStatusCompleted:
		return "已完成"
	case models.ReturnStatusCancelled:
		return "已取消"
	default:
		return status
	}
}

// isValidStatusTransition checks if a status transition is valid
// This is a simplified example; a more robust solution might use a state machine definition.
func isValidStatusTransition(currentStatus, nextStatus, orderType string) bool {
	// Allow cancelling from most early stages
	if nextStatus == models.ReturnStatusCancelled {
		switch currentStatus {
		case models.ReturnStatusPendingApproval, models.ReturnStatusApproved:
			return true
		default:
			// Potentially allow cancellation from other states if business logic permits
			// return false // Or more specific checks
		}
	}

	switch currentStatus {
	case models.ReturnStatusPendingApproval:
		return nextStatus == models.ReturnStatusApproved || nextStatus == models.ReturnStatusRejected
	case models.ReturnStatusApproved:
		return nextStatus == models.ReturnStatusProcessing ||
			(orderType == models.ReturnTypeReturn && (nextStatus == models.ReturnStatusPendingGoodsReceipt || nextStatus == models.ReturnStatusGoodsReceived)) ||
			(orderType == models.ReturnTypeExchange && (nextStatus == models.ReturnStatusPendingShipment || nextStatus == models.ReturnStatusExchangeShipped)) || // Added PENDING_SHIPMENT for exchange
			nextStatus == models.ReturnStatusCompleted // Direct completion if no intermediate steps
	case models.ReturnStatusPendingGoodsReceipt: // New case for PENDING_GOODS_RECEIPT
		return orderType == models.ReturnTypeReturn && (nextStatus == models.ReturnStatusGoodsReceived || nextStatus == models.ReturnStatusCancelled)
	case models.ReturnStatusPendingShipment: // New case for PENDING_SHIPMENT
		return orderType == models.ReturnTypeExchange && (nextStatus == models.ReturnStatusExchangeShipped || nextStatus == models.ReturnStatusCancelled)
	case models.ReturnStatusRejected:
		return nextStatus == models.ReturnStatusCompleted // A rejected order can be marked as 'completed' in terms of workflow
	case models.ReturnStatusProcessing:
		if orderType == models.ReturnTypeReturn {
			return nextStatus == models.ReturnStatusGoodsReceived || nextStatus == models.ReturnStatusRefunded || nextStatus == models.ReturnStatusRefundProcessed || nextStatus == models.ReturnStatusCompleted
		} else { // EXCHANGE
			return nextStatus == models.ReturnStatusExchangeShipped || nextStatus == models.ReturnStatusCompleted
		}
	case models.ReturnStatusGoodsReceived: // RETURN only
		return nextStatus == models.ReturnStatusRefunded || nextStatus == models.ReturnStatusRefundProcessed || nextStatus == models.ReturnStatusCompleted
	case models.ReturnStatusExchangeShipped: // EXCHANGE only
		return nextStatus == models.ReturnStatusCompleted
	case models.ReturnStatusRefunded: // RETURN only
		return nextStatus == models.ReturnStatusCompleted
	case models.ReturnStatusRefundProcessed: // RETURN only
		return nextStatus == models.ReturnStatusCompleted
	case models.ReturnStatusCompleted, models.ReturnStatusCancelled:
		return false // Cannot transition from a terminal state (except for re-opening, which is not handled here)
	}
	return false // Default deny
}

// Deprecated: 此函数暂未使用，保留以备将来使用
// getUserIDFromString 将字符串形式的用户ID转换为uint类型
func getUserIDFromString(userIDStr string) (uint, error) {
	if userIDStr == "" {
		return 0, utils.NewValidationError("用户ID不能为空")
	}
	uid, err := strconv.ParseUint(userIDStr, 10, 32)
	if err != nil {
		return 0, fmt.Errorf("无效的用户ID格式: %s", userIDStr)
	}
	return uint(uid), nil
}

// MarkExchangeShippedInput defines the input for marking an exchange order as shipped
type MarkExchangeShippedInput struct {
	ShippingCarrier string    `json:"shippingCarrier" binding:"required"`
	TrackingNumber  string    `json:"trackingNumber" binding:"required"`
	ShippedDate     time.Time `json:"shippedDate" binding:"required"`
	Remarks         string    `json:"remarks,omitempty"`
	UserID          uint      `json:"-"` // Operator ID from context
	UserName        string    `json:"-"` // Operator Name from context
}

// ProcessRefundInput defines the input for processing a refund
type ProcessRefundInput struct {
	RefundMethod        string    `json:"refundMethod" binding:"required"`
	RefundTransactionID string    `json:"refundTransactionId,omitempty"`
	ActualRefundAmount  float64   `json:"actualRefundAmount" binding:"required,gt=0"`
	RefundDate          time.Time `json:"refundDate" binding:"required"`
	Remarks             string    `json:"remarks,omitempty"`
	UserID              uint      `json:"-"` // Operator ID from context
	UserName            string    `json:"-"` // Operator Name from context
}

// MarkGoodsReceived updates the return order status to GOODS_RECEIVED
func (s *ReturnService) MarkGoodsReceived(returnOrderID uint, userID uint, userName string) (*models.ReturnOrder, error) {
	var returnOrder models.ReturnOrder
	tx := s.DB.Begin()
	defer tx.Rollback() // Rollback if not committed

	if err := tx.Preload(clause.Associations).First(&returnOrder, returnOrderID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, utils.NewNotFoundError("退换货订单未找到")
		}
		return nil, fmt.Errorf("获取退换货订单失败: %w", err)
	}

	if returnOrder.Type != models.ReturnTypeReturn {
		return nil, utils.NewValidationError("只有退货类型的订单才能标记为已收货")
	}
	if returnOrder.Status != models.ReturnStatusApproved && returnOrder.Status != models.ReturnStatusPendingGoodsReceipt && returnOrder.Status != models.ReturnStatusProcessing {
		return nil, utils.NewValidationError(fmt.Sprintf("当前状态 (%s) 无法标记为已收货", returnOrder.Status))
	}

	returnOrder.Status = models.ReturnStatusGoodsReceived
	logEntry := models.ReturnOrderLog{
		ReturnOrderID: returnOrderID,
		OperatorID:    &userID,
		OperatorName:  userName,
		Action:        "标记退货已收到",
		LogTime:       time.Now(),
	}

	if err := tx.Save(&returnOrder).Error; err != nil {
		return nil, fmt.Errorf("更新退换货订单状态失败: %w", err)
	}
	if err := tx.Create(&logEntry).Error; err != nil {
		return nil, fmt.Errorf("创建退换货日志失败: %w", err)
	}

	if err := tx.Commit().Error; err != nil {
		return nil, fmt.Errorf("提交事务失败: %w", err)
	}
	return &returnOrder, nil
}

// MarkExchangeShipped updates the exchange order status to EXCHANGE_SHIPPED
func (s *ReturnService) MarkExchangeShipped(returnOrderID uint, input MarkExchangeShippedInput) (*models.ReturnOrder, error) {
	var returnOrder models.ReturnOrder
	tx := s.DB.Begin()
	defer tx.Rollback()

	if err := tx.Preload(clause.Associations).First(&returnOrder, returnOrderID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, utils.NewNotFoundError("退换货订单未找到")
		}
		return nil, fmt.Errorf("获取退换货订单失败: %w", err)
	}

	if returnOrder.Type != models.ReturnTypeExchange {
		return nil, utils.NewValidationError("此操作仅适用于换货订单")
	}
	if returnOrder.Status != models.ReturnStatusApproved && returnOrder.Status != models.ReturnStatusGoodsReceived && returnOrder.Status != models.ReturnStatusPendingShipment {
		return nil, utils.NewValidationError(fmt.Sprintf("当前状态 (%s) 无法标记为换货已发货", returnOrder.Status))
	}

	returnOrder.Status = models.ReturnStatusExchangeShipped
	returnOrder.ExchangeShippingCarrier = input.ShippingCarrier
	returnOrder.ExchangeTrackingNumber = input.TrackingNumber
	returnOrder.ExchangeShippedDate = &input.ShippedDate
	// Potentially update remarks if needed, or add to log

	logEntry := models.ReturnOrderLog{
		ReturnOrderID: returnOrderID,
		OperatorID:    &input.UserID,
		OperatorName:  input.UserName,
		Action:        "标记换货已发货",
		Details:       fmt.Sprintf("物流公司: %s, 运单号: %s", input.ShippingCarrier, input.TrackingNumber),
		LogTime:       time.Now(),
	}

	if err := tx.Save(&returnOrder).Error; err != nil {
		return nil, fmt.Errorf("更新退换货订单状态失败: %w", err)
	}
	if err := tx.Create(&logEntry).Error; err != nil {
		return nil, fmt.Errorf("创建退换货日志失败: %w", err)
	}

	if err := tx.Commit().Error; err != nil {
		return nil, fmt.Errorf("提交事务失败: %w", err)
	}
	return &returnOrder, nil
}

// ProcessRefund updates the return order status to REFUND_PROCESSED
func (s *ReturnService) ProcessRefund(returnOrderID uint, input ProcessRefundInput) (*models.ReturnOrder, error) {
	var returnOrder models.ReturnOrder
	tx := s.DB.Begin()
	defer tx.Rollback()

	if err := tx.Preload(clause.Associations).First(&returnOrder, returnOrderID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, utils.NewNotFoundError("退换货订单未找到")
		}
		return nil, fmt.Errorf("获取退换货订单失败: %w", err)
	}

	if returnOrder.Type != models.ReturnTypeReturn {
		return nil, utils.NewValidationError("此操作仅适用于退货订单")
	}
	if returnOrder.Status != models.ReturnStatusGoodsReceived && returnOrder.Status != models.ReturnStatusApproved { // Assuming refund can be processed after approval or goods received
		return nil, utils.NewValidationError(fmt.Sprintf("当前状态 (%s) 无法处理退款", returnOrder.Status))
	}

	returnOrder.Status = models.ReturnStatusRefundProcessed
	returnOrder.RefundMethod = &input.RefundMethod
	returnOrder.RefundTransactionID = &input.RefundTransactionID
	returnOrder.ActualRefundAmount = &input.ActualRefundAmount
	returnOrder.RefundDate = &input.RefundDate

	logEntry := models.ReturnOrderLog{
		ReturnOrderID: returnOrderID,
		OperatorID:    &input.UserID,
		OperatorName:  input.UserName,
		Action:        "处理退款",
		Details:       fmt.Sprintf("退款方式: %s, 金额: %.2f", input.RefundMethod, input.ActualRefundAmount),
		LogTime:       time.Now(),
	}

	if err := tx.Save(&returnOrder).Error; err != nil {
		return nil, fmt.Errorf("更新退换货订单状态失败: %w", err)
	}
	if err := tx.Create(&logEntry).Error; err != nil {
		return nil, fmt.Errorf("创建退换货日志失败: %w", err)
	}

	if err := tx.Commit().Error; err != nil {
		return nil, fmt.Errorf("提交事务失败: %w", err)
	}
	return &returnOrder, nil
}

// CompleteReturnOrder updates the return order status to COMPLETED
func (s *ReturnService) CompleteReturnOrder(returnOrderID uint, userID uint, userName string) (*models.ReturnOrder, error) {
	var returnOrder models.ReturnOrder
	tx := s.DB.Begin()
	defer tx.Rollback()

	if err := tx.Preload(clause.Associations).First(&returnOrder, returnOrderID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, utils.NewNotFoundError("退换货订单未找到")
		}
		return nil, fmt.Errorf("获取退换货订单失败: %w", err)
	}

	// Define valid previous statuses for completion
	validPreviousStatuses := map[string]bool{
		models.ReturnStatusRefundProcessed: true, // For RETURN type
		models.ReturnStatusExchangeShipped: true, // For EXCHANGE type
		models.ReturnStatusGoodsReceived:   true, // If RETURN type and no refund, or EXCHANGE type if no separate shipping step
		models.ReturnStatusApproved:        true, // If simple case, directly complete
	}
	if !validPreviousStatuses[returnOrder.Status] {
		return nil, utils.NewValidationError(fmt.Sprintf("当前状态 (%s) 无法完成订单", returnOrder.Status))
	}

	// Specific checks based on type
	if returnOrder.Type == models.ReturnTypeReturn && returnOrder.Status != models.ReturnStatusRefundProcessed && returnOrder.Status != models.ReturnStatusApproved && returnOrder.Status != models.ReturnStatusGoodsReceived {
		// If it's a return, it should ideally be RefundProcessed or GoodsReceived (if no refund) or Approved (if simple case)
		return nil, utils.NewValidationError(fmt.Sprintf("退货订单在状态 (%s) 时无法直接完成，需先处理退款或确认收货", returnOrder.Status))
	}
	if returnOrder.Type == models.ReturnTypeExchange && returnOrder.Status != models.ReturnStatusExchangeShipped && returnOrder.Status != models.ReturnStatusApproved && returnOrder.Status != models.ReturnStatusGoodsReceived {
		// If it's an exchange, it should ideally be ExchangeShipped or GoodsReceived (if goods receipt is part of exchange flow) or Approved
		return nil, utils.NewValidationError(fmt.Sprintf("换货订单在状态 (%s) 时无法直接完成，需先标记已发货或确认收货", returnOrder.Status))
	}

	returnOrder.Status = models.ReturnStatusCompleted
	returnOrder.CompletedDate = &time.Time{}
	*returnOrder.CompletedDate = time.Now()

	logEntry := models.ReturnOrderLog{
		ReturnOrderID: returnOrderID,
		OperatorID:    &userID,
		OperatorName:  userName,
		Action:        "完成退换货订单",
		LogTime:       time.Now(),
	}

	if err := tx.Save(&returnOrder).Error; err != nil {
		return nil, fmt.Errorf("更新退换货订单状态失败: %w", err)
	}
	if err := tx.Create(&logEntry).Error; err != nil {
		return nil, fmt.Errorf("创建退换货日志失败: %w", err)
	}

	if err := tx.Commit().Error; err != nil {
		return nil, fmt.Errorf("提交事务失败: %w", err)
	}
	return &returnOrder, nil
}

// TODO: Add more service methods for specific status updates if needed,
// e.g., MarkAsGoodsReceived, MarkAsShipped, ProcessRefund, CompleteOrder

// Example: ApproveReturnOrder
func (s *ReturnService) ApproveReturnOrder(id uint, userID uint, userName string) (*models.ReturnOrder, error) {
	return s.UpdateReturnOrderStatus(id, UpdateReturnOrderStatusInput{
		Status:   models.ReturnStatusApproved,
		UserID:   userID,
		UserName: userName,
	})
}

// Example: RejectReturnOrder
func (s *ReturnService) RejectReturnOrder(id uint, reason string, userID uint, userName string) (*models.ReturnOrder, error) {
	return s.UpdateReturnOrderStatus(id, UpdateReturnOrderStatusInput{
		Status:          models.ReturnStatusRejected,
		RejectionReason: reason,
		UserID:          userID,
		UserName:        userName,
	})
}

// Add more specific action methods as needed, e.g., for processing, shipping, refunding, completing.
// This makes the controller logic cleaner.

// UpdateReturnOrderItems allows updating items for a return order, e.g., received quantity
// This is a more complex operation and needs careful handling, especially with status transitions.
// For now, this is a placeholder for potential future enhancements.
/*
func (s *ReturnService) UpdateReturnOrderItems(returnOrderID uint, itemsInput []UpdateReturnOrderItemInput, userID uint, userName string) error {
    // 1. Fetch the return order
    // 2. Validate status (e.g., only if in 'PROCESSING' or 'GOODS_RECEIVED' for certain updates)
    // 3. For each item, find the existing item and update (e.g., ReceivedQuantity)
    // 4. Add a log entry
    // 5. Potentially update the main order status if all items are processed.
    return errors.New("not implemented")
}
*/

// DeleteReturnOrder (soft delete)
func (s *ReturnService) DeleteReturnOrder(id uint, userID uint, userName string) error {
	var returnOrder models.ReturnOrder
	if err := s.DB.First(&returnOrder, id).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return utils.NewNotFoundError("未找到要删除的退换货订单")
		}
		return fmt.Errorf("查询退换货订单失败: %w", err)
	}

	// Add log before deleting
	logEntry := models.ReturnOrderLog{
		ReturnOrderID: id,
		OperatorID:    &userID,
		OperatorName:  userName,
		Action:        "删除退换货申请",
		LogTime:       time.Now(),
	}
	if err := s.DB.Create(&logEntry).Error; err != nil {
		// Log the error but proceed with deletion if critical
		fmt.Printf("添加删除日志失败: %v\n", err)
	}

	if err := s.DB.Delete(&returnOrder).Error; err != nil {
		return fmt.Errorf("删除退换货订单失败: %w", err)
	}
	return nil
}
