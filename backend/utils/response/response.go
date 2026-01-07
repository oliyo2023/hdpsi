package response

import (
	"hd_psi/backend/utils/errors"
	"net/http"

	"github.com/kataras/iris/v12"
)

// Success 返回成功响应
// 参数：
//   - ctx: Iris上下文
//   - data: 响应数据
func Success(ctx iris.Context, data interface{}) {
	ctx.StatusCode(http.StatusOK)
	ctx.JSON(map[string]interface{}{
		"code":    errors.CodeSuccess,
		"message": errors.GetMessage(errors.CodeSuccess),
		"data":    data,
	})
}

// Created 返回创建成功响应
// 参数：
//   - ctx: Iris上下文
//   - data: 创建的资源数据
func Created(ctx iris.Context, data interface{}) {
	ctx.StatusCode(http.StatusCreated)
	ctx.JSON(map[string]interface{}{
		"code":    errors.CodeCreated,
		"message": errors.GetMessage(errors.CodeCreated),
		"data":    data,
	})
}

// NoContent 返回无内容响应
// 参数：
//   - ctx: Iris上下文
func NoContent(ctx iris.Context) {
	ctx.StatusCode(http.StatusOK)
	ctx.JSON(map[string]interface{}{
		"code":    errors.CodeNoContent,
		"message": errors.GetMessage(errors.CodeNoContent),
	})
}

// Fail 返回失败响应
// 参数：
//   - ctx: Iris上下文
//   - code: 错误码
//   - err: 错误信息（可选）
func Fail(ctx iris.Context, code int, err ...string) {
	httpStatus := errors.GetHTTPStatus(code)
	message := errors.GetMessage(code)

	resp := map[string]interface{}{
		"code":    code,
		"message": message,
	}

	// 如果提供了错误信息，则添加到响应中
	if len(err) > 0 && err[0] != "" {
		resp["error"] = err[0]
	}

	ctx.StatusCode(httpStatus)
	ctx.JSON(resp)
}

// BadRequest 返回请求参数错误响应
// 参数：
//   - ctx: Iris上下文
//   - err: 错误信息（可选）
func BadRequest(ctx iris.Context, err ...string) {
	Fail(ctx, errors.CodeBadRequest, err...)
}

// Unauthorized 返回未授权响应
// 参数：
//   - ctx: Iris上下文
//   - err: 错误信息（可选）
func Unauthorized(ctx iris.Context, err ...string) {
	Fail(ctx, errors.CodeUnauthorized, err...)
}

// Forbidden 返回禁止访问响应
// 参数：
//   - ctx: Iris上下文
//   - err: 错误信息（可选）
func Forbidden(ctx iris.Context, err ...string) {
	Fail(ctx, errors.CodeForbidden, err...)
}

// NotFound 返回资源不存在响应
// 参数：
//   - ctx: Iris上下文
//   - err: 错误信息（可选）
func NotFound(ctx iris.Context, err ...string) {
	Fail(ctx, errors.CodeNotFound, err...)
}

// MethodNotAllowed 返回方法不允许响应
// 参数：
//   - ctx: Iris上下文
//   - err: 错误信息（可选）
func MethodNotAllowed(ctx iris.Context, err ...string) {
	Fail(ctx, errors.CodeMethodNotAllowed, err...)
}

// Conflict 返回资源冲突响应
// 参数：
//   - ctx: Iris上下文
//   - err: 错误信息（可选）
func Conflict(ctx iris.Context, err ...string) {
	Fail(ctx, errors.CodeConflict, err...)
}

// TooManyRequests 返回请求过于频繁响应
// 参数：
//   - ctx: Iris上下文
//   - err: 错误信息（可选）
func TooManyRequests(ctx iris.Context, err ...string) {
	Fail(ctx, errors.CodeTooManyRequests, err...)
}

// InternalError 返回服务器内部错误响应
// 参数：
//   - ctx: Iris上下文
//   - err: 错误信息（可选）
func InternalError(ctx iris.Context, err ...string) {
	Fail(ctx, errors.CodeInternalError, err...)
}

// ServiceUnavailable 返回服务不可用响应
// 参数：
//   - ctx: Iris上下文
//   - err: 错误信息（可选）
func ServiceUnavailable(ctx iris.Context, err ...string) {
	Fail(ctx, errors.CodeServiceUnavailable, err...)
}

// DatabaseError 返回数据库错误响应
// 参数：
//   - ctx: Iris上下文
//   - err: 错误信息（可选）
func DatabaseError(ctx iris.Context, err ...string) {
	Fail(ctx, errors.CodeDatabaseError, err...)
}

// Paginated 返回分页数据响应
// 参数：
//   - ctx: Iris上下文
//   - items: 分页数据项
//   - total: 总记录数
//   - page: 当前页码
//   - pageSize: 每页记录数
func Paginated(ctx iris.Context, items interface{}, total int64, page, pageSize int) {
	ctx.StatusCode(http.StatusOK)
	ctx.JSON(map[string]interface{}{
		"code":    errors.CodeSuccess,
		"message": errors.GetMessage(errors.CodeSuccess),
		"data": map[string]interface{}{
			"items":    items,
			"total":    total,
			"page":     page,
			"pageSize": pageSize,
		},
	})
}

// FromError 根据AppError返回对应的错误响应
// 参数：
//   - ctx: Iris上下文
//   - err: 应用程序错误对象
func FromError(ctx iris.Context, err *errors.AppError) {
	// 根据错误类型映射到错误码
	code := mapErrorTypeToCode(err.Type)

	// 获取HTTP状态码
	httpStatus := errors.GetHTTPStatus(code)

	// 构建响应
	resp := map[string]interface{}{
		"code":    code,
		"message": err.Message,
	}

	// 如果有详细错误信息，则添加到响应中
	if err.Details != "" {
		resp["error"] = err.Details
	}

	ctx.StatusCode(httpStatus)
	ctx.JSON(resp)
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