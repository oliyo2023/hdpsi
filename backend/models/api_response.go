package models

// APIResponse 通用API响应结构
type APIResponse struct {
	Code    int         `json:"code" example:"200"`                // 状态码
	Message string      `json:"message" example:"操作成功"`          // 响应消息
	Data    interface{} `json:"data,omitempty"`                   // 响应数据
	Error   string      `json:"error,omitempty" example:"错误信息"` // 错误信息，仅在发生错误时返回
}

// PaginatedResponse 分页响应结构
type PaginatedResponse struct {
	Items    interface{} `json:"items"`                      // 数据项列表
	Total    int64       `json:"total" example:"100"`        // 总记录数
	Page     int         `json:"page" example:"1"`           // 当前页码
	PageSize int         `json:"pageSize" example:"10"`      // 每页记录数
}

// ErrorResponse 错误响应结构
type ErrorResponse struct {
	Code    int    `json:"code" example:"400"`       // 错误码
	Message string `json:"message" example:"参数错误"` // 错误消息
	Error   string `json:"error,omitempty"`          // 详细错误信息，仅在开发环境返回
}
