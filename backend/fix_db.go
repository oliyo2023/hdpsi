package main

import (
	"hd_psi/backend/config"
	"log"
	"time"

	"gorm.io/driver/mysql"
	"gorm.io/gorm"
)

func main() {
	// 初始化配置
	config.InitConfig()

	// 连接数据库
	dsn := config.GetDBConfig()
	db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{
		NowFunc: func() time.Time {
			return time.Now().Local() // 使用本地时间
		},
	})
	if err != nil {
		log.Fatal("数据库连接失败: ", err)
	}

	log.Println("开始修复数据库...")

	// 禁用外键约束检查
	db.Exec("SET FOREIGN_KEY_CHECKS = 0")

	// 删除现有的表
	log.Println("删除现有的商品相关表...")
	db.Exec("DROP TABLE IF EXISTS product_variants")
	db.Exec("DROP TABLE IF EXISTS products")

	// 重新创建表
	log.Println("重新创建商品表...")

	// 直接使用SQL创建表，而不是使用GORM的AutoMigrate
	db.Exec(`CREATE TABLE products (
		id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
		sku VARCHAR(255) UNIQUE,
		name VARCHAR(255) NOT NULL,
		category_id BIGINT UNSIGNED,
		brand_id BIGINT UNSIGNED,
		image VARCHAR(255),
		images TEXT,
		description TEXT,
		cost_price DOUBLE,
		retail_price DOUBLE,
		status BOOLEAN DEFAULT TRUE,
		created_at DATETIME(3),
		updated_at DATETIME(3)
	)`)

	db.Exec(`CREATE TABLE product_variants (
		id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
		product_id BIGINT UNSIGNED NOT NULL,
		sku VARCHAR(255) UNIQUE,
		color_id BIGINT UNSIGNED,
		size_id BIGINT UNSIGNED,
		season_id BIGINT UNSIGNED,
		fabric_id BIGINT UNSIGNED,
		barcode VARCHAR(100),
		qr_code VARCHAR(255),
		cost_price DOUBLE,
		retail_price DOUBLE,
		status BOOLEAN DEFAULT TRUE,
		created_at DATETIME(3),
		updated_at DATETIME(3),
		INDEX idx_product_variants_product_id (product_id)
	)`)

	// 添加测试数据
	db.Exec(`INSERT INTO products (sku, name, cost_price, retail_price, status) VALUES
		('MS001', '男士休闲衬衫', 80, 199, TRUE),
		('WD001', '女士连衣裙', 120, 299, TRUE),
		('MT001', '男士T恤', 50, 129, TRUE),
		('WS001', '女士衬衫', 70, 179, TRUE),
		('MJ001', '男士牛仔裤', 100, 259, TRUE)
	`)

	// 重新启用外键约束检查
	db.Exec("SET FOREIGN_KEY_CHECKS = 1")

	log.Println("数据库修复完成!")
}
