package controllers

import (
	"fmt"
	"hd_psi/backend/models"
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type PurchaseReceivingController struct {
	db *gorm.DB
}

func NewPurchaseReceivingController(db *gorm.DB) *PurchaseReceivingController {
	return &PurchaseReceivingController{db: db}
}

// 采购入库列表请求参数
type ListPurchaseReceivingsQuery struct {
	PurchaseOrderID uint   `form:"purchase_order_id"`
	StoreID         uint   `form:"store_id"`
	StartDate       string `form:"start_date"`
	EndDate         string `form:"end_date"`
	Page            int    `form:"page,default=1"`
	PageSize        int    `form:"page_size,default=10"`
}

// 采购入库列表响应
type PurchaseReceivingsResponse struct {
	Total int                        `json:"total"`
	Items []models.PurchaseReceiving `json:"items"`
}

// ListPurchaseReceivings 获取采购入库列表
func (prc *PurchaseReceivingController) ListPurchaseReceivings(c *gin.Context) {
	var query ListPurchaseReceivingsQuery
	if err := c.ShouldBindQuery(&query); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 构建查询
	db := prc.db.Model(&models.PurchaseReceiving{})

	// 应用过滤条件
	if query.PurchaseOrderID != 0 {
		db = db.Where("purchase_order_id = ?", query.PurchaseOrderID)
	}
	if query.StoreID != 0 {
		db = db.Where("store_id = ?", query.StoreID)
	}
	if query.StartDate != "" {
		db = db.Where("receiving_date >= ?", query.StartDate)
	}
	if query.EndDate != "" {
		db = db.Where("receiving_date <= ?", query.EndDate+" 23:59:59")
	}

	// 计算总数
	var total int64
	db.Count(&total)

	// 分页
	offset := (query.Page - 1) * query.PageSize
	var receivings []models.PurchaseReceiving

	if err := db.Preload("PurchaseOrder").Preload("Store").
		Offset(offset).Limit(query.PageSize).
		Order("created_at DESC").
		Find(&receivings).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, PurchaseReceivingsResponse{
		Total: int(total),
		Items: receivings,
	})
}

// GetPurchaseReceiving 获取采购入库详情
func (prc *PurchaseReceivingController) GetPurchaseReceiving(c *gin.Context) {
	id := c.Param("id")
	var receiving models.PurchaseReceiving

	if err := prc.db.Preload("Items.Product").Preload("PurchaseOrder").Preload("Store").
		First(&receiving, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "采购入库单不存在"})
		return
	}

	c.JSON(http.StatusOK, receiving)
}

// 采购入库明细请求
type PurchaseReceivingItemRequest struct {
	PurchaseOrderItemID uint   `json:"purchase_order_item_id" binding:"required"`
	ProductID           uint   `json:"product_id" binding:"required"`
	ProductVariantID    uint   `json:"product_variant_id" binding:"required"`
	ExpectedQuantity    int    `json:"expected_quantity" binding:"required"`
	ActualQuantity      int    `json:"actual_quantity" binding:"required,min=0"`
	BatchNumber         string `json:"batch_number"`
	QualityStatus       string `json:"quality_status"`
	Note                string `json:"note"`
}

// 创建采购入库请求
type CreatePurchaseReceivingRequest struct {
	PurchaseOrderID uint                           `json:"purchase_order_id" binding:"required"`
	StoreID         uint                           `json:"store_id" binding:"required"`
	ReceivingDate   string                         `json:"receiving_date" binding:"required"`
	Note            string                         `json:"note"`
	Items           []PurchaseReceivingItemRequest `json:"items" binding:"required,min=1"`
}

