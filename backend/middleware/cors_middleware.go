package middleware

import (
	"github.com/kataras/iris/v12"
)

// CORSMiddleware 处理跨域资源共享(CORS)
// 允许前端应用从不同的域名或端口访问后端API
func CORSMiddleware() iris.Handler {
	return func(ctx iris.Context) {
		// 允许的来源域名，可以设置为具体的域名，如 http://localhost:8081
		// 在开发环境中，可以设置为 * 允许所有域名
		ctx.Header("Access-Control-Allow-Origin", "*")
		
		// 允许的HTTP方法
		ctx.Header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS, PATCH")
		
		// 允许的HTTP头
		ctx.Header("Access-Control-Allow-Headers", "Origin, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")
		
		// 允许浏览器缓存预检请求结果的时间（秒）
		ctx.Header("Access-Control-Max-Age", "86400")
		
		// 允许客户端获取自定义头信息
		ctx.Header("Access-Control-Expose-Headers", "Content-Length")
		
		// 允许请求携带认证信息（如cookies）
		ctx.Header("Access-Control-Allow-Credentials", "true")

		// 处理OPTIONS请求
		if ctx.Method() == "OPTIONS" {
			ctx.StatusCode(204)
			ctx.StopExecution()
			return
		}

		// 继续处理请求
		ctx.Next()
	}
}