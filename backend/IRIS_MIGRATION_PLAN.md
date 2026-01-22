# Iris框架重构计划

## 概述
本文档描述了将backend从Gin框架迁移到Iris框架的详细计划。

## 主要变更

### 1. 依赖更新
- 移除: `github.com/gin-gonic/gin`
- 移除: `github.com/swaggo/gin-swagger`
- 添加: `github.com/kataras/iris/v12`
- 保留: `github.com/swaggo/files` (用于Swagger静态文件)
- 保留: `github.com/swaggo/swag` (用于生成Swagger文档)

### 2. 核心文件变更

#### main.go
**Gin方式:**
```go
r := gin.New()
r.Use(gin.Logger())
r.Use(gin.Recovery())
r.Run(":8080")
```

**Iris方式:**
```go
app := iris.New()
app.Use(iris.Compression)
app.Logger().SetLevel("info")
app.Listen(":8080")
```

#### routes/routes.go
**Gin路由:**
```go
api := r.Group("/api/v1")
api.GET("/products", productController.ListProducts)
api.POST("/products", productController.CreateProduct)
```

**Iris路由:**
```go
api := app.Party("/api/v1")
api.Get("/products", productController.ListProducts)
api.Post("/products", productController.CreateProduct)
```

### 3. 中间件适配

#### auth_middleware.go
**Gin Context → Iris Context:**
- `gin.Context` → `iris.Context`
- `c.GetHeader()` → `c.GetHeader()`
- `c.JSON()` → `c.JSON()`
- `c.Abort()` → `c.StopWithStatus()`
- `c.Next()` → `c.Next()`
- `c.Set()` → `c.Set()`
- `c.Get()` → `c.Get()`

#### cors_middleware.go
Iris内置了CORS支持，可以使用 `iris.DefaultCORS()` 或自定义CORS中间件。

### 4. 控制器适配

所有控制器方法需要将 `*gin.Context` 改为 `iris.Context`:

**Gin:**
```go
func (pc *ProductController) ListProducts(c *gin.Context) {
    name := c.Query("name")
    c.JSON(http.StatusOK, gin.H{"data": products})
}
```

**Iris:**
```go
func (pc *ProductController) ListProducts(c iris.Context) {
    name := c.URLParam("name")
    c.JSON(iris.StatusOK, iris.Map{"data": products})
}
```

### 5. 响应工具适配

#### utils/response/response.go
需要更新响应函数以适配Iris Context:

```go
// Gin
func Success(c *gin.Context, data interface{}) {
    c.JSON(http.StatusOK, gin.H{
        "code":    0,
        "message": "success",
        "data":    data,
    })
}

// Iris
func Success(c iris.Context, data interface{}) {
    c.JSON(iris.StatusOK, iris.Map{
        "code":    0,
        "message": "success",
        "data":    data,
    })
}
```

### 6. 日志适配

#### utils/logger/logger.go
Iris有自己的日志系统，可以集成或继续使用自定义logger。

### 7. Swagger集成

Iris需要不同的Swagger集成方式:
- 使用 `iris.StaticHandler` 提供Swagger UI
- 或者使用第三方Iris Swagger库

### 8. 静态文件服务

**Gin:**
```go
r.Static("/assets", "./public/assets")
r.StaticFS("/assets", embed.GetPublicFS())
```

**Iris:**
```go
app.HandleDir("/assets", iris.Dir("./public/assets"))
app.HandleDir("/assets", embed.GetPublicFS())
```

### 9. 参数绑定

**Gin:**
```go
var input LoginInput
if err := c.ShouldBindJSON(&input); err != nil {
    // 处理错误
}
```

**Iris:**
```go
var input LoginInput
if err := c.ReadJSON(&input); err != nil {
    // 处理错误
}
```

### 10. 路径参数

**Gin:**
```go
id := c.Param("id")
```

**Iris:**
```go
id := c.Params().Get("id")
```

## 迁移步骤

1. **更新go.mod** - 添加Iris依赖，移除Gin依赖
2. **重构main.go** - 使用Iris初始化应用
3. **重构middleware** - 适配Iris Context
4. **重构routes** - 转换路由定义
5. **重构controllers** - 更新所有控制器方法签名
6. **重构utils/response** - 更新响应工具函数
7. **重构utils/logger** - 适配Iris日志系统
8. **更新Swagger集成** - 使用Iris方式提供Swagger文档
9. **测试** - 确保所有API端点正常工作
10. **更新文档** - 更新相关文档

## 注意事项

1. **Context差异**: Gin和Iris的Context API有差异，需要仔细适配
2. **中间件顺序**: 确保中间件顺序正确
3. **错误处理**: Iris的错误处理机制与Gin略有不同
4. **性能**: Iris在某些场景下可能有不同的性能特征
5. **兼容性**: 确保前端API调用不受影响

## 文件清单

需要修改的文件:
- `backend/go.mod`
- `backend/main.go`
- `backend/routes/routes.go`
- `backend/routes/file_routes.go`
- `backend/routes/product_image_routes.go`
- `backend/middleware/*.go`
- `backend/controllers/*.go`
- `backend/utils/response/response.go`
- `backend/utils/logger/logger.go`

## 测试计划

1. 单元测试 - 测试各个控制器方法
2. 集成测试 - 测试API端点
3. 中间件测试 - 测试认证、CORS等中间件
4. 性能测试 - 对比迁移前后的性能