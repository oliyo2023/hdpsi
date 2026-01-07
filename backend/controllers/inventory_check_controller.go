package controllers

import (
	"fmt"
	"hd_psi/backend/models"
	"time"

	"github.com/kataras/iris/v12"
	"gorm.io/gorm"
)

type InventoryCheckController struct {
	db *gorm.DB
}

func NewInventoryCheckController(db *gorm.DB) *InventoryCheckController {
	return &InventoryCheckController{db: db}
}

// ListChecks 获取盘点单列表
func (icc *InventoryCheckController) ListChecks(c iris.Context) {
	var checks []models.InventoryCheck

	// 获取查询参数
	storeID := c.URLParam("store_id")
	status := c.URLParam("status")
	checkType := c.URLParam("check_type")

	// 构建查询
	query := icc.db.Model(&models.InventoryCheck{})

	if storeID != "" {
		query = query.Where("store_id = ?", storeID)
	}

	if status != "" {
		query = query.Where("status = ?", status)
	}

	if checkType != "" {
		query = query.Where("check_type = ?", checkType)
	}

	// 执行查询
	if err := query.Order("created_at DESC").Find(&checks).Error; err != nil {
		c.JSON(map[string]interface{}{"error": err.Error()})
		return
	}

	c.JSON(checks)
}

// GetCheck 获取盘点单详情
func (icc *InventoryCheckController) GetCheck(c iris.Context) {
	id := c.Params().Get("id")
	var check models.InventoryCheck
	if err := icc.db.First(&check, id).Error; err != nil {
		c.JSON(map[string]interface{}{"error": "Inventory check not found"})
		return
	}

	// 获取盘点明细
	var items []models.InventoryCheckItem
	if err := icc.db.Where("check_id = ?", check.ID).Find(&items).Error; err != nil {
		c.JSON(map[string]interface{}{"error": err.Error()})
		return
	}

	c.JSON(map[string]interface{}{
		"check": check,
		"items": items,
	})
}

// CreateCheck 创建盘点单
func (icc *InventoryCheckController) CreateCheck(c iris.Context) {
	var input struct {
		StoreID     uint      `json:"store_id" binding:"required"`
		CheckType   string    `json:"check_type" binding:"required"`
		PlanDate    time.Time `json:"plan_date" binding:"required"`
		OperatorID  uint      `json:"operator_id" binding:"required"`
		Description string    `json:"description"`
		ProductIDs  []uint    `json:"product_ids"` // 抽盘时指定的商品ID列表
	}

	if err := c.ReadJSON(&input); err != nil {
		c.JSON(map[string]interface{}{"error": err.Error()})
		return
	}

	// 开始事务
	tx := icc.db.Begin()

	// 生成盘点单号 (格式: IC + 年月日 + 4位序号)
	now := time.Now()
	var count int64
	tx.Model(&models.InventoryCheck{}).Where("DATE(created_at) = DATE(?)", now).Count(&count)
	checkCode := fmt.Sprintf("IC%s%04d", now.Format("20060102"), count+1)

	// 创建盘点单
	check := models.InventoryCheck{
		StoreID:     input.StoreID,
		CheckCode:   checkCode,
		CheckType:   models.CheckType(input.CheckType),
		Status:      models.Planned,
		PlanDate:    input.PlanDate,
		OperatorID:  input.OperatorID,
		Description: input.Description,
	}

	if err := tx.Create(&check).Error; err != nil {
		tx.Rollback()
		c.JSON(map[string]interface{}{"error": "Failed to create inventory check: " + err.Error()})
		return
	}

	// 创建盘点明细
	var items []models.InventoryCheckItem

	// 根据盘点类型获取商品
	if check.CheckType == models.FullCheck {
		// 全盘：获取该店铺所有库存商品
		var inventories []struct {
			ProductVariantID uint
			Quantity         int
		}

		if err := tx.Table("inventories").
			Select("product_variant_id, quantity").
			Where("store_id = ? AND quantity > 0", check.StoreID).
			Scan(&inventories).Error; err != nil {
			tx.Rollback()
			c.JSON(map[string]interface{}{"error": "Failed to get inventory data: " + err.Error()})
			return
		}

		for _, inv := range inventories {
			items = append(items, models.InventoryCheckItem{
				CheckID:          check.ID,
				ProductVariantID: inv.ProductVariantID,
				SystemQuantity:   inv.Quantity,
				Status:           "pending",
			})
		}
	} else if check.CheckType == models.SpotCheck && len(input.ProductIDs) > 0 {
		// 抽盘：获取指定商品的库存
		for _, productID := range input.ProductIDs {
			var inventory models.Inventory
			result := tx.Where("store_id = ? AND product_variant_id = ?", check.StoreID, productID).First(&inventory)

			if result.Error == nil {
				items = append(items, models.InventoryCheckItem{
					CheckID:          check.ID,
					ProductVariantID: productID,
					SystemQuantity:   inventory.Quantity,
					Status:           "pending",
				})
			} else if result.Error != gorm.ErrRecordNotFound {
				tx.Rollback()
				c.JSON(map[string]interface{}{"error": "Failed to get inventory data: " + result.Error.Error()})
				return
			}
		}
	}

	// 批量创建盘点明细
	if len(items) > 0 {
		if err := tx.Create(&items).Error; err != nil {
			tx.Rollback()
			c.JSON(map[string]interface{}{"error": "Failed to create inventory check items: " + err.Error()})
			return
		}
	}

	// 提交事务
	if err := tx.Commit().Error; err != nil {
		c.JSON(map[string]interface{}{"error": "Failed to commit transaction: " + err.Error()})
		return
	}

	c.JSON(map[string]interface{}{
		"check":       check,
		"items_count": len(items),
	})
}

