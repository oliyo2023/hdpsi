package response

import (
	"hd_psi/backend/models"
	"hd_psi/backend/utils/errors"
	"net/http"

	"github.com/gin-gonic/gin"
)

// Success 返回成功响应
// 参数：
//   - c: Gin上下文
//   - data: 响应数据
func Success(c *gin.Context, data interface{}) {
	c.JSON(http.StatusOK, models.APIResponse{
		Code:    errors.CodeSuccess,
		Message: errors.GetMessage(errors.CodeSuccess),
		Data:    data,
	})
}

// Created 返回创建成功响应
// 参数：
//   - c: Gin上下文
//   - data: 创建的资源数据
func Created(c *gin.Context, data interface{}) {
	c.JSON(http.StatusCreated, models.APIResponse{
		Code:    errors.CodeCreated,
		Message: errors.GetMessage(errors.CodeCreated),
		Data:    data,
	})
}

// NoContent 返回无内容响应
// 参数：
//   - c: Gin上下文
func NoContent(c *gin.Context) {
	c.JSON(http.StatusOK, models.APIResponse{
		Code:    errors.CodeNoContent,
		Message: errors.GetMessage(errors.CodeNoContent),
	})
}

// Fail 返回失败响应
// 参数：
//   - c: Gin上下文
//   - code: 错误码
//   - err: 错误信息（可选）
func Fail(c *gin.Context, code int, err ...string) {
	httpStatus := errors.GetHTTPStatus(code)
	message := errors.GetMessage(code)
	
	resp := models.APIResponse{
		Code:    code,
		Message: message,
	}
	
	// 如果提供了错误信息，则添加到响应中
	if len(err) > 0 && err[0] != "" {
		resp.Error = err[0]
	}
	
	c.JSON(httpStatus, resp)
}

// BadRequest 返回请求参数错误响应
// 参数：
//   - c: Gin上下文
//   - err: 错误信息（可选）
func BadRequest(c *gin.Context, err ...string) {
	Fail(c, errors.CodeBadRequest, err...)
}

// Unauthorized 返回未授权响应
// 参数：
//   - c: Gin上下文
//   - err: 错误信息（可选）
func Unauthorized(c *gin.Context, err ...string) {
	Fail(c, errors.CodeUnauthorized, err...)
}

// Forbidden 返回禁止访问响应
// 参数：
//   - c: Gin上下文
//   - err: 错误信息（可选）
func Forbidden(c *gin.Context, err ...string) {
	Fail(c, errors.CodeForbidden, err...)
}

// NotFound 返回资源不存在响应
// 参数：
//   - c: Gin上下文
//   - err: 错误信息（可选）
func NotFound(c *gin.Context, err ...string) {
	Fail(c, errors.CodeNotFound, err...)
}

// MethodNotAllowed 返回方法不允许响应
// 参数：
//   - c: Gin上下文
//   - err: 错误信息（可选）
func MethodNotAllowed(c *gin.Context, err ...string) {
	Fail(c, errors.CodeMethodNotAllowed, err...)
}

// Conflict 返回资源冲突响应
// 参数：
//   - c: Gin上下文
//   - err: 错误信息（可选）
func Conflict(c *gin.Context, err ...string) {
	Fail(c, errors.CodeConflict, err...)
}

// TooManyRequests 返回请求过于频繁响应
// 参数：
//   - c: Gin上下文
//   - err: 错误信息（可选）
func TooManyRequests(c *gin.Context, err ...string) {
	Fail(c, errors.CodeTooManyRequests, err...)
}

// InternalError 返回服务器内部错误响应
// 参数：
//   - c: Gin上下文
//   - err: 错误信息（可选）
func InternalError(c *gin.Context, err ...string) {
	Fail(c, errors.CodeInternalError, err...)
}

// ServiceUnavailable 返回服务不可用响应
// 参数：
//   - c: Gin上下文
//   - err: 错误信息（可选）
func ServiceUnavailable(c *gin.Context, err ...string) {
	Fail(c, errors.CodeServiceUnavailable, err...)
}

// DatabaseError 返回数据库错误响应
// 参数：
//   - c: Gin上下文
//   - err: 错误信息（可选）
func DatabaseError(c *gin.Context, err ...string) {
	Fail(c, errors.CodeDatabaseError, err...)
}

// Paginated 返回分页数据响应
// 参数：
//   - c: Gin上下文
//   - items: 分页数据项
//   - total: 总记录数
//   - page: 当前页码
//   - pageSize: 每页记录数
func Paginated(c *gin.Context, items interface{}, total int64, page, pageSize int) {
	c.JSON(http.StatusOK, models.APIResponse{
		Code:    errors.CodeSuccess,
		Message: errors.GetMessage(errors.CodeSuccess),
		Data: models.PaginatedResponse{
			Items:    items,
			Total:    total,
			Page:     page,
			PageSize: pageSize,
		},
	})
}

// FromError 根据AppError返回对应的错误响应
// 参数：
//   - c: Gin上下文
//   - err: 应用程序错误对象
func FromError(c *gin.Context, err *errors.AppError) {
	// 根据错误类型映射到错误码
	code := mapErrorTypeToCode(err.Type)
	
	// 获取HTTP状态码
	httpStatus := errors.GetHTTPStatus(code)
	
	// 构建响应
	resp := models.APIResponse{
		Code:    code,
		Message: err.Message,
	}
	
	// 如果有详细错误信息，则添加到响应中
	if err.Details != "" {
		resp.Error = err.Details
	}
	
	c.JSON(httpStatus, resp)
}

// 将错误类型映射到错误码
func mapErrorTypeToCode(errType string) int {
	switch errType {
	case errors.ErrInternal:
		return errors.CodeInternalError
	case errors.ErrInvalidInput:
		return errors.CodeBadRequest
	case errors.ErrNotFound:
		return errors.CodeNotFound
	case errors.ErrUnauthorized:
		return errors.CodeUnauthorized
	case errors.ErrForbidden:
		return errors.CodeForbidden
	case errors.ErrConflict:
		return errors.CodeConflict
	case errors.ErrTooManyRequests:
		return errors.CodeTooManyRequests
	case errors.ErrServiceUnavailable:
		return errors.CodeServiceUnavailable
	case errors.ErrDatabaseConnection:
		return errors.CodeDatabaseConnection
	case errors.ErrDatabaseQuery:
		return errors.CodeDatabaseQuery
	case errors.ErrDatabaseInsert:
		return errors.CodeDatabaseInsert
	case errors.ErrDatabaseUpdate:
		return errors.CodeDatabaseUpdate
	case errors.ErrDatabaseDelete:
		return errors.CodeDatabaseDelete
	case errors.ErrUserNotFound:
		return errors.CodeUserNotFound
	case errors.ErrUserAlreadyExists:
		return errors.CodeUserAlreadyExists
	case errors.ErrInvalidCredentials:
		return errors.CodeInvalidCredentials
	case errors.ErrUserDisabled:
		return errors.CodeUserDisabled
	case errors.ErrUserLocked:
		return errors.CodeUserLocked
	case errors.ErrPasswordTooShort:
		return errors.CodePasswordTooShort
	case errors.ErrInvalidToken:
		return errors.CodeInvalidToken
	case errors.ErrTokenExpired:
		return errors.CodeTokenExpired
	default:
		return errors.CodeInternalError
	}
}
