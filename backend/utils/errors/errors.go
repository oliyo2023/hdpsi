package errors

import (
	"fmt"
	"net/http"
)

// 错误类型常量
const (
	// 通用错误
	ErrInternal           = "internal_error"
	ErrInvalidInput       = "invalid_input"
	ErrNotFound           = "not_found"
	ErrUnauthorized       = "unauthorized"
	ErrForbidden          = "forbidden"
	ErrConflict           = "conflict"
	ErrTooManyRequests    = "too_many_requests"
	ErrServiceUnavailable = "service_unavailable"
	ErrInvalidOperation   = "invalid_operation"

	// 数据库错误
	ErrDatabaseConnection = "database_connection_error"
	ErrDatabaseQuery      = "database_query_error"
	ErrDatabaseInsert     = "database_insert_error"
	ErrDatabaseUpdate     = "database_update_error"
	ErrDatabaseDelete     = "database_delete_error"

	// 用户相关错误
	ErrUserNotFound       = "user_not_found"
	ErrUserAlreadyExists  = "user_already_exists"
	ErrInvalidCredentials = "invalid_credentials"
	ErrUserDisabled       = "user_disabled"
	ErrUserLocked         = "user_locked"
	ErrPasswordTooShort   = "password_too_short"

	// 令牌相关错误
	ErrInvalidToken    = "invalid_token"
	ErrTokenExpired    = "token_expired"
	ErrTokenGeneration = "token_generation_error"
)

// AppError 定义应用程序错误结构
type AppError struct {
	// 错误类型
	Type string `json:"type"`
	// 错误消息
	Message string `json:"error"`
	// 错误详情
	Details string `json:"details,omitempty"`
	// 请求ID
	RequestID string `json:"request_id,omitempty"`
	// 原始错误
	Err error `json:"-"`
}

// Error 实现error接口
func (e *AppError) Error() string {
	if e.Err != nil {
		return fmt.Sprintf("%s: %s (%s)", e.Message, e.Details, e.Err.Error())
	}
	return fmt.Sprintf("%s: %s", e.Message, e.Details)
}

// HTTPStatus 返回对应的HTTP状态码
func (e *AppError) HTTPStatus() int {
	switch e.Type {
	case ErrInvalidInput:
		return http.StatusBadRequest
	case ErrNotFound, ErrUserNotFound:
		return http.StatusNotFound
	case ErrUnauthorized, ErrInvalidToken, ErrTokenExpired:
		return http.StatusUnauthorized
	case ErrForbidden:
		return http.StatusForbidden
	case ErrConflict, ErrUserAlreadyExists:
		return http.StatusConflict
	case ErrTooManyRequests, ErrUserLocked:
		return http.StatusTooManyRequests
	case ErrServiceUnavailable:
		return http.StatusServiceUnavailable
	default:
		return http.StatusInternalServerError
	}
}

// New 创建一个新的AppError
func New(errType string) *AppError {
	message := errTypeToMessage(errType)
	return &AppError{
		Type:    errType,
		Message: message,
	}
}

// Wrap 将原始错误包装为AppError
func Wrap(err error, errType string) *AppError {
	message := errTypeToMessage(errType)
	return &AppError{
		Type:    errType,
		Message: message,
		Err:     err,
	}
}

// WithDetails 添加错误详情
func (e *AppError) WithDetails(details string) *AppError {
	e.Details = details
	return e
}

// WithError 添加原始错误
func (e *AppError) WithError(err error) *AppError {
	e.Err = err
	return e
}

// WithRequestID 添加请求ID
func (e *AppError) WithRequestID(requestID string) *AppError {
	e.RequestID = requestID
	return e
}

// ShouldAlert 判断是否需要发送告警
// 返回：
//   - bool: 如果错误需要发送告警返回true，否则返回false
func (e *AppError) ShouldAlert() bool {
	// 内部错误、数据库错误和服务不可用错误需要告警
	switch e.Type {
	case ErrInternal,
		ErrDatabaseConnection,
		ErrDatabaseQuery,
		ErrDatabaseInsert,
		ErrDatabaseUpdate,
		ErrDatabaseDelete,
		ErrServiceUnavailable:
		return true
	default:
		return false
	}
}

// ToResponse 将错误转换为HTTP响应
// 参数：
//   - err: 应用程序错误对象
//
// 返回：
//   - int: HTTP状态码
//   - map[string]interface{}: 响应体
func ToResponse(err *AppError) (int, map[string]interface{}) {
	status := err.HTTPStatus()
	response := map[string]interface{}{
		"error": err.Message,
	}

	if err.Details != "" {
		response["details"] = err.Details
	}

	if err.RequestID != "" {
		response["request_id"] = err.RequestID
	}

	return status, response
}

// errTypeToMessage 将错误类型转换为用户友好的消息
func errTypeToMessage(errType string) string {
	switch errType {
	case ErrInternal:
		return "服务器内部错误"
	case ErrInvalidInput:
		return "无效的输入参数"
	case ErrNotFound:
		return "请求的资源不存在"
	case ErrUnauthorized:
		return "未授权的请求"
	case ErrForbidden:
		return "禁止访问"
	case ErrConflict:
		return "资源冲突"
	case ErrTooManyRequests:
		return "请求过于频繁"
	case ErrServiceUnavailable:
		return "服务暂时不可用"
	case ErrDatabaseConnection:
		return "数据库连接错误"
	case ErrDatabaseQuery:
		return "数据库查询错误"
	case ErrDatabaseInsert:
		return "数据库插入错误"
	case ErrDatabaseUpdate:
		return "数据库更新错误"
	case ErrDatabaseDelete:
		return "数据库删除错误"
	case ErrUserNotFound:
		return "用户不存在"
	case ErrUserAlreadyExists:
		return "用户已存在"
	case ErrInvalidCredentials:
		return "无效的凭证"
	case ErrUserDisabled:
		return "用户已被禁用"
	case ErrUserLocked:
		return "用户已被锁定"
	case ErrPasswordTooShort:
		return "密码太短"
	case ErrInvalidToken:
		return "无效的令牌"
	case ErrTokenExpired:
		return "令牌已过期"
	case ErrTokenGeneration:
		return "令牌生成错误"
	default:
		return "未知错误"
	}
}