// StartCheck 开始盘点
func (icc *InventoryCheckController) StartCheck(c iris.Context) {
	id := c.Params().Get("id")
	var check models.InventoryCheck
	if err := icc.db.First(&check, id).Error; err != nil {
		c.JSON(map[string]interface{}{"error": "Inventory check not found"})
		return
	}

	// 检查状态
	if check.Status != models.Planned {
		c.JSON(map[string]interface{}{"error": "Only planned inventory checks can be started"})
		return
	}

	// 更新状态
	now := time.Now()
	check.Status = models.InProcess
	check.StartTime = &now

	if err := icc.db.Save(&check).Error; err != nil {
		c.JSON(map[string]interface{}{"error": err.Error()})
		return
	}

	c.JSON(check)
}

// UpdateCheckItem 更新盘点明细
func (icc *InventoryCheckController) UpdateCheckItem(c iris.Context) {
	checkID := c.Params().Get("id")
	itemID := c.Params().Get("itemId")

	// 验证盘点单存在
	var check models.InventoryCheck
	if err := icc.db.First(&check, checkID).Error; err != nil {
		c.JSON(map[string]interface{}{"error": "Inventory check not found"})
		return
	}

	// 检查状态
	if check.Status != models.InProcess {
		c.JSON(map[string]interface{}{"error": "Only in-process inventory checks can be updated"})
		return
	}

	// 验证盘点明细存在
	var item models.InventoryCheckItem
	if err := icc.db.Where("id = ? AND check_id = ?", itemID, checkID).First(&item).Error; err != nil {
		c.JSON(map[string]interface{}{"error": "Inventory check item not found"})
		return
	}

	// 绑定请求数据
	var input struct {
		ActualQuantity int    `json:"actual_quantity" binding:"required"`
		Note           string `json:"note"`
	}

	if err := c.ReadJSON(&input); err != nil {
		c.JSON(map[string]interface{}{"error": err.Error()})
		return
	}

	// 更新盘点明细
	item.ActualQuantity = input.ActualQuantity
	item.DifferenceQty = input.ActualQuantity - item.SystemQuantity
	item.Note = input.Note
	item.Status = "checked"

	if err := icc.db.Save(&item).Error; err != nil {
		c.JSON(map[string]interface{}{"error": err.Error()})
		return
	}

	c.JSON(item)
}

