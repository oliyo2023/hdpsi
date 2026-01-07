package middleware

import (
	"bytes"
	"hd_psi/backend/utils/logger"
	"io"
	"time"

	"github.com/kataras/iris/v12"
	"github.com/google/uuid"
)

// RequestLoggerMiddleware 创建请求日志中间件
// 记录每个请求的详细信息，包括请求方法、路径、状态码、处理时间等
// 参数：
//   - skipPaths: 不需要记录日志的路径列表，如静态文件路径
//
// 返回：
//   - iris.Handler: Iris中间件函数
func RequestLoggerMiddleware(skipPaths ...string) iris.Handler {
	return func(ctx iris.Context) {
		// 检查是否需要跳过日志记录
		path := ctx.Path()
		for _, skipPath := range skipPaths {
			if path == skipPath {
				ctx.Next()
				return
			}
		}

		// 生成请求ID
		requestID := uuid.New().String()
		ctx.Values().Set("request_id", requestID)
		ctx.Header("X-Request-ID", requestID)

		// 记录请求开始时间
		startTime := time.Now()

		// 创建请求体的副本
		var requestBody []byte
		if ctx.Request().Body != nil {
			requestBody, _ = io.ReadAll(ctx.Request().Body)
			ctx.Request().Body = io.NopCloser(bytes.NewBuffer(requestBody))
		}

		// 处理请求
		ctx.Next()

		// 计算请求处理时间
		latency := time.Since(startTime)

		// 获取请求和响应信息
		statusCode := ctx.GetStatusCode()
		clientIP := ctx.RemoteAddr()
		method := ctx.Method()
		userAgent := ctx.GetHeader("User-Agent")

		// 记录日志
		log := logger.WithContext(ctx).WithFields(
			logger.F("client_ip", clientIP),
			logger.F("method", method),
			logger.F("path", path),
			logger.F("status_code", statusCode),
			logger.F("latency_ms", latency.Milliseconds()),
			logger.F("user_agent", userAgent),
		)

		// 添加用户信息（如果有）
		if userID := ctx.Values().Get("userID"); userID != nil {
			log = log.WithField("user_id", userID)
		}
		if username := ctx.Values().Get("username"); username != nil {
			log = log.WithField("username", username)
		}

		// 根据状态码选择日志级别
		if statusCode >= 500 {
			log.Error("请求处理失败")
		} else if statusCode >= 400 {
			log.Warn("请求处理出错")
		} else {
			log.Info("请求处理完成")
		}
	}
}