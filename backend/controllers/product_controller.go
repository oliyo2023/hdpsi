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

// ListProducts godoc
// @Summary 获取商品列表
// @Description 获取商品列表，支持按名称、SKU、分类等条件筛选，并支持分页
// @Tags 商品管理
// @Accept json
// @Produce json
// @Param name query string false "商品名称（模糊查询）" example:"牛仔裤"
// @Param sku query string false "商品SKU（模糊查询）" example:"JN001"
// @Param category query string false "商品分类" example:"裤装"
// @Param category_id query string false "商品分类ID" example:"1"
// @Param page query int false "页码，默认1" minimum(1) example:"1"
// @Param pageSize query int false "每页数量，默认10" minimum(1) maximum(100) example:"10"
// @Success 200 {object} models.PaginatedResponse{items=[]models.Product} "成功获取商品列表"
// @Failure 400 {object} models.ErrorResponse "请求参数错误"
// @Failure 401 {object} models.ErrorResponse "未授权"
// @Failure 500 {object} models.ErrorResponse "服务器内部错误"
// @Router /products [get]
// @Security BearerAuth
func (pc *ProductController) ListProducts(c *gin.Context) {
	// 创建请求日志
	log := logger.WithContext(c)
	log.Info("获取商品列表")

	// 获取查询参数
	name := c.Query("name")
	sku := c.Query("sku")
	category := c.Query("category")
	categoryID := c.Query("category_id") // 添加对category_id参数的支持
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("pageSize", "10"))

	// 记录查询参数
	log = log.WithFields(
		logger.F("name", name),
		logger.F("sku", sku),
		logger.F("category", category),
		logger.F("category_id", categoryID),
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
	// 优先使用category_id参数，如果没有再使用category参数
	if categoryID != "" {
		query = query.Where("category_id = ?", categoryID)
	} else if category != "" {
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

// GetProduct godoc
// @Summary 获取商品详情
// @Description 根据ID获取商品的详细信息，包括基本信息、变体、价格等
// @Tags 商品管理
// @Accept json
// @Produce json
// @Param id path int true "商品ID" example:"1"
// @Success 200 {object} models.Product "成功获取商品详情"
// @Failure 401 {object} models.ErrorResponse "未授权"
// @Failure 404 {object} models.ErrorResponse "商品不存在"
// @Failure 500 {object} models.ErrorResponse "服务器内部错误"
// @Router /products/{id} [get]
// @Security BearerAuth
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
			if product.Variants[i].ColorID != nil && *product.Variants[i].ColorID > 0 && (product.Variants[i].Color == nil || product.Variants[i].Color.ID == 0) {
				var color models.DictionaryItem
				pc.db.First(&color, *product.Variants[i].ColorID)
				product.Variants[i].Color = &color
			}
			if product.Variants[i].SizeID != nil && *product.Variants[i].SizeID > 0 && (product.Variants[i].Size == nil || product.Variants[i].Size.ID == 0) {
				var size models.DictionaryItem
				pc.db.First(&size, *product.Variants[i].SizeID)
				product.Variants[i].Size = &size
			}
			if product.Variants[i].SeasonID != nil && *product.Variants[i].SeasonID > 0 && (product.Variants[i].Season == nil || product.Variants[i].Season.ID == 0) {
				var season models.DictionaryItem
				pc.db.First(&season, *product.Variants[i].SeasonID)
				product.Variants[i].Season = &season
			}
			if product.Variants[i].FabricID != nil && *product.Variants[i].FabricID > 0 && (product.Variants[i].Fabric == nil || product.Variants[i].Fabric.ID == 0) {
				var fabric models.DictionaryItem
				pc.db.First(&fabric, *product.Variants[i].FabricID)
				product.Variants[i].Fabric = &fabric
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

// CreateProduct godoc
// @Summary 创建商品
// @Description 创建新的商品及其变体，需提供商品基本信息和变体信息
// @Tags 商品管理
// @Accept json
// @Produce json
// @Param product body map[string]interface{} true "商品信息"
// @Success 201 {object} models.Product "创建成功"
// @Failure 400 {object} models.ErrorResponse "请求参数错误"
// @Failure 401 {object} models.ErrorResponse "未授权"
// @Failure 409 {object} models.ErrorResponse "商品SKU已存在"
// @Failure 500 {object} models.ErrorResponse "服务器内部错误"
// @Router /products [post]
// @Security BearerAuth
// @Example 请求示例
//
//	{
//	  "name": "经典牛仔裤",
//	  "description": "高品质牛仔面料，舒适耐穿",
//	  "category_id": 1,
//	  "brand": "宏达",
//	  "season": "四季",
//	  "gender": "男",
//	  "material": "牛仔布",
//	  "status": true,
//	  "variants": [
//	    {
//	      "sku": "JN001-M-BLUE",
//	      "size": "M",
//	      "color": "蓝色",
//	      "cost_price": 89.00,
//	      "retail_price": 199.00,
//	      "wholesale_price": 129.00,
//	      "stock_quantity": 100
//	    },
//	    {
//	      "sku": "JN001-L-BLUE",
//	      "size": "L",
//	      "color": "蓝色",
//	      "cost_price": 89.00,
//	      "retail_price": 199.00,
//	      "wholesale_price": 129.00,
//	      "stock_quantity": 80
//	    }
//	  ]
//	}
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

// UpdateProduct godoc
// @Summary 更新商品
// @Description 更新现有商品及其变体，需提供完整的商品信息
// @Tags 商品管理
// @Accept json
// @Produce json
// @Param id path int true "商品ID" example:"1"
// @Param product body map[string]interface{} true "商品信息"
// @Success 200 {object} models.Product "更新成功"
// @Failure 400 {object} models.ErrorResponse "请求参数错误"
// @Failure 401 {object} models.ErrorResponse "未授权"
// @Failure 404 {object} models.ErrorResponse "商品不存在"
// @Failure 409 {object} models.ErrorResponse "商品SKU已被其他商品使用"
// @Failure 500 {object} models.ErrorResponse "服务器内部错误"
// @Router /products/{id} [put]
// @Security BearerAuth
// @Example 请求示例
//
//	{
//	  "name": "经典牛仔裤（更新）",
//	  "description": "高品质牛仔面料，舒适耐穿，新增弹力设计",
//	  "category_id": 1,
//	  "brand": "宏达",
//	  "season": "四季",
//	  "gender": "男",
//	  "material": "牛仔布+弹性纤维",
//	  "status": true,
//	  "variants": [
//	    {
//	      "id": 1,
//	      "sku": "JN001-M-BLUE",
//	      "size": "M",
//	      "color": "蓝色",
//	      "cost_price": 95.00,
//	      "retail_price": 219.00,
//	      "wholesale_price": 139.00,
//	      "stock_quantity": 120
//	    },
//	    {
//	      "id": 2,
//	      "sku": "JN001-L-BLUE",
//	      "size": "L",
//	      "color": "蓝色",
//	      "cost_price": 95.00,
//	      "retail_price": 219.00,
//	      "wholesale_price": 139.00,
//	      "stock_quantity": 100
//	    },
//	    {
//	      "sku": "JN001-XL-BLUE",
//	      "size": "XL",
//	      "color": "蓝色",
//	      "cost_price": 95.00,
//	      "retail_price": 219.00,
//	      "wholesale_price": 139.00,
//	      "stock_quantity": 50
//	    }
//	  ]
//	}
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

	// 从数据库中获取当前商品的完整信息
	var currentProduct models.Product
	if err := tx.First(&currentProduct, product.ID).Error; err != nil {
		tx.Rollback()
		log.Error("获取当前商品信息失败", logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrDatabaseQuery).
			WithDetails("获取当前商品信息失败").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	// 保留原始的创建时间
	input.Product.CreatedAt = currentProduct.CreatedAt

	// 确保所有必要字段都有值
	if input.Product.SKU == "" {
		input.Product.SKU = currentProduct.SKU
	}
	if input.Product.Name == "" {
		input.Product.Name = currentProduct.Name
	}

	// 记录更新前的商品信息
	log.Info("更新前的商品信息",
		logger.F("product_id", currentProduct.ID),
		logger.F("sku", currentProduct.SKU),
		logger.F("name", currentProduct.Name),
		logger.F("category_id", currentProduct.CategoryID))

	// 记录即将更新的商品信息
	log.Info("即将更新的商品信息",
		logger.F("product_id", input.Product.ID),
		logger.F("sku", input.Product.SKU),
		logger.F("name", input.Product.Name),
		logger.F("category_id", input.Product.CategoryID))

	// 使用Updates而不是Save，只更新非零值字段
	if err := tx.Model(&currentProduct).Updates(input.Product).Error; err != nil {
		tx.Rollback()
		log.Error("更新商品失败", logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrDatabaseUpdate).
			WithDetails("更新商品失败").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	// 验证更新后的商品信息
	var updatedProduct models.Product
	if err := tx.First(&updatedProduct, product.ID).Error; err != nil {
		tx.Rollback()
		log.Error("获取更新后的商品信息失败", logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrDatabaseQuery).
			WithDetails("获取更新后的商品信息失败").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	// 记录更新后的商品信息
	log.Info("更新后的商品信息",
		logger.F("product_id", updatedProduct.ID),
		logger.F("sku", updatedProduct.SKU),
		logger.F("name", updatedProduct.Name),
		logger.F("category_id", updatedProduct.CategoryID))

	// Fetch existing variants
	var existingVariants []models.ProductVariant
	if err := tx.Where("product_id = ?", product.ID).Find(&existingVariants).Error; err != nil {
		tx.Rollback()
		log.Error("获取现有变体失败",
			logger.F("product_id", product.ID),
			logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrDatabaseQuery).
			WithDetails("获取现有变体失败").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	// Map existing variants by ID for quick lookup
	existingVariantsMap := make(map[uint]models.ProductVariant)
	for _, variant := range existingVariants {
		existingVariantsMap[variant.ID] = variant
	}

	// Map incoming variant IDs to track which ones are still present
	incomingVariantIDs := make(map[uint]bool)

	// Process incoming variants (update or create)
	for i := range input.Variants {
		variant := &input.Variants[i]  // Use pointer to modify in place
		variant.ProductID = product.ID // Ensure ProductID is set

		if variant.ID != 0 { // If variant has an ID, check if it exists
			if _, exists := existingVariantsMap[variant.ID]; exists {
				// Variant exists, update it
				// 获取原始变体数据
				existingVariant := existingVariantsMap[variant.ID]

				// 保留原始的创建时间
				variant.CreatedAt = existingVariant.CreatedAt

				// 确保所有必要字段都有值
				if variant.SKU == "" {
					variant.SKU = existingVariant.SKU
				}

				// 使用Updates而不是Save，只更新非零值字段
				if err := tx.Model(&existingVariant).Updates(variant).Error; err != nil {
					tx.Rollback()
					log.Error("更新商品变体失败",
						logger.F("product_id", product.ID),
						logger.F("variant_id", variant.ID),
						logger.F("error", err.Error()))
					appErr := errors.New(errors.ErrDatabaseUpdate).
						WithDetails("更新商品变体失败").
						WithError(err).
						WithRequestID(c.GetString("request_id"))
					c.Error(appErr)
					return
				}
				incomingVariantIDs[variant.ID] = true // Mark as processed
			} else {
				// Variant has an ID but doesn't exist (shouldn't happen if frontend sends correct data, but handle defensively)
				// Treat as new variant
				variant.ID = 0 // Reset ID to let GORM create a new one
				if err := tx.Create(variant).Error; err != nil {
					tx.Rollback()
					log.Error("创建商品变体失败 (ID不存在)",
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
				incomingVariantIDs[variant.ID] = true // Mark as processed with new ID
			}
		} else {
			// New variant (no ID provided)
			if err := tx.Create(variant).Error; err != nil {
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
			incomingVariantIDs[variant.ID] = true // Mark as processed with new ID
		}
	}

	// Delete variants that are no longer in the input
	for variantID, existingVariant := range existingVariantsMap {
		if _, exists := incomingVariantIDs[variantID]; !exists {
			// Variant exists in DB but not in incoming list, delete it
			if err := tx.Delete(&existingVariant).Error; err != nil {
				tx.Rollback()
				log.Error("删除商品变体失败",
					logger.F("product_id", product.ID),
					logger.F("variant_id", variantID),
					logger.F("error", err.Error()))
				appErr := errors.New(errors.ErrDatabaseDelete).
					WithDetails("删除商品变体失败").
					WithError(err).
					WithRequestID(c.GetString("request_id"))
				c.Error(appErr)
				return
			}
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

// ListDeletedProducts 获取已删除的商品列表
func (pc *ProductController) ListDeletedProducts(c *gin.Context) {
	// 创建请求日志
	log := logger.WithContext(c)
	log.Info("获取已删除商品列表")

	// 获取查询参数
	name := c.Query("name")
	sku := c.Query("sku")
	category := c.Query("category")
	categoryID := c.Query("category_id") // 添加对category_id参数的支持
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("pageSize", "10"))

	// 记录查询参数
	log = log.WithFields(
		logger.F("name", name),
		logger.F("sku", sku),
		logger.F("category", category),
		logger.F("category_id", categoryID),
		logger.F("page", page),
		logger.F("pageSize", pageSize),
	)

	// 构建查询 - 使用Unscoped()来包含已删除的记录
	query := pc.db.Unscoped().Model(&models.Product{}).Where("deleted_at IS NOT NULL")

	// 添加过滤条件
	if name != "" {
		query = query.Where("name LIKE ?", "%"+name+"%")
	}
	if sku != "" {
		query = query.Where("sku LIKE ?", "%"+sku+"%")
	}
	// 优先使用category_id参数，如果没有再使用category参数
	if categoryID != "" {
		query = query.Where("category_id = ?", categoryID)
	} else if category != "" {
		query = query.Where("category_id = ?", category)
	}

	// 计算总数
	var total int64
	if err := query.Count(&total).Error; err != nil {
		log.Error("获取已删除商品总数失败", logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrDatabaseQuery).
			WithDetails("获取已删除商品总数失败").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	// 分页查询
	offset := (page - 1) * pageSize
	var products []models.Product
	// 使用Preload预加载关联数据
	if err := query.Preload("Category").Preload("Brand").Offset(offset).Limit(pageSize).Order("deleted_at DESC").Find(&products).Error; err != nil {
		log.Error("获取已删除商品列表失败", logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrDatabaseQuery).
			WithDetails("获取已删除商品列表失败").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	log.Info("获取已删除商品列表成功",
		logger.F("total", total),
		logger.F("count", len(products)))

	c.JSON(http.StatusOK, gin.H{
		"items":    products,
		"total":    total,
		"page":     page,
		"pageSize": pageSize,
	})
}

// RestoreProduct 恢复已删除的商品
func (pc *ProductController) RestoreProduct(c *gin.Context) {
	// 创建请求日志
	log := logger.WithContext(c)

	id := c.Param("id")
	log.Info("恢复已删除商品", logger.F("product_id", id))

	// 检查商品是否存在且已被删除
	var product models.Product
	if err := pc.db.Unscoped().Where("id = ? AND deleted_at IS NOT NULL", id).First(&product).Error; err != nil {
		log.Warn("已删除商品不存在", logger.F("product_id", id), logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrNotFound).
			WithDetails("已删除商品不存在").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	// 检查SKU是否已被其他商品使用
	var existingProduct models.Product
	if err := pc.db.Where("sku = ? AND id != ?", product.SKU, id).First(&existingProduct).Error; err == nil {
		log.Warn("SKU已被其他商品使用",
			logger.F("sku", product.SKU),
			logger.F("existing_product_id", existingProduct.ID))
		appErr := errors.New(errors.ErrConflict).
			WithDetails("商品SKU已被其他商品使用，无法恢复").
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	// 开始事务
	tx := pc.db.Begin()

	// 恢复商品
	if err := tx.Unscoped().Model(&models.Product{}).Where("id = ?", id).Update("deleted_at", nil).Error; err != nil {
		tx.Rollback()
		log.Error("恢复商品失败",
			logger.F("product_id", id),
			logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrDatabaseUpdate).
			WithDetails("恢复商品失败").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	// 恢复商品变体
	if err := tx.Unscoped().Model(&models.ProductVariant{}).Where("product_id = ?", id).Update("deleted_at", nil).Error; err != nil {
		tx.Rollback()
		log.Error("恢复商品变体失败",
			logger.F("product_id", id),
			logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrDatabaseUpdate).
			WithDetails("恢复商品变体失败").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
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

	log.Info("恢复商品成功",
		logger.F("product_id", id),
		logger.F("sku", product.SKU))

	c.JSON(http.StatusOK, gin.H{"message": "商品恢复成功"})
}