// CompleteCheck 完成盘点
func (icc *InventoryCheckController) CompleteCheck(c iris.Context) {
	id := c.Params().Get("id")
	var check models.InventoryCheck
	if err := icc.db.First(&check, id).Error; err != nil {
		c.JSON(map[string]interface{}{"error": "Inventory check not found"})
		return
	}

	// 检查状态
	if check.Status != models.InProcess {
		c.JSON(map[string]interface{}{"error": "Only in-process inventory checks can be completed"})
		return
	}

	// 检查是否所有明细都已盘点
	var pendingCount int64
	if err := icc.db.Model(&models.InventoryCheckItem{}).
		Where("check_id = ? AND status = 'pending'", check.ID).
		Count(&pendingCount).Error; err != nil {
		c.JSON(map[string]interface{}{"error": err.Error()})
		return
	}

	if pendingCount > 0 {
		c.JSON(map[string]interface{}{"error": "Cannot complete inventory check with pending items"})
		return
	}

	// 开始事务
	tx := icc.db.Begin()

	// 更新盘点单状态
	now := time.Now()
	check.Status = models.Completed
	check.EndTime = &now

	if err := tx.Save(&check).Error; err != nil {
		tx.Rollback()
		c.JSON(map[string]interface{}{"error": err.Error()})
		return
	}

	// 提交事务
	if err := tx.Commit().Error; err != nil {
		c.JSON(map[string]interface{}{"error": "Failed to commit transaction: " + err.Error()})
		return
	}

	c.JSON(check)
}

// CancelCheck 取消盘点
func (icc *InventoryCheckController) CancelCheck(c iris.Context) {
	id := c.Params().Get("id")
	var check models.InventoryCheck
	if err := icc.db.First(&check, id).Error; err != nil {
		c.JSON(map[string]interface{}{"error": "Inventory check not found"})
		return
	}

	// 检查状态
	if check.Status == models.Completed {
		c.JSON(map[string]interface{}{"error": "Completed inventory checks cannot be cancelled"})
		return
	}

	// 更新状态
	check.Status = models.Cancelled

	if err := icc.db.Save(&check).Error; err != nil {
		c.JSON(map[string]interface{}{"error": err.Error()})
		return
	}

	c.JSON(check)
}

// CreateAdjustment 创建库存调整
func (icc *InventoryCheckController) CreateAdjustment(c iris.Context) {
	checkID := c.Params().Get("id")

	// 验证盘点单存在
	var check models.InventoryCheck
	if err := icc.db.First(&check, checkID).Error; err != nil {
		c.JSON(map[string]interface{}{"error": "Inventory check not found"})
		return
	}

	// 检查状态
	if check.Status != models.Completed {
		c.JSON(map[string]interface{}{"error": "Only completed inventory checks can have adjustments"})
		return
	}

	// 绑定请求数据
	var input struct {
		CheckItemID    uint   `json:"check_item_id" binding:"required"`
		AdjustQuantity int    `json:"adjust_quantity" binding:"required"`
		Reason         string `json:"reason" binding:"required"`
	}

	if err := c.ReadJSON(&input); err != nil {
		c.JSON(map[string]interface{}{"error": err.Error()})
		return
	}

	// 验证盘点明细存在
	var item models.InventoryCheckItem
	if err := icc.db.Where("id = ? AND check_id = ?", input.CheckItemID, checkID).First(&item).Error; err != nil {
		c.JSON(map[string]interface{}{"error": "Inventory check item not found"})
		return
	}

	// 创建调整记录
	adjustment := models.InventoryCheckAdjustment{
		CheckID:          check.ID,
		CheckItemID:      input.CheckItemID,
		ProductVariantID: item.ProductVariantID,
		AdjustQuantity:   input.AdjustQuantity,
		Reason:           input.Reason,
		ApprovalStatus:   "pending",
	}

	if err := icc.db.Create(&adjustment).Error; err != nil {
		c.JSON(map[string]interface{}{"error": err.Error()})
		return
	}

	c.JSON(adjustment)
}

