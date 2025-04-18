package controllers

import (
	"hd_psi/backend/models"
	"hd_psi/backend/utils/errors"
	"hd_psi/backend/utils/logger"
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type InventoryController struct {
	db *gorm.DB
}

func NewInventoryController(db *gorm.DB) *InventoryController {
	return &InventoryController{db: db}
}

func (ic *InventoryController) ListInventories(c *gin.Context) {
	// 创建请求日志
	log := logger.WithContext(c)
	log.Info("获取库存列表")

	var inventories []models.Inventory
	if err := ic.db.Find(&inventories).Error; err != nil {
		log.Error("获取库存列表失败", logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrDatabaseQuery).
			WithDetails("获取库存列表失败").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	log.Info("获取库存列表成功", logger.F("count", len(inventories)))
	c.JSON(http.StatusOK, inventories)
}

func (ic *InventoryController) GetInventory(c *gin.Context) {
	// 创建请求日志
	log := logger.WithContext(c)
	
	id := c.Param("id")
	log.Info("获取库存详情", logger.F("inventory_id", id))

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

	log.Info("获取库存详情成功", logger.F("inventory_id", inventory.ID))
	c.JSON(http.StatusOK, inventory)
}

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

	// 检查是否已存在相同的库存记录
	var existingInventory models.Inventory
	if inventory.ProductID > 0 && inventory.StoreID > 0 {
		if err := ic.db.Where("product_id = ? AND store_id = ?", inventory.ProductID, inventory.StoreID).First(&existingInventory).Error; err == nil {
			log.Warn("库存记录已存在", 
				logger.F("product_id", inventory.ProductID), 
				logger.F("store_id", inventory.StoreID))
			appErr := errors.New(errors.ErrConflict).
				WithDetails("该商品在此店铺已有库存记录").
				WithRequestID(c.GetString("request_id"))
			c.Error(appErr)
			return
		}
	}

	if err := ic.db.Create(&inventory).Error; err != nil {
		log.Error("创建库存失败", logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrDatabaseInsert).
			WithDetails("创建库存失败").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	log.Info("创建库存成功", 
		logger.F("inventory_id", inventory.ID), 
		logger.F("product_id", inventory.ProductID),
		logger.F("store_id", inventory.StoreID),
		logger.F("quantity", inventory.Quantity))
	c.JSON(http.StatusCreated, inventory)
}

func (ic *InventoryController) UpdateInventory(c *gin.Context) {
	// 创建请求日志
	log := logger.WithContext(c)
	
	id := c.Param("id")
	log.Info("更新库存", logger.F("inventory_id", id))

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

	// 保存原始数据用于日志记录
	oldQuantity := inventory.Quantity
	oldProductID := inventory.ProductID
	oldStoreID := inventory.StoreID

	if err := c.ShouldBindJSON(&inventory); err != nil {
		log.Warn("更新库存请求参数无效", logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrInvalidInput).
			WithDetails("请提供有效的库存信息").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	// 检查是否已存在相同的库存记录（排除当前记录）
	if inventory.ProductID > 0 && inventory.StoreID > 0 && 
	   (inventory.ProductID != oldProductID || inventory.StoreID != oldStoreID) {
		var existingInventory models.Inventory
		if err := ic.db.Where("product_id = ? AND store_id = ? AND id != ?", 
			inventory.ProductID, inventory.StoreID, id).First(&existingInventory).Error; err == nil {
			log.Warn("库存记录已存在", 
				logger.F("product_id", inventory.ProductID), 
				logger.F("store_id", inventory.StoreID))
			appErr := errors.New(errors.ErrConflict).
				WithDetails("该商品在此店铺已有库存记录").
				WithRequestID(c.GetString("request_id"))
			c.Error(appErr)
			return
		}
	}

	if err := ic.db.Save(&inventory).Error; err != nil {
		log.Error("更新库存失败", logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrDatabaseUpdate).
			WithDetails("更新库存失败").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	log.Info("更新库存成功", 
		logger.F("inventory_id", inventory.ID), 
		logger.F("product_id", inventory.ProductID),
		logger.F("store_id", inventory.StoreID),
		logger.F("old_quantity", oldQuantity),
		logger.F("new_quantity", inventory.Quantity))
	c.JSON(http.StatusOK, inventory)
}

func (ic *InventoryController) DeleteInventory(c *gin.Context) {
	// 创建请求日志
	log := logger.WithContext(c)
	
	id := c.Param("id")
	log.Info("删除库存", logger.F("inventory_id", id))

	// 检查库存是否存在
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

	// 检查是否有关联的库存交易记录
	var transactionCount int64
	if err := ic.db.Model(&models.InventoryTransaction{}).Where("inventory_id = ?", id).Count(&transactionCount).Error; err != nil {
		log.Error("检查库存交易记录失败", logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrDatabaseQuery).
			WithDetails("检查库存交易记录失败").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	if transactionCount > 0 {
		log.Warn("库存有关联的交易记录，无法删除", 
			logger.F("inventory_id", id), 
			logger.F("transaction_count", transactionCount))
		appErr := errors.New(errors.ErrInvalidOperation).
			WithDetails("该库存有关联的交易记录，无法删除").
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	if err := ic.db.Delete(&models.Inventory{}, id).Error; err != nil {
		log.Error("删除库存失败", logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrDatabaseDelete).
			WithDetails("删除库存失败").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	log.Info("删除库存成功", 
		logger.F("inventory_id", id), 
		logger.F("product_id", inventory.ProductID),
		logger.F("store_id", inventory.StoreID))
	c.JSON(http.StatusOK, gin.H{"message": "库存删除成功"})
}
