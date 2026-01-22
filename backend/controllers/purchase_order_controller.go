package controllers

import (
	"hd_psi/backend/models"
	"net/http"

	"github.com/kataras/iris/v12"
	"gorm.io/gorm"
)

type PurchaseOrderController struct {
	db *gorm.DB
}

func NewPurchaseOrderController(db *gorm.DB) *PurchaseOrderController {
	return &PurchaseOrderController{db: db}
}

func (poc *PurchaseOrderController) ListPurchaseOrders(c iris.Context) {
	var purchaseOrders []models.PurchaseOrder
	if err := poc.db.Find(&purchaseOrders).Error; err != nil {
		c.StatusCode(http.StatusInternalServerError)
		c.JSON(iris.Map{"error": err.Error()})
		return
	}
	c.StatusCode(http.StatusOK)
	c.JSON(purchaseOrders)
}

func (poc *PurchaseOrderController) GetPurchaseOrder(c iris.Context) {
	id := c.Params().Get("id")
	var purchaseOrder models.PurchaseOrder
	if err := poc.db.First(&purchaseOrder, id).Error; err != nil {
		c.StatusCode(http.StatusNotFound)
		c.JSON(iris.Map{"error": "PurchaseOrder not found"})
		return
	}
	c.StatusCode(http.StatusOK)
	c.JSON(purchaseOrder)
}

func (poc *PurchaseOrderController) CreatePurchaseOrder(c iris.Context) {
	var purchaseOrder models.PurchaseOrder
	if err := c.ReadJSON(&purchaseOrder); err != nil {
		c.StatusCode(http.StatusBadRequest)
		c.JSON(iris.Map{"error": err.Error()})
		return
	}

	if err := poc.db.Create(&purchaseOrder).Error; err != nil {
		c.StatusCode(http.StatusInternalServerError)
		c.JSON(iris.Map{"error": err.Error()})
		return
	}
	c.StatusCode(http.StatusCreated)
	c.JSON(purchaseOrder)
}

func (poc *PurchaseOrderController) UpdatePurchaseOrder(c iris.Context) {
	id := c.Params().Get("id")
	var purchaseOrder models.PurchaseOrder
	if err := poc.db.First(&purchaseOrder, id).Error; err != nil {
		c.StatusCode(http.StatusNotFound)
		c.JSON(iris.Map{"error": "PurchaseOrder not found"})
		return
	}

	if err := c.ReadJSON(&purchaseOrder); err != nil {
		c.StatusCode(http.StatusBadRequest)
		c.JSON(iris.Map{"error": err.Error()})
		return
	}

	if err := poc.db.Save(&purchaseOrder).Error; err != nil {
		c.StatusCode(http.StatusInternalServerError)
		c.JSON(iris.Map{"error": err.Error()})
		return
	}
	c.StatusCode(http.StatusOK)
	c.JSON(purchaseOrder)
}

func (poc *PurchaseOrderController) DeletePurchaseOrder(c iris.Context) {
	id := c.Params().Get("id")
	if err := poc.db.Delete(&models.PurchaseOrder{}, id).Error; err != nil {
		c.StatusCode(http.StatusInternalServerError)
		c.JSON(iris.Map{"error": err.Error()})
		return
	}
	c.StatusCode(http.StatusOK)
	c.JSON(iris.Map{"message": "PurchaseOrder deleted"})
}