package controllers

import (
	"fmt"
	"hd_psi/backend/models"
	"hd_psi/backend/utils/response"
	"net/http"
	"strconv"
	"time"

	"github.com/kataras/iris/v12"
	"gorm.io/gorm"
)

type PurchaseController struct {
	db *gorm.DB
}

func NewPurchaseController(db *gorm.DB) *PurchaseController {
	return &PurchaseController{db: db}
}

// 采购单列表请求参数
type ListPurchaseOrdersQuery struct {
	Status     string `form:"status"`
	SupplierID uint   `form:"supplier_id"`
	StoreID    uint   `form:"store_id"`
	StartDate  string `form:"start_date"`
	EndDate    string `form:"end_date"`
	Page       int    `form:"page,default=1"`
	PageSize   int    `form:"page_size,default=10"`
}

// 采购单列表响应
type PurchaseOrdersResponse struct {
	Total int                    `json:"total"`
	Items []models.PurchaseOrder `json:"items"`
}

// ListPurchaseOrders 获取采购单列表
func (pc *PurchaseController) ListPurchaseOrders(c iris.Context) {
	var query ListPurchaseOrdersQuery
	if err := c.ReadForm(&query); err != nil {
		response.BadRequest(c, err.Error())
		return
	}

	// 构建查询
	db := pc.db.Model(&models.PurchaseOrder{})

	// 应用过滤条件
	if query.Status != "" {
		db = db.Where("status = ?", query.Status)
	}
	if query.SupplierID != 0 {
		db = db.Where("supplier_id = ?", query.SupplierID)
	}
	if query.StoreID != 0 {
		db = db.Where("store_id = ?", query.StoreID)
	}
	if query.StartDate != "" {
		db = db.Where("created_at >= ?", query.StartDate)
	}
	if query.EndDate != "" {
		db = db.Where("created_at <= ?", query.EndDate+" 23:59:59")
	}

	// 计算总数
	var total int64
	db.Count(&total)

	// 分页
	offset := (query.Page - 1) * query.PageSize
	var purchaseOrders []models.PurchaseOrder

	if err := db.Preload("Supplier").Preload("Store").
		Offset(offset).Limit(query.PageSize).
		Order("created_at DESC").
		Find(&purchaseOrders).Error; err != nil {
	response.InternalError(c, err.Error())
	return
}

c.StatusCode(http.StatusOK)
c.JSON(PurchaseOrdersResponse{
	Total: int(total),
	Items: purchaseOrders,
})
}

// GetPurchaseOrder 获取采购单详情
func (pc *PurchaseController) GetPurchaseOrder(c iris.Context) {
	id := c.Params().Get("id")
	var purchaseOrder models.PurchaseOrder

	if err := pc.db.Preload("Items.Product").Preload("Supplier").Preload("Store").
		First(&purchaseOrder, id).Error; err != nil {
		response.NotFound(c, "采购单不存在")
		return
	}

	c.StatusCode(http.StatusOK)
	c.JSON(purchaseOrder)
}

// 创建采购单请求
type CreatePurchaseOrderRequest struct {
	SupplierID   uint                       `json:"supplier_id" binding:"required"`
	StoreID      uint                       `json:"store_id" binding:"required"`
	ExpectedDate string                     `json:"expected_date"`
	Note         string                     `json:"note"`
	Items        []PurchaseOrderItemRequest `json:"items" binding:"required,min=1"`
}

// 采购单明细请求
type PurchaseOrderItemRequest struct {
	ProductID uint    `json:"product_id" binding:"required"`
	Quantity  int     `json:"quantity" binding:"required,min=1"`
	UnitPrice float64 `json:"unit_price" binding:"required,min=0"`
	Note      string  `json:"note"`
}

