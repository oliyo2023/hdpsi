package controllers

import (
	"database/sql"
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// DashboardController 处理仪表盘相关的请求
type DashboardController struct {
	db *gorm.DB
}

// NewDashboardController 创建一个新的仪表盘控制器
func NewDashboardController(db *gorm.DB) *DashboardController {
	return &DashboardController{db: db}
}

// GetStatistics 获取仪表盘统计数据
func (dc *DashboardController) GetStatistics(c *gin.Context) {
	// 获取商品总数
	var productCount int64
	if err := dc.db.Table("products").Count(&productCount).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "获取商品总数失败"})
		return
	}

	// 获取库存总数
	// 使用可为NULL的类型来处理空表的情况
	var inventoryCount sql.NullInt64
	if err := dc.db.Table("inventories").Select("SUM(quantity)").Scan(&inventoryCount).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "获取库存总数失败"})
		return
	}

	// 如果结果为NULL，则使用零
	inventoryTotal := int64(0)
	if inventoryCount.Valid {
		inventoryTotal = inventoryCount.Int64
	}

	// 获取会员总数
	var memberCount int64
	if err := dc.db.Table("members").Count(&memberCount).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "获取会员总数失败"})
		return
	}

	// 获取销售订单总数
	var orderCount int64
	if err := dc.db.Table("sales_orders").Count(&orderCount).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "获取销售订单总数失败"})
		return
	}

	// 打印统计数据，便于调试
	c.JSON(http.StatusOK, gin.H{
		"productCount":   productCount,
		"inventoryCount": inventoryTotal,
		"memberCount":    memberCount,
		"orderCount":     orderCount,
	})
}
