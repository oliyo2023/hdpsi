package main

import (
	"hd_psi/backend/config"
	"hd_psi/backend/controllers"
	_ "hd_psi/backend/docs" // 导入swagger文档
	"hd_psi/backend/embed"
	"hd_psi/backend/middleware"
	"hd_psi/backend/models"
	"hd_psi/backend/routes"
	"hd_psi/backend/services"
	"hd_psi/backend/utils/logger"
	"io"
	"os"
	"path/filepath"
	"time"

	"github.com/kataras/iris/v12"
	irisLogger "github.com/kataras/iris/v12/middleware/logger"
	"github.com/kataras/iris/v12/middleware/recover"
	"gorm.io/driver/mysql"

	"github.com/glebarez/sqlite"
	"gorm.io/gorm"
)

func main() {
	// 初始化配置
	config.InitConfig()

	// 初始化日志系统
	logDir := config.AppConfig.Log.Directory
	logLevel := config.AppConfig.Log.Level
	logFile := filepath.Join(logDir, config.AppConfig.Log.Filename)

	// 创建日志实例
	log := &logger.Logger{
		Fields: make(map[string]interface{}),
	}
	log.SetLogFile(logFile)
	log.Info("日志系统初始化成功", logger.F("level", logLevel), logger.F("directory", logDir), logger.F("file", logFile))

	// 设置Iris模式
	irisMode := config.GetServerMode()
	log.Info("Iris模式设置为", logger.F("mode", irisMode))

	// 初始化数据库连接
	dbType, dsn := config.GetDBConfig()
	log.Info("数据库配置", logger.F("type", dbType), logger.F("dsn", dsn))

	var db *gorm.DB
	var err error

	// 根据数据库类型选择驱动
	switch dbType {
	case "sqlite":
		// 确保数据目录存在
		if err := os.MkdirAll("./data", 0755); err != nil {
			log.Error("创建数据目录失败", logger.F("error", err.Error()))
		}
		log.Info("使用SQLite数据库")
		db, err = gorm.Open(sqlite.Open(dsn), &gorm.Config{
			NowFunc: func() time.Time {
				return time.Now().Local() // 使用本地时间
			},
		})
	case "mysql":
		db, err = gorm.Open(mysql.Open(dsn), &gorm.Config{
			NowFunc: func() time.Time {
				return time.Now().Local() // 使用本地时间
			},
		})
	default:
		log.Error("不支持的数据库类型", logger.F("type", dbType))
		panic("Unsupported database type: " + dbType)
	}
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
		log.Info("开始自动迁移数据模型")

		// 只对MySQL禁用外键约束检查
		if dbType == "mysql" {
			db.Exec("SET FOREIGN_KEY_CHECKS = 0")
		}

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
			&models.SystemSetting{},
			&models.ReturnOrder{},
			&models.ReturnOrderItem{},
			&models.ExchangeOrderItem{},
			&models.ReturnOrderLog{},
			&models.SalesOrder{},
			&models.SalesOrderItem{},
			&models.SalesOrderPayment{},
			&models.SalesOrderLog{},
			&models.NegotiationLog{},
		)

		// 只对MySQL重新启用外键约束检查
		if dbType == "mysql" {
			db.Exec("SET FOREIGN_KEY_CHECKS = 1")
		}

		log.Info("数据模型自动迁移完成")
	} else {
		log.Info("自动迁移已禁用，跳过数据模型迁移")
	}

	// 初始化Casbin服务

	// 初始化Iris引擎
	app := iris.New()

	// 配置Iris
	app.Configure(iris.WithConfiguration(iris.Configuration{
		DisableStartupLog: false,
		Charset:           "UTF-8",
		TimeFormat:        "Mon, 02 Jan 2006 15:04:05 GMT",
	}))

	// 设置日志级别
	if irisMode == "release" {
		app.Logger().SetLevel("info")
	} else {
		app.Logger().SetLevel("debug")
	}

	// 添加中间件
	app.Use(irisLogger.New())
	app.Use(recover.New())

	app.Use(middleware.APIVersionMiddleware())
	app.Use(middleware.APIVersionHeaderMiddleware())

	app.OnErrorCode(iris.StatusMethodNotAllowed, func(ctx iris.Context) {
		// 对于OPTIONS预检请求，返回204
		if ctx.Method() == "OPTIONS" {
			ctx.Header("Access-Control-Allow-Origin", "*")
			ctx.Header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS, PATCH")
			ctx.Header("Access-Control-Allow-Headers", "Origin, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")
			ctx.Header("Access-Control-Max-Age", "86400")
			ctx.Header("Access-Control-Allow-Credentials", "true")
			ctx.StatusCode(204)
			return
		}

		ctx.StatusCode(iris.StatusMethodNotAllowed)
		ctx.JSON(map[string]interface{}{"error": "方法不允许"})
	})

	app.OnErrorCode(iris.StatusNotFound, func(ctx iris.Context) {
		// 对于OPTIONS预检请求，返回204
		if ctx.Method() == "OPTIONS" {
			ctx.Header("Access-Control-Allow-Origin", "*")
			ctx.Header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS, PATCH")
			ctx.Header("Access-Control-Allow-Headers", "Origin, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")
			ctx.Header("Access-Control-Max-Age", "86400")
			ctx.Header("Access-Control-Allow-Credentials", "true")
			ctx.StatusCode(204)
			return
		}

		// 如果是API请求，返回404
		if len(ctx.Path()) >= 4 && ctx.Path()[:4] == "/api" {
			ctx.StatusCode(iris.StatusNotFound)
			ctx.JSON(map[string]interface{}{"error": "路由不存在"})
			return
		}

		// 检查是否存在物理index.html文件
		indexPath := filepath.Join("./public", "index.html")
		if _, err := os.Stat(indexPath); os.IsNotExist(err) {
			// 如果物理文件不存在，使用嵌入的index.html
			file, err := embed.GetPublicFS().Open("index.html")
			if err == nil {
				defer file.Close()
				data, err := io.ReadAll(file)
				if err == nil {
					ctx.ContentType("text/html")
					ctx.Write(data)
				} else {
					ctx.StatusCode(iris.StatusInternalServerError)
					ctx.WriteString("Error reading file")
				}
			} else {
				ctx.StatusCode(iris.StatusNotFound)
				ctx.WriteString("File not found")
			}
		} else {
			// 如果物理文件存在，使用物理文件
			ctx.ServeFile(indexPath)
		}
	})

	// 注册路由
	routes.RegisterRoutes(app, db)

	// 初始化默认用户
	userInitService := services.NewUserInitService(db)
	if err := userInitService.InitDefaultUsers(); err != nil {
		log.Error("初始化默认用户失败", logger.F("error", err.Error()))
	} else {
		log.Info("默认用户初始化成功")
	}

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
	if err := app.Listen(serverPort); err != nil {
		log.Error("服务启动失败", logger.F("error", err.Error()))
		panic("Server start failed: " + err.Error())
	}
}
