package controllers

import (
	"hd_psi/backend/models"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type ProductController struct {
	db *gorm.DB
}

func NewProductController(db *gorm.DB) *ProductController {
	return &ProductController{db: db}
}

func (pc *ProductController) ListProducts(c *gin.Context) {
	// 获取查询参数
	name := c.Query("name")
	sku := c.Query("sku")
	category := c.Query("category")
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("pageSize", "10"))

	// 构建查询
	query := pc.db.Model(&models.Product{})

	// 添加过滤条件
	if name != "" {
		query = query.Where("name LIKE ?", "%"+name+"%")
	}
	if sku != "" {
		query = query.Where("sku LIKE ?", "%"+sku+"%")
	}
	if category != "" {
		query = query.Where("category_id = ?", category)
	}

	// 计算总数
	var total int64
	if err := query.Count(&total).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "获取商品总数失败"})
		return
	}

	// 分页查询
	offset := (page - 1) * pageSize
	var products []models.Product
	// 使用Preload预加载关联数据
	if err := query.Preload("Category").Preload("Brand").Preload("Variants").Preload("Variants.Color").Preload("Variants.Size").Preload("Variants.Season").Preload("Variants.Fabric").Offset(offset).Limit(pageSize).Order("id DESC").Find(&products).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "获取商品列表失败"})
		return
	}

	// 检查是否有商品数据
	if len(products) == 0 && page == 1 {
		// 创建测试数据
		// 首先获取字典项ID
		var categoryShirt, categoryPants, categoryTshirt uint
		var colorWhite, colorBlue, colorBlack uint
		var sizeL, sizeM, sizeXL uint
		var seasonSpring, seasonSummer uint

		// 获取类别ID
		var categoryItems []models.DictionaryItem
		pc.db.Where("dictionary_code = ?", models.DictCategory).Find(&categoryItems)
		for _, item := range categoryItems {
			if item.Code == "shirt" {
				categoryShirt = item.ID
			} else if item.Code == "pants" {
				categoryPants = item.ID
			} else if item.Code == "tshirt" {
				categoryTshirt = item.ID
			}
		}

		// 获取颜色ID
		var colorItems []models.DictionaryItem
		pc.db.Where("dictionary_code = ?", models.DictColor).Find(&colorItems)
		for _, item := range colorItems {
			if item.Code == "white" {
				colorWhite = item.ID
			} else if item.Code == "blue" {
				colorBlue = item.ID
			} else if item.Code == "black" {
				colorBlack = item.ID
			}
		}

		// 获取尺码ID
		var sizeItems []models.DictionaryItem
		pc.db.Where("dictionary_code = ?", models.DictSize).Find(&sizeItems)
		for _, item := range sizeItems {
			if item.Code == "l" {
				sizeL = item.ID
			} else if item.Code == "m" {
				sizeM = item.ID
			} else if item.Code == "xl" {
				sizeXL = item.ID
			}
		}

		// 获取季节ID
		var seasonItems []models.DictionaryItem
		pc.db.Where("dictionary_code = ?", models.DictSeason).Find(&seasonItems)
		for _, item := range seasonItems {
			if item.Code == "spring" {
				seasonSpring = item.ID
			} else if item.Code == "summer" {
				seasonSummer = item.ID
			}
		}

		testProducts := []models.Product{
			{
				SKU:         "MS001",
				Name:        "男士休闲衬衫",
				CategoryID:  &categoryShirt,
				CostPrice:   89.00,
				RetailPrice: 199.00,
				Status:      true,
			},
			{
				SKU:         "WD001",
				Name:        "女士连衣裙",
				CategoryID:  &categoryPants,
				CostPrice:   120.00,
				RetailPrice: 299.00,
				Status:      true,
			},
			{
				SKU:         "MT001",
				Name:        "男士T恤",
				CategoryID:  &categoryTshirt,
				CostPrice:   45.00,
				RetailPrice: 99.00,
				Status:      true,
			},
		}

		// 将测试数据保存到数据库
		for _, product := range testProducts {
			if err := pc.db.Create(&product).Error; err != nil {
				continue
			}

			// 为每个商品创建变体
			if product.SKU == "MS001" && colorWhite > 0 && sizeL > 0 && seasonSpring > 0 {
				colorWhitePtr := colorWhite
				sizeLPtr := sizeL
				seasonSpringPtr := seasonSpring
				variant := models.ProductVariant{
					ProductID:   product.ID,
					SKU:         product.SKU + "-WL",
					ColorID:     &colorWhitePtr,
					SizeID:      &sizeLPtr,
					SeasonID:    &seasonSpringPtr,
					CostPrice:   product.CostPrice,
					RetailPrice: product.RetailPrice,
					Status:      true,
				}
				pc.db.Create(&variant)
			} else if product.SKU == "WD001" && colorBlue > 0 && sizeM > 0 && seasonSummer > 0 {
				colorBluePtr := colorBlue
				sizeMPtr := sizeM
				seasonSummerPtr := seasonSummer
				variant := models.ProductVariant{
					ProductID:   product.ID,
					SKU:         product.SKU + "-BM",
					ColorID:     &colorBluePtr,
					SizeID:      &sizeMPtr,
					SeasonID:    &seasonSummerPtr,
					CostPrice:   product.CostPrice,
					RetailPrice: product.RetailPrice,
					Status:      true,
				}
				pc.db.Create(&variant)
			} else if product.SKU == "MT001" && colorBlack > 0 && sizeXL > 0 && seasonSummer > 0 {
				colorBlackPtr := colorBlack
				sizeXLPtr := sizeXL
				seasonSummerPtr := seasonSummer
				variant := models.ProductVariant{
					ProductID:   product.ID,
					SKU:         product.SKU + "-BXL",
					ColorID:     &colorBlackPtr,
					SizeID:      &sizeXLPtr,
					SeasonID:    &seasonSummerPtr,
					CostPrice:   product.CostPrice,
					RetailPrice: product.RetailPrice,
					Status:      true,
				}
				pc.db.Create(&variant)
			}
		}

		// 重新查询商品
		query.Preload("Category").Preload("Brand").Preload("Variants").Preload("Variants.Color").Preload("Variants.Size").Preload("Variants.Season").Preload("Variants.Fabric").Offset(offset).Limit(pageSize).Order("id DESC").Find(&products)
		total = int64(len(products))
	}

	c.JSON(http.StatusOK, gin.H{
		"items":    products,
		"total":    total,
		"page":     page,
		"pageSize": pageSize,
	})
}

