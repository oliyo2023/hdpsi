package middleware

import (
	"hd_psi/backend/config"
	"hd_psi/backend/utils/logger"
	"strings"

	"github.com/gin-gonic/gin"
)

// APIVersionMiddleware 处理API版本的中间件
func APIVersionMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		// 获取当前API版本
		currentVersion := config.GetAPIVersion()

		// 从请求路径中提取版本信息
		path := c.Request.URL.Path

		// 检查路径是否包含版本信息
		if strings.HasPrefix(path, config.AppConfig.API.Prefix) {
			// 移除API前缀
			versionPath := strings.TrimPrefix(path, config.AppConfig.API.Prefix)
			if versionPath == "" || versionPath == "/" {
				// 如果路径只有前缀，直接通过
				c.Next()
				return
			}

			// 分割路径，获取版本部分
			parts := strings.SplitN(strings.TrimPrefix(versionPath, "/"), "/", 2)
			if len(parts) > 0 {
				requestedVersion := parts[0]

				// 检查版本是否有效
				if isValidVersion(requestedVersion) {
					// 如果请求的版本与当前版本不同，记录警告
					if requestedVersion != currentVersion {
						log := logger.WithContext(c)
						log.Warn("使用非当前版本的API",
							logger.F("requested_version", requestedVersion),
							logger.F("current_version", currentVersion))
					}

					// 继续处理请求
					c.Next()
					return
				}
			}
		}

		// 如果没有指定版本或版本无效，使用当前版本
		c.Next()
	}
}

// isValidVersion 检查版本是否有效
func isValidVersion(version string) bool {
	// 这里可以根据需要添加更复杂的版本验证逻辑
	return strings.HasPrefix(version, "v") && len(version) > 1
}

// APIVersionHeaderMiddleware 添加API版本响应头的中间件
func APIVersionHeaderMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		// 添加API版本响应头
		c.Header("X-API-Version", config.GetAPIVersion())

		// 继续处理请求
		c.Next()
	}
}

// APIDeprecationMiddleware 处理API弃用的中间件
func APIDeprecationMiddleware(deprecatedVersions []string) gin.HandlerFunc {
	return func(c *gin.Context) {
		// 从请求路径中提取版本信息
		path := c.Request.URL.Path

		// 检查路径是否包含版本信息
		if strings.HasPrefix(path, config.AppConfig.API.Prefix) {
			// 移除API前缀
			versionPath := strings.TrimPrefix(path, config.AppConfig.API.Prefix)
			if versionPath != "" && versionPath != "/" {
				// 分割路径，获取版本部分
				parts := strings.SplitN(strings.TrimPrefix(versionPath, "/"), "/", 2)
				if len(parts) > 0 {
					requestedVersion := parts[0]

					// 检查版本是否已弃用
					for _, deprecatedVersion := range deprecatedVersions {
						if requestedVersion == deprecatedVersion {
							// 添加弃用警告响应头
							c.Header("X-API-Deprecated", "true")
							c.Header("X-API-Deprecated-Warning", "This API version is deprecated and will be removed in the future. Please upgrade to the latest version.")

							// 记录警告日志
							log := logger.WithContext(c)
							log.Warn("使用已弃用的API版本",
								logger.F("deprecated_version", requestedVersion),
								logger.F("path", c.Request.URL.Path))

							break
						}
					}
				}
			}
		}

		// 继续处理请求
		c.Next()
	}
}