// ApproveAdjustment 审批库存调整
func (icc *InventoryCheckController) ApproveAdjustment(c iris.Context) {
	adjustmentID := c.Params().Get("adjustmentId")

	// 验证调整记录存在
	var adjustment models.InventoryCheckAdjustment
	if err := icc.db.First(&adjustment, adjustmentID).Error; err != nil {
		c.JSON(map[string]interface{}{"error": "Adjustment not found"})
		return
	}

	// 检查状态
	if adjustment.ApprovalStatus != "pending" {
		c.JSON(map[string]interface{}{"error": "Only pending adjustments can be approved"})
		return
	}

	// 绑定请求数据
	var input struct {
		ApproverID     uint   `json:"approver_id" binding:"required"`
		ApprovalStatus string `json:"approval_status" binding:"required"`
		ApprovalNote   string `json:"approval_note"`
	}

	if err := c.ReadJSON(&input); err != nil {
		c.JSON(map[string]interface{}{"error": err.Error()})
		return
	}

	// 开始事务
	tx := icc.db.Begin()

	// 更新调整记录
	now := time.Now()
	adjustment.ApproverID = input.ApproverID
	adjustment.ApprovalStatus = input.ApprovalStatus
	adjustment.ApprovalNote = input.ApprovalNote
	adjustment.ApprovalTime = &now

	if err := tx.Save(&adjustment).Error; err != nil {
		tx.Rollback()
		c.JSON(map[string]interface{}{"error": err.Error()})
		return
	}

	// 如果审批通过，更新库存
	if input.ApprovalStatus == "approved" {
		// 获取盘点单信息
		var check models.InventoryCheck
		if err := tx.First(&check, adjustment.CheckID).Error; err != nil {
			tx.Rollback()
			c.JSON(map[string]interface{}{"error": "Failed to get inventory check: " + err.Error()})
			return
		}

		// 更新库存
		var inventory models.Inventory
		result := tx.Where("store_id = ? AND product_variant_id = ?", check.StoreID, adjustment.ProductVariantID).First(&inventory)

		if result.Error != nil {
			if result.Error == gorm.ErrRecordNotFound {
				// 如果库存记录不存在且是增加库存，则创建新记录
				if adjustment.AdjustQuantity > 0 {
					newInventory := models.Inventory{
						StoreID:          check.StoreID,
						ProductVariantID: adjustment.ProductVariantID,
						Quantity:         adjustment.AdjustQuantity,
					}
					if err := tx.Create(&newInventory).Error; err != nil {
						tx.Rollback()
						c.JSON(map[string]interface{}{"error": "Failed to create inventory: " + err.Error()})
						return
					}
				} else {
					tx.Rollback()
					c.JSON(map[string]interface{}{"error": "Cannot adjust non-existent inventory"})
					return
				}
			} else {
				tx.Rollback()
				c.JSON(map[string]interface{}{"error": "Failed to get inventory: " + result.Error.Error()})
				return
			}
		} else {
			// 更新现有库存
			inventory.Quantity += adjustment.AdjustQuantity
			if inventory.Quantity < 0 {
				tx.Rollback()
				c.JSON(map[string]interface{}{"error": "Adjustment would result in negative inventory"})
				return
			}

			if err := tx.Save(&inventory).Error; err != nil {
				tx.Rollback()
				c.JSON(map[string]interface{}{"error": "Failed to update inventory: " + err.Error()})
				return
			}
		}

		// 创建库存交易记录
		transaction := models.InventoryTransaction{
			TransactionType:  models.TransactionType("inventory_check"),
			ProductVariantID: adjustment.ProductVariantID,
			StoreID:          check.StoreID,
			Quantity:         adjustment.AdjustQuantity,
			ReferenceID:      &adjustment.ID,
			ReferenceType:    "inventory_check_adjustment",
			OperatorID:       input.ApproverID,
			Note:             "盘点调整: " + adjustment.Reason,
		}

		if err := tx.Create(&transaction).Error; err != nil {
			tx.Rollback()
			c.JSON(map[string]interface{}{"error": "Failed to create transaction: " + err.Error()})
			return
		}
	}

	// 提交事务
	if err := tx.Commit().Error; err != nil {
		c.JSON(map[string]interface{}{"error": "Failed to commit transaction: " + err.Error()})
		return
	}

	c.JSON(adjustment)
}
