package middleware

import (
	"hd_psi/backend/utils/errors"
	"hd_psi/backend/utils/logger"
	"hd_psi/backend/utils/response"
	"runtime/debug"

	"github.com/gin-gonic/gin"
)

// ErrorHandlerMiddleware 创建错误处理中间件
// 捕获请求处理过程中的panic，并将其转换为适当的HTTP响应
// 返回：
//   - gin.HandlerFunc: Gin中间件函数
func ErrorHandlerMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		defer func() {
			if r := recover(); r != nil {
				// 获取请求ID
				requestID, _ := c.Get("request_id")

				// 获取堆栈跟踪
				stack := string(debug.Stack())

				// 创建错误对象
				var err *errors.AppError
				switch v := r.(type) {
				case *errors.AppError:
					err = v
				case error:
					err = errors.Wrap(v, errors.ErrInternal)
				default:
					err = errors.New(errors.ErrInternal).WithDetails("发生未知错误")
				}

				// 添加请求ID
				if requestID != nil {
					err.WithRequestID(requestID.(string))
				}

				// 记录错误日志
				log := logger.WithContext(c).WithFields(
					logger.F("error", err.Error()),
					logger.F("stack", stack),
				)

				if err.ShouldAlert() {
					log.Error("请求处理发生严重错误")
					// TODO: 发送告警通知
				} else {
					log.Warn("请求处理发生错误")
				}

				// 返回错误响应
				response.FromError(c, err)
				c.Abort()
			}
		}()

		c.Next()
	}
}

// ValidationErrorMiddleware 创建验证错误处理中间件
// 处理请求参数验证错误，将其转换为统一的错误响应格式
// 返回：
//   - gin.HandlerFunc: Gin中间件函数
func ValidationErrorMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Next()

		// 检查是否有验证错误
		if len(c.Errors) > 0 {
			// 获取请求ID
			requestID, _ := c.Get("request_id")

			// 创建错误对象
			err := errors.New(errors.ErrInvalidInput)
			if c.Errors.Last() != nil {
				err.WithDetails(c.Errors.Last().Error())
			}

			// 添加请求ID
			if requestID != nil {
				err.WithRequestID(requestID.(string))
			}

			// 记录错误日志
			logger.WithContext(c).WithError(err).Warn("请求参数验证失败")

			// 返回错误响应
			response.FromError(c, err)
			c.Abort()
		}
	}
}

// NotFoundHandler 处理404错误
// 当请求的路由不存在时调用
// 参数：
//   - c: Gin上下文对象
func NotFoundHandler(c *gin.Context) {
	// 获取请求ID
	requestID, exists := c.Get("request_id")
	if !exists {
		requestID = "unknown"
	}

	// 创建错误对象
	err := errors.New(errors.ErrNotFound).
		WithDetails("请求的资源不存在").
		WithRequestID(requestID.(string))

	// 记录错误日志
	logger.WithContext(c).WithError(err).Warn("请求的资源不存在")

	// 返回错误响应
	response.NotFound(c, "请求的URL或资源不存在")
}

// MethodNotAllowedHandler 处理405错误
// 当请求的HTTP方法不被允许时调用
// 参数：
//   - c: Gin上下文对象
func MethodNotAllowedHandler(c *gin.Context) {
	// 获取请求ID
	requestID, exists := c.Get("request_id")
	if !exists {
		requestID = "unknown"
	}

	// 创建错误对象
	err := errors.New(errors.ErrInvalidOperation).
		WithDetails("不支持的HTTP方法").
		WithRequestID(requestID.(string))

	// 记录错误日志
	logger.WithContext(c).WithError(err).Warn("不支持的HTTP方法")

	// 返回错误响应
	response.MethodNotAllowed(c, "不支持的HTTP方法")
}
