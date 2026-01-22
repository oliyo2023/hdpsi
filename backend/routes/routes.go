package routes

import (
	"hd_psi/backend/config"
	"hd_psi/backend/controllers"
	"hd_psi/backend/middleware"
	"hd_psi/backend/services"

	"github.com/kataras/iris/v12"
	"gorm.io/gorm"
)

// RegisterRoutes 注册所有路由
func RegisterRoutes(app *iris.Application, db *gorm.DB) {
	// 添加API版本中间件
	app.Use(middleware.APIVersionMiddleware())
	app.Use(middleware.APIVersionHeaderMiddleware())

	// 添加API弃用中间件（如果有弃用的版本）
	// app.Use(middleware.APIDeprecationMiddleware([]string{"v0"}))

	// 认证路由 - 不需要认证
	authController := controllers.NewAuthController(db)
	wechatLoginController := controllers.NewWechatLoginController(db)
	// 认证路由
	app.Post("/auth/login", authController.Login)
	app.Post("/auth/register", authController.Register)

	// 系统设置路由 - 公开访问
	systemSettingController := controllers.NewSystemSettingController(db)
	app.Get("/api/settings/theme", systemSettingController.GetUserTheme)

	// 微信公众号事件接收路由 - 不需要认证
	wechatController := controllers.NewWechatController(db)
	app.Post("/wechat/event", wechatController.HandleWechatEvent)

	// 获取API基础路径
	apiBasePath := config.GetAPIBasePath()

	// API路由组 - 使用版本前缀
	api := app.Party(apiBasePath)

	// 添加CORS头到所有响应
	api.Use(func(ctx iris.Context) {
		origin := ctx.GetHeader("Origin")
		ctx.Header("Access-Control-Allow-Origin", origin)
		ctx.Header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS, PATCH")
		ctx.Header("Access-Control-Allow-Headers", "Origin, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")
		ctx.Header("Access-Control-Max-Age", "86400")
		ctx.Header("Access-Control-Allow-Credentials", "true")

		if ctx.Method() == "OPTIONS" {
			ctx.StatusCode(204)
			return
		}

		ctx.Next()
	})

	// 认证API路由
	authGroup := api.Party("/auth")

	authGroup.Post("/login", authController.Login)
	authGroup.Post("/register", authController.Register)
	authGroup.Post("/refresh-token", authController.RefreshToken)
	authGroup.Post("/wechat/login", wechatLoginController.Login)

	// 字典管理路由 - 不需要认证
	dictionaryController := controllers.NewDictionaryController(db)
	dictGroup := api.Party("/dictionaries")
	{
		// 字典类型路由
		dictGroup.Get("", dictionaryController.ListDictionaries)
		dictGroup.Get("/{code:string}", dictionaryController.GetDictionary)
		dictGroup.Post("", dictionaryController.CreateDictionary)
		dictGroup.Put("/{code:string}", dictionaryController.UpdateDictionary)
		dictGroup.Delete("/{code:string}", dictionaryController.DeleteDictionary)

		// 字典项路由
		dictGroup.Get("/{code:string}/items", dictionaryController.ListDictionaryItems)
		dictGroup.Get("/{code:string}/items/{itemId:uint}", dictionaryController.GetDictionaryItem)
		dictGroup.Post("/{code:string}/items", dictionaryController.CreateDictionaryItem)
		dictGroup.Put("/{code:string}/items/{itemId:uint}", dictionaryController.UpdateDictionaryItem)
		dictGroup.Delete("/{code:string}/items/{itemId:uint}", dictionaryController.DeleteDictionaryItem)
	}

	// 需要认证的路由
	apiAuth := api.Party("/")
	apiAuth.Use(middleware.JWTAuth())
	{
		// 仪表盘路由
		dashboardController := controllers.NewDashboardController(db)
		apiAuth.Get("/dashboard/statistics", dashboardController.GetStatistics)
		// 用户信息路由
		apiAuth.Get("/profile", authController.GetProfile)
		apiAuth.Put("/profile", authController.UpdateProfile)
		apiAuth.Put("/change-password", authController.ChangePassword)

		// 系统设置路由
		apiAuth.Get("/settings", systemSettingController.GetSettings)
		apiAuth.Put("/settings", middleware.RoleAuth("admin"), systemSettingController.UpdateSettings)
		apiAuth.Put("/settings/theme", systemSettingController.UpdateUserTheme)

		// 商品管理路由
		productController := controllers.NewProductController(db)
		productGroup := apiAuth.Party("/products")
		{
			productGroup.Get("", productController.ListProducts)
			productGroup.Get("/{id:uint}", productController.GetProduct)
			productGroup.Post("", middleware.RoleAuth("admin", "manager"), productController.CreateProduct)
			productGroup.Put("/{id:uint}", middleware.RoleAuth("admin", "manager"), productController.UpdateProduct)
			productGroup.Delete("/{id:uint}", middleware.RoleAuth("admin", "manager"), productController.DeleteProduct)

			// 已删除商品管理路由
			productGroup.Get("/deleted/list", middleware.RoleAuth("admin"), productController.ListDeletedProducts)
			productGroup.Post("/deleted/{id:uint}/restore", middleware.RoleAuth("admin"), productController.RestoreProduct)
		}

		// 库存管理路由
		inventoryController := controllers.NewInventoryController(db)
		inventoryGroup := apiAuth.Party("/inventory")
		{
			inventoryGroup.Get("", inventoryController.ListInventories)
			inventoryGroup.Get("/{id:uint}", inventoryController.GetInventory)
			inventoryGroup.Post("", middleware.RoleAuth("admin", "manager"), inventoryController.CreateInventory)
			inventoryGroup.Put("/{id:uint}", middleware.RoleAuth("admin", "manager"), inventoryController.UpdateInventory)
			inventoryGroup.Delete("/{id:uint}", middleware.RoleAuth("admin", "manager"), inventoryController.DeleteInventory)
		}

		// 供应商管理路由
		supplierController := controllers.NewSupplierController(db)
		supplierGroup := apiAuth.Party("/suppliers")
		{
			supplierGroup.Get("", supplierController.ListSuppliers)
			supplierGroup.Get("/{id:uint}", supplierController.GetSupplier)
			supplierGroup.Post("", middleware.RoleAuth("admin", "manager"), supplierController.CreateSupplier)
			supplierGroup.Put("/{id:uint}", middleware.RoleAuth("admin", "manager"), supplierController.UpdateSupplier)
			supplierGroup.Delete("/{id:uint}", middleware.RoleAuth("admin", "manager"), supplierController.DeleteSupplier)
		}

		// 采购管理路由
		purchaseController := controllers.NewPurchaseController(db)
		purchaseGroup := apiAuth.Party("/purchases")
		{
			purchaseGroup.Get("", purchaseController.ListPurchaseOrders)
			purchaseGroup.Get("/{id:uint}", purchaseController.GetPurchaseOrder)
			purchaseGroup.Post("", middleware.RoleAuth("admin", "manager"), purchaseController.CreatePurchaseOrder)
			purchaseGroup.Put("/{id:uint}", middleware.RoleAuth("admin", "manager"), purchaseController.UpdatePurchaseOrder)
			purchaseGroup.Put("/{id:uint}/status", middleware.RoleAuth("admin", "manager"), purchaseController.UpdatePurchaseOrderStatus)
			purchaseGroup.Delete("/{id:uint}", middleware.RoleAuth("admin", "manager"), purchaseController.DeletePurchaseOrder)
		}

		// 销售管理路由
		salesOrderController := controllers.NewSalesOrderController(db)
		salesGroup := apiAuth.Party("/sales")
		{
			salesGroup.Get("", salesOrderController.ListSalesOrders)
			salesGroup.Get("/recent", salesOrderController.GetRecentSalesOrders)
			salesGroup.Get("/{id:uint}", salesOrderController.GetSalesOrder)
			salesGroup.Post("", salesOrderController.CreateSalesOrder)
			salesGroup.Put("/{id:uint}", salesOrderController.UpdateSalesOrder)
			salesGroup.Put("/{id:uint}/status", salesOrderController.UpdateSalesOrderStatus)
			salesGroup.Delete("/{id:uint}", middleware.RoleAuth("admin", "manager"), salesOrderController.DeleteSalesOrder)
			salesGroup.Post("/{id:uint}/payments", salesOrderController.AddPayment)
			salesGroup.Get("/statistics", salesOrderController.GetSalesOrderStatistics)
		}

		// 采购入库路由
		purchaseReceivingController := controllers.NewPurchaseReceivingController(db)
		receivingGroup := apiAuth.Party("/purchase-receivings")
		{
			receivingGroup.Get("", purchaseReceivingController.ListPurchaseReceivings)
			receivingGroup.Get("/{id:uint}", purchaseReceivingController.GetPurchaseReceiving)
			receivingGroup.Post("", middleware.RoleAuth("admin", "manager", "staff"), purchaseReceivingController.CreatePurchaseReceiving)
			receivingGroup.Delete("/{id:uint}", middleware.RoleAuth("admin", "manager"), purchaseReceivingController.DeletePurchaseReceiving)
		}

		// 会员管理路由 - 暂时移除权限控制以便于开发
		memberController := controllers.NewMemberController(db)
		memberGroup := apiAuth.Party("/members")
		{
			memberGroup.Get("", memberController.ListMembers)
			memberGroup.Get("/{id:uint}", memberController.GetMember)
			memberGroup.Post("", memberController.CreateMember)
			memberGroup.Put("/{id:uint}", memberController.UpdateMember)
			memberGroup.Delete("/{id:uint}", memberController.DeleteMember)

			// 会员积分路由
			memberPointsController := controllers.NewMemberPointsController(db)
			memberGroup.Get("/{id:uint}/points", memberPointsController.GetMemberPoints)
			memberGroup.Get("/{id:uint}/points/transactions", memberPointsController.ListPointsTransactions)
			memberGroup.Post("/{id:uint}/points/add", memberPointsController.AddPoints)
			memberGroup.Post("/{id:uint}/points/deduct", memberPointsController.DeductPoints)
			memberGroup.Post("/{id:uint}/level/calculate", memberPointsController.CalculateMemberLevel)
		}

		// 店铺管理路由
		storeController := controllers.NewStoreController(db)
		storeGroup := apiAuth.Party("/stores")
		{
			storeGroup.Get("", storeController.ListStores)
			storeGroup.Get("/{id:uint}", storeController.GetStore)
			storeGroup.Post("", middleware.RoleAuth("admin"), storeController.CreateStore)
			storeGroup.Put("/{id:uint}", middleware.RoleAuth("admin"), storeController.UpdateStore)
			storeGroup.Delete("/{id:uint}", middleware.RoleAuth("admin"), storeController.DeleteStore)
		}

		// 库存交易路由
		inventoryTransactionController := controllers.NewInventoryTransactionController(db)
		transactionGroup := apiAuth.Party("/inventory-transactions")
		{
			transactionGroup.Get("", inventoryTransactionController.ListTransactions)
			transactionGroup.Get("/{id:uint}", inventoryTransactionController.GetTransaction)
			transactionGroup.Post("", middleware.RoleAuth("admin", "manager", "staff"), inventoryTransactionController.CreateTransaction)
			transactionGroup.Get("/store/{storeId:uint}", inventoryTransactionController.GetStoreTransactions)
			transactionGroup.Get("/product/{productId:uint}", inventoryTransactionController.GetProductTransactions)
		}

		// 库存预警路由
		inventoryAlertController := controllers.NewInventoryAlertController(db)
		alertGroup := apiAuth.Party("/inventory-alerts")
		{
			alertGroup.Get("", inventoryAlertController.ListAlerts)
			alertGroup.Get("/{id:uint}", inventoryAlertController.GetAlert)
			alertGroup.Put("/{id:uint}/status", middleware.RoleAuth("admin", "manager"), inventoryAlertController.UpdateAlertStatus)
			alertGroup.Post("/check", inventoryAlertController.CheckInventoryLevels)
		}

		// 库存阈值路由
		inventoryThresholdController := controllers.NewInventoryThresholdController(db)
		thresholdGroup := apiAuth.Party("/inventory-thresholds")
		{
			thresholdGroup.Get("", inventoryThresholdController.ListThresholds)
			thresholdGroup.Get("/{id:uint}", inventoryThresholdController.GetThreshold)
			thresholdGroup.Post("", middleware.RoleAuth("admin", "manager"), inventoryThresholdController.CreateThreshold)
			thresholdGroup.Put("/{id:uint}", middleware.RoleAuth("admin", "manager"), inventoryThresholdController.UpdateThreshold)
			thresholdGroup.Delete("/{id:uint}", middleware.RoleAuth("admin", "manager"), inventoryThresholdController.DeleteThreshold)
		}

		// 退换货管理路由
		returnController := controllers.NewReturnController(services.NewReturnService(db))
		returnGroup := apiAuth.Party("/returns")
		{
			returnGroup.Post("", returnController.CreateReturnOrder)                                                             // 创建退换货申请
			returnGroup.Get("", returnController.GetReturnOrderList)                                                             // 获取退换货列表
			returnGroup.Get("/{id:uint}", returnController.GetReturnOrderByID)                                                   // 获取单个退换货详情
			returnGroup.Put("/{id:uint}/status", returnController.UpdateReturnOrderStatus)                                       // 更新退换货状态 (通用)
			returnGroup.Post("/{id:uint}/approve", middleware.RoleAuth("admin", "manager"), returnController.ApproveReturnOrder) // 审批通过
			returnGroup.Post("/{id:uint}/reject", middleware.RoleAuth("admin", "manager"), returnController.RejectReturnOrder)
			returnGroup.Delete("/{id:uint}", middleware.RoleAuth("admin", "manager"), returnController.DeleteReturnOrder)

			// More specific status updates
			returnGroup.Post("/{id:uint}/goods-received", middleware.RoleAuth("admin", "manager", "staff"), returnController.MarkGoodsReceived)
			returnGroup.Post("/{id:uint}/exchange-shipped", middleware.RoleAuth("admin", "manager", "staff"), returnController.MarkExchangeShipped)
			returnGroup.Post("/{id:uint}/process-refund", middleware.RoleAuth("admin", "manager"), returnController.ProcessRefund)
			returnGroup.Post("/{id:uint}/complete", middleware.RoleAuth("admin", "manager"), returnController.CompleteReturnOrder)
		}

		// 文件上传路由
		inventoryCheckController := controllers.NewInventoryCheckController(db)
		checkGroup := apiAuth.Party("/inventory-checks")
		{
			checkGroup.Get("", inventoryCheckController.ListChecks)
			checkGroup.Get("/{id:uint}", inventoryCheckController.GetCheck)
			checkGroup.Post("", middleware.RoleAuth("admin", "manager"), inventoryCheckController.CreateCheck)
			checkGroup.Put("/{id:uint}/start", middleware.RoleAuth("admin", "manager"), inventoryCheckController.StartCheck)
			checkGroup.Put("/{id:uint}/complete", middleware.RoleAuth("admin", "manager"), inventoryCheckController.CompleteCheck)
			checkGroup.Put("/{id:uint}/cancel", middleware.RoleAuth("admin", "manager"), inventoryCheckController.CancelCheck)
			checkGroup.Put("/{id:uint}/items/{itemId:uint}", middleware.RoleAuth("admin", "manager", "staff"), inventoryCheckController.UpdateCheckItem)
			checkGroup.Post("/{id:uint}/adjustments", middleware.RoleAuth("admin", "manager"), inventoryCheckController.CreateAdjustment)
			checkGroup.Put("/adjustments/{adjustmentId:uint}/approve", middleware.RoleAuth("admin", "manager"), inventoryCheckController.ApproveAdjustment)
		}

	}
}
