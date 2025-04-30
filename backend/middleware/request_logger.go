package middleware

import (
	"bytes"
	"hd_psi/backend/utils/logger"
	"io"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// RequestLoggerMiddleware 创建请求日志中间件
// 记录每个请求的详细信息，包括请求方法、路径、状态码、处理时间等
// 参数：
//   - skipPaths: 不需要记录日志的路径列表，如静态文件路径
//
// 返回：
//   - gin.HandlerFunc: Gin中间件函数
func RequestLoggerMiddleware(skipPaths ...string) gin.HandlerFunc {
	return func(c *gin.Context) {
		// 检查是否需要跳过日志记录
		path := c.Request.URL.Path
		for _, skipPath := range skipPaths {
			if path == skipPath {
				c.Next()
				return
			}
		}

		// 生成请求ID
		requestID := uuid.New().String()
		c.Set("request_id", requestID)
		c.Header("X-Request-ID", requestID)

		// 记录请求开始时间
		startTime := time.Now()

		// 创建请求体的副本
		var requestBody []byte
		if c.Request.Body != nil {
			requestBody, _ = io.ReadAll(c.Request.Body)
			c.Request.Body = io.NopCloser(bytes.NewBuffer(requestBody))
		}

		// 创建响应体的副本
		responseWriter := &responseBodyWriter{
			ResponseWriter: c.Writer,
			body:           bytes.NewBufferString(""),
		}
		c.Writer = responseWriter

		// 处理请求
		c.Next()

		// 计算请求处理时间
		latency := time.Since(startTime)

		// 获取请求和响应信息
		statusCode := c.Writer.Status()
		clientIP := c.ClientIP()
		method := c.Request.Method
		userAgent := c.Request.UserAgent()

		// 记录日志
		log := logger.WithFields(
			logger.F("request_id", requestID),
			logger.F("client_ip", clientIP),
			logger.F("method", method),
			logger.F("path", path),
			logger.F("status_code", statusCode),
			logger.F("latency_ms", latency.Milliseconds()),
			logger.F("user_agent", userAgent),
		)

		// 添加用户信息（如果有）
		if userID, exists := c.Get("userID"); exists {
			log = log.WithField("user_id", userID)
		}
		if username, exists := c.Get("username"); exists {
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

// responseBodyWriter 是一个自定义的响应写入器，用于捕获响应体
type responseBodyWriter struct {
	gin.ResponseWriter
	body *bytes.Buffer
}

// Write 实现ResponseWriter接口的Write方法
func (r *responseBodyWriter) Write(b []byte) (int, error) {
	r.body.Write(b)
	return r.ResponseWriter.Write(b)
}

// WriteString 实现ResponseWriter接口的WriteString方法
func (r *responseBodyWriter) WriteString(s string) (int, error) {
	r.body.WriteString(s)
	return r.ResponseWriter.WriteString(s)
}

// GetBody 获取响应体内容
func (r *responseBodyWriter) GetBody() string {
	return r.body.String()
}
