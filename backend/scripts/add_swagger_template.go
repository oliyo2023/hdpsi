package main

import (
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"
	"strings"
)

// 控制器方法模板
var methodTemplates = map[string]string{
	"auth_controller.go": `// Login godoc
// @Summary 用户登录
// @Description 用户登录并获取JWT令牌
// @Tags 认证管理
// @Accept json
// @Produce json
// @Param login body LoginRequest true "登录信息"
// @Success 200 {object} LoginResponse "登录成功"
// @Failure 400 {object} map[string]interface{} "请求参数错误"
// @Failure 401 {object} map[string]interface{} "用户名或密码错误"
// @Router /auth/login [post]
`,
	"product_controller.go": `// ListProducts godoc
// @Summary 获取商品列表
// @Description 获取商品列表，支持分页和筛选
// @Tags 商品管理
// @Accept json
// @Produce json
// @Param name query string false "商品名称（模糊查询）"
// @Param category query string false "商品分类"
// @Param status query string false "状态（active/inactive）"
// @Param page query int false "页码，默认1"
// @Param limit query int false "每页数量，默认10"
// @Success 200 {object} ProductsResponse "成功"
// @Failure 400 {object} map[string]interface{} "请求参数错误"
// @Failure 500 {object} map[string]interface{} "服务器内部错误"
// @Router /products [get]
// @Security BearerAuth
`,
	"inventory_controller.go": `// ListInventories godoc
// @Summary 获取库存列表
// @Description 获取库存列表，支持分页和筛选
// @Tags 库存管理
// @Accept json
// @Produce json
// @Param product_id query int false "商品ID"
// @Param store_id query int false "店铺ID"
// @Param status query string false "状态（active/inactive）"
// @Param page query int false "页码，默认1"
// @Param limit query int false "每页数量，默认10"
// @Success 200 {object} InventoriesResponse "成功"
// @Failure 400 {object} map[string]interface{} "请求参数错误"
// @Failure 500 {object} map[string]interface{} "服务器内部错误"
// @Router /inventory [get]
// @Security BearerAuth
`,
	"member_controller.go": `// ListMembers godoc
// @Summary 获取会员列表
// @Description 获取会员列表，支持分页和筛选
// @Tags 会员管理
// @Accept json
// @Produce json
// @Param name query string false "会员名称（模糊查询）"
// @Param phone query string false "手机号码（模糊查询）"
// @Param level query string false "会员等级"
// @Param page query int false "页码，默认1"
// @Param limit query int false "每页数量，默认10"
// @Success 200 {object} MembersResponse "成功"
// @Failure 400 {object} map[string]interface{} "请求参数错误"
// @Failure 500 {object} map[string]interface{} "服务器内部错误"
// @Router /members [get]
// @Security BearerAuth
`,
	"sales_controller.go": `// ListOrders godoc
// @Summary 获取销售订单列表
// @Description 获取销售订单列表，支持分页和筛选
// @Tags 销售管理
// @Accept json
// @Produce json
// @Param order_no query string false "订单编号（模糊查询）"
// @Param status query string false "订单状态"
// @Param start_date query string false "开始日期（YYYY-MM-DD）"
// @Param end_date query string false "结束日期（YYYY-MM-DD）"
// @Param page query int false "页码，默认1"
// @Param limit query int false "每页数量，默认10"
// @Success 200 {object} OrdersResponse "成功"
// @Failure 400 {object} map[string]interface{} "请求参数错误"
// @Failure 500 {object} map[string]interface{} "服务器内部错误"
// @Router /sales/orders [get]
// @Security BearerAuth
`,
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

	// 创建模板文件
	for fileName, template := range methodTemplates {
		filePath := filepath.Join(controllersDir, fileName+".template")
		err := ioutil.WriteFile(filePath, []byte(template), 0644)
		if err != nil {
			fmt.Printf("创建模板文件失败: %v\n", err)
			continue
		}
		fmt.Printf("创建模板文件: %s\n", filePath)
	}

	fmt.Println("Swagger模板创建完成！")
}
