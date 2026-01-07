package controllers

import (
	"fmt"
	"hd_psi/backend/models"
	"hd_psi/backend/utils"
	"hd_psi/backend/utils/logger"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"strconv"
	"time"

	"github.com/kataras/iris/v12"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

// ProductImageController 商品图片控制器
type ProductImageController struct {
	db        *gorm.DB
	uploadDir string
}

// NewProductImageController 创建商品图片控制器
func NewProductImageController(db *gorm.DB) *ProductImageController {
	// 确保上传目录存在
	uploadDir := "public/uploads/products"
	if err := os.MkdirAll(uploadDir, 0755); err != nil {
		panic(fmt.Sprintf("无法创建商品图片上传目录: %v", err))
	}

	return &ProductImageController{
		db:        db,
		uploadDir: uploadDir,
	}
}

// UploadProductImage 上传商品图片
// @Summary 上传商品图片
// @Description 为指定商品上传图片，支持多张图片上传
// @Tags 商品图片管理
// @Accept multipart/form-data
// @Produce json
// @Param product_id path int true "商品ID"
// @Param file formData file true "图片文件"
// @Param sort formData int false "排序顺序，默认为0"
// @Success 200 {object} models.ProductImage "上传成功"
// @Failure 400 {object} models.ErrorResponse "请求参数错误"
// @Failure 404 {object} models.ErrorResponse "商品不存在"
// @Failure 500 {object} models.ErrorResponse "服务器内部错误"
// @Router /products/{product_id}/images [post]
// @Security BearerAuth
func (pic *ProductImageController) UploadProductImage(ctx iris.Context) {
	log := logger.WithContext(ctx)
	log.Info("上传商品图片")

	// 获取商品ID
	productIDStr := ctx.Params().Get("product_id")
	productID, err := strconv.ParseUint(productIDStr, 10, 32)
	if err != nil {
		ctx.StatusCode(http.StatusBadRequest)
		ctx.JSON(iris.Map{"error": "无效的商品ID"})
		return
	}

	// 检查商品是否存在
	var product models.Product
	if err := pic.db.First(&product, productID).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			ctx.StatusCode(http.StatusNotFound)
			ctx.JSON(iris.Map{"error": "商品不存在"})
		} else {
			log.Error("查询商品失败", logger.F("error", err.Error()))
			ctx.StatusCode(http.StatusInternalServerError)
			ctx.JSON(iris.Map{"error": "查询商品失败"})
		}
		return
	}

	// 获取上传的文件
	file, header, err := ctx.FormFile("file")
	if err != nil {
		ctx.StatusCode(http.StatusBadRequest)
		ctx.JSON(iris.Map{"error": "无法获取上传的文件"})
		return
	}
	defer file.Close()

	// 检查文件类型
	contentType := header.Header.Get("Content-Type")
	if !utils.IsAllowedImageType(contentType) {
		ctx.StatusCode(http.StatusBadRequest)
		ctx.JSON(iris.Map{"error": "不支持的文件类型，仅支持 jpg、png、gif 和 webp 格式"})
		return
	}

	// 检查文件大小
	if header.Size > 10*1024*1024 { // 10MB
		ctx.StatusCode(http.StatusBadRequest)
		ctx.JSON(iris.Map{"error": "文件过大，最大支持 10MB"})
		return
	}

	// 获取排序参数
	sort := 0
	if sortStr := ctx.PostValue("sort"); sortStr != "" {
		if s, err := strconv.Atoi(sortStr); err == nil {
			sort = s
		}
	}

	// 创建年月日目录结构
	now := time.Now()
	datePath := fmt.Sprintf("%d/%02d/%02d", now.Year(), now.Month(), now.Day())
	uploadPath := filepath.Join(pic.uploadDir, datePath)
	if err := os.MkdirAll(uploadPath, 0755); err != nil {
		log.Error("创建上传目录失败", logger.F("error", err.Error()))
		ctx.StatusCode(http.StatusInternalServerError)
		ctx.JSON(iris.Map{"error": "创建上传目录失败"})
		return
	}

	// 生成唯一文件名
	fileExt := filepath.Ext(header.Filename)
	fileName := uuid.New().String() + fileExt
	filePath := filepath.Join(uploadPath, fileName)

	// 创建目标文件
	dst, err := os.Create(filePath)
	if err != nil {
		log.Error("创建文件失败", logger.F("error", err.Error()))
		ctx.StatusCode(http.StatusInternalServerError)
		ctx.JSON(iris.Map{"error": "创建文件失败"})
		return
	}
	defer dst.Close()

	// 复制文件内容
	if _, err = io.Copy(dst, file); err != nil {
		log.Error("保存文件失败", logger.F("error", err.Error()))
		ctx.StatusCode(http.StatusInternalServerError)
		ctx.JSON(iris.Map{"error": "保存文件失败"})
		return
	}

	// 生成文件URL
	fileURL := fmt.Sprintf("/uploads/products/%s/%s", datePath, fileName)

	// 保存到数据库
	productImage := models.ProductImage{
		ProductID: uint(productID),
		URL:       fileURL,
		Sort:      sort,
	}

	if err := pic.db.Create(&productImage).Error; err != nil {
		log.Error("保存图片记录失败", logger.F("error", err.Error()))
		// 删除已上传的文件
		os.Remove(filePath)
		ctx.StatusCode(http.StatusInternalServerError)
		ctx.JSON(iris.Map{"error": "保存图片记录失败"})
		return
	}

	log.Info("商品图片上传成功", logger.F("product_id", productID), logger.F("image_id", productImage.ID))
	ctx.StatusCode(http.StatusOK)
	ctx.JSON(productImage)
}

