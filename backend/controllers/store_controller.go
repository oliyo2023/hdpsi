package controllers

import (
	"hd_psi/backend/models"
	"net/http"

	"github.com/kataras/iris/v12"
	"gorm.io/gorm"
)

type StoreController struct {
	db *gorm.DB
}

func NewStoreController(db *gorm.DB) *StoreController {
	return &StoreController{db: db}
}

func (sc *StoreController) ListStores(c iris.Context) {
	var stores []models.Store
	if err := sc.db.Find(&stores).Error; err != nil {
		c.StatusCode(http.StatusInternalServerError)
		c.JSON(iris.Map{"error": err.Error()})
		return
	}
	c.StatusCode(http.StatusOK)
	c.JSON(stores)
}

func (sc *StoreController) GetStore(c iris.Context) {
	id := c.Params().Get("id")
	var store models.Store
	if err := sc.db.First(&store, id).Error; err != nil {
		c.StatusCode(http.StatusNotFound)
		c.JSON(iris.Map{"error": "Store not found"})
		return
	}
	c.StatusCode(http.StatusOK)
	c.JSON(store)
}

func (sc *StoreController) CreateStore(c iris.Context) {
	var store models.Store
	if err := c.ReadJSON(&store); err != nil {
		c.StatusCode(http.StatusBadRequest)
		c.JSON(iris.Map{"error": err.Error()})
		return
	}

	if err := sc.db.Create(&store).Error; err != nil {
		c.StatusCode(http.StatusInternalServerError)
		c.JSON(iris.Map{"error": err.Error()})
		return
	}
	c.StatusCode(http.StatusCreated)
	c.JSON(store)
}

func (sc *StoreController) UpdateStore(c iris.Context) {
	id := c.Params().Get("id")
	var store models.Store
	if err := sc.db.First(&store, id).Error; err != nil {
		c.StatusCode(http.StatusNotFound)
		c.JSON(iris.Map{"error": "Store not found"})
		return
	}

	if err := c.ReadJSON(&store); err != nil {
		c.StatusCode(http.StatusBadRequest)
		c.JSON(iris.Map{"error": err.Error()})
		return
	}

	if err := sc.db.Save(&store).Error; err != nil {
		c.StatusCode(http.StatusInternalServerError)
		c.JSON(iris.Map{"error": err.Error()})
		return
	}
	c.StatusCode(http.StatusOK)
	c.JSON(store)
}

func (sc *StoreController) DeleteStore(c iris.Context) {
	id := c.Params().Get("id")
	if err := sc.db.Delete(&models.Store{}, id).Error; err != nil {
		c.StatusCode(http.StatusInternalServerError)
		c.JSON(iris.Map{"error": err.Error()})
		return
	}
	c.StatusCode(http.StatusOK)
	c.JSON(iris.Map{"message": "Store deleted"})
}