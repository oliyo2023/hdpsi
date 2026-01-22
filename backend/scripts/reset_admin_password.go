package main

import (
	"fmt"
	"hd_psi/backend/config"
	"hd_psi/backend/models"
	"hd_psi/backend/utils"
	"log"

	"github.com/glebarez/sqlite"
	"gorm.io/gorm"
)

func main() {
	// 初始化配置
	config.InitConfig()

	// 获取数据库配置
	dbType, dsn := config.GetDBConfig()
	fmt.Printf("数据库类型: %s, DSN: %s\n", dbType, dsn)

	// 连接数据库
	var db *gorm.DB
	var err error

	switch dbType {
	case "sqlite":
		db, err = gorm.Open(sqlite.Open(dsn), &gorm.Config{})
	default:
		log.Fatal("不支持的数据库类型")
	}

	if err != nil {
		log.Fatal("数据库连接失败:", err)
	}

	// 查找admin用户
	var user models.User
	if err := db.Where("username = ?", "admin").First(&user).Error; err != nil {
		log.Fatal("找不到admin用户:", err)
	}

	fmt.Printf("找到用户: %s (ID: %d)\n", user.Username, user.ID)

	// 重置密码为123456
	newPassword := "123456"
	hashedPassword, err := utils.HashPassword(newPassword)
	if err != nil {
		log.Fatal("密码加密失败:", err)
	}

	// 更新密码
	if err := db.Model(&user).Update("password", hashedPassword).Error; err != nil {
		log.Fatal("更新密码失败:", err)
	}

	fmt.Printf("成功将用户 %s 的密码重置为: %s\n", user.Username, newPassword)
	fmt.Println("请使用以下凭据登录:")
	fmt.Printf("  用户名: %s\n", user.Username)
	fmt.Printf("  密码: %s\n", newPassword)
}