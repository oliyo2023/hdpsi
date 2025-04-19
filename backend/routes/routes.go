package routes

import (
	"hd_psi/backend/controllers"
	"hd_psi/backend/middleware"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// RegisterRoutes 注册所有路由
func RegisterRoutes(r *gin.Engine, db *gorm.DB) {
	// 认证路由 - 不需要认证
	authController := controllers.NewAuthController(db)
	// 认证路由
	r.POST("/auth/login", authController.Login)
	r.POST("/auth/register", authController.Register)

	// API路由组
	api := r.Group("/api")

	// 认证API路由
	authGroup := api.Group("/auth")
	{
		authGroup.POST("/login", authController.Login)
		authGroup.POST("/register", authController.Register)
		authGroup.POST("/refresh-token", authController.RefreshToken)
	}

	// 字典管理路由 - 不需要认证
	dictionaryController := controllers.NewDictionaryController(db)
	dictGroup := api.Group("/dictionaries")
	{
		// 字典类型路由
		dictGroup.GET("", dictionaryController.ListDictionaries)
		dictGroup.GET("/:code", dictionaryController.GetDictionary)
		dictGroup.POST("", dictionaryController.CreateDictionary)
		dictGroup.PUT("/:code", dictionaryController.UpdateDictionary)
		dictGroup.DELETE("/:code", dictionaryController.DeleteDictionary)

		// 字典项路由
		dictGroup.GET("/:code/items", dictionaryController.ListDictionaryItems)
		dictGroup.GET("/:code/items/:itemId", dictionaryController.GetDictionaryItem)
		dictGroup.POST("/:code/items", dictionaryController.CreateDictionaryItem)
		dictGroup.PUT("/:code/items/:itemId", dictionaryController.UpdateDictionaryItem)
		dictGroup.DELETE("/:code/items/:itemId", dictionaryController.DeleteDictionaryItem)
	}

	// 权限管理路由 - 仅管理员可访问
	// permissionController := controllers.NewPermissionController(db, casbinService)
	// permGroup := api.Group("/permissions")
	// permGroup.Use(middleware.JWTAuth(), middleware.RoleAuth("admin"))
	// {
	// permGroup.GET("/policies", permissionController.GetAllPolicies)
	// permGroup.GET("/roles", permissionController.GetAllRoles)
	// permGroup.GET("/roles/:role", permissionController.GetRolePermissions)
	// permGroup.POST("/policies", permissionController.AddPolicy)
	// permGroup.DELETE("/policies", permissionController.RemovePolicy)
	// permGroup.POST("/roles", permissionController.AddRoleForUser)
	// permGroup.DELETE("/roles", permissionController.DeleteRoleForUser)
	// permGroup.GET("/users/:user/roles", permissionController.GetRolesForUser)
	// permGroup.GET("/roles/:role/users", permissionController.GetUsersForRole)
	// permGroup.POST("/check", permissionController.CheckPermission)
	// permGroup.GET("/audit-logs", permissionController.GetAuditLogs)
	// }

	// 需要认证的路由
	apiAuth := api.Group("/")
	apiAuth.Use(middleware.JWTAuth())
	{
		// 仪表盘路由
		dashboardController := controllers.NewDashboardController(db)
		apiAuth.GET("/dashboard/statistics", dashboardController.GetStatistics)
		// 用户信息路由
		apiAuth.GET("/profile", authController.GetProfile)
		apiAuth.PUT("/profile", authController.UpdateProfile)
		apiAuth.PUT("/change-password", authController.ChangePassword)

		// 系统设置路由
		systemSettingController := controllers.NewSystemSettingController(db)
		apiAuth.GET("/settings", systemSettingController.GetSettings)
		apiAuth.PUT("/settings", middleware.RoleAuth("admin"), systemSettingController.UpdateSettings)
		apiAuth.GET("/settings/theme", systemSettingController.GetUserTheme)
		apiAuth.PUT("/settings/theme", systemSettingController.UpdateUserTheme)

		// 商品管理路由
		productController := controllers.NewProductController(db)
		productGroup := apiAuth.Group("/products")
		{
			productGroup.GET("", productController.ListProducts)
			productGroup.GET("/:id", productController.GetProduct)
			productGroup.POST("", middleware.RoleAuth("admin", "manager"), productController.CreateProduct)
			productGroup.PUT("/:id", middleware.RoleAuth("admin", "manager"), productController.UpdateProduct)
			productGroup.DELETE("/:id", middleware.RoleAuth("admin"), productController.DeleteProduct)
		}

		// 库存管理路由
		inventoryController := controllers.NewInventoryController(db)
		inventoryGroup := apiAuth.Group("/inventory")
		{
			inventoryGroup.GET("", inventoryController.ListInventories)
			inventoryGroup.GET("/:id", inventoryController.GetInventory)
			inventoryGroup.POST("", middleware.RoleAuth("admin", "manager"), inventoryController.CreateInventory)
			inventoryGroup.PUT("/:id", middleware.RoleAuth("admin", "manager"), inventoryController.UpdateInventory)
			inventoryGroup.DELETE("/:id", middleware.RoleAuth("admin"), inventoryController.DeleteInventory)
		}

		// 供应商管理路由
		supplierController := controllers.NewSupplierController(db)
		supplierGroup := apiAuth.Group("/suppliers")
		{
			supplierGroup.GET("", supplierController.ListSuppliers)
			supplierGroup.GET("/:id", supplierController.GetSupplier)
			supplierGroup.POST("", middleware.RoleAuth("admin", "manager"), supplierController.CreateSupplier)
			supplierGroup.PUT("/:id", middleware.RoleAuth("admin", "manager"), supplierController.UpdateSupplier)
			supplierGroup.DELETE("/:id", middleware.RoleAuth("admin"), supplierController.DeleteSupplier)
		}

		// 采购管理路由
		purchaseController := controllers.NewPurchaseController(db)
		purchaseGroup := apiAuth.Group("/purchases")
		{
			purchaseGroup.GET("", purchaseController.ListPurchaseOrders)
			purchaseGroup.GET("/:id", purchaseController.GetPurchaseOrder)
			purchaseGroup.POST("", middleware.RoleAuth("admin", "manager"), purchaseController.CreatePurchaseOrder)
			purchaseGroup.PUT("/:id", middleware.RoleAuth("admin", "manager"), purchaseController.UpdatePurchaseOrder)
			purchaseGroup.PUT("/:id/status", middleware.RoleAuth("admin", "manager"), purchaseController.UpdatePurchaseOrderStatus)
			purchaseGroup.DELETE("/:id", middleware.RoleAuth("admin"), purchaseController.DeletePurchaseOrder)
		}

		// 采购入库路由
		purchaseReceivingController := controllers.NewPurchaseReceivingController(db)
		receivingGroup := apiAuth.Group("/purchase-receivings")
		{
			receivingGroup.GET("", purchaseReceivingController.ListPurchaseReceivings)
			receivingGroup.GET("/:id", purchaseReceivingController.GetPurchaseReceiving)
			receivingGroup.POST("", middleware.RoleAuth("admin", "manager", "staff"), purchaseReceivingController.CreatePurchaseReceiving)
			receivingGroup.DELETE("/:id", middleware.RoleAuth("admin", "manager"), purchaseReceivingController.DeletePurchaseReceiving)
		}

		// 会员管理路由 - 暂时移除权限控制以便于开发
		memberController := controllers.NewMemberController(db)
		memberGroup := api.Group("/members")
		{
			memberGroup.GET("", memberController.ListMembers)
			memberGroup.GET("/:id", memberController.GetMember)
			memberGroup.POST("", memberController.CreateMember)
			memberGroup.PUT("/:id", memberController.UpdateMember)
			memberGroup.DELETE("/:id", memberController.DeleteMember)

			// 会员积分路由
			memberPointsController := controllers.NewMemberPointsController(db)
			memberGroup.GET("/:id/points", memberPointsController.GetMemberPoints)
			memberGroup.GET("/:id/points/transactions", memberPointsController.ListPointsTransactions)
			memberGroup.POST("/:id/points/add", memberPointsController.AddPoints)
			memberGroup.POST("/:id/points/deduct", memberPointsController.DeductPoints)
			memberGroup.POST("/:id/level/calculate", memberPointsController.CalculateMemberLevel)
		}

		// 店铺管理路由
		storeController := controllers.NewStoreController(db)
		storeGroup := api.Group("/stores")
		{
			storeGroup.GET("", storeController.ListStores)
			storeGroup.GET("/:id", storeController.GetStore)
			storeGroup.POST("", middleware.RoleAuth("admin"), storeController.CreateStore)
			storeGroup.PUT("/:id", middleware.RoleAuth("admin"), storeController.UpdateStore)
			storeGroup.DELETE("/:id", middleware.RoleAuth("admin"), storeController.DeleteStore)
		}

		// 库存交易路由
		inventoryTransactionController := controllers.NewInventoryTransactionController(db)
		transactionGroup := api.Group("/inventory-transactions")
		{
			transactionGroup.GET("", inventoryTransactionController.ListTransactions)
			transactionGroup.GET("/:id", inventoryTransactionController.GetTransaction)
			transactionGroup.POST("", middleware.RoleAuth("admin", "manager", "staff"), inventoryTransactionController.CreateTransaction)
			transactionGroup.GET("/store/:storeId", inventoryTransactionController.GetStoreTransactions)
			transactionGroup.GET("/product/:productId", inventoryTransactionController.GetProductTransactions)
		}

		// 库存预警路由
		inventoryAlertController := controllers.NewInventoryAlertController(db)
		alertGroup := api.Group("/inventory-alerts")
		{
			alertGroup.GET("", inventoryAlertController.ListAlerts)
			alertGroup.GET("/:id", inventoryAlertController.GetAlert)
			alertGroup.PUT("/:id/status", middleware.RoleAuth("admin", "manager"), inventoryAlertController.UpdateAlertStatus)
			alertGroup.POST("/check", inventoryAlertController.CheckInventoryLevels)
		}

		// 库存阈值路由
		inventoryThresholdController := controllers.NewInventoryThresholdController(db)
		thresholdGroup := api.Group("/inventory-thresholds")
		{
			thresholdGroup.GET("", inventoryThresholdController.ListThresholds)
			thresholdGroup.GET("/:id", inventoryThresholdController.GetThreshold)
			thresholdGroup.POST("", middleware.RoleAuth("admin", "manager"), inventoryThresholdController.CreateThreshold)
			thresholdGroup.PUT("/:id", middleware.RoleAuth("admin", "manager"), inventoryThresholdController.UpdateThreshold)
			thresholdGroup.DELETE("/:id", middleware.RoleAuth("admin"), inventoryThresholdController.DeleteThreshold)
		}

		// 库存盘点路由
		inventoryCheckController := controllers.NewInventoryCheckController(db)
		checkGroup := api.Group("/inventory-checks")
		{
			checkGroup.GET("", inventoryCheckController.ListChecks)
			checkGroup.GET("/:id", inventoryCheckController.GetCheck)
			checkGroup.POST("", middleware.RoleAuth("admin", "manager"), inventoryCheckController.CreateCheck)
			checkGroup.PUT("/:id/start", middleware.RoleAuth("admin", "manager"), inventoryCheckController.StartCheck)
			checkGroup.PUT("/:id/complete", middleware.RoleAuth("admin", "manager"), inventoryCheckController.CompleteCheck)
			checkGroup.PUT("/:id/cancel", middleware.RoleAuth("admin", "manager"), inventoryCheckController.CancelCheck)
			checkGroup.PUT("/:id/items/:itemId", middleware.RoleAuth("admin", "manager", "staff"), inventoryCheckController.UpdateCheckItem)
			checkGroup.POST("/:id/adjustments", middleware.RoleAuth("admin", "manager"), inventoryCheckController.CreateAdjustment)
			checkGroup.PUT("/adjustments/:adjustmentId/approve", middleware.RoleAuth("admin", "manager"), inventoryCheckController.ApproveAdjustment)
		}

		// 销售管理路由
		salesController := controllers.NewSalesController(db)
		salesGroup := api.Group("/sales")
		{
			// 最近销售路由
			salesGroup.GET("/recent", salesController.GetRecentSales)

			// 销售订单路由
			salesGroup.GET("/orders", salesController.ListOrders)
			salesGroup.GET("/orders/:id", salesController.GetOrder)
			salesGroup.POST("/orders", middleware.RoleAuth("admin", "manager", "cashier"), salesController.CreateOrder)
			salesGroup.PUT("/orders/:id/status", middleware.RoleAuth("admin", "manager", "cashier"), salesController.UpdateOrderStatus)

			// 退换货路由
			salesGroup.POST("/returns", middleware.RoleAuth("admin", "manager", "cashier"), salesController.CreateReturnOrder)
			salesGroup.PUT("/returns/:id/status", middleware.RoleAuth("admin", "manager"), salesController.UpdateReturnOrderStatus)
		}

		// 试衣管理路由
		fittingController := controllers.NewFittingController(db)
		fittingGroup := api.Group("/fitting")
		{
			// 试衣间路由
			fittingGroup.GET("/rooms", fittingController.ListFittingRooms)
			fittingGroup.GET("/rooms/:id", fittingController.GetFittingRoom)
			fittingGroup.POST("/rooms", middleware.RoleAuth("admin", "manager"), fittingController.CreateFittingRoom)
			fittingGroup.PUT("/rooms/:id", middleware.RoleAuth("admin", "manager"), fittingController.UpdateFittingRoom)
			fittingGroup.DELETE("/rooms/:id", middleware.RoleAuth("admin"), fittingController.DeleteFittingRoom)

			// 试衣记录路由
			fittingGroup.GET("/records", fittingController.ListFittingRecords)
			fittingGroup.GET("/records/:id", fittingController.GetFittingRecord)
			fittingGroup.POST("/records", middleware.RoleAuth("admin", "manager", "staff"), fittingController.CreateFittingRecord)
			fittingGroup.PUT("/records/:id", middleware.RoleAuth("admin", "manager", "staff"), fittingController.UpdateFittingRecord)
			fittingGroup.PUT("/records/:id/complete", middleware.RoleAuth("admin", "manager", "staff"), fittingController.CompleteFitting)
		}

	}
}