// GetProductImages 获取商品图片列表
// @Summary 获取商品图片列表
// @Description 获取指定商品的所有图片，按排序顺序返回
// @Tags 商品图片管理
// @Accept json
// @Produce json
// @Param product_id path int true "商品ID"
// @Success 200 {array} models.ProductImage "获取成功"
// @Failure 400 {object} models.ErrorResponse "请求参数错误"
// @Failure 404 {object} models.ErrorResponse "商品不存在"
// @Failure 500 {object} models.ErrorResponse "服务器内部错误"
// @Router /products/{product_id}/images [get]
// @Security BearerAuth
func (pic *ProductImageController) GetProductImages(ctx iris.Context) {
	log := logger.WithContext(ctx)
	log.Info("获取商品图片列表")

	// 获取商品ID
	productIDStr := ctx.Params().Get("product_id")
	productID, err := strconv.ParseUint(productIDStr, 10, 32)
	if err != nil {
		ctx.StatusCode(http.StatusBadRequest)
		ctx.JSON(iris.Map{"error": "无效的商品ID"})
		return
	}

	// 检查商品是否存在
	var product models.Product
	if err := pic.db.First(&product, productID).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			ctx.StatusCode(http.StatusNotFound)
			ctx.JSON(iris.Map{"error": "商品不存在"})
		} else {
			log.Error("查询商品失败", logger.F("error", err.Error()))
			ctx.StatusCode(http.StatusInternalServerError)
			ctx.JSON(iris.Map{"error": "查询商品失败"})
		}
		return
	}

	// 获取商品图片列表
	var images []models.ProductImage
	if err := pic.db.Where("product_id = ?", productID).Order("sort ASC, created_at ASC").Find(&images).Error; err != nil {
		log.Error("获取商品图片失败", logger.F("error", err.Error()))
		ctx.StatusCode(http.StatusInternalServerError)
		ctx.JSON(iris.Map{"error": "获取商品图片失败"})
		return
	}

	log.Info("获取商品图片成功", logger.F("product_id", productID), logger.F("count", len(images)))
	ctx.StatusCode(http.StatusOK)
	ctx.JSON(images)
}

// UpdateProductImageSort 更新商品图片排序
// @Summary 更新商品图片排序
// @Description 更新指定商品图片的排序顺序
// @Tags 商品图片管理
// @Accept json
// @Produce json
// @Param product_id path int true "商品ID"
// @Param image_id path int true "图片ID"
// @Param sort body object{sort=int} true "排序信息"
// @Success 200 {object} models.ProductImage "更新成功"
// @Failure 400 {object} models.ErrorResponse "请求参数错误"
// @Failure 404 {object} models.ErrorResponse "图片不存在"
// @Failure 500 {object} models.ErrorResponse "服务器内部错误"
// @Router /products/{product_id}/images/{image_id}/sort [put]
// @Security BearerAuth
func (pic *ProductImageController) UpdateProductImageSort(ctx iris.Context) {
	log := logger.WithContext(ctx)
	log.Info("更新商品图片排序")

	// 获取参数
	productIDStr := ctx.Params().Get("product_id")
	imageIDStr := ctx.Params().Get("image_id")

	productID, err := strconv.ParseUint(productIDStr, 10, 32)
	if err != nil {
		ctx.StatusCode(http.StatusBadRequest)
		ctx.JSON(iris.Map{"error": "无效的商品ID"})
		return
	}

	imageID, err := strconv.ParseUint(imageIDStr, 10, 32)
	if err != nil {
		ctx.StatusCode(http.StatusBadRequest)
		ctx.JSON(iris.Map{"error": "无效的图片ID"})
		return
	}

	// 解析请求体
	var req struct {
		Sort int `json:"sort"`
	}
	if err := ctx.ReadJSON(&req); err != nil {
		ctx.StatusCode(http.StatusBadRequest)
		ctx.JSON(iris.Map{"error": "请求参数错误: " + err.Error()})
		return
	}

	// 查找图片记录
	var image models.ProductImage
	if err := pic.db.Where("id = ? AND product_id = ?", imageID, productID).First(&image).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			ctx.StatusCode(http.StatusNotFound)
			ctx.JSON(iris.Map{"error": "图片不存在"})
		} else {
			log.Error("查询图片失败", logger.F("error", err.Error()))
			ctx.StatusCode(http.StatusInternalServerError)
			ctx.JSON(iris.Map{"error": "查询图片失败"})
		}
		return
	}

	// 更新排序
	image.Sort = req.Sort
	if err := pic.db.Save(&image).Error; err != nil {
		log.Error("更新图片排序失败", logger.F("error", err.Error()))
		ctx.StatusCode(http.StatusInternalServerError)
		ctx.JSON(iris.Map{"error": "更新图片排序失败"})
		return
	}

	log.Info("更新商品图片排序成功", logger.F("image_id", imageID), logger.F("sort", req.Sort))
	ctx.StatusCode(http.StatusOK)
	ctx.JSON(image)
}

