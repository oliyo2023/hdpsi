package errors

// 错误码常量
// 错误码规则：
// 1. 成功响应: 200xx
// 2. 客户端错误: 4xxxx
// 3. 服务器错误: 5xxxx
// 4. 业务错误: 6xxxx
const (
	// 成功响应码
	CodeSuccess           = 20000 // 操作成功
	CodeCreated           = 20001 // 创建成功
	CodeAccepted          = 20002 // 请求已接受
	CodeNoContent         = 20004 // 无内容

	// 客户端错误码 (4xxxx)
	CodeBadRequest        = 40000 // 请求参数错误
	CodeUnauthorized      = 40100 // 未授权
	CodeTokenExpired      = 40101 // 令牌已过期
	CodeInvalidToken      = 40102 // 无效的令牌
	CodeForbidden         = 40300 // 禁止访问
	CodeNotFound          = 40400 // 资源不存在
	CodeMethodNotAllowed  = 40500 // 方法不允许
	CodeConflict          = 40900 // 资源冲突
	CodeTooManyRequests   = 42900 // 请求过于频繁

	// 服务器错误码 (5xxxx)
	CodeInternalError     = 50000 // 服务器内部错误
	CodeNotImplemented    = 50100 // 功能未实现
	CodeServiceUnavailable = 50300 // 服务不可用
	CodeDatabaseError     = 50400 // 数据库错误
	CodeDatabaseConnection = 50401 // 数据库连接错误
	CodeDatabaseQuery     = 50402 // 数据库查询错误
	CodeDatabaseInsert    = 50403 // 数据库插入错误
	CodeDatabaseUpdate    = 50404 // 数据库更新错误
	CodeDatabaseDelete    = 50405 // 数据库删除错误

	// 业务错误码 (6xxxx)
	// 用户相关 (61xxx)
	CodeUserNotFound      = 61001 // 用户不存在
	CodeUserAlreadyExists = 61002 // 用户已存在
	CodeInvalidCredentials = 61003 // 无效的凭证
	CodeUserDisabled      = 61004 // 用户已被禁用
	CodeUserLocked        = 61005 // 用户已被锁定
	CodePasswordTooShort  = 61006 // 密码太短
	
	// 商品相关 (62xxx)
	CodeProductNotFound   = 62001 // 商品不存在
	CodeProductOutOfStock = 62002 // 商品库存不足
	CodeProductDisabled   = 62003 // 商品已下架
	
	// 订单相关 (63xxx)
	CodeOrderNotFound     = 63001 // 订单不存在
	CodeOrderStatusError  = 63002 // 订单状态错误
	CodeOrderCreateFailed = 63003 // 订单创建失败
	
	// 库存相关 (64xxx)
	CodeInventoryNotEnough = 64001 // 库存不足
	CodeInventoryOpFailed  = 64002 // 库存操作失败
	
	// 会员相关 (65xxx)
	CodeMemberNotFound    = 65001 // 会员不存在
	CodeMemberDisabled    = 65002 // 会员已禁用
	
	// 供应商相关 (66xxx)
	CodeSupplierNotFound  = 66001 // 供应商不存在
	
	// 文件相关 (67xxx)
	CodeFileUploadFailed  = 67001 // 文件上传失败
	CodeFileNotFound      = 67002 // 文件不存在
	CodeFileTypeNotAllowed = 67003 // 文件类型不允许
	CodeFileTooLarge      = 67004 // 文件太大
)

// 错误码与消息映射
var codeMessageMap = map[int]string{
	// 成功响应
	CodeSuccess:           "操作成功",
	CodeCreated:           "创建成功",
	CodeAccepted:          "请求已接受",
	CodeNoContent:         "无内容",

	// 客户端错误
	CodeBadRequest:        "请求参数错误",
	CodeUnauthorized:      "未授权",
	CodeTokenExpired:      "令牌已过期",
	CodeInvalidToken:      "无效的令牌",
	CodeForbidden:         "禁止访问",
	CodeNotFound:          "资源不存在",
	CodeMethodNotAllowed:  "方法不允许",
	CodeConflict:          "资源冲突",
	CodeTooManyRequests:   "请求过于频繁",

	// 服务器错误
	CodeInternalError:     "服务器内部错误",
	CodeNotImplemented:    "功能未实现",
	CodeServiceUnavailable: "服务不可用",
	CodeDatabaseError:     "数据库错误",
	CodeDatabaseConnection: "数据库连接错误",
	CodeDatabaseQuery:     "数据库查询错误",
	CodeDatabaseInsert:    "数据库插入错误",
	CodeDatabaseUpdate:    "数据库更新错误",
	CodeDatabaseDelete:    "数据库删除错误",

	// 业务错误
	CodeUserNotFound:      "用户不存在",
	CodeUserAlreadyExists: "用户已存在",
	CodeInvalidCredentials: "无效的凭证",
	CodeUserDisabled:      "用户已被禁用",
	CodeUserLocked:        "用户已被锁定",
	CodePasswordTooShort:  "密码太短",
	CodeProductNotFound:   "商品不存在",
	CodeProductOutOfStock: "商品库存不足",
	CodeProductDisabled:   "商品已下架",
	CodeOrderNotFound:     "订单不存在",
	CodeOrderStatusError:  "订单状态错误",
	CodeOrderCreateFailed: "订单创建失败",
	CodeInventoryNotEnough: "库存不足",
	CodeInventoryOpFailed:  "库存操作失败",
	CodeMemberNotFound:    "会员不存在",
	CodeMemberDisabled:    "会员已禁用",
	CodeSupplierNotFound:  "供应商不存在",
	CodeFileUploadFailed:  "文件上传失败",
	CodeFileNotFound:      "文件不存在",
	CodeFileTypeNotAllowed: "文件类型不允许",
	CodeFileTooLarge:      "文件太大",
}

// GetMessage 根据错误码获取对应的消息
func GetMessage(code int) string {
	if msg, ok := codeMessageMap[code]; ok {
		return msg
	}
	return "未知错误"
}

// GetHTTPStatus 根据错误码获取对应的HTTP状态码
func GetHTTPStatus(code int) int {
	// 根据错误码前两位判断HTTP状态码
	switch {
	case code >= 20000 && code < 30000:
		return 200 // 成功
	case code >= 40000 && code < 41000:
		return 400 // 请求参数错误
	case code >= 41000 && code < 42000:
		return 401 // 未授权
	case code >= 43000 && code < 44000:
		return 403 // 禁止访问
	case code >= 44000 && code < 45000:
		return 404 // 资源不存在
	case code >= 45000 && code < 46000:
		return 405 // 方法不允许
	case code >= 49000 && code < 50000:
		return 409 // 资源冲突
	case code >= 42900 && code < 43000:
		return 429 // 请求过于频繁
	case code >= 50000 && code < 60000:
		return 500 // 服务器内部错误
	case code >= 60000 && code < 70000:
		return 200 // 业务错误，HTTP状态码仍为200，由前端根据code判断
	default:
		return 500 // 默认为服务器内部错误
	}
}
