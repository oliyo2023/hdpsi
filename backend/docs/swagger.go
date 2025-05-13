package docs

import (
	"hd_psi/backend/config"
)

// 初始化配置
func init() {
	config.InitConfig()
}

// @title           HD-PSI 服装进销存系统 API
// @version         1.0
// @description     服装行业进销存管理系统API文档
// @termsOfService  http://swagger.io/terms/

// @contact.name   API Support
// @contact.url    http://www.example.com/support
// @contact.email  support@example.com

// @license.name  Apache 2.0
// @license.url   http://www.apache.org/licenses/LICENSE-2.0.html

// @host      localhost:8081
// @BasePath  /api/v1

// @securityDefinitions.apikey  BearerAuth
// @in                          header
// @name                        Authorization
// @description                 JWT授权令牌，格式: Bearer {token}

// @x-extension-openapi {"example": "value on a json format"}

// @tag.name 供应商管理
// @tag.description 供应商信息的增删改查
// @tag.docs.url https://example.com/suppliers
// @tag.docs.description 供应商管理详细文档

// @tag.name 商品管理
// @tag.description 商品信息的增删改查
// @tag.docs.url https://example.com/products
// @tag.docs.description 商品管理详细文档

// @tag.name 库存管理
// @tag.description 库存信息的增删改查
// @tag.docs.url https://example.com/inventory
// @tag.docs.description 库存管理详细文档

// @tag.name 会员管理
// @tag.description 会员信息的增删改查
// @tag.docs.url https://example.com/members
// @tag.docs.description 会员管理详细文档