func (pc *ProductController) GetProduct(c *gin.Context) {
	id := c.Param("id")
	var product models.Product
	// 使用Preload预加载关联数据
	if err := pc.db.Preload("Category").Preload("Brand").Preload("Variants").Preload("Variants.Color").Preload("Variants.Size").Preload("Variants.Season").Preload("Variants.Fabric").First(&product, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Product not found"})
		return
	}

	// 变体数据已经通过Preload加载，不需要再次查询
	if product.Variants == nil {
		product.Variants = []models.ProductVariant{}
	} else {
		// 确保变体的关联数据已加载
		for i := range product.Variants {
			if product.Variants[i].ColorID != nil && *product.Variants[i].ColorID > 0 && product.Variants[i].Color.ID == 0 {
				var color models.DictionaryItem
				pc.db.First(&color, *product.Variants[i].ColorID)
				product.Variants[i].Color = color
			}
			if product.Variants[i].SizeID != nil && *product.Variants[i].SizeID > 0 && product.Variants[i].Size.ID == 0 {
				var size models.DictionaryItem
				pc.db.First(&size, *product.Variants[i].SizeID)
				product.Variants[i].Size = size
			}
			if product.Variants[i].SeasonID != nil && *product.Variants[i].SeasonID > 0 && product.Variants[i].Season.ID == 0 {
				var season models.DictionaryItem
				pc.db.First(&season, *product.Variants[i].SeasonID)
				product.Variants[i].Season = season
			}
			if product.Variants[i].FabricID != nil && *product.Variants[i].FabricID > 0 && product.Variants[i].Fabric.ID == 0 {
				var fabric models.DictionaryItem
				pc.db.First(&fabric, *product.Variants[i].FabricID)
				product.Variants[i].Fabric = fabric
			}
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"product":  product,
		"variants": product.Variants,
	})
}

func (pc *ProductController) CreateProduct(c *gin.Context) {
	var input struct {
		Product  models.Product          `json:"product"`
		Variants []models.ProductVariant `json:"variants"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 开始事务
	tx := pc.db.Begin()

	// 处理外键字段，如果为null则保持null
	// 注意：在GORM中，如果要将外键设置为null，需要使用指针类型
	// 在指针类型中，如果值为nil，则会存储为SQL的NULL

	// 创建商品
	if err := tx.Create(&input.Product).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "创建商品失败: " + err.Error()})
		return
	}

	// 创建商品变体
	for i := range input.Variants {
		input.Variants[i].ProductID = input.Product.ID

		// 处理外键字段，如果为null则保持null
		// 在指针类型中，如果值为nil，则会存储为SQL的NULL

		if err := tx.Create(&input.Variants[i]).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"error": "创建商品变体失败: " + err.Error()})
			return
		}
	}

	// 提交事务
	if err := tx.Commit().Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "提交事务失败: " + err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"product":  input.Product,
		"variants": input.Variants,
	})
}

func (pc *ProductController) UpdateProduct(c *gin.Context) {
	id := c.Param("id")
	var product models.Product
	if err := pc.db.First(&product, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Product not found"})
		return
	}

	var input struct {
		Product  models.Product          `json:"product"`
		Variants []models.ProductVariant `json:"variants"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 开始事务
	tx := pc.db.Begin()

	// 更新商品
	input.Product.ID = product.ID
	if err := tx.Save(&input.Product).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "更新商品失败: " + err.Error()})
		return
	}

	// 删除旧的变体
	if err := tx.Where("product_id = ?", product.ID).Delete(&models.ProductVariant{}).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "删除旧变体失败: " + err.Error()})
		return
	}

	// 创建新的变体
	for i := range input.Variants {
		input.Variants[i].ProductID = product.ID
		if err := tx.Create(&input.Variants[i]).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"error": "创建商品变体失败: " + err.Error()})
			return
		}
	}

	// 提交事务
	if err := tx.Commit().Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "提交事务失败: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"product":  input.Product,
		"variants": input.Variants,
	})
}

func (pc *ProductController) DeleteProduct(c *gin.Context) {
	id := c.Param("id")

	// 开始事务
	tx := pc.db.Begin()

	// 删除商品变体
	if err := tx.Where("product_id = ?", id).Delete(&models.ProductVariant{}).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "删除商品变体失败: " + err.Error()})
		return
	}

	// 删除商品
	if err := tx.Delete(&models.Product{}, id).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "删除商品失败: " + err.Error()})
		return
	}

	// 提交事务
	if err := tx.Commit().Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "提交事务失败: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "商品删除成功"})
}
