package main

import (
	"hd_psi/backend/config"
	"hd_psi/backend/controllers"
	"hd_psi/backend/embed"
	"hd_psi/backend/middleware"
	"hd_psi/backend/models"
	"hd_psi/backend/routes"
	"hd_psi/backend/services"
	"hd_psi/backend/utils/logger"
	"net/http"
	"os"
	"path/filepath"
	"time"

	"github.com/gin-gonic/gin"
	"gorm.io/driver/mysql"
	"gorm.io/gorm"
)

func main() {
	// 初始化配置
	config.InitConfig()

	// 初始化日志系统
	logDir := config.AppConfig.Log.Directory
	logLevel := logger.INFO
	if config.AppConfig.Log.Level == "debug" {
		logLevel = logger.DEBUG
	} else if config.AppConfig.Log.Level == "warn" {
		logLevel = logger.WARN
	} else if config.AppConfig.Log.Level == "error" {
		logLevel = logger.ERROR
	}

	if err := logger.SetupLogger(logLevel, logDir); err != nil {
		panic("初始化日志系统失败: " + err.Error())
	}
	logger.Info("日志系统初始化成功", logger.F("level", logLevel), logger.F("directory", logDir))

	// 设置Gin模式
	gin.SetMode(config.GetServerMode())
	logger.Info("Gin模式设置为", logger.F("mode", config.GetServerMode()))

	// 初始化数据库连接
	// 确保在DSN中设置parseTime=true以正确处理datetime类型
	dsn := config.GetDBConfig()
	db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{
		NowFunc: func() time.Time {
			return time.Now().Local() // 使用本地时间
		},
	})
	if err != nil {
		logger.Fatal("数据库连接失败", logger.F("error", err.Error()))
	}
	logger.Info("数据库连接成功")

	// 配置数据库连接池
	sqlDB, err := db.DB()
	if err != nil {
		logger.Fatal("获取数据库连接池失败", logger.F("error", err.Error()))
	}

	// 设置连接池参数
	sqlDB.SetMaxIdleConns(config.AppConfig.Database.MaxIdleConns)
	sqlDB.SetMaxOpenConns(config.AppConfig.Database.MaxOpenConns)
	sqlDB.SetConnMaxLifetime(time.Duration(config.AppConfig.Database.ConnMaxLifetime) * time.Second)
	logger.Info("数据库连接池配置完成", 
		logger.F("max_idle_conns", config.AppConfig.Database.MaxIdleConns),
		logger.F("max_open_conns", config.AppConfig.Database.MaxOpenConns),
		logger.F("conn_max_lifetime", config.AppConfig.Database.ConnMaxLifetime))

	// 自动迁移数据模型
	// 禁用外键约束检查
	db.Exec("SET FOREIGN_KEY_CHECKS = 0")
	logger.Info("开始自动迁移数据模型")
	db.AutoMigrate(
		&models.User{},
		&models.Dictionary{},
		&models.DictionaryItem{},
		&models.Product{},
		&models.ProductVariant{},
		&models.Inventory{},
		&models.Supplier{},
		&models.PurchaseOrder{},
		&models.PurchaseOrderItem{},
		&models.PurchaseReceiving{},
		&models.PurchaseReceivingItem{},
		&models.Store{},
		&models.InventoryTransaction{},
		&models.InventoryAlert{},
		&models.InventoryThreshold{},
		&models.Member{},
		&models.InventoryCheck{},
		&models.InventoryCheckItem{},
		&models.InventoryCheckAdjustment{},
		&models.SalesOrder{},
		&models.SalesOrderItem{},
		&models.NegotiationRecord{},
		&models.FittingRecord{},
		&models.ReturnOrder{},
		&models.ReturnOrderItem{},
		&models.FittingRoom{},
		&controllers.PointsTransaction{},
		&models.SystemSetting{},
		&models.PermissionAuditLog{},
	)
	// 重新启用外键约束检查
	db.Exec("SET FOREIGN_KEY_CHECKS = 1")
	logger.Info("数据模型自动迁移完成")

	// 初始化Casbin服务
	casbinService := services.NewCasbinService(db)
	logger.Info("Casbin服务初始化成功")

	// 初始化Gin引擎
	r := gin.New() // 使用New()而不是Default()，因为我们将自定义中间件

	// 添加中间件
	r.Use(middleware.ErrorHandlerMiddleware())                                // 错误处理中间件
	r.Use(middleware.RequestLoggerMiddleware("/assets/*", "/favicon.ico"))    // 请求日志中间件，跳过静态资源
	r.Use(middleware.CORSMiddleware())                                        // CORS中间件
	r.Use(middleware.ValidationErrorMiddleware())                             // 验证错误处理中间件

	// 设置404和405处理器
	r.NoRoute(middleware.NotFoundHandler)
	r.NoMethod(middleware.MethodNotAllowedHandler)

	// 注册路由
	routes.RegisterRoutes(r, db, casbinService)
	logger.Info("路由注册完成")

	// 静态文件服务
	// 检查是否存在物理文件目录
	if _, err := os.Stat("./public/assets"); os.IsNotExist(err) {
		// 如果物理目录不存在，使用嵌入的静态文件
		logger.Info("使用嵌入的静态文件")
		r.StaticFS("/assets", embed.GetPublicFS())
	} else {
		// 如果物理目录存在，使用物理文件
		logger.Info("使用物理静态文件目录")
		r.Static("/assets", "./public/assets")
	}

	// 所有前端路由都返回首页，由前端路由处理
	r.NoRoute(func(c *gin.Context) {
		// 如果是API请求，返回404
		if len(c.Request.URL.Path) >= 4 && c.Request.URL.Path[:4] == "/api" {
			c.JSON(http.StatusNotFound, gin.H{"error": "路由不存在"})
			return
		}

		// 检查是否存在物理index.html文件
		indexPath := filepath.Join("./public", "index.html")
		if _, err := os.Stat(indexPath); os.IsNotExist(err) {
			// 如果物理文件不存在，使用嵌入的index.html
			c.FileFromFS("index.html", embed.GetPublicFS())
		} else {
			// 如果物理文件存在，使用物理文件
			c.File(indexPath)
		}
	})

	// 初始化字典数据
	dictionaryController := controllers.NewDictionaryController(db)
	if err := dictionaryController.InitDefaultDictionaries(); err != nil {
		logger.Error("初始化字典数据失败", logger.F("error", err.Error()))
	} else {
		logger.Info("字典数据初始化成功")
	}

	// 初始化系统设置数据
	systemSettingController := controllers.NewSystemSettingController(db)
	if err := systemSettingController.InitDefaultSettings(); err != nil {
		logger.Error("初始化系统设置失败", logger.F("error", err.Error()))
	} else {
		logger.Info("系统设置初始化成功")
	}

	// 启动服务
	serverPort := config.GetServerPort()
	logger.Info("服务启动", logger.F("port", serverPort), logger.F("mode", config.GetServerMode()))
	if err := r.Run(serverPort); err != nil {
		logger.Fatal("服务启动失败", logger.F("error", err.Error()))
	}
}
