package controllers

import (
	"fmt"
	"hd_psi/backend/models"
	"net/http"
	"strconv"
	"time"

	"github.com/kataras/iris/v12"
	"gorm.io/gorm"
)

type SalesOrderController struct {
	db *gorm.DB
}

func NewSalesOrderController(db *gorm.DB) *SalesOrderController {
	return &SalesOrderController{db: db}
}

// 销售订单列表请求参数
type ListSalesOrdersQuery struct {
	Status       string `form:"status"`
	OrderType    string `form:"order_type"`
	StoreID      uint   `form:"store_id"`
	MemberID     uint   `form:"member_id"`
	StartDate    string `form:"start_date"`
	EndDate      string `form:"end_date"`
	CustomerName string `form:"customer_name"`
	OrderNumber  string `form:"order_number"`
	Page         int    `form:"page,default=1"`
	PageSize     int    `form:"page_size,default=10"`
}

// 销售订单列表响应
type SalesOrdersResponse struct {
	Total int                 `json:"total"`
	Items []models.SalesOrder `json:"items"`
}

// ListSalesOrders 获取销售订单列表
func (soc *SalesOrderController) ListSalesOrders(c iris.Context) {
	var query ListSalesOrdersQuery
	if err := c.ReadQuery(&query); err != nil {
		c.StatusCode(http.StatusBadRequest)
		c.JSON(iris.Map{"error": err.Error()})
		return
	}

	// 构建查询
	db := soc.db.Model(&models.SalesOrder{})

	// 应用过滤条件
	if query.Status != "" {
		db = db.Where("status = ?", query.Status)
	}
	if query.OrderType != "" {
		db = db.Where("order_type = ?", query.OrderType)
	}
	if query.StoreID != 0 {
		db = db.Where("store_id = ?", query.StoreID)
	}
	if query.MemberID != 0 {
		db = db.Where("member_id = ?", query.MemberID)
	}
	if query.CustomerName != "" {
		db = db.Where("customer_name LIKE ?", "%"+query.CustomerName+"%")
	}
	if query.OrderNumber != "" {
		db = db.Where("order_number LIKE ?", "%"+query.OrderNumber+"%")
	}
	if query.StartDate != "" {
		db = db.Where("order_date >= ?", query.StartDate)
	}
	if query.EndDate != "" {
		db = db.Where("order_date <= ?", query.EndDate+" 23:59:59")
	}

	// 获取总数
	var total int64
	db.Count(&total)

	// 分页查询
	offset := (query.Page - 1) * query.PageSize
	var salesOrders []models.SalesOrder
	if err := db.Preload("Store").Preload("Member").Preload("Salesperson").
		Preload("Items.Product").Preload("Items.ProductVariant").
		Offset(offset).Limit(query.PageSize).
		Order("created_at DESC").
		Find(&salesOrders).Error; err != nil {
		c.StatusCode(http.StatusInternalServerError)
		c.JSON(iris.Map{"error": "查询销售订单失败: " + err.Error()})
		return
	}

	c.StatusCode(http.StatusOK)
	c.JSON(SalesOrdersResponse{
		Total: int(total),
		Items: salesOrders,
	})
}

// GetSalesOrder 获取销售订单详情
func (soc *SalesOrderController) GetSalesOrder(c iris.Context) {
	id := c.Params().Get("id")
	var salesOrder models.SalesOrder

	if err := soc.db.Preload("Store").Preload("Member").Preload("Salesperson").
		Preload("Cashier").Preload("Creator").
		Preload("Items.Product").Preload("Items.ProductVariant").
		Preload("Payments").Preload("Logs.Operator").
		First(&salesOrder, id).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.StatusCode(http.StatusNotFound)
			c.JSON(iris.Map{"error": "销售订单不存在"})
		} else {
			c.StatusCode(http.StatusInternalServerError)
			c.JSON(iris.Map{"error": "查询销售订单失败: " + err.Error()})
		}
		return
	}

	c.StatusCode(http.StatusOK)
	c.JSON(salesOrder)
}

// 创建销售订单请求
type CreateSalesOrderRequest struct {
	StoreID         uint                    `json:"store_id"`
	MemberID        *uint                   `json:"member_id"`
	CustomerName    string                  `json:"customer_name"`
	CustomerPhone   string                  `json:"customer_phone"`
	CustomerAddress string                  `json:"customer_address"`
	OrderType       models.SalesOrderType   `json:"order_type"`
	PaymentMethod   models.PaymentMethod    `json:"payment_method"`
	FittingRoomID   *uint                   `json:"fitting_room_id"`
	Note            string                  `json:"note"`
	Items           []SalesOrderItemRequest `json:"items"`
}