// CreatePurchaseOrder 创建采购单
func (pc *PurchaseController) CreatePurchaseOrder(c iris.Context) {
	var request CreatePurchaseOrderRequest
	if err := c.ReadJSON(&request); err != nil {
		response.BadRequest(c, err.Error())
		return
	}

	// 获取当前用户ID
	userID := c.Values().Get("userID")
	if userID == nil {
		response.Unauthorized(c, "未授权")
		return
	}

	// 生成采购单号
	orderNumber := fmt.Sprintf("PO%s%04d", time.Now().Format("20060102"), 1)

	// 查询当天最后一个采购单号
	var lastOrder models.PurchaseOrder
	pc.db.Where("order_number LIKE ?", "PO"+time.Now().Format("20060102")+"%").
		Order("order_number DESC").
		Limit(1).
		Find(&lastOrder)

	if lastOrder.ID != 0 {
		// 提取序号并加1
		seq, _ := strconv.Atoi(lastOrder.OrderNumber[10:])
		orderNumber = fmt.Sprintf("PO%s%04d", time.Now().Format("20060102"), seq+1)
	}

	// 开始事务
	tx := pc.db.Begin()

	// 计算总金额并创建采购单明细
	var totalAmount float64
	var items []models.PurchaseOrderItem

	for _, item := range request.Items {
		totalPrice := item.UnitPrice * float64(item.Quantity)
		totalAmount += totalPrice

		items = append(items, models.PurchaseOrderItem{
			ProductID:  item.ProductID,
			Quantity:   item.Quantity,
			UnitPrice:  item.UnitPrice,
			TotalPrice: totalPrice,
			Note:       item.Note,
		})
	}

	// 解析预计到货日期
	var expectedDate *time.Time
	if request.ExpectedDate != "" {
		date, err := time.Parse("2006-01-02", request.ExpectedDate)
		if err != nil {
			tx.Rollback()
			response.BadRequest(c, "预计到货日期格式错误，应为YYYY-MM-DD")
			return
		}
		expectedDate = &date
	}

	// 创建采购单
	purchaseOrder := models.PurchaseOrder{
		OrderNumber:  orderNumber,
		SupplierID:   request.SupplierID,
		StoreID:      request.StoreID,
		Status:       models.PurchaseDraft,
		TotalAmount:  totalAmount,
		ExpectedDate: expectedDate,
		CreatorID:    userID.(uint),
		Note:         request.Note,
	}

	if err := tx.Create(&purchaseOrder).Error; err != nil {
		tx.Rollback()
		response.InternalError(c, "创建采购单失败: "+err.Error())
		return
	}

	// 创建采购单明细
	for i := range items {
		items[i].PurchaseOrderID = purchaseOrder.ID
	}

	if err := tx.Create(&items).Error; err != nil {
		tx.Rollback()
		response.InternalError(c, "创建采购单明细失败: "+err.Error())
		return
	}

	// 提交事务
	if err := tx.Commit().Error; err != nil {
		response.InternalError(c, "提交事务失败: "+err.Error())
		return
	}

	// 返回创建的采购单
	var result models.PurchaseOrder
	pc.db.Preload("Items.Product").Preload("Supplier").Preload("Store").
		First(&result, purchaseOrder.ID)

	response.Created(c, result)
}

// 更新采购单请求
type UpdatePurchaseOrderRequest struct {
	SupplierID   uint                       `json:"supplier_id"`
	StoreID      uint                       `json:"store_id"`
	ExpectedDate string                     `json:"expected_date"`
	Note         string                     `json:"note"`
	Items        []PurchaseOrderItemRequest `json:"items"`
}

// UpdatePurchaseOrder 更新采购单
func (pc *PurchaseController) UpdatePurchaseOrder(c iris.Context) {
	id := c.Params().Get("id")
	var purchaseOrder models.PurchaseOrder

	// 查询采购单
	if err := pc.db.Preload("Items").First(&purchaseOrder, id).Error; err != nil {
		response.NotFound(c, "采购单不存在")
		return
	}

	// 只有草稿状态的采购单可以修改
	if purchaseOrder.Status != models.PurchaseDraft {
		response.BadRequest(c, "只有草稿状态的采购单可以修改")
		return
	}

	var request UpdatePurchaseOrderRequest
	if err := c.ReadJSON(&request); err != nil {
		response.BadRequest(c, err.Error())
		return
	}

	// 开始事务
	tx := pc.db.Begin()

	// 更新采购单基本信息
	if request.SupplierID != 0 {
		purchaseOrder.SupplierID = request.SupplierID
	}
	if request.StoreID != 0 {
		purchaseOrder.StoreID = request.StoreID
	}
	if request.ExpectedDate != "" {
		date, err := time.Parse("2006-01-02", request.ExpectedDate)
		if err != nil {
			tx.Rollback()
			response.BadRequest(c, "预计到货日期格式错误，应为YYYY-MM-DD")
			return
		}
		purchaseOrder.ExpectedDate = &date
	}
	if request.Note != "" {
		purchaseOrder.Note = request.Note
	}

	// 如果提供了新的明细，则更新明细
	if len(request.Items) > 0 {
		// 删除原有明细
		if err := tx.Where("purchase_order_id = ?", purchaseOrder.ID).Delete(&models.PurchaseOrderItem{}).Error; err != nil {
			tx.Rollback()
			response.InternalError(c, "删除原有明细失败: "+err.Error())
			return
		}

		// 计算新的总金额并创建新明细
		var totalAmount float64
		var items []models.PurchaseOrderItem

		for _, item := range request.Items {
			totalPrice := item.UnitPrice * float64(item.Quantity)
			totalAmount += totalPrice

			items = append(items, models.PurchaseOrderItem{
				PurchaseOrderID: purchaseOrder.ID,
				ProductID:       item.ProductID,
				Quantity:        item.Quantity,
				UnitPrice:       item.UnitPrice,
				TotalPrice:      totalPrice,
				Note:            item.Note,
			})
		}

		purchaseOrder.TotalAmount = totalAmount

		// 创建新明细
		if err := tx.Create(&items).Error; err != nil {
			tx.Rollback()
			response.InternalError(c, "创建新明细失败: "+err.Error())
			return
		}
	}

	// 保存采购单
	if err := tx.Save(&purchaseOrder).Error; err != nil {
		tx.Rollback()
		response.InternalError(c, "更新采购单失败: "+err.Error())
		return
	}

	// 提交事务
	if err := tx.Commit().Error; err != nil {
		response.InternalError(c, "提交事务失败: "+err.Error())
		return
	}

	// 返回更新后的采购单
	var result models.PurchaseOrder
	pc.db.Preload("Items.Product").Preload("Supplier").Preload("Store").
		First(&result, purchaseOrder.ID)

	response.Success(c, result)
}

