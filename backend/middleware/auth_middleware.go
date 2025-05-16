package middleware

import (
	"hd_psi/backend/utils"
	"hd_psi/backend/utils/errors"
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
)

// JWTAuth 创建JWT认证中间件
// 用于验证请求中的JWT令牌，并将用户信息添加到请求上下文中
// 返回：
//   - gin.HandlerFunc: Gin中间件函数
func JWTAuth() gin.HandlerFunc {
	return func(c *gin.Context) {
		// 从请求头获取令牌
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "未提供授权令牌"})
			c.Abort()
			return
		}

		// 检查令牌格式
		parts := strings.SplitN(authHeader, " ", 2)
		if !(len(parts) == 2 && parts[0] == "Bearer") {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "授权格式无效"})
			c.Abort()
			return
		}

		// 解析令牌
		claims, err := utils.ParseToken(parts[1])
		if err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "无效的令牌"})
			c.Abort()
			return
		}

		// 将用户信息存储在上下文中
		c.Set("userID", claims.UserID)
		c.Set("username", claims.Username)
		c.Set("role", claims.Role)

		c.Next()
	}
}

// GetUserFromContext retrieves userID and username from Gin context
// It's a helper function to be used by controllers after JWTAuth middleware has run.
func GetUserFromContext(c *gin.Context) (uint, string, error) {
	userIDVal, exists := c.Get("userID")
	if !exists {
		return 0, "", errors.New("userID not found in context")
	}

	usernameVal, exists := c.Get("username")
	if !exists {
		return 0, "", errors.New("username not found in context")
	}

	userID, ok := userIDVal.(uint)
	if !ok {
		return 0, "", errors.New("userID in context is not of type uint")
	}

	username, ok := usernameVal.(string)
	if !ok {
		return 0, "", errors.New("username in context is not of type string")
	}

	return userID, username, nil
}

// RoleAuth 创建基于角色的权限控制中间件
// 用于验证用户是否具有指定的角色权限
// 参数：
//   - roles: 允许访问的角色列表，可变参数
//
// 返回：
//   - gin.HandlerFunc: Gin中间件函数
func RoleAuth(roles ...string) gin.HandlerFunc {
	return func(c *gin.Context) {
		// 获取用户角色
		role, exists := c.Get("role")
		if !exists {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
			c.Abort()
			return
		}

		// 检查用户角色是否在允许的角色列表中
		roleStr := role.(string)
		allowed := false
		for _, r := range roles {
			if r == roleStr {
				allowed = true
				break
			}
		}

		if !allowed {
			c.JSON(http.StatusForbidden, gin.H{"error": "权限不足"})
			c.Abort()
			return
		}

		c.Next()
	}
}