// 销售订单明细请求
type SalesOrderItemRequest struct {
	ProductID        uint    `json:"product_id"`
	ProductVariantID *uint   `json:"product_variant_id"`
	Quantity         int     `json:"quantity"`
	UnitPrice        float64 `json:"unit_price"`
	DiscountAmount   float64 `json:"discount_amount"`
	QRCode           string  `json:"qr_code"`
	BatchNumber      string  `json:"batch_number"`
	IsTried          bool    `json:"is_tried"`
	TriedSize        string  `json:"tried_size"`
	FitRating        *int    `json:"fit_rating"`
	Note             string  `json:"note"`
}

// CreateSalesOrder 创建销售订单
func (soc *SalesOrderController) CreateSalesOrder(c iris.Context) {
	var request CreateSalesOrderRequest
	if err := c.ReadJSON(&request); err != nil {
		c.StatusCode(http.StatusBadRequest)
		c.JSON(iris.Map{"error": err.Error()})
		return
	}

	// 获取当前用户ID
	userID := c.Values().Get("userID")
	if userID == nil {
		c.StatusCode(http.StatusUnauthorized)
		c.JSON(iris.Map{"error": "未授权"})
		return
	}

	// 生成订单号
	orderNumber := fmt.Sprintf("SO%s%04d", time.Now().Format("20060102"), 1)

	// 查询当天最后一个订单号
	var lastOrder models.SalesOrder
	soc.db.Where("order_number LIKE ?", "SO"+time.Now().Format("20060102")+"%").
		Order("order_number DESC").
		Limit(1).
		Find(&lastOrder)

	if lastOrder.ID != 0 {
		// 提取序号并加1
		seq, _ := strconv.Atoi(lastOrder.OrderNumber[10:])
		orderNumber = fmt.Sprintf("SO%s%04d", time.Now().Format("20060102"), seq+1)
	}

	// 开始事务
	tx := soc.db.Begin()

	// 计算订单金额并创建订单明细
	var subtotalAmount, totalDiscountAmount float64
	var items []models.SalesOrderItem

	for _, item := range request.Items {
		// 获取商品信息
		var product models.Product
		if err := tx.First(&product, item.ProductID).Error; err != nil {
			tx.Rollback()
			c.StatusCode(http.StatusBadRequest)
			c.JSON(iris.Map{"error": fmt.Sprintf("商品ID %d 不存在", item.ProductID)})
			return
		}

		totalPrice := item.UnitPrice*float64(item.Quantity) - item.DiscountAmount
		subtotalAmount += item.UnitPrice * float64(item.Quantity)
		totalDiscountAmount += item.DiscountAmount

		items = append(items, models.SalesOrderItem{
			ProductID:        item.ProductID,
			ProductVariantID: item.ProductVariantID,
			ProductName:      product.Name,
			ProductSKU:       product.SKU,
			Quantity:         item.Quantity,
			UnitPrice:        item.UnitPrice,
			OriginalPrice:    product.RetailPrice,
			DiscountAmount:   item.DiscountAmount,
			TotalPrice:       totalPrice,
			QRCode:           item.QRCode,
			BatchNumber:      item.BatchNumber,
			IsTried:          item.IsTried,
			TriedSize:        item.TriedSize,
			FitRating:        item.FitRating,
			Note:             item.Note,
		})
	}

	totalAmount := subtotalAmount - totalDiscountAmount

	// 创建销售订单
	salesOrder := models.SalesOrder{
		OrderNumber:     orderNumber,
		StoreID:         request.StoreID,
		MemberID:        request.MemberID,
		CustomerName:    request.CustomerName,
		CustomerPhone:   request.CustomerPhone,
		CustomerAddress: request.CustomerAddress,
		OrderType:       request.OrderType,
		Status:          models.SalesDraft,
		SubtotalAmount:  subtotalAmount,
		DiscountAmount:  totalDiscountAmount,
		TotalAmount:     totalAmount,
		PaymentMethod:   request.PaymentMethod,
		PaymentStatus:   "unpaid",
		SalespersonID:   userID.(uint),
		CreatorID:       userID.(uint),
		OrderDate:       time.Now(),
		FittingRoomID:   request.FittingRoomID,
		Note:            request.Note,
	}

	if err := tx.Create(&salesOrder).Error; err != nil {
		tx.Rollback()
		c.StatusCode(http.StatusInternalServerError)
		c.JSON(iris.Map{"error": "创建销售订单失败: " + err.Error()})
		return
	}

	// 创建订单明细
	for i := range items {
		items[i].SalesOrderID = salesOrder.ID
	}

	if err := tx.Create(&items).Error; err != nil {
		tx.Rollback()
		c.StatusCode(http.StatusInternalServerError)
		c.JSON(iris.Map{"error": "创建订单明细失败: " + err.Error()})
		return
	}

	// 创建操作日志
	log := models.SalesOrderLog{
		SalesOrderID: salesOrder.ID,
		OperatorID:   userID.(uint),
		Action:       "create",
		Description:  "创建销售订单",
		NewValue:     fmt.Sprintf("订单号: %s, 总金额: %.2f", orderNumber, totalAmount),
	}
	tx.Create(&log)

	// 提交事务
	if err := tx.Commit().Error; err != nil {
		c.StatusCode(http.StatusInternalServerError)
		c.JSON(iris.Map{"error": "提交事务失败: " + err.Error()})
		return
	}

	// 返回创建的销售订单
	var result models.SalesOrder
	soc.db.Preload("Store").Preload("Member").Preload("Salesperson").
		Preload("Items.Product").Preload("Items.ProductVariant").
		First(&result, salesOrder.ID)

	c.StatusCode(http.StatusCreated)
	c.JSON(result)
}

