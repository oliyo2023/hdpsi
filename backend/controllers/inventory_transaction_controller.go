package controllers

import (
	"hd_psi/backend/models"
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type InventoryTransactionController struct {
	db *gorm.DB
}

func NewInventoryTransactionController(db *gorm.DB) *InventoryTransactionController {
	return &InventoryTransactionController{db: db}
}

func (itc *InventoryTransactionController) ListTransactions(c *gin.Context) {
	var transactions []models.InventoryTransaction
	if err := itc.db.Find(&transactions).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, transactions)
}

func (itc *InventoryTransactionController) GetTransaction(c *gin.Context) {
	id := c.Param("id")
	var transaction models.InventoryTransaction
	if err := itc.db.First(&transaction, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Transaction not found"})
		return
	}
	c.JSON(http.StatusOK, transaction)
}

func (itc *InventoryTransactionController) CreateTransaction(c *gin.Context) {
	var transaction models.InventoryTransaction
	if err := c.ShouldBindJSON(&transaction); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 开始事务
	tx := itc.db.Begin()

	// 创建库存交易记录
	if err := tx.Create(&transaction).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// 更新库存
	var inventory models.Inventory
	result := tx.Where("store_id = ? AND product_variant_id = ?", transaction.StoreID, transaction.ProductVariantID).First(&inventory)

	if result.Error != nil {
		// 如果库存记录不存在且是入库操作，则创建新的库存记录
		if result.Error == gorm.ErrRecordNotFound && transaction.Quantity > 0 {
			newInventory := models.Inventory{
				StoreID:          transaction.StoreID,
				ProductVariantID: transaction.ProductVariantID,
				Quantity:         transaction.Quantity,
			}
			if err := tx.Create(&newInventory).Error; err != nil {
				tx.Rollback()
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create inventory record: " + err.Error()})
				return
			}
		} else {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to find inventory record: " + result.Error.Error()})
			return
		}
	} else {
		// 更新现有库存
		inventory.Quantity += transaction.Quantity
		if err := tx.Save(&inventory).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update inventory: " + err.Error()})
			return
		}
	}

	// 提交事务
	if err := tx.Commit().Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to commit transaction: " + err.Error()})
		return
	}

	c.JSON(http.StatusCreated, transaction)
}

// 获取指定店铺的库存交易记录
func (itc *InventoryTransactionController) GetStoreTransactions(c *gin.Context) {
	storeID := c.Param("storeId")
	var transactions []models.InventoryTransaction
	if err := itc.db.Where("store_id = ?", storeID).Find(&transactions).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, transactions)
}

// 获取指定产品的库存交易记录
func (itc *InventoryTransactionController) GetProductTransactions(c *gin.Context) {
	productID := c.Param("productId")
	var transactions []models.InventoryTransaction
	if err := itc.db.Where("product_id = ?", productID).Find(&transactions).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, transactions)
}
