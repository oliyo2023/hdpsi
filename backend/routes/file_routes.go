package routes

import (
	"hd_psi/backend/controllers"

	"github.com/kataras/iris/v12"
)

// SetupFileRoutes 设置文件上传相关路由
func SetupFileRoutes(app *iris.Application) {
	fileController := controllers.NewFileController()

	// 文件上传路由组
	upload := app.Party("/api/upload")
	{
		// 图片上传
		upload.Post("/image", fileController.UploadImage)

		// 富文本编辑器图片上传
		upload.Post("/editor/image", fileController.UploadEditorImage)
	}
}