// UpdateSalesOrder 更新销售订单
func (soc *SalesOrderController) UpdateSalesOrder(c iris.Context) {
	id := c.Params().Get("id")
	var request CreateSalesOrderRequest
	if err := c.ReadJSON(&request); err != nil {
		c.StatusCode(http.StatusBadRequest)
		c.JSON(iris.Map{"error": err.Error()})
		return
	}

	// 获取当前用户ID
	userID := c.Values().Get("userID")
	if userID == nil {
		c.StatusCode(http.StatusUnauthorized)
		c.JSON(iris.Map{"error": "未授权"})
		return
	}

	// 查找销售订单
	var salesOrder models.SalesOrder
	if err := soc.db.Preload("Items").First(&salesOrder, id).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.StatusCode(http.StatusNotFound)
			c.JSON(iris.Map{"error": "销售订单不存在"})
		} else {
			c.StatusCode(http.StatusInternalServerError)
			c.JSON(iris.Map{"error": "查询销售订单失败: " + err.Error()})
		}
		return
	}

	// 检查订单状态是否允许修改
	if salesOrder.Status != models.SalesDraft && salesOrder.Status != models.SalesPending {
		c.StatusCode(http.StatusBadRequest)
		c.JSON(iris.Map{"error": "订单状态不允许修改"})
		return
	}

	// 开始事务
	tx := soc.db.Begin()

	// 删除原有明细
	if err := tx.Where("sales_order_id = ?", salesOrder.ID).Delete(&models.SalesOrderItem{}).Error; err != nil {
		tx.Rollback()
		c.StatusCode(http.StatusInternalServerError)
		c.JSON(iris.Map{"error": "删除原有明细失败: " + err.Error()})
		return
	}

	// 重新计算订单金额并创建新明细
	var subtotalAmount, totalDiscountAmount float64
	var items []models.SalesOrderItem

	for _, item := range request.Items {
		// 获取商品信息
		var product models.Product
		if err := tx.First(&product, item.ProductID).Error; err != nil {
			tx.Rollback()
			c.StatusCode(http.StatusBadRequest)
			c.JSON(iris.Map{"error": fmt.Sprintf("商品ID %d 不存在", item.ProductID)})
			return
		}

		totalPrice := item.UnitPrice*float64(item.Quantity) - item.DiscountAmount
		subtotalAmount += item.UnitPrice * float64(item.Quantity)
		totalDiscountAmount += item.DiscountAmount

		items = append(items, models.SalesOrderItem{
			SalesOrderID:     salesOrder.ID,
			ProductID:        item.ProductID,
			ProductVariantID: item.ProductVariantID,
			ProductName:      product.Name,
			ProductSKU:       product.SKU,
			Quantity:         item.Quantity,
			UnitPrice:        item.UnitPrice,
			OriginalPrice:    product.RetailPrice,
			DiscountAmount:   item.DiscountAmount,
			TotalPrice:       totalPrice,
			QRCode:           item.QRCode,
			BatchNumber:      item.BatchNumber,
			IsTried:          item.IsTried,
			TriedSize:        item.TriedSize,
			FitRating:        item.FitRating,
			Note:             item.Note,
		})
	}

	totalAmount := subtotalAmount - totalDiscountAmount

	// 更新销售订单
	salesOrder.StoreID = request.StoreID
	salesOrder.MemberID = request.MemberID
	salesOrder.CustomerName = request.CustomerName
	salesOrder.CustomerPhone = request.CustomerPhone
	salesOrder.CustomerAddress = request.CustomerAddress
	salesOrder.OrderType = request.OrderType
	salesOrder.SubtotalAmount = subtotalAmount
	salesOrder.DiscountAmount = totalDiscountAmount
	salesOrder.TotalAmount = totalAmount
	salesOrder.PaymentMethod = request.PaymentMethod
	salesOrder.FittingRoomID = request.FittingRoomID
	salesOrder.Note = request.Note

	if err := tx.Save(&salesOrder).Error; err != nil {
		tx.Rollback()
		c.StatusCode(http.StatusInternalServerError)
		c.JSON(iris.Map{"error": "更新销售订单失败: " + err.Error()})
		return
	}

	// 创建新明细
	if err := tx.Create(&items).Error; err != nil {
		tx.Rollback()
		c.StatusCode(http.StatusInternalServerError)
		c.JSON(iris.Map{"error": "创建新明细失败: " + err.Error()})
		return
	}

	// 创建操作日志
	log := models.SalesOrderLog{
		SalesOrderID: salesOrder.ID,
		OperatorID:   userID.(uint),
		Action:       "update",
		Description:  "更新销售订单",
		NewValue:     fmt.Sprintf("总金额: %.2f", totalAmount),
	}
	tx.Create(&log)

	// 提交事务
	if err := tx.Commit().Error; err != nil {
		c.StatusCode(http.StatusInternalServerError)
		c.JSON(iris.Map{"error": "提交事务失败: " + err.Error()})
		return
	}

	// 返回更新后的销售订单
	var result models.SalesOrder
	soc.db.Preload("Store").Preload("Member").Preload("Salesperson").
		Preload("Items.Product").Preload("Items.ProductVariant").
		First(&result, salesOrder.ID)

	c.StatusCode(http.StatusOK)
	c.JSON(result)
}