// DeleteProductImage 删除商品图片
// @Summary 删除商品图片
// @Description 删除指定的商品图片，同时删除文件系统中的图片文件
// @Tags 商品图片管理
// @Accept json
// @Produce json
// @Param product_id path int true "商品ID"
// @Param image_id path int true "图片ID"
// @Success 200 {object} object{message=string} "删除成功"
// @Failure 400 {object} models.ErrorResponse "请求参数错误"
// @Failure 404 {object} models.ErrorResponse "图片不存在"
// @Failure 500 {object} models.ErrorResponse "服务器内部错误"
// @Router /products/{product_id}/images/{image_id} [delete]
// @Security BearerAuth
func (pic *ProductImageController) DeleteProductImage(ctx iris.Context) {
	log := logger.WithContext(ctx)
	log.Info("删除商品图片")

	// 获取参数
	productIDStr := ctx.Params().Get("product_id")
	imageIDStr := ctx.Params().Get("image_id")

	productID, err := strconv.ParseUint(productIDStr, 10, 32)
	if err != nil {
		ctx.StatusCode(http.StatusBadRequest)
		ctx.JSON(iris.Map{"error": "无效的商品ID"})
		return
	}

	imageID, err := strconv.ParseUint(imageIDStr, 10, 32)
	if err != nil {
		ctx.StatusCode(http.StatusBadRequest)
		ctx.JSON(iris.Map{"error": "无效的图片ID"})
		return
	}

	// 查找图片记录
	var image models.ProductImage
	if err := pic.db.Where("id = ? AND product_id = ?", imageID, productID).First(&image).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			ctx.StatusCode(http.StatusNotFound)
			ctx.JSON(iris.Map{"error": "图片不存在"})
		} else {
			log.Error("查询图片失败", logger.F("error", err.Error()))
			ctx.StatusCode(http.StatusInternalServerError)
			ctx.JSON(iris.Map{"error": "查询图片失败"})
		}
		return
	}

	// 删除数据库记录
	if err := pic.db.Delete(&image).Error; err != nil {
		log.Error("删除图片记录失败", logger.F("error", err.Error()))
		ctx.StatusCode(http.StatusInternalServerError)
		ctx.JSON(iris.Map{"error": "删除图片记录失败"})
		return
	}

	// 删除文件系统中的文件
	if image.URL != "" {
		// 构建文件路径
		filePath := filepath.Join("public", image.URL)
		if err := os.Remove(filePath); err != nil {
			log.Warn("删除图片文件失败", logger.F("file_path", filePath), logger.F("error", err.Error()))
			// 文件删除失败不影响数据库记录的删除
		}
	}

	log.Info("删除商品图片成功", logger.F("image_id", imageID))
	ctx.StatusCode(http.StatusOK)
	ctx.JSON(iris.Map{"message": "图片删除成功"})
}

