package main

import (
	"hd_psi/backend/config"
	"hd_psi/backend/controllers"
	"hd_psi/backend/middleware"
	"hd_psi/backend/models"
	"hd_psi/backend/routes"
	"log"
	"net/http"
	"os"
	"time"

	"./embed"

	"github.com/gin-gonic/gin"
	"gorm.io/driver/mysql"
	"gorm.io/gorm"
)

func main() {
	// 初始化配置
	config.InitConfig()

	// 设置Gin模式
	gin.SetMode(config.GetServerMode())

	// 初始化数据库连接
	// 确保在DSN中设置parseTime=true以正确处理datetime类型
	dsn := config.GetDBConfig()
	db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{
		NowFunc: func() time.Time {
			return time.Now().Local() // 使用本地时间
		},
	})
	if err != nil {
		log.Fatal("数据库连接失败: ", err)
	}

	// 配置数据库连接池
	sqlDB, err := db.DB()
	if err != nil {
		log.Fatal("获取数据库连接池失败: ", err)
	}

	// 设置连接池参数
	sqlDB.SetMaxIdleConns(config.AppConfig.Database.MaxIdleConns)
	sqlDB.SetMaxOpenConns(config.AppConfig.Database.MaxOpenConns)
	sqlDB.SetConnMaxLifetime(time.Duration(config.AppConfig.Database.ConnMaxLifetime) * time.Second)

	// 自动迁移数据模型
	// 禁用外键约束检查
	db.Exec("SET FOREIGN_KEY_CHECKS = 0")
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
	)
	// 重新启用外键约束检查
	db.Exec("SET FOREIGN_KEY_CHECKS = 1")

	// 初始化Gin引擎
	r := gin.Default()

	// 使用CORS中间件，从配置中获取CORS设置
	// corsConfig := config.GetCORSConfig()
	r.Use(middleware.CORSMiddleware())

	// 注册路由
	routes.RegisterRoutes(r, db)

	// 静态文件服务
	// 检查是否存在物理文件目录
	if _, err := os.Stat("./public/assets"); os.IsNotExist(err) {
		// 如果物理目录不存在，使用嵌入的静态文件
		log.Println("使用嵌入的静态文件")
		r.StaticFS("/", embed.GetPublicFS())
	} else {
		// 如果物理目录存在，使用物理文件
		log.Println("使用物理静态文件目录")
		r.Static("/assets", "./public/assets")
		r.StaticFile("/", "./public/index.html")
	}

	// 所有前端路由都返回首页，由前端路由处理
	r.NoRoute(func(c *gin.Context) {
		// 如果是API请求，返回404
		if len(c.Request.URL.Path) >= 4 && c.Request.URL.Path[:4] == "/api" {
			c.JSON(http.StatusNotFound, gin.H{"error": "路由不存在"})
			return
		}

		// 检查是否存在物理index.html文件
		indexPath := "./public/index.html"
		if _, err := os.Stat(indexPath); os.IsNotExist(err) {
			// 如果物理文件不存在，使用嵌入的index.html
			c.FileFromFS("public/index.html", embed.GetPublicFS())
		} else {
			// 如果物理文件存在，使用物理文件
			c.File(indexPath)
		}
	})

	// 初始化字典数据
	dictionaryController := controllers.NewDictionaryController(db)
	if err := dictionaryController.InitDefaultDictionaries(); err != nil {
		log.Printf("初始化字典数据失败: %v", err)
	} else {
		log.Println("字典数据初始化成功")
	}

	// 初始化系统设置数据
	systemSettingController := controllers.NewSystemSettingController(db)
	if err := systemSettingController.InitDefaultSettings(); err != nil {
		log.Printf("初始化系统设置失败: %v", err)
	} else {
		log.Println("系统设置初始化成功")
	}

	// 启动服务
	serverPort := config.GetServerPort()
	log.Printf("服务启动在端口%s，模式：%s\n", serverPort, config.GetServerMode())
	if err := r.Run(serverPort); err != nil {
		log.Fatal("服务启动失败: ", err)
	}
}