// UpdateSalesOrderStatus 更新销售订单状态
func (soc *SalesOrderController) UpdateSalesOrderStatus(c iris.Context) {
	id := c.Params().Get("id")

	var request struct {
		Status models.SalesOrderStatus `json:"status"`
		Note   string                  `json:"note"`
	}

	if err := c.ReadJSON(&request); err != nil {
		c.StatusCode(http.StatusBadRequest)
		c.JSON(iris.Map{"error": err.Error()})
		return
	}

	// 获取当前用户ID
	userID := c.Values().Get("userID")
	if userID == nil {
		c.StatusCode(http.StatusUnauthorized)
		c.JSON(iris.Map{"error": "未授权"})
		return
	}

	// 查找销售订单
	var salesOrder models.SalesOrder
	if err := soc.db.First(&salesOrder, id).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.StatusCode(http.StatusNotFound)
			c.JSON(iris.Map{"error": "销售订单不存在"})
		} else {
			c.StatusCode(http.StatusInternalServerError)
			c.JSON(iris.Map{"error": "查询销售订单失败: " + err.Error()})
		}
		return
	}

	oldStatus := salesOrder.Status

	// 开始事务
	tx := soc.db.Begin()

	// 更新订单状态
	salesOrder.Status = request.Status

	// 根据状态更新相关字段
	switch request.Status {
	case models.SalesPaid:
		salesOrder.PaymentStatus = "paid"
		now := time.Now()
		salesOrder.PaymentTime = &now
		salesOrder.PaidAmount = salesOrder.TotalAmount
	case models.SalesCompleted:
		if salesOrder.CompletedAt == nil {
			now := time.Now()
			salesOrder.CompletedAt = &now
		}
	case models.SalesDelivered:
		if salesOrder.DeliveryDate == nil {
			now := time.Now()
			salesOrder.DeliveryDate = &now
		}
	}

	if err := tx.Save(&salesOrder).Error; err != nil {
		tx.Rollback()
		c.StatusCode(http.StatusInternalServerError)
		c.JSON(iris.Map{"error": "更新订单状态失败: " + err.Error()})
		return
	}

	// 创建操作日志
	log := models.SalesOrderLog{
		SalesOrderID: salesOrder.ID,
		OperatorID:   userID.(uint),
		Action:       "status_change",
		Description:  "更新订单状态",
		OldValue:     string(oldStatus),
		NewValue:     string(request.Status),
	}
	if request.Note != "" {
		log.Description += ": " + request.Note
	}
	tx.Create(&log)

	// 提交事务
	if err := tx.Commit().Error; err != nil {
		c.StatusCode(http.StatusInternalServerError)
		c.JSON(iris.Map{"error": "提交事务失败: " + err.Error()})
		return
	}

	c.StatusCode(http.StatusOK)
	c.JSON(iris.Map{"message": "订单状态更新成功"})
}

