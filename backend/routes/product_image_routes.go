package routes

import (
	"hd_psi/backend/controllers"
	"hd_psi/backend/middleware"

	"github.com/kataras/iris/v12"
	"gorm.io/gorm"
)

// SetupProductImageRoutes 设置商品图片管理相关路由
func SetupProductImageRoutes(app *iris.Application, db *gorm.DB) {
	productImageController := controllers.NewProductImageController(db)

	// 获取API基础路径
	apiBasePath := "/api/v1"
	api := app.Party(apiBasePath)

	// 需要认证的路由
	apiAuth := api.Party("/")
	apiAuth.Use(middleware.JWTAuth())

	// 商品图片管理路由组
	productImages := apiAuth.Party("/products/{product_id:uint}/images")
	{
		// 获取商品图片列表
		productImages.Get("", productImageController.GetProductImages)

		// 上传单张商品图片
		productImages.Post("", productImageController.UploadProductImage)

		// 批量上传商品图片
		productImages.Post("/batch", productImageController.BatchUploadProductImages)

		// 更新图片排序
		productImages.Put("/{image_id:uint}/sort", productImageController.UpdateProductImageSort)

		// 删除商品图片
		productImages.Delete("/{image_id:uint}", productImageController.DeleteProductImage)
	}
}