// CreatePurchaseReceiving 创建采购入库
func (prc *PurchaseReceivingController) CreatePurchaseReceiving(c *gin.Context) {
	var request CreatePurchaseReceivingRequest
	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 获取当前用户ID
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	// 检查采购单是否存在且状态是否为已下单或待入库
	var purchaseOrder models.PurchaseOrder
	if err := prc.db.First(&purchaseOrder, request.PurchaseOrderID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "采购单不存在"})
		return
	}

	if purchaseOrder.Status != models.PurchaseOrdered && purchaseOrder.Status != models.PurchaseInReceiving {
		c.JSON(http.StatusBadRequest, gin.H{"error": "只有已下单或待入库状态的采购单可以创建入库单"})
		return
	}

	// 生成入库单号
	receivingNumber := fmt.Sprintf("GR%s%04d", time.Now().Format("20060102"), 1)

	// 查询当天最后一个入库单号
	var lastReceiving models.PurchaseReceiving
	prc.db.Where("receiving_number LIKE ?", "GR"+time.Now().Format("20060102")+"%").
		Order("receiving_number DESC").
		Limit(1).
		Find(&lastReceiving)

	if lastReceiving.ID != 0 {
		// 提取序号并加1
		seq, _ := strconv.Atoi(lastReceiving.ReceivingNumber[10:])
		receivingNumber = fmt.Sprintf("GR%s%04d", time.Now().Format("20060102"), seq+1)
	}

	// 解析入库日期
	receivingDate, err := time.Parse("2006-01-02", request.ReceivingDate)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "入库日期格式错误，应为YYYY-MM-DD"})
		return
	}

	// 开始事务
	tx := prc.db.Begin()

	// 创建入库单
	receiving := models.PurchaseReceiving{
		PurchaseOrderID: request.PurchaseOrderID,
		ReceivingNumber: receivingNumber,
		StoreID:         request.StoreID,
		OperatorID:      userID.(uint),
		ReceivingDate:   receivingDate,
		Note:            request.Note,
	}

	if err := tx.Create(&receiving).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "创建入库单失败: " + err.Error()})
		return
	}

	// 创建入库明细并更新采购单明细的已入库数量
	var items []models.PurchaseReceivingItem
	var totalReceivedQty int

	for _, item := range request.Items {
		// 创建入库明细
		items = append(items, models.PurchaseReceivingItem{
			PurchaseReceivingID: receiving.ID,
			PurchaseOrderItemID: item.PurchaseOrderItemID,
			ProductID:           item.ProductID,
			ProductVariantID:    item.ProductVariantID,
			ExpectedQuantity:    item.ExpectedQuantity,
			ActualQuantity:      item.ActualQuantity,
			BatchNumber:         item.BatchNumber,
			QualityStatus:       item.QualityStatus,
			Note:                item.Note,
		})

		// 更新采购单明细的已入库数量
		var orderItem models.PurchaseOrderItem
		if err := tx.First(&orderItem, item.PurchaseOrderItemID).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusNotFound, gin.H{"error": "采购单明细不存在"})
			return
		}

		orderItem.ReceivedQty += item.ActualQuantity
		if err := tx.Save(&orderItem).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"error": "更新采购单明细失败: " + err.Error()})
			return
		}

		totalReceivedQty += item.ActualQuantity

		// 更新库存
		if item.ActualQuantity > 0 && item.QualityStatus != "defective" {
			// 查找库存记录
			var inventory models.Inventory
			result := tx.Where("product_variant_id = ? AND store_id = ?", item.ProductVariantID, request.StoreID).First(&inventory)

			if result.Error != nil {
				// 库存记录不存在，创建新记录
				inventory = models.Inventory{
					ProductVariantID: item.ProductVariantID,
					StoreID:          request.StoreID,
					Quantity:         item.ActualQuantity,
				}
				if err := tx.Create(&inventory).Error; err != nil {
					tx.Rollback()
					c.JSON(http.StatusInternalServerError, gin.H{"error": "创建库存记录失败: " + err.Error()})
					return
				}
			} else {
				// 更新现有库存
				inventory.Quantity += item.ActualQuantity
				if err := tx.Save(&inventory).Error; err != nil {
					tx.Rollback()
					c.JSON(http.StatusInternalServerError, gin.H{"error": "更新库存失败: " + err.Error()})
					return
				}
			}

			// 创建库存交易记录
			transaction := models.InventoryTransaction{
				ProductVariantID: item.ProductVariantID,
				StoreID:          request.StoreID,
				TransactionType:  models.PurchaseIn,
				Quantity:         item.ActualQuantity,
				OperatorID:       userID.(uint),
				ReferenceType:    "purchase_receiving",
				Note:             fmt.Sprintf("采购入库: %s", receivingNumber),
			}

			// 设置关联ID
			refID := receiving.ID
			transaction.ReferenceID = &refID

			if err := tx.Create(&transaction).Error; err != nil {
				tx.Rollback()
				c.JSON(http.StatusInternalServerError, gin.H{"error": "创建库存交易记录失败: " + err.Error()})
				return
			}
		}
	}

	// 创建入库明细
	if err := tx.Create(&items).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "创建入库明细失败: " + err.Error()})
		return
	}

	// 更新采购单状态
	if totalReceivedQty > 0 {
		// 检查是否所有采购单明细都已完全入库
		var orderItems []models.PurchaseOrderItem
		if err := tx.Where("purchase_order_id = ?", request.PurchaseOrderID).Find(&orderItems).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"error": "查询采购单明细失败: " + err.Error()})
			return
		}

		allReceived := true
		for _, item := range orderItems {
			if item.ReceivedQty < item.Quantity {
				allReceived = false
				break
			}
		}

		// 更新采购单状态
		if allReceived {
			purchaseOrder.Status = models.PurchaseCompleted
			now := time.Now()
			purchaseOrder.ActualDate = &now
		} else {
			purchaseOrder.Status = models.PurchaseInReceiving
		}

		if err := tx.Save(&purchaseOrder).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"error": "更新采购单状态失败: " + err.Error()})
			return
		}
	}

	// 提交事务
	if err := tx.Commit().Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "提交事务失败: " + err.Error()})
		return
	}

	// 返回创建的入库单
	var result models.PurchaseReceiving
	prc.db.Preload("Items.Product").Preload("PurchaseOrder").Preload("Store").
		First(&result, receiving.ID)

	c.JSON(http.StatusCreated, result)
}