// DeleteSalesOrder 删除销售订单
func (soc *SalesOrderController) DeleteSalesOrder(c iris.Context) {
	id := c.Params().Get("id")

	// 获取当前用户ID
	userID := c.Values().Get("userID")
	if userID == nil {
		c.StatusCode(http.StatusUnauthorized)
		c.JSON(iris.Map{"error": "未授权"})
		return
	}

	// 查找销售订单
	var salesOrder models.SalesOrder
	if err := soc.db.First(&salesOrder, id).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.StatusCode(http.StatusNotFound)
			c.JSON(iris.Map{"error": "销售订单不存在"})
		} else {
			c.StatusCode(http.StatusInternalServerError)
			c.JSON(iris.Map{"error": "查询销售订单失败: " + err.Error()})
		}
		return
	}

	// 检查订单状态是否允许删除
	if salesOrder.Status != models.SalesDraft && salesOrder.Status != models.SalesCancelled {
		c.StatusCode(http.StatusBadRequest)
		c.JSON(iris.Map{"error": "只能删除草稿或已取消的订单"})
		return
	}

	// 开始事务
	tx := soc.db.Begin()

	// 删除相关记录
	tx.Where("sales_order_id = ?", salesOrder.ID).Delete(&models.SalesOrderItem{})
	tx.Where("sales_order_id = ?", salesOrder.ID).Delete(&models.SalesOrderPayment{})
	tx.Where("sales_order_id = ?", salesOrder.ID).Delete(&models.SalesOrderLog{})
	tx.Where("sales_order_id = ?", salesOrder.ID).Delete(&models.NegotiationLog{})

	// 删除订单
	if err := tx.Delete(&salesOrder).Error; err != nil {
		tx.Rollback()
		c.StatusCode(http.StatusInternalServerError)
		c.JSON(iris.Map{"error": "删除销售订单失败: " + err.Error()})
		return
	}

	// 提交事务
	if err := tx.Commit().Error; err != nil {
		c.StatusCode(http.StatusInternalServerError)
		c.JSON(iris.Map{"error": "提交事务失败: " + err.Error()})
		return
	}

	c.StatusCode(http.StatusOK)
	c.JSON(iris.Map{"message": "销售订单删除成功"})
}

