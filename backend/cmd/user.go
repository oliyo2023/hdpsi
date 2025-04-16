package main

import (
	"fmt"
	"hd_psi/backend/config"
	"hd_psi/backend/models"
	"log"
	"os"
	"strings"

	"github.com/spf13/cobra"
	"gorm.io/driver/mysql"
	"gorm.io/gorm"
)

// 定义命令行参数
var (
	username string
	password string
	name     string
	email    string
	phone    string
	role     string
	storeID  uint
)

// 支持的角色列表
var validRoles = map[string]bool{
	"admin":    true,
	"manager":  true,
	"staff":    true,
	"cashier":  true,
	"operator": true,
}

// 用户命令
var userCmd = &cobra.Command{
	Use:   "user",
	Short: "用户管理",
	Long:  `用户管理命令，用于创建、查询用户等操作。`,
}

// 创建用户命令
var createUserCmd = &cobra.Command{
	Use:   "create",
	Short: "创建新用户",
	Long:  `创建新用户，设置用户名、密码、角色等信息。`,
	Run: func(cmd *cobra.Command, args []string) {
		// 验证必填参数
		if username == "" || password == "" || name == "" {
			fmt.Println("错误: 用户名、密码和姓名为必填项")
			cmd.Help()
			os.Exit(1)
		}

		// 验证角色
		role = strings.ToLower(role)
		if !validRoles[role] {
			fmt.Printf("错误: 无效的角色 '%s'。有效角色: admin, manager, staff, cashier, operator\n", role)
			os.Exit(1)
		}

		// 连接数据库
		dsn := config.GetDBConfig()
		db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{})
		if err != nil {
			log.Fatalf("数据库连接失败: %v", err)
		}

		// 检查用户名是否已存在
		var existingUser models.User
		if err := db.Where("username = ?", username).First(&existingUser).Error; err == nil {
			fmt.Printf("错误: 用户名 '%s' 已存在\n", username)
			os.Exit(1)
		}

		// 创建用户
		var storeIDPtr *uint
		if storeID > 0 {
			storeIDPtr = &storeID
		}

		user := models.User{
			Username: username,
			Password: password, // 密码会在BeforeSave钩子中自动加密
			Name:     name,
			Email:    email,
			Phone:    phone,
			Role:     models.Role(role),
			StoreID:  storeIDPtr,
			Status:   true,
		}

		if err := db.Create(&user).Error; err != nil {
			log.Fatalf("创建用户失败: %v", err)
		}

		fmt.Printf("用户创建成功!\n")
		fmt.Printf("用户名: %s\n", username)
		fmt.Printf("姓名: %s\n", name)
		fmt.Printf("角色: %s\n", role)
		if storeID > 0 {
			fmt.Printf("店铺ID: %d\n", storeID)
		} else {
			fmt.Printf("店铺: 总部\n")
		}
	},
}

func init() {
	// 添加创建用户子命令
	userCmd.AddCommand(createUserCmd)

	// 设置创建用户命令的参数
	createUserCmd.Flags().StringVar(&username, "username", "", "用户登录名 (必填)")
	createUserCmd.Flags().StringVar(&password, "password", "", "用户密码 (必填)")
	createUserCmd.Flags().StringVar(&name, "name", "", "用户姓名 (必填)")
	createUserCmd.Flags().StringVar(&email, "email", "", "电子邮箱")
	createUserCmd.Flags().StringVar(&phone, "phone", "", "手机号码")
	createUserCmd.Flags().StringVar(&role, "role", "staff", "用户角色 (admin/manager/staff/cashier/operator)")
	createUserCmd.Flags().UintVar(&storeID, "store", 0, "所属店铺ID (0表示总部)")
}
