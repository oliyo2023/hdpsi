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

type ProductController struct {
	db *gorm.DB
}

func NewProductController(db *gorm.DB) *ProductController {
	return &ProductController{db: db}
}

func (pc *ProductController) ListProducts(c *gin.Context) {
	// 创建请求日志
	log := logger.WithContext(c)
	log.Info("获取商品列表")

	// 获取查询参数
	name := c.Query("name")
	sku := c.Query("sku")
	category := c.Query("category")
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("pageSize", "10"))

	// 记录查询参数
	log = log.WithFields(
		logger.F("name", name),
		logger.F("sku", sku),
		logger.F("category", category),
		logger.F("page", page),
		logger.F("pageSize", pageSize),
	)

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
		log.Error("获取商品总数失败", logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrDatabaseQuery).
			WithDetails("获取商品总数失败").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	// 分页查询
	offset := (page - 1) * pageSize
	var products []models.Product
	// 使用Preload预加载关联数据
	if err := query.Preload("Category").Preload("Brand").Preload("Variants").Preload("Variants.Color").Preload("Variants.Size").Preload("Variants.Season").Preload("Variants.Fabric").Offset(offset).Limit(pageSize).Order("id DESC").Find(&products).Error; err != nil {
		log.Error("获取商品列表失败", logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrDatabaseQuery).
			WithDetails("获取商品列表失败").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	// 检查是否有商品数据
	if len(products) == 0 && page == 1 {
		log.Info("商品列表为空，创建测试数据")
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
				log.Warn("创建测试商品失败", 
					logger.F("sku", product.SKU), 
					logger.F("error", err.Error()))
				continue
			}

			log.Info("创建测试商品成功", 
				logger.F("product_id", product.ID), 
				logger.F("sku", product.SKU))

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
				if err := pc.db.Create(&variant).Error; err != nil {
					log.Warn("创建测试商品变体失败", 
						logger.F("product_id", product.ID), 
						logger.F("sku", variant.SKU), 
						logger.F("error", err.Error()))
				} else {
					log.Info("创建测试商品变体成功", 
						logger.F("variant_id", variant.ID), 
						logger.F("sku", variant.SKU))
				}
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
				if err := pc.db.Create(&variant).Error; err != nil {
					log.Warn("创建测试商品变体失败", 
						logger.F("product_id", product.ID), 
						logger.F("sku", variant.SKU), 
						logger.F("error", err.Error()))
				} else {
					log.Info("创建测试商品变体成功", 
						logger.F("variant_id", variant.ID), 
						logger.F("sku", variant.SKU))
				}
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
				if err := pc.db.Create(&variant).Error; err != nil {
					log.Warn("创建测试商品变体失败", 
						logger.F("product_id", product.ID), 
						logger.F("sku", variant.SKU), 
						logger.F("error", err.Error()))
				} else {
					log.Info("创建测试商品变体成功", 
						logger.F("variant_id", variant.ID), 
						logger.F("sku", variant.SKU))
				}
			}
		}

		// 重新查询商品
		if err := query.Preload("Category").Preload("Brand").Preload("Variants").Preload("Variants.Color").Preload("Variants.Size").Preload("Variants.Season").Preload("Variants.Fabric").Offset(offset).Limit(pageSize).Order("id DESC").Find(&products).Error; err != nil {
			log.Error("重新查询商品列表失败", logger.F("error", err.Error()))
		}
		total = int64(len(products))
	}

	log.Info("获取商品列表成功", 
		logger.F("total", total), 
		logger.F("count", len(products)))

	c.JSON(http.StatusOK, gin.H{
		"items":    products,
		"total":    total,
		"page":     page,
		"pageSize": pageSize,
	})
}

