package controllers

import (
	"hd_psi/backend/models"
	"hd_psi/backend/utils/errors"
	"hd_psi/backend/utils/logger"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// InventoryController 库存控制器
type InventoryController struct {
	db *gorm.DB
}

// NewInventoryController 创建库存控制器实例
func NewInventoryController(db *gorm.DB) *InventoryController {
	return &InventoryController{db: db}
}

// ListInventories 获取库存列表
func (ic *InventoryController) ListInventories(c *gin.Context) {
	// 创建请求日志
	log := logger.WithContext(c)
	log.Info("获取库存列表")

	// 获取查询参数
	productVariantID := c.Query("product_variant_id")
	storeID := c.Query("store_id")
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("pageSize", "10"))

	// 构建查询
	query := ic.db.Model(&models.Inventory{})

	// 添加过滤条件
	if productVariantID != "" {
		query = query.Where("product_variant_id = ?", productVariantID)
	}
	if storeID != "" {
		query = query.Where("store_id = ?", storeID)
	}

	// 计算总数
	var total int64
	if err := query.Count(&total).Error; err != nil {
		log.Error("获取库存总数失败", logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrDatabaseQuery).
			WithDetails("获取库存总数失败").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	// 分页查询
	offset := (page - 1) * pageSize
	var inventories []models.Inventory
	if err := query.Preload("ProductVariant").Preload("ProductVariant.Product").Preload("Store").Offset(offset).Limit(pageSize).Find(&inventories).Error; err != nil {
		log.Error("获取库存列表失败", logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrDatabaseQuery).
			WithDetails("获取库存列表失败").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	log.Info("获取库存列表成功",
		logger.F("total", total),
		logger.F("count", len(inventories)))

	c.JSON(http.StatusOK, gin.H{
		"items":    inventories,
		"total":    total,
		"page":     page,
		"pageSize": pageSize,
	})
}

// GetInventory 获取库存详情
func (ic *InventoryController) GetInventory(c *gin.Context) {
	// 创建请求日志
	log := logger.WithContext(c)

	id := c.Param("id")
	log.Info("获取库存详情", logger.F("inventory_id", id))

	var inventory models.Inventory
	if err := ic.db.Preload("ProductVariant").Preload("ProductVariant.Product").Preload("Store").First(&inventory, id).Error; err != nil {
		log.Warn("库存不存在", logger.F("inventory_id", id), logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrNotFound).
			WithDetails("库存不存在或已被删除").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	log.Info("获取库存详情成功",
		logger.F("inventory_id", inventory.ID),
		logger.F("product_variant_id", inventory.ProductVariantID),
		logger.F("store_id", inventory.StoreID),
		logger.F("quantity", inventory.Quantity))

	c.JSON(http.StatusOK, inventory)
}

// CreateInventory 创建库存
func (ic *InventoryController) CreateInventory(c *gin.Context) {
	// 创建请求日志
	log := logger.WithContext(c)
	log.Info("创建库存")

	var inventory models.Inventory
	if err := c.ShouldBindJSON(&inventory); err != nil {
		log.Warn("创建库存请求参数无效", logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrInvalidInput).
			WithDetails("请提供有效的库存信息").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	log = log.WithFields(
		logger.F("product_variant_id", inventory.ProductVariantID),
		logger.F("store_id", inventory.StoreID),
		logger.F("quantity", inventory.Quantity),
	)

	// 检查产品变体是否存在
	var productVariant models.ProductVariant
	if err := ic.db.First(&productVariant, inventory.ProductVariantID).Error; err != nil {
		log.Warn("产品变体不存在", logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrNotFound).
			WithDetails("指定的产品变体不存在").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	// 检查店铺是否存在
	var store models.Store
	if err := ic.db.First(&store, inventory.StoreID).Error; err != nil {
		log.Warn("店铺不存在", logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrNotFound).
			WithDetails("指定的店铺不存在").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	// 检查是否已存在相同产品变体和店铺的库存记录
	var existingInventory models.Inventory
	result := ic.db.Where("product_variant_id = ? AND store_id = ?", inventory.ProductVariantID, inventory.StoreID).First(&existingInventory)
	if result.Error == nil {
		log.Warn("库存记录已存在",
			logger.F("existing_inventory_id", existingInventory.ID),
			logger.F("quantity", existingInventory.Quantity))
		appErr := errors.New(errors.ErrConflict).
			WithDetails("该产品在指定店铺中已有库存记录，请使用更新操作").
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	// 创建库存记录
	if err := ic.db.Create(&inventory).Error; err != nil {
		log.Error("创建库存失败", logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrDatabaseInsert).
			WithDetails("创建库存失败").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	log.Info("创建库存成功", logger.F("inventory_id", inventory.ID))

	// 加载关联数据
	ic.db.Preload("ProductVariant").Preload("ProductVariant.Product").Preload("Store").First(&inventory, inventory.ID)

	c.JSON(http.StatusCreated, inventory)
}

// UpdateInventory 更新库存
func (ic *InventoryController) UpdateInventory(c *gin.Context) {
	// 创建请求日志
	log := logger.WithContext(c)

	id := c.Param("id")
	log.Info("更新库存", logger.F("inventory_id", id))

	// 查找现有库存
	var existingInventory models.Inventory
	if err := ic.db.First(&existingInventory, id).Error; err != nil {
		log.Warn("库存不存在", logger.F("inventory_id", id), logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrNotFound).
			WithDetails("库存不存在或已被删除").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	// 获取更新数据
	var input struct {
		Quantity int    `json:"quantity" binding:"required"`
		Reason   string `json:"reason"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		log.Warn("更新库存请求参数无效", logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrInvalidInput).
			WithDetails("请提供有效的库存信息").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	log = log.WithFields(
		logger.F("old_quantity", existingInventory.Quantity),
		logger.F("new_quantity", input.Quantity),
		logger.F("reason", input.Reason),
	)

	// 记录原始数量
	oldQuantity := existingInventory.Quantity

	// 更新库存
	existingInventory.Quantity = input.Quantity
	if err := ic.db.Save(&existingInventory).Error; err != nil {
		log.Error("更新库存失败", logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrDatabaseUpdate).
			WithDetails("更新库存失败").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	log.Info("更新库存成功",
		logger.F("inventory_id", existingInventory.ID),
		logger.F("quantity_change", input.Quantity-oldQuantity))

	// 加载关联数据
	ic.db.Preload("ProductVariant").Preload("ProductVariant.Product").Preload("Store").First(&existingInventory, existingInventory.ID)

	c.JSON(http.StatusOK, existingInventory)
}

// DeleteInventory 删除库存
func (ic *InventoryController) DeleteInventory(c *gin.Context) {
	// 创建请求日志
	log := logger.WithContext(c)

	id := c.Param("id")
	log.Info("删除库存", logger.F("inventory_id", id))

	// 查找现有库存
	var inventory models.Inventory
	if err := ic.db.First(&inventory, id).Error; err != nil {
		log.Warn("库存不存在", logger.F("inventory_id", id), logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrNotFound).
			WithDetails("库存不存在或已被删除").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	// 删除库存
	if err := ic.db.Delete(&inventory).Error; err != nil {
		log.Error("删除库存失败", logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrDatabaseDelete).
			WithDetails("删除库存失败").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	log.Info("删除库存成功",
		logger.F("inventory_id", inventory.ID),
		logger.F("product_variant_id", inventory.ProductVariantID),
		logger.F("store_id", inventory.StoreID))

	c.JSON(http.StatusOK, gin.H{"message": "库存已删除"})
}
