# 统一API响应格式

本文档介绍了HD-PSI系统中统一的API响应格式和错误处理机制。

## 响应格式

所有API响应都应该遵循以下格式：

```json
{
  "code": 20000,        // 状态码，成功为20000，错误码根据具体错误类型定义
  "message": "操作成功",  // 响应消息，用于前端显示
  "data": {},           // 响应数据，可以是任何JSON对象或数组
  "error": ""           // 错误信息，仅在发生错误时返回
}
```

## 错误码规则

错误码采用5位数字编码，规则如下：

1. 成功响应: 200xx
2. 客户端错误: 4xxxx
3. 服务器错误: 5xxxx
4. 业务错误: 6xxxx

## 使用示例

### 成功响应

```go
// 返回普通数据
response.Success(c, user)

// 返回创建成功
response.Created(c, newUser)

// 返回无内容
response.NoContent(c)

// 返回分页数据
response.Paginated(c, products, total, page, pageSize)
```

### 错误响应

```go
// 返回请求参数错误
response.BadRequest(c, "用户名不能为空")

// 返回未授权错误
response.Unauthorized(c, "请先登录")

// 返回禁止访问错误
response.Forbidden(c, "没有权限执行此操作")

// 返回资源不存在错误
response.NotFound(c, "用户不存在")

// 返回服务器内部错误
response.InternalError(c, "服务器内部错误")

// 返回自定义错误码
response.Fail(c, errors.CodeUserLocked, "用户账号已被锁定")
```

### 在控制器中的完整示例

```go
func (uc *UserController) GetUser(c *gin.Context) {
    id := c.Param("id")
    var user models.User
    
    if err := uc.db.First(&user, id).Error; err != nil {
        if errors.Is(err, gorm.ErrRecordNotFound) {
            response.NotFound(c, "用户不存在")
            return
        }
        response.DatabaseError(c, "获取用户信息失败")
        return
    }
    
    response.Success(c, user)
}
```

## 前端处理

前端应该统一处理API响应，根据`code`字段判断请求是否成功，并根据`message`或`error`字段显示相应的提示信息。

```javascript
api.get('/users/1')
  .then(res => {
    if (res.code === 20000) {
      // 请求成功，处理数据
      const userData = res.data;
      // ...
    } else {
      // 请求失败，显示错误信息
      showError(res.message || res.error || '未知错误');
    }
  })
  .catch(err => {
    // 网络错误等异常情况
    showError('请求失败，请检查网络连接');
  });
```