func (pc *ProductController) GetProduct(c *gin.Context) {
	// 创建请求日志
	log := logger.WithContext(c)
	
	id := c.Param("id")
	log.Info("获取商品详情", logger.F("product_id", id))

	var product models.Product
	// 使用Preload预加载关联数据
	if err := pc.db.Preload("Category").Preload("Brand").Preload("Variants").Preload("Variants.Color").Preload("Variants.Size").Preload("Variants.Season").Preload("Variants.Fabric").First(&product, id).Error; err != nil {
		log.Warn("商品不存在", logger.F("product_id", id), logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrNotFound).
			WithDetails("商品不存在或已被删除").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
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

	log.Info("获取商品详情成功", 
		logger.F("product_id", product.ID), 
		logger.F("sku", product.SKU),
		logger.F("variants_count", len(product.Variants)))

	c.JSON(http.StatusOK, gin.H{
		"product":  product,
		"variants": product.Variants,
	})
}

func (pc *ProductController) CreateProduct(c *gin.Context) {
	// 创建请求日志
	log := logger.WithContext(c)
	log.Info("创建商品")

	var input struct {
		Product  models.Product          `json:"product"`
		Variants []models.ProductVariant `json:"variants"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		log.Warn("创建商品请求参数无效", logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrInvalidInput).
			WithDetails("请提供有效的商品信息").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	log = log.WithFields(
		logger.F("sku", input.Product.SKU),
		logger.F("name", input.Product.Name),
		logger.F("variants_count", len(input.Variants)),
	)

	// 检查SKU是否已存在
	var existingProduct models.Product
	if err := pc.db.Where("sku = ?", input.Product.SKU).First(&existingProduct).Error; err == nil {
		log.Warn("SKU已存在", logger.F("sku", input.Product.SKU))
		appErr := errors.New(errors.ErrConflict).
			WithDetails("商品SKU已存在，请使用其他SKU").
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
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
		log.Error("创建商品失败", logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrDatabaseInsert).
			WithDetails("创建商品失败").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	// 创建商品变体
	for i := range input.Variants {
		input.Variants[i].ProductID = input.Product.ID

		// 处理外键字段，如果为null则保持null
		// 在指针类型中，如果值为nil，则会存储为SQL的NULL

		if err := tx.Create(&input.Variants[i]).Error; err != nil {
			tx.Rollback()
			log.Error("创建商品变体失败", 
				logger.F("product_id", input.Product.ID),
				logger.F("variant_index", i),
				logger.F("error", err.Error()))
			appErr := errors.New(errors.ErrDatabaseInsert).
				WithDetails("创建商品变体失败").
				WithError(err).
				WithRequestID(c.GetString("request_id"))
			c.Error(appErr)
			return
		}
	}

	// 提交事务
	if err := tx.Commit().Error; err != nil {
		log.Error("提交事务失败", logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrDatabaseInsert).
			WithDetails("提交事务失败").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	log.Info("创建商品成功", 
		logger.F("product_id", input.Product.ID), 
		logger.F("sku", input.Product.SKU),
		logger.F("variants_count", len(input.Variants)))

	c.JSON(http.StatusCreated, gin.H{
		"product":  input.Product,
		"variants": input.Variants,
	})
}

func (pc *ProductController) UpdateProduct(c *gin.Context) {
	// 创建请求日志
	log := logger.WithContext(c)
	
	id := c.Param("id")
	log.Info("更新商品", logger.F("product_id", id))

	var product models.Product
	if err := pc.db.First(&product, id).Error; err != nil {
		log.Warn("商品不存在", logger.F("product_id", id), logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrNotFound).
			WithDetails("商品不存在或已被删除").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	var input struct {
		Product  models.Product          `json:"product"`
		Variants []models.ProductVariant `json:"variants"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		log.Warn("更新商品请求参数无效", logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrInvalidInput).
			WithDetails("请提供有效的商品信息").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	log = log.WithFields(
		logger.F("sku", input.Product.SKU),
		logger.F("name", input.Product.Name),
		logger.F("variants_count", len(input.Variants)),
	)

	// 检查SKU是否已被其他商品使用
	var existingProduct models.Product
	if err := pc.db.Where("sku = ? AND id != ?", input.Product.SKU, id).First(&existingProduct).Error; err == nil {
		log.Warn("SKU已被其他商品使用", 
			logger.F("sku", input.Product.SKU), 
			logger.F("existing_product_id", existingProduct.ID))
		appErr := errors.New(errors.ErrConflict).
			WithDetails("商品SKU已被其他商品使用，请使用其他SKU").
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	// 开始事务
	tx := pc.db.Begin()

	// 更新商品
	input.Product.ID = product.ID
	if err := tx.Save(&input.Product).Error; err != nil {
		tx.Rollback()
		log.Error("更新商品失败", logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrDatabaseUpdate).
			WithDetails("更新商品失败").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	// 删除旧的变体
	if err := tx.Where("product_id = ?", product.ID).Delete(&models.ProductVariant{}).Error; err != nil {
		tx.Rollback()
		log.Error("删除旧变体失败", 
			logger.F("product_id", product.ID),
			logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrDatabaseDelete).
			WithDetails("删除旧变体失败").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	// 创建新的变体
	for i := range input.Variants {
		input.Variants[i].ProductID = product.ID
		if err := tx.Create(&input.Variants[i]).Error; err != nil {
			tx.Rollback()
			log.Error("创建商品变体失败", 
				logger.F("product_id", product.ID),
				logger.F("variant_index", i),
				logger.F("error", err.Error()))
			appErr := errors.New(errors.ErrDatabaseInsert).
				WithDetails("创建商品变体失败").
				WithError(err).
				WithRequestID(c.GetString("request_id"))
			c.Error(appErr)
			return
		}
	}

	// 提交事务
	if err := tx.Commit().Error; err != nil {
		log.Error("提交事务失败", logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrDatabaseUpdate).
			WithDetails("提交事务失败").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	log.Info("更新商品成功", 
		logger.F("product_id", product.ID), 
		logger.F("sku", input.Product.SKU),
		logger.F("variants_count", len(input.Variants)))

	c.JSON(http.StatusOK, gin.H{
		"product":  input.Product,
		"variants": input.Variants,
	})
}

func (pc *ProductController) DeleteProduct(c *gin.Context) {
	// 创建请求日志
	log := logger.WithContext(c)
	
	id := c.Param("id")
	log.Info("删除商品", logger.F("product_id", id))

	// 检查商品是否存在
	var product models.Product
	if err := pc.db.First(&product, id).Error; err != nil {
		log.Warn("商品不存在", logger.F("product_id", id), logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrNotFound).
			WithDetails("商品不存在或已被删除").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	// 开始事务
	tx := pc.db.Begin()

	// 删除商品变体
	if err := tx.Where("product_id = ?", id).Delete(&models.ProductVariant{}).Error; err != nil {
		tx.Rollback()
		log.Error("删除商品变体失败", 
			logger.F("product_id", id),
			logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrDatabaseDelete).
			WithDetails("删除商品变体失败").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	// 删除商品
	if err := tx.Delete(&models.Product{}, id).Error; err != nil {
		tx.Rollback()
		log.Error("删除商品失败", 
			logger.F("product_id", id),
			logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrDatabaseDelete).
			WithDetails("删除商品失败").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	// 提交事务
	if err := tx.Commit().Error; err != nil {
		log.Error("提交事务失败", logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrDatabaseDelete).
			WithDetails("提交事务失败").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	log.Info("删除商品成功", 
		logger.F("product_id", id), 
		logger.F("sku", product.SKU))

	c.JSON(http.StatusOK, gin.H{"message": "商品删除成功"})
}
