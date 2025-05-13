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

// ListInventories godoc
// @Summary 获取库存列表
// @Description 获取库存列表，支持按产品变体和店铺筛选，并支持分页
// @Tags 库存管理
// @Accept json
// @Produce json
// @Param product_variant_id query int false "产品变体ID" example:"1"
// @Param store_id query int false "店铺ID" example:"1"
// @Param page query int false "页码，默认1" minimum(1) example:"1"
// @Param pageSize query int false "每页数量，默认10" minimum(1) maximum(100) example:"10"
// @Success 200 {object} models.PaginatedResponse{items=[]models.Inventory} "成功获取库存列表"
// @Failure 400 {object} models.ErrorResponse "请求参数错误"
// @Failure 401 {object} models.ErrorResponse "未授权"
// @Failure 500 {object} models.ErrorResponse "服务器内部错误"
// @Router /inventory [get]
// @Security BearerAuth
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

// GetInventory godoc
// @Summary 获取库存详情
// @Description 根据ID获取库存的详细信息，包括产品变体和店铺信息
// @Tags 库存管理
// @Accept json
// @Produce json
// @Param id path int true "库存ID" example:"1"
// @Success 200 {object} models.Inventory "成功获取库存详情"
// @Failure 401 {object} models.ErrorResponse "未授权"
// @Failure 404 {object} models.ErrorResponse "库存不存在"
// @Failure 500 {object} models.ErrorResponse "服务器内部错误"
// @Router /inventory/{id} [get]
// @Security BearerAuth
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

// CreateInventory godoc
// @Summary 创建库存
// @Description 创建新的库存记录，需提供产品变体ID、店铺ID和库存数量
// @Tags 库存管理
// @Accept json
// @Produce json
// @Param inventory body models.Inventory true "库存信息"
// @Success 201 {object} models.Inventory "创建成功"
// @Failure 400 {object} models.ErrorResponse "请求参数错误"
// @Failure 401 {object} models.ErrorResponse "未授权"
// @Failure 404 {object} models.ErrorResponse "产品变体或店铺不存在"
// @Failure 409 {object} models.ErrorResponse "库存记录已存在"
// @Failure 500 {object} models.ErrorResponse "服务器内部错误"
// @Router /inventory [post]
// @Security BearerAuth
// @Example 请求示例
//
//	{
//	  "product_variant_id": 1,
//	  "store_id": 1,
//	  "quantity": 100
//	}
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

// UpdateInventory godoc
// @Summary 更新库存
// @Description 更新现有库存记录，可以修改库存数量并提供更新原因
// @Tags 库存管理
// @Accept json
// @Produce json
// @Param id path int true "库存ID" example:"1"
// @Param inventory body object true "库存信息"
// @Success 200 {object} models.Inventory "更新成功"
// @Failure 400 {object} models.ErrorResponse "请求参数错误"
// @Failure 401 {object} models.ErrorResponse "未授权"
// @Failure 404 {object} models.ErrorResponse "库存不存在"
// @Failure 500 {object} models.ErrorResponse "服务器内部错误"
// @Router /inventory/{id} [put]
// @Security BearerAuth
// @Example 请求示例
//
//	{
//	  "quantity": 120,
//	  "reason": "补货入库"
//	}
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

// DeleteInventory godoc
// @Summary 删除库存
// @Description 删除指定ID的库存记录，此操作不可逆
// @Tags 库存管理
// @Accept json
// @Produce json
// @Param id path int true "库存ID" example:"1"
// @Success 200 {object} models.APIResponse "删除成功"
// @Failure 401 {object} models.ErrorResponse "未授权"
// @Failure 404 {object} models.ErrorResponse "库存不存在"
// @Failure 500 {object} models.ErrorResponse "服务器内部错误"
// @Router /inventory/{id} [delete]
// @Security BearerAuth
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
