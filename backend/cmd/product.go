package main

import (
	"encoding/csv"
	"fmt"
	"hd_psi/backend/config"
	"hd_psi/backend/models"
	"io"
	"log"
	"os"
	"strconv"
	"strings"

	"github.com/spf13/cobra"
	"gorm.io/driver/mysql"
	"gorm.io/gorm"
)

// 定义商品命令行参数
var (
	sku         string
	productName string
	color       string
	size        string
	season      string
	category    string
	image       string
	costPrice   float64
	retailPrice float64
	csvFile     string
)

// 商品命令
var productCmd = &cobra.Command{
	Use:   "product",
	Short: "商品管理",
	Long:  `商品管理命令，用于创建、查询商品等操作。`,
}

// 创建单个商品命令
var createProductCmd = &cobra.Command{
	Use:   "create",
	Short: "创建单个商品",
	Long:  `创建单个商品，设置SKU、名称、价格等信息。`,
	Run: func(cmd *cobra.Command, args []string) {
		// 验证必填参数
		if sku == "" || productName == "" {
			fmt.Println("错误: SKU和商品名称为必填项")
			cmd.Help()
			os.Exit(1)
		}

		// 连接数据库
		dsn := config.GetDBConfig()
		db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{})
		if err != nil {
			log.Fatalf("数据库连接失败: %v", err)
		}

		// 检查SKU是否已存在
		var existingProduct models.Product
		if err := db.Where("sku = ?", sku).First(&existingProduct).Error; err == nil {
			fmt.Printf("错误: SKU '%s' 已存在\n", sku)
			os.Exit(1)
		}

		// 创建商品
		product := models.Product{
			SKU:         sku,
			Name:        productName,
			Image:       image,
			CostPrice:   costPrice,
			RetailPrice: retailPrice,
		}

		if err := db.Create(&product).Error; err != nil {
			log.Fatalf("创建商品失败: %v", err)
		}

		fmt.Printf("商品创建成功! ID: %d, SKU: %s, 名称: %s\n", product.ID, product.SKU, product.Name)
	},
}

// 批量导入商品命令
var batchProductCmd = &cobra.Command{
	Use:   "batch",
	Short: "批量导入商品",
	Long:  `从CSV文件批量导入商品数据。`,
	Run: func(cmd *cobra.Command, args []string) {
		// 验证必填参数
		if csvFile == "" {
			fmt.Println("错误: 请提供CSV文件路径")
			cmd.Help()
			os.Exit(1)
		}

		// 打开CSV文件
		file, err := os.Open(csvFile)
		if err != nil {
			log.Fatalf("无法打开CSV文件: %v", err)
		}
		defer file.Close()

		// 连接数据库
		dsn := config.GetDBConfig()
		db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{})
		if err != nil {
			log.Fatalf("数据库连接失败: %v", err)
		}

		// 读取CSV文件
		reader := csv.NewReader(file)
		reader.Comma = ',' // 设置分隔符
		reader.LazyQuotes = true

		// 读取标题行
		header, err := reader.Read()
		if err != nil {
			log.Fatalf("读取CSV标题行失败: %v", err)
		}

		// 验证CSV格式
		requiredColumns := []string{"sku", "name"}
		for _, col := range requiredColumns {
			found := false
			for _, h := range header {
				if strings.ToLower(h) == col {
					found = true
					break
				}
			}
			if !found {
				log.Fatalf("CSV文件缺少必要的列: %s", col)
			}
		}

		// 获取列索引
		colIndex := make(map[string]int)
		for i, h := range header {
			colIndex[strings.ToLower(h)] = i
		}

		// 读取并处理每一行
		lineNum := 1 // 标题行是第1行
		successCount := 0
		errorCount := 0

		for {
			lineNum++
			record, err := reader.Read()
			if err == io.EOF {
				break
			}
			if err != nil {
				fmt.Printf("警告: 第%d行读取失败: %v\n", lineNum, err)
				errorCount++
				continue
			}

			// 提取数据
			sku := getColumnValue(record, colIndex, "sku")
			name := getColumnValue(record, colIndex, "name")

			// 验证必填字段
			if sku == "" || name == "" {
				fmt.Printf("警告: 第%d行缺少必填字段 (SKU或名称)\n", lineNum)
				errorCount++
				continue
			}

			// 检查SKU是否已存在
			var existingProduct models.Product
			if err := db.Where("sku = ?", sku).First(&existingProduct).Error; err == nil {
				fmt.Printf("警告: 第%d行的SKU '%s' 已存在\n", lineNum, sku)
				errorCount++
				continue
			}

			// 创建商品
			product := models.Product{
				SKU:   sku,
				Name:  name,
				Image: getColumnValue(record, colIndex, "image"),
			}

			// 处理价格
			if costStr := getColumnValue(record, colIndex, "cost"); costStr != "" {
				if cost, err := strconv.ParseFloat(costStr, 64); err == nil {
					product.CostPrice = cost
				} else {
					fmt.Printf("警告: 第%d行的成本价格格式无效: %s\n", lineNum, costStr)
				}
			}

			if retailStr := getColumnValue(record, colIndex, "retail"); retailStr != "" {
				if retail, err := strconv.ParseFloat(retailStr, 64); err == nil {
					product.RetailPrice = retail
				} else {
					fmt.Printf("警告: 第%d行的零售价格格式无效: %s\n", lineNum, retailStr)
				}
			}

			// 保存到数据库
			if err := db.Create(&product).Error; err != nil {
				fmt.Printf("错误: 第%d行保存失败: %v\n", lineNum, err)
				errorCount++
				continue
			}

			fmt.Printf("成功: 第%d行 - 商品 '%s' (SKU: %s) 已添加\n", lineNum, product.Name, product.SKU)
			successCount++
		}

		// 打印总结
		fmt.Printf("\n导入完成: 成功 %d 条, 失败 %d 条\n", successCount, errorCount)
	},
}

// 获取列值，不区分大小写
func getColumnValue(record []string, colIndex map[string]int, colName string) string {
	if idx, ok := colIndex[colName]; ok && idx < len(record) {
		return strings.TrimSpace(record[idx])
	}
	return ""
}

func init() {
	// 添加创建商品子命令
	productCmd.AddCommand(createProductCmd)

	// 设置创建商品命令的参数
	createProductCmd.Flags().StringVar(&sku, "sku", "", "商品SKU编码 (必填)")
	createProductCmd.Flags().StringVar(&productName, "name", "", "商品名称 (必填)")
	createProductCmd.Flags().StringVar(&color, "color", "", "商品颜色")
	createProductCmd.Flags().StringVar(&size, "size", "", "商品尺码")
	createProductCmd.Flags().StringVar(&season, "season", "", "商品季节")
	createProductCmd.Flags().StringVar(&category, "category", "", "商品类别")
	createProductCmd.Flags().StringVar(&image, "image", "", "商品图片URL")
	createProductCmd.Flags().Float64Var(&costPrice, "cost", 0, "成本价")
	createProductCmd.Flags().Float64Var(&retailPrice, "retail", 0, "零售价")

	// 设置批量导入商品命令的参数
	batchProductCmd.Flags().StringVar(&csvFile, "file", "", "CSV文件路径 (必填)")
}
