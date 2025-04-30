package routes

import (
	"hd_psi/backend/controllers"

	"github.com/gin-gonic/gin"
)

// SetupFileRoutes 设置文件上传相关路由
func SetupFileRoutes(router *gin.Engine) {
	fileController := controllers.NewFileController()

	// 文件上传路由组
	upload := router.Group("/api/upload")
	{
		// 图片上传
		upload.POST("/image", fileController.UploadImage)

		// 富文本编辑器图片上传
		upload.POST("/editor/image", fileController.UploadEditorImage)
	}
}