// AddPayment 添加支付记录
func (soc *SalesOrderController) AddPayment(c iris.Context) {
	id := c.Params().Get("id")

	var request struct {
		PaymentMethod models.PaymentMethod `json:"payment_method"`
		Amount        float64              `json:"amount"`
		TransactionID string               `json:"transaction_id"`
		Note          string               `json:"note"`
	}

	if err := c.ReadJSON(&request); err != nil {
		c.StatusCode(http.StatusBadRequest)
		c.JSON(iris.Map{"error": err.Error()})
		return
	}

	// 获取当前用户ID
	userID := c.Values().Get("userID")
	if userID == nil {
		c.StatusCode(http.StatusUnauthorized)
		c.JSON(iris.Map{"error": "未授权"})
		return
	}

	// 查找销售订单
	var salesOrder models.SalesOrder
	if err := soc.db.First(&salesOrder, id).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.StatusCode(http.StatusNotFound)
			c.JSON(iris.Map{"error": "销售订单不存在"})
		} else {
			c.StatusCode(http.StatusInternalServerError)
			c.JSON(iris.Map{"error": "查询销售订单失败: " + err.Error()})
		}
		return
	}

	// 检查支付金额
	if salesOrder.PaidAmount+request.Amount > salesOrder.TotalAmount {
		c.StatusCode(http.StatusBadRequest)
		c.JSON(iris.Map{"error": "支付金额超过订单总额"})
		return
	}

	// 开始事务
	tx := soc.db.Begin()

	// 创建支付记录
	payment := models.SalesOrderPayment{
		SalesOrderID: salesOrder.ID,
		PaymentMethod: request.PaymentMethod,
		Amount:        request.Amount,
		TransactionID: request.TransactionID,
		PaymentTime:   time.Now(),
		Status:        "success",
		Note:          request.Note,
	}

	if err := tx.Create(&payment).Error; err != nil {
		tx.Rollback()
		c.StatusCode(http.StatusInternalServerError)
		c.JSON(iris.Map{"error": "创建支付记录失败: " + err.Error()})
		return
	}

	// 更新订单支付状态
	salesOrder.PaidAmount += request.Amount
	if salesOrder.PaidAmount >= salesOrder.TotalAmount {
		salesOrder.PaymentStatus = "paid"
		now := time.Now()
		salesOrder.PaymentTime = &now
	} else {
		salesOrder.PaymentStatus = "partial"
	}

	if err := tx.Save(&salesOrder).Error; err != nil {
		tx.Rollback()
		c.StatusCode(http.StatusInternalServerError)
		c.JSON(iris.Map{"error": "更新订单支付状态失败: " + err.Error()})
		return
	}

	// 创建操作日志
	log := models.SalesOrderLog{
		SalesOrderID: salesOrder.ID,
		OperatorID:   userID.(uint),
		Action:       "payment",
		Description:  fmt.Sprintf("添加支付记录，支付方式: %s，金额: %.2f", request.PaymentMethod, request.Amount),
		NewValue:     fmt.Sprintf("已付金额: %.2f", salesOrder.PaidAmount),
	}
	tx.Create(&log)

	// 提交事务
	if err := tx.Commit().Error; err != nil {
		c.StatusCode(http.StatusInternalServerError)
		c.JSON(iris.Map{"error": "提交事务失败: " + err.Error()})
		return
	}

	c.StatusCode(http.StatusCreated)
	c.JSON(payment)
}

// GetSalesOrderStatistics 获取销售订单统计
func (soc *SalesOrderController) GetSalesOrderStatistics(c iris.Context) {
	var stats struct {
		TotalOrders     int64   `json:"total_orders"`
		TotalAmount     float64 `json:"total_amount"`
		PaidOrders      int64   `json:"paid_orders"`
		PendingOrders   int64   `json:"pending_orders"`
		CompletedOrders int64   `json:"completed_orders"`
		CancelledOrders int64   `json:"cancelled_orders"`
		TodayOrders     int64   `json:"today_orders"`
		TodayAmount     float64 `json:"today_amount"`
	}

	// 总订单数和总金额
	soc.db.Model(&models.SalesOrder{}).Count(&stats.TotalOrders)
	soc.db.Model(&models.SalesOrder{}).Select("COALESCE(SUM(total_amount), 0)").Scan(&stats.TotalAmount)

	// 各状态订单数
	soc.db.Model(&models.SalesOrder{}).Where("status = ?", models.SalesPaid).Count(&stats.PaidOrders)
	soc.db.Model(&models.SalesOrder{}).Where("status = ?", models.SalesPending).Count(&stats.PendingOrders)
	soc.db.Model(&models.SalesOrder{}).Where("status = ?", models.SalesCompleted).Count(&stats.CompletedOrders)
	soc.db.Model(&models.SalesOrder{}).Where("status = ?", models.SalesCancelled).Count(&stats.CancelledOrders)

	// 今日订单数和金额
	today := time.Now().Format("2006-01-02")
	soc.db.Model(&models.SalesOrder{}).Where("DATE(order_date) = ?", today).Count(&stats.TodayOrders)
	soc.db.Model(&models.SalesOrder{}).Where("DATE(order_date) = ?", today).
		Select("COALESCE(SUM(total_amount), 0)").Scan(&stats.TodayAmount)

	c.StatusCode(http.StatusOK)
	c.JSON(stats)
}

// GetRecentSalesOrders 获取最近的销售订单
func (soc *SalesOrderController) GetRecentSalesOrders(c iris.Context) {
	var salesOrders []models.SalesOrder

	// 获取最近10个销售订单
	if err := soc.db.Preload("Store").Preload("Member").Preload("Salesperson").
		Order("created_at DESC").
		Limit(10).
		Find(&salesOrders).Error; err != nil {
		c.StatusCode(http.StatusInternalServerError)
		c.JSON(iris.Map{"error": "查询最近销售订单失败: " + err.Error()})
		return
	}

	c.StatusCode(http.StatusOK)
	c.JSON(iris.Map{
		"items": salesOrders,
		"total": len(salesOrders),
	})
}