// DeletePurchaseReceiving 删除采购入库
func (prc *PurchaseReceivingController) DeletePurchaseReceiving(c *gin.Context) {
	id := c.Param("id")

	// 获取当前用户ID
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	var receiving models.PurchaseReceiving

	// 查询入库单
	if err := prc.db.Preload("Items").First(&receiving, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "采购入库单不存在"})
		return
	}

	// 开始事务
	tx := prc.db.Begin()

	// 恢复采购单明细的已入库数量
	for _, item := range receiving.Items {
		var orderItem models.PurchaseOrderItem
		if err := tx.First(&orderItem, item.PurchaseOrderItemID).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"error": "查询采购单明细失败: " + err.Error()})
			return
		}

		orderItem.ReceivedQty -= item.ActualQuantity
		if orderItem.ReceivedQty < 0 {
			orderItem.ReceivedQty = 0
		}

		if err := tx.Save(&orderItem).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"error": "更新采购单明细失败: " + err.Error()})
			return
		}

		// 恢复库存
		if item.ActualQuantity > 0 && item.QualityStatus != "defective" {
			// 查找库存记录
			var inventory models.Inventory
			if err := tx.Where("product_variant_id = ? AND store_id = ?", item.ProductVariantID, receiving.StoreID).First(&inventory).Error; err != nil {
				tx.Rollback()
				c.JSON(http.StatusInternalServerError, gin.H{"error": "查询库存记录失败: " + err.Error()})
				return
			}

			// 更新库存
			inventory.Quantity -= item.ActualQuantity
			if inventory.Quantity < 0 {
				inventory.Quantity = 0
			}

			if err := tx.Save(&inventory).Error; err != nil {
				tx.Rollback()
				c.JSON(http.StatusInternalServerError, gin.H{"error": "更新库存失败: " + err.Error()})
				return
			}

			// 创建库存交易记录
			transaction := models.InventoryTransaction{
				ProductVariantID: item.ProductVariantID,
				StoreID:          receiving.StoreID,
				TransactionType:  models.PurchaseIn, // 使用采购入库类型，但数量为负
				Quantity:         -item.ActualQuantity,
				OperatorID:       userID.(uint),
				ReferenceType:    "purchase_receiving_cancel",
				Note:             fmt.Sprintf("取消采购入库: %s", receiving.ReceivingNumber),
			}

			// 设置关联ID
			refID := receiving.ID
			transaction.ReferenceID = &refID

			if err := tx.Create(&transaction).Error; err != nil {
				tx.Rollback()
				c.JSON(http.StatusInternalServerError, gin.H{"error": "创建库存交易记录失败: " + err.Error()})
				return
			}
		}
	}

	// 更新采购单状态
	var purchaseOrder models.PurchaseOrder
	if err := tx.First(&purchaseOrder, receiving.PurchaseOrderID).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "查询采购单失败: " + err.Error()})
		return
	}

	// 检查是否有其他入库单
	var count int64
	tx.Model(&models.PurchaseReceiving{}).
		Where("purchase_order_id = ? AND id != ?", receiving.PurchaseOrderID, id).
		Count(&count)

	if count > 0 {
		purchaseOrder.Status = models.PurchaseInReceiving
	} else {
		purchaseOrder.Status = models.PurchaseOrdered
	}

	if err := tx.Save(&purchaseOrder).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "更新采购单状态失败: " + err.Error()})
		return
	}

	// 删除入库明细
	if err := tx.Where("purchase_receiving_id = ?", id).Delete(&models.PurchaseReceivingItem{}).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "删除入库明细失败: " + err.Error()})
		return
	}

	// 删除入库单
	if err := tx.Delete(&receiving).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "删除入库单失败: " + err.Error()})
		return
	}

	// 提交事务
	if err := tx.Commit().Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "提交事务失败: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "采购入库单删除成功"})
}
