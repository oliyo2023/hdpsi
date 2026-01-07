package controllers

import (
	"fmt"
	"hd_psi/backend/utils"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"time"

	"github.com/kataras/iris/v12"
	"github.com/google/uuid"
)

// FileController 处理文件上传相关的请求
type FileController struct {
	UploadDir string
}

// NewFileController 创建一个新的文件控制器
func NewFileController() *FileController {
	// 确保上传目录存在
	uploadDir := "public/uploads"
	if err := os.MkdirAll(uploadDir, 0755); err != nil {
		panic(fmt.Sprintf("无法创建上传目录: %v", err))
	}

	return &FileController{
		UploadDir: uploadDir,
	}
}

// UploadImage 处理图片上传
func (c *FileController) UploadImage(ctx iris.Context) {
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
	if header.Size > 5*1024*1024 { // 5MB
		ctx.StatusCode(http.StatusBadRequest)
		ctx.JSON(iris.Map{"error": "文件过大，最大支持 5MB"})
		return
	}

	// 创建年月日目录结构
	now := time.Now()
	datePath := fmt.Sprintf("%d/%02d/%02d", now.Year(), now.Month(), now.Day())
	uploadPath := filepath.Join(c.UploadDir, "images", datePath)
	if err := os.MkdirAll(uploadPath, 0755); err != nil {
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
		ctx.StatusCode(http.StatusInternalServerError)
		ctx.JSON(iris.Map{"error": "创建文件失败"})
		return
	}
	defer dst.Close()

	// 复制文件内容
	if _, err = io.Copy(dst, file); err != nil {
		ctx.StatusCode(http.StatusInternalServerError)
		ctx.JSON(iris.Map{"error": "保存文件失败"})
		return
	}

	// 返回文件URL
	fileURL := fmt.Sprintf("/uploads/images/%s/%s", datePath, fileName)
	ctx.StatusCode(http.StatusOK)
	ctx.JSON(iris.Map{
		"url":      fileURL,
		"fileName": header.Filename,
		"size":     header.Size,
	})
}

// UploadEditorImage 处理富文本编辑器的图片上传
func (c *FileController) UploadEditorImage(ctx iris.Context) {
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
	if header.Size > 5*1024*1024 { // 5MB
		ctx.StatusCode(http.StatusBadRequest)
		ctx.JSON(iris.Map{"error": "文件过大，最大支持 5MB"})
		return
	}

	// 创建年月日目录结构
	now := time.Now()
	datePath := fmt.Sprintf("%d/%02d/%02d", now.Year(), now.Month(), now.Day())
	uploadPath := filepath.Join(c.UploadDir, "editor", datePath)
	if err := os.MkdirAll(uploadPath, 0755); err != nil {
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
		ctx.StatusCode(http.StatusInternalServerError)
		ctx.JSON(iris.Map{"error": "创建文件失败"})
		return
	}
	defer dst.Close()

	// 复制文件内容
	if _, err = io.Copy(dst, file); err != nil {
		ctx.StatusCode(http.StatusInternalServerError)
		ctx.JSON(iris.Map{"error": "保存文件失败"})
		return
	}

	// 返回文件URL (适配AiEditor格式)
	fileURL := fmt.Sprintf("/uploads/editor/%s/%s", datePath, fileName)
	ctx.StatusCode(http.StatusOK)
	ctx.JSON(iris.Map{
		"errno": 0,
		"data": iris.Map{
			"url": fileURL,
		},
	})
}