// BatchUploadProductImages 批量上传商品图片
// @Summary 批量上传商品图片
// @Description 为指定商品批量上传多张图片
// @Tags 商品图片管理
// @Accept multipart/form-data
// @Produce json
// @Param product_id path int true "商品ID"
// @Param files formData file true "图片文件（可多选）"
// @Success 200 {array} models.ProductImage "上传成功"
// @Failure 400 {object} models.ErrorResponse "请求参数错误"
// @Failure 404 {object} models.ErrorResponse "商品不存在"
// @Failure 500 {object} models.ErrorResponse "服务器内部错误"
// @Router /products/{product_id}/images/batch [post]
// @Security BearerAuth
func (pic *ProductImageController) BatchUploadProductImages(ctx iris.Context) {
	log := logger.WithContext(ctx)
	log.Info("批量上传商品图片")

	// 获取商品ID
	productIDStr := ctx.Params().Get("product_id")
	productID, err := strconv.ParseUint(productIDStr, 10, 32)
	if err != nil {
		ctx.StatusCode(http.StatusBadRequest)
		ctx.JSON(iris.Map{"error": "无效的商品ID"})
		return
	}

	// 检查商品是否存在
	var product models.Product
	if err := pic.db.First(&product, productID).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			ctx.StatusCode(http.StatusNotFound)
			ctx.JSON(iris.Map{"error": "商品不存在"})
		} else {
			log.Error("查询商品失败", logger.F("error", err.Error()))
			ctx.StatusCode(http.StatusInternalServerError)
			ctx.JSON(iris.Map{"error": "查询商品失败"})
		}
		return
	}

	// Get all files with name "files"
	files, _, err := ctx.UploadFormFiles("files")
	if err != nil {
		ctx.StatusCode(http.StatusBadRequest)
		ctx.JSON(iris.Map{"error": "解析上传文件失败"})
		return
	}

	if len(files) == 0 {
		ctx.StatusCode(http.StatusBadRequest)
		ctx.JSON(iris.Map{"error": "没有选择文件"})
		return
	}

	// Limit batch upload count
	if len(files) > 10 {
		ctx.StatusCode(http.StatusBadRequest)
		ctx.JSON(iris.Map{"error": "一次最多上传10张图片"})
		return
	}

	// Create date directory structure
	now := time.Now()
	datePath := fmt.Sprintf("%d/%02d/%02d", now.Year(), now.Month(), now.Day())
	uploadPath := filepath.Join(pic.uploadDir, datePath)
	if err := os.MkdirAll(uploadPath, 0755); err != nil {
		log.Error("创建上传目录失败", logger.F("error", err.Error()))
		ctx.StatusCode(http.StatusInternalServerError)
		ctx.JSON(iris.Map{"error": "创建上传目录失败"})
		return
	}

	var uploadedImages []models.ProductImage
	var errorList []string

	// Process each file
	for i, fileHeader := range files {
		// Check file type
		contentType := fileHeader.Header.Get("Content-Type")
		if !utils.IsAllowedImageType(contentType) {
			errorList = append(errorList, fmt.Sprintf("文件 %s: 不支持的文件类型", fileHeader.Filename))
			continue
		}

		// Open file
		file, err := fileHeader.Open()
		if err != nil {
			errorList = append(errorList, fmt.Sprintf("文件 %s: 打开文件失败", fileHeader.Filename))
			continue
		}
		defer file.Close()

		// Generate unique filename
		fileExt := filepath.Ext(fileHeader.Filename)
		fileName := uuid.New().String() + fileExt
		filePath := filepath.Join(uploadPath, fileName)

		// Create destination file
		dst, err := os.Create(filePath)
		if err != nil {
			errorList = append(errorList, fmt.Sprintf("文件 %s: 创建文件失败", fileHeader.Filename))
			continue
		}
		defer dst.Close()

		// Copy file content
		if _, err = io.Copy(dst, file); err != nil {
			errorList = append(errorList, fmt.Sprintf("文件 %s: 保存文件失败", fileHeader.Filename))
			os.Remove(filePath) // Clean up failed file
			continue
		}

		// Generate file URL
		fileURL := fmt.Sprintf("/uploads/products/%s/%s", datePath, fileName)

		// Save to database
		productImage := models.ProductImage{
			ProductID: uint(productID),
			URL:       fileURL,
			Sort:      i, // Use file order as sort
		}

		if err := pic.db.Create(&productImage).Error; err != nil {
			errorList = append(errorList, fmt.Sprintf("文件 %s: 保存图片记录失败", fileHeader.Filename))
			os.Remove(filePath) // Clean up failed file
			continue
		}

		uploadedImages = append(uploadedImages, productImage)
	}

	log.Info("批量上传商品图片完成",
		logger.F("product_id", productID),
		logger.F("success_count", len(uploadedImages)),
		logger.F("error_count", len(errorList)))

	// Return result
	result := iris.Map{
		"uploaded_images": uploadedImages,
		"success_count":   len(uploadedImages),
		"error_count":     len(errorList),
	}

	if len(errorList) > 0 {
		result["errors"] = errorList
	}

	ctx.StatusCode(http.StatusOK)
	ctx.JSON(result)
}