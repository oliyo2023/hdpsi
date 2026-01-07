package middleware

import (
	"hd_psi/backend/utils"
	"hd_psi/backend/utils/errors"
	"net/http"
	"strings"

	"github.com/kataras/iris/v12"
)

// JWTAuth 创建JWT认证中间件
// 用于验证请求中的JWT令牌，并将用户信息添加到请求上下文中
// 返回：
//   - iris.Handler: Iris中间件函数
func JWTAuth() iris.Handler {
	return func(ctx iris.Context) {
		// 从请求头获取令牌
		authHeader := ctx.GetHeader("Authorization")
		if authHeader == "" {
			ctx.StatusCode(http.StatusUnauthorized)
			ctx.JSON(iris.Map{"error": "未提供授权令牌"})
			ctx.StopExecution()
			return
		}

		// 检查令牌格式
		parts := strings.SplitN(authHeader, " ", 2)
		if !(len(parts) == 2 && parts[0] == "Bearer") {
			ctx.StatusCode(http.StatusUnauthorized)
			ctx.JSON(iris.Map{"error": "授权格式无效"})
			ctx.StopExecution()
			return
		}

		// 解析令牌
		claims, err := utils.ParseToken(parts[1])
		if err != nil {
			ctx.StatusCode(http.StatusUnauthorized)
			ctx.JSON(iris.Map{"error": "无效的令牌"})
			ctx.StopExecution()
			return
		}

		// 将用户信息存储在上下文中
		ctx.Values().Set("userID", claims.UserID)
		ctx.Values().Set("username", claims.Username)
		ctx.Values().Set("role", claims.Role)

		ctx.Next()
	}
}

// GetUserFromContext retrieves userID and username from Iris context
// It's a helper function to be used by controllers after JWTAuth middleware has run.
func GetUserFromContext(ctx iris.Context) (uint, string, error) {
	userIDVal := ctx.Values().Get("userID")
	if userIDVal == nil {
		return 0, "", errors.New("userID not found in context")
	}

	usernameVal := ctx.Values().Get("username")
	if usernameVal == nil {
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
//   - iris.Handler: Iris中间件函数
func RoleAuth(roles ...string) iris.Handler {
	return func(ctx iris.Context) {
		// 获取用户角色
		role := ctx.Values().Get("role")
		if role == nil {
			ctx.StatusCode(http.StatusUnauthorized)
			ctx.JSON(iris.Map{"error": "未授权"})
			ctx.StopExecution()
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
			ctx.StatusCode(http.StatusForbidden)
			ctx.JSON(iris.Map{"error": "权限不足"})
			ctx.StopExecution()
			return
		}

		ctx.Next()
	}
}