package main

import (
	"hd_psi/backend/config"
	"hd_psi/backend/controllers"
	_ "hd_psi/backend/docs" // 导入swagger文档
	"hd_psi/backend/embed"
	"hd_psi/backend/middleware"
	"hd_psi/backend/models"
	"hd_psi/backend/routes"
	"hd_psi/backend/utils/logger"
	"net/http"
	"os"
	"path/filepath"
	"time"

	"github.com/gin-gonic/gin"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
	"gorm.io/driver/mysql"
	"gorm.io/gorm"
)

func main() {
	// 初始化配置
	config.InitConfig()

	// 初始化日志系统
	logDir := config.AppConfig.Log.Directory
	logLevel := config.AppConfig.Log.Level

	// 创建日志实例
	log := &logger.Logger{
		Fields: make(map[string]interface{}),
	}
	log.Info("日志系统初始化成功", logger.F("level", logLevel), logger.F("directory", logDir))

	// 设置Gin模式
	gin.SetMode(config.GetServerMode())
	log.Info("Gin模式设置为", logger.F("mode", config.GetServerMode()))

	// 初始化数据库连接
	// 确保在DSN中设置parseTime=true以正确处理datetime类型
	dsn := config.GetDBConfig()
	db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{
		NowFunc: func() time.Time {
			return time.Now().Local() // 使用本地时间
		},
	})
	if err != nil {
		log.Error("数据库连接失败", logger.F("error", err.Error()))
		panic("Database connection failed: " + err.Error())
	}
	log.Info("数据库连接成功")

	// 配置数据库连接池
	sqlDB, err := db.DB()
	if err != nil {
		log.Error("获取数据库连接池失败", logger.F("error", err.Error()))
		panic("Failed to get database connection pool: " + err.Error())
	}

	// 设置连接池参数
	sqlDB.SetMaxIdleConns(config.AppConfig.Database.MaxIdleConns)
	sqlDB.SetMaxOpenConns(config.AppConfig.Database.MaxOpenConns)
	sqlDB.SetConnMaxLifetime(time.Duration(config.AppConfig.Database.ConnMaxLifetime) * time.Second)
	log.Info("数据库连接池配置完成",
		logger.F("max_idle_conns", config.AppConfig.Database.MaxIdleConns),
		logger.F("max_open_conns", config.AppConfig.Database.MaxOpenConns),
		logger.F("conn_max_lifetime", config.AppConfig.Database.ConnMaxLifetime),
		logger.F("auto_migrate", config.AppConfig.Database.AutoMigrate))

	// 根据配置决定是否自动迁移数据模型
	// 确保从配置中读取最新的 AutoMigrate 值
	autoMigrate := config.AppConfig.Database.AutoMigrate
	log.Info("自动迁移设置", logger.F("auto_migrate", autoMigrate))

	if autoMigrate {
		// 禁用外键约束检查
		db.Exec("SET FOREIGN_KEY_CHECKS = 0")
		log.Info("开始自动迁移数据模型")
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
			&controllers.PointsTransaction{},
			&models.SystemSetting{},
			&models.ReturnOrder{},
			&models.ReturnOrderItem{},
			&models.ExchangeOrderItem{},
			&models.ReturnOrderLog{},
		)
		// 重新启用外键约束检查
		db.Exec("SET FOREIGN_KEY_CHECKS = 1")
		log.Info("数据模型自动迁移完成")
	} else {
		log.Info("自动迁移已禁用，跳过数据模型迁移")
	}

	// 初始化Casbin服务

	// 初始化Gin引擎
	r := gin.New() // 使用New()而不是Default()，因为我们将自定义中间件

	// 添加中间件
	r.Use(gin.Logger())                            // 使用Gin的默认日志中间件
	r.Use(gin.Recovery())                          // 使用Gin的默认恢复中间件
	r.Use(middleware.CORSMiddleware())             // CORS中间件
	r.Use(middleware.APIVersionMiddleware())       // API版本中间件
	r.Use(middleware.APIVersionHeaderMiddleware()) // API版本响应头中间件

	// 设置404和405处理器
	r.NoRoute(func(c *gin.Context) {
		c.JSON(http.StatusNotFound, gin.H{"error": "路由不存在"})
	})
	r.NoMethod(func(c *gin.Context) {
		c.JSON(http.StatusMethodNotAllowed, gin.H{"error": "方法不允许"})
	})

	// 注册Swagger路由
	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))
	log.Info("Swagger文档已启用，访问地址: /swagger/index.html")

	// 注册路由
	routes.RegisterRoutes(r, db)
	log.Info("路由注册完成")

	// 静态文件服务
	// 检查是否存在物理文件目录
	if _, err := os.Stat("./public/assets"); os.IsNotExist(err) {
		// 如果物理目录不存在，使用嵌入的静态文件
		log.Info("使用嵌入的静态文件")
		r.StaticFS("/assets", embed.GetPublicFS())
	} else {
		// 如果物理目录存在，使用物理文件
		log.Info("使用物理静态文件目录")
		r.Static("/assets", "./public/assets")
	}

	// 创建上传目录
	uploadDirs := []string{"./public/uploads/images", "./public/uploads/editor"}
	for _, dir := range uploadDirs {
		if err := os.MkdirAll(dir, 0755); err != nil {
			log.Error("创建上传目录失败", logger.F("dir", dir), logger.F("error", err.Error()))
		}
	}
	// 静态文件服务 - 上传文件
	r.Static("/uploads", "./public/uploads")

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
		log.Error("初始化字典数据失败", logger.F("error", err.Error()))
	} else {
		log.Info("字典数据初始化成功")
	}

	// 初始化系统设置数据
	systemSettingController := controllers.NewSystemSettingController(db)
	if err := systemSettingController.InitDefaultSettings(); err != nil {
		log.Error("初始化系统设置失败", logger.F("error", err.Error()))
	} else {
		log.Info("系统设置初始化成功")
	}

	// 启动服务
	serverPort := config.GetServerPort()
	log.Info("服务启动", logger.F("port", serverPort), logger.F("mode", config.GetServerMode()))
	if err := r.Run(serverPort); err != nil {
		log.Error("服务启动失败", logger.F("error", err.Error()))
		panic("Server start failed: " + err.Error())
	}
}
