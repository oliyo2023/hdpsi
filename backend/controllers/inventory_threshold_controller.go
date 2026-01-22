package controllers

import (
	"hd_psi/backend/models"
	"net/http"

	"github.com/kataras/iris/v12"
	"gorm.io/gorm"
)

type InventoryThresholdController struct {
	db *gorm.DB
}

func NewInventoryThresholdController(db *gorm.DB) *InventoryThresholdController {
	return &InventoryThresholdController{db: db}
}

// ListThresholds 获取所有库存阈值设置
func (itc *InventoryThresholdController) ListThresholds(c iris.Context) {
	var thresholds []models.InventoryThreshold
	
	// 获取查询参数
	storeID := c.URLParam("store_id")
	category := c.URLParam("category")
	
	// 构建查询
	query := itc.db.Model(&models.InventoryThreshold{})
	
	if storeID != "" {
		query = query.Where("store_id = ? OR store_id = 0", storeID)
	}
	
	if category != "" {
		query = query.Where("category = ? OR category = ''", category)
	}
	
	// 执行查询
	if err := query.Find(&thresholds).Error; err != nil {
		c.StatusCode(http.StatusInternalServerError)
		c.JSON(iris.Map{"error": err.Error()})
		return
	}
	
	c.StatusCode(http.StatusOK)
	c.JSON(thresholds)
}

// GetThreshold 获取单个阈值设置
func (itc *InventoryThresholdController) GetThreshold(c iris.Context) {
	id := c.Params().Get("id")
	var threshold models.InventoryThreshold
	if err := itc.db.First(&threshold, id).Error; err != nil {
		c.StatusCode(http.StatusNotFound)
		c.JSON(iris.Map{"error": "Threshold not found"})
		return
	}
	c.StatusCode(http.StatusOK)
	c.JSON(threshold)
}

// CreateThreshold 创建阈值设置
func (itc *InventoryThresholdController) CreateThreshold(c iris.Context) {
	var threshold models.InventoryThreshold
	if err := c.ReadJSON(&threshold); err != nil {
		c.StatusCode(http.StatusBadRequest)
		c.JSON(iris.Map{"error": err.Error()})
		return
	}
	
	// 验证高阈值必须大于低阈值
	if threshold.HighLevel <= threshold.LowLevel {
		c.StatusCode(http.StatusBadRequest)
		c.JSON(iris.Map{"error": "High level must be greater than low level"})
		return
	}
	
	if err := itc.db.Create(&threshold).Error; err != nil {
		c.StatusCode(http.StatusInternalServerError)
		c.JSON(iris.Map{"error": err.Error()})
		return
	}
	
	c.StatusCode(http.StatusCreated)
	c.JSON(threshold)
}

// UpdateThreshold 更新阈值设置
func (itc *InventoryThresholdController) UpdateThreshold(c iris.Context) {
	id := c.Params().Get("id")
	var threshold models.InventoryThreshold
	if err := itc.db.First(&threshold, id).Error; err != nil {
		c.StatusCode(http.StatusNotFound)
		c.JSON(iris.Map{"error": "Threshold not found"})
		return
	}
	
	// 绑定请求数据
	if err := c.ReadJSON(&threshold); err != nil {
		c.StatusCode(http.StatusBadRequest)
		c.JSON(iris.Map{"error": err.Error()})
		return
	}
	
	// 验证高阈值必须大于低阈值
	if threshold.HighLevel <= threshold.LowLevel {
		c.StatusCode(http.StatusBadRequest)
		c.JSON(iris.Map{"error": "High level must be greater than low level"})
		return
	}
	
	if err := itc.db.Save(&threshold).Error; err != nil {
		c.StatusCode(http.StatusInternalServerError)
		c.JSON(iris.Map{"error": err.Error()})
		return
	}
	
	c.StatusCode(http.StatusOK)
	c.JSON(threshold)
}

// DeleteThreshold 删除阈值设置
func (itc *InventoryThresholdController) DeleteThreshold(c iris.Context) {
	id := c.Params().Get("id")
	if err := itc.db.Delete(&models.InventoryThreshold{}, id).Error; err != nil {
		c.StatusCode(http.StatusInternalServerError)
		c.JSON(iris.Map{"error": err.Error()})
		return
	}
	
	c.StatusCode(http.StatusOK)
	c.JSON(iris.Map{"message": "Threshold deleted"})
}