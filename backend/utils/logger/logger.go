package logger

import (
	"context"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/gin-gonic/gin"
)

// 日志级别
const (
	LevelDebug = "DEBUG"
	LevelInfo  = "INFO"
	LevelWarn  = "WARN"
	LevelError = "ERROR"
	LevelFatal = "FATAL"
)

// Logger 定义日志记录器结构
type Logger struct {
	// 请求ID
	RequestID string
	// 用户ID
	UserID uint
	// 用户名
	Username string
	// 其他字段
	Fields map[string]interface{}
}

// F 创建一个日志字段
func F(key string, value interface{}) map[string]interface{} {
	return map[string]interface{}{key: value}
}

// WithContext 从Gin上下文创建一个新的日志记录器
func WithContext(c *gin.Context) *Logger {
	logger := &Logger{
		RequestID: c.GetString("request_id"),
		Fields:    make(map[string]interface{}),
	}

	// 尝试获取用户ID
	if userID, exists := c.Get("userID"); exists {
		if id, ok := userID.(uint); ok {
			logger.UserID = id
		}
	}

	// 尝试获取用户名
	if username, exists := c.Get("username"); exists {
		if name, ok := username.(string); ok {
			logger.Username = name
		}
	}

	return logger
}

// WithRequestID 创建一个带有请求ID的新日志记录器
func WithRequestID(requestID string) *Logger {
	return &Logger{
		RequestID: requestID,
		Fields:    make(map[string]interface{}),
	}
}

// WithFields 添加字段到日志记录器
func (l *Logger) WithFields(fields ...map[string]interface{}) *Logger {
	newLogger := &Logger{
		RequestID: l.RequestID,
		UserID:    l.UserID,
		Username:  l.Username,
		Fields:    make(map[string]interface{}),
	}

	// 复制现有字段
	for k, v := range l.Fields {
		newLogger.Fields[k] = v
	}

	// 添加新字段
	for _, field := range fields {
		for k, v := range field {
			newLogger.Fields[k] = v
		}
	}

	return newLogger
}

// WithField 添加单个字段到日志记录器
func (l *Logger) WithField(key string, value interface{}) *Logger {
	return l.WithFields(map[string]interface{}{key: value})
}

// log 记录日志
func (l *Logger) log(level, message string, fields ...map[string]interface{}) {
	// 合并字段
	mergedFields := make(map[string]interface{})
	for k, v := range l.Fields {
		mergedFields[k] = v
	}

	for _, f := range fields {
		for k, v := range f {
			mergedFields[k] = v
		}
	}

	// 构建日志条目
	timestamp := time.Now().Format("2006-01-02 15:04:05.000")
	logEntry := fmt.Sprintf("[%s] [%s]", timestamp, level)

	// 添加请求ID
	if l.RequestID != "" {
		logEntry += fmt.Sprintf(" [%s]", l.RequestID)
	}

	// 添加用户信息
	if l.UserID > 0 {
		logEntry += fmt.Sprintf(" [User:%d]", l.UserID)
	}
	if l.Username != "" {
		logEntry += fmt.Sprintf(" [%s]", l.Username)
	}

	// 添加消息
	logEntry += fmt.Sprintf(" %s", message)

	// 添加字段
	if len(mergedFields) > 0 {
		logEntry += " {"
		first := true
		for k, v := range mergedFields {
			if !first {
				logEntry += ", "
			}
			logEntry += fmt.Sprintf("%s:%v", k, v)
			first = false
		}
		logEntry += "}"
	}

	// 输出日志
	log.Println(logEntry)

	// 如果是致命错误，退出程序
	if level == LevelFatal {
		os.Exit(1)
	}
}

// Debug 记录调试级别日志
func (l *Logger) Debug(message string, fields ...map[string]interface{}) {
	l.log(LevelDebug, message, fields...)
}

// Info 记录信息级别日志
func (l *Logger) Info(message string, fields ...map[string]interface{}) {
	l.log(LevelInfo, message, fields...)
}

// Warn 记录警告级别日志
func (l *Logger) Warn(message string, fields ...map[string]interface{}) {
	l.log(LevelWarn, message, fields...)
}

// Error 记录错误级别日志
func (l *Logger) Error(message string, fields ...map[string]interface{}) {
	l.log(LevelError, message, fields...)
}

// Fatal 记录致命级别日志并退出程序
func (l *Logger) Fatal(message string, fields ...map[string]interface{}) {
	l.log(LevelFatal, message, fields...)
}

// FromContext 从上下文中获取日志记录器
func FromContext(ctx context.Context) *Logger {
	if ctx == nil {
		return &Logger{Fields: make(map[string]interface{})}
	}

	if logger, ok := ctx.Value("logger").(*Logger); ok {
		return logger
	}

	return &Logger{Fields: make(map[string]interface{})}
}

// WithLogger 将日志记录器添加到上下文
func WithLogger(ctx context.Context, logger *Logger) context.Context {
	return context.WithValue(ctx, "logger", logger)
}