// 采购单状态更新请求
type UpdatePurchaseOrderStatusRequest struct {
	Status string `json:"status" binding:"required"`
	Note   string `json:"note"`
}

// UpdatePurchaseOrderStatus 更新采购单状态
func (pc *PurchaseController) UpdatePurchaseOrderStatus(c iris.Context) {
	id := c.Params().Get("id")
	var purchaseOrder models.PurchaseOrder

	// 查询采购单
	if err := pc.db.First(&purchaseOrder, id).Error; err != nil {
		response.NotFound(c, "采购单不存在")
		return
	}

	var request UpdatePurchaseOrderStatusRequest
	if err := c.ReadJSON(&request); err != nil {
		response.BadRequest(c, err.Error())
		return
	}

	// 获取当前用户ID
	userID := c.Values().Get("userID")
	if userID == nil {
		response.Unauthorized(c, "未授权")
		return
	}

	// 验证状态转换的合法性
	if !isValidStatusTransition(purchaseOrder.Status, models.PurchaseOrderStatus(request.Status)) {
		response.BadRequest(c, "无效的状态转换")
		return
	}

	// 更新状态
	purchaseOrder.Status = models.PurchaseOrderStatus(request.Status)

	// 如果是审核状态，记录审核信息
	if request.Status == string(models.PurchaseApproved) || request.Status == string(models.PurchaseRejected) {
		now := time.Now()
		approverID := userID.(uint)
		purchaseOrder.ApproverID = &approverID
		purchaseOrder.ApprovalTime = &now
		purchaseOrder.ApprovalNote = request.Note
	}

	// 如果是完成状态，记录实际到货日期
	if request.Status == string(models.PurchaseCompleted) {
		now := time.Now()
		purchaseOrder.ActualDate = &now
	}

	// 保存采购单
	if err := pc.db.Save(&purchaseOrder).Error; err != nil {
		response.InternalError(c, "更新采购单状态失败: "+err.Error())
		return
	}

	response.Success(c, purchaseOrder)
}

// 验证采购单状态转换是否合法
func isValidStatusTransition(currentStatus, newStatus models.PurchaseOrderStatus) bool {
	// 定义状态转换规则
	validTransitions := map[models.PurchaseOrderStatus][]models.PurchaseOrderStatus{
		models.PurchaseDraft:       {models.PurchasePending, models.PurchaseCancelled},
		models.PurchasePending:     {models.PurchaseApproved, models.PurchaseRejected},
		models.PurchaseApproved:    {models.PurchaseOrdered, models.PurchaseCancelled},
		models.PurchaseRejected:    {models.PurchaseDraft, models.PurchaseCancelled},
		models.PurchaseOrdered:     {models.PurchaseInReceiving, models.PurchaseCancelled},
		models.PurchaseInReceiving: {models.PurchaseCompleted},
		models.PurchaseCompleted:   {},
		models.PurchaseCancelled:   {},
	}

	// 检查转换是否合法
	for _, validStatus := range validTransitions[currentStatus] {
		if validStatus == newStatus {
			return true
		}
	}

	return false
}

// DeletePurchaseOrder 删除采购单
func (pc *PurchaseController) DeletePurchaseOrder(c iris.Context) {
	id := c.Params().Get("id")
	var purchaseOrder models.PurchaseOrder

	// 查询采购单
	if err := pc.db.First(&purchaseOrder, id).Error; err != nil {
		response.NotFound(c, "采购单不存在")
		return
	}

	// 只有草稿状态的采购单可以删除
	if purchaseOrder.Status != models.PurchaseDraft {
		response.BadRequest(c, "只有草稿状态的采购单可以删除")
		return
	}

	// 开始事务
	tx := pc.db.Begin()

	// 删除采购单明细
	if err := tx.Where("purchase_order_id = ?", id).Delete(&models.PurchaseOrderItem{}).Error; err != nil {
		tx.Rollback()
		response.InternalError(c, "删除采购单明细失败: "+err.Error())
		return
	}

	// 删除采购单
	if err := tx.Delete(&purchaseOrder).Error; err != nil {
		tx.Rollback()
		response.InternalError(c, "删除采购单失败: "+err.Error())
		return
	}

	// 提交事务
	if err := tx.Commit().Error; err != nil {
		response.InternalError(c, "提交事务失败: "+err.Error())
		return
	}

	response.Success(c, map[string]string{"message": "采购单删除成功"})
}
