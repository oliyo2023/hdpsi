package main

import (
	"bufio"
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"
	"regexp"
	"strings"
)

// 控制器方法的正则表达式
var funcRegex = regexp.MustCompile(`func \(\w+ \*(\w+)\) (\w+)\(c \*gin\.Context\)`)

// 路由路径映射
var routePathMap = map[string]string{
	"AuthController":                   "/auth",
	"DashboardController":              "/dashboard",
	"DictionaryController":             "/dictionaries",
	"FileController":                   "/files",
	"FittingController":                "/fitting",
	"InventoryAlertController":         "/inventory-alerts",
	"InventoryCheckController":         "/inventory-checks",
	"InventoryController":              "/inventory",
	"InventoryThresholdController":     "/inventory-thresholds",
	"InventoryTransactionController":   "/inventory-transactions",
	"MemberController":                 "/members",
	"MemberPointsController":           "/members/{id}/points",
	"ProductController":                "/products",
	"PurchaseController":               "/purchases",
	"PurchaseOrderController":          "/purchases",
	"PurchaseReceivingController":      "/purchase-receivings",
	"SalesController":                  "/sales",
	"StoreController":                  "/stores",
	"SupplierController":               "/suppliers",
	"SystemSettingController":          "/settings",
	"WechatController":                 "/wechat",
}

// 方法名到HTTP方法的映射
var methodMap = map[string]string{
	"List":     "get",
	"Get":      "get",
	"Create":   "post",
	"Update":   "put",
	"Delete":   "delete",
	"Login":    "post",
	"Register": "post",
	"Refresh":  "post",
	"Upload":   "post",
	"Download": "get",
}

// 方法名到标签的映射
var tagMap = map[string]string{
	"AuthController":                   "认证管理",
	"DashboardController":              "仪表盘",
	"DictionaryController":             "字典管理",
	"FileController":                   "文件管理",
	"FittingController":                "试衣管理",
	"InventoryAlertController":         "库存预警",
	"InventoryCheckController":         "库存盘点",
	"InventoryController":              "库存管理",
	"InventoryThresholdController":     "库存阈值",
	"InventoryTransactionController":   "库存交易",
	"MemberController":                 "会员管理",
	"MemberPointsController":           "会员积分",
	"ProductController":                "商品管理",
	"PurchaseController":               "采购管理",
	"PurchaseOrderController":          "采购订单",
	"PurchaseReceivingController":      "采购入库",
	"SalesController":                  "销售管理",
	"StoreController":                  "店铺管理",
	"SupplierController":               "供应商管理",
	"SystemSettingController":          "系统设置",
	"WechatController":                 "微信管理",
}

func main() {
	// 控制器目录
	controllersDir := "controllers"

	// 获取所有控制器文件
	files, err := ioutil.ReadDir(controllersDir)
	if err != nil {
		fmt.Printf("读取控制器目录失败: %v\n", err)
		return
	}

	// 处理每个控制器文件
	for _, file := range files {
		if !file.IsDir() && strings.HasSuffix(file.Name(), "_controller.go") && !strings.HasSuffix(file.Name(), ".new") {
			processControllerFile(filepath.Join(controllersDir, file.Name()))
		}
	}

	fmt.Println("Swagger注释添加完成！")
}

func processControllerFile(filePath string) {
	fmt.Printf("处理文件: %s\n", filePath)

	// 读取文件内容
	content, err := ioutil.ReadFile(filePath)
	if err != nil {
		fmt.Printf("读取文件失败: %v\n", err)
		return
	}

	// 创建临时文件
	tempFilePath := filePath + ".temp"
	tempFile, err := os.Create(tempFilePath)
	if err != nil {
		fmt.Printf("创建临时文件失败: %v\n", err)
		return
	}
	defer tempFile.Close()

	writer := bufio.NewWriter(tempFile)

	// 逐行处理文件内容
	scanner := bufio.NewScanner(strings.NewReader(string(content)))
	for scanner.Scan() {
		line := scanner.Text()

		// 查找控制器方法
		matches := funcRegex.FindStringSubmatch(line)
		if len(matches) == 3 {
			controllerName := matches[1]
			methodName := matches[2]

			// 获取HTTP方法
			httpMethod := "get" // 默认为GET
			for prefix, method := range methodMap {
				if strings.HasPrefix(methodName, prefix) {
					httpMethod = method
					break
				}
			}

			// 获取路由路径
			routePath := routePathMap[controllerName]
			if routePath == "" {
				routePath = "/" + strings.ToLower(strings.TrimSuffix(controllerName, "Controller"))
			}

			// 获取标签
			tag := tagMap[controllerName]
			if tag == "" {
				tag = controllerName
			}

			// 生成Swagger注释
			swaggerComment := fmt.Sprintf(`// %s godoc
// @Summary %s
// @Description %s
// @Tags %s
// @Accept json
// @Produce json
// @Success 200 {object} map[string]interface{} "成功"
// @Failure 400 {object} map[string]interface{} "请求参数错误"
// @Failure 500 {object} map[string]interface{} "服务器内部错误"
// @Router %s [%s]
// @Security BearerAuth
`, methodName, methodName, methodName, tag, routePath, httpMethod)

			// 写入Swagger注释
			writer.WriteString(swaggerComment)
		}

		// 写入原始行
		writer.WriteString(line + "\n")
	}

	writer.Flush()

	// 替换原始文件
	err = os.Rename(tempFilePath, filePath)
	if err != nil {
		fmt.Printf("替换文件失败: %v\n", err)
		return
	}

	fmt.Printf("文件处理完成: %s\n", filePath)
}
