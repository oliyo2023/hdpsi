# 微信登录功能配置指南

本文档介绍如何配置和使用微信登录功能。

## 前置条件

1. 在微信开放平台申请移动应用
2. 获取微信应用的 AppID 和 AppSecret
3. 配置应用包名和签名

## 配置步骤

### 1. 微信开放平台配置

1. 访问 [微信开放平台](https://open.weixin.qq.com/)
2. 注册开发者账号并完成认证
3. 创建移动应用
4. 记录应用的 AppID 和 AppSecret

### 2. Flutter 应用配置

#### 2.1 更新微信 AppID

在以下文件中将 `your_wechat_app_id` 替换为实际的微信 AppID：

- `mobile/lib/services/wechat_service.dart`
- `mobile/android/app/src/main/res/values/strings.xml`

#### 2.2 Android 配置

1. **包名配置**：确保 `android/app/build.gradle` 中的 `applicationId` 与微信开放平台注册的包名一致

2. **签名配置**：
   - 生成签名文件或使用现有签名
   - 在微信开放平台填写应用签名
   - 确保发布版本使用正确的签名

3. **权限配置**：已在 `AndroidManifest.xml` 中添加必要权限

#### 2.3 iOS 配置

1. 在 `ios/Runner/Info.plist` 中添加微信 URL Scheme：

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>weixin</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>your_wechat_app_id</string>
        </array>
    </dict>
</array>

<key>LSApplicationQueriesSchemes</key>
<array>
    <string>weixin</string>
    <string>weixinULAPI</string>
</array>
```

### 3. 后端配置

在 `backend/controllers/wechat_login_controller.go` 中更新微信应用配置：

```go
// 微信应用配置 - 建议从环境变量或配置文件读取
appID := "your_wechat_app_id"
appSecret := "your_wechat_app_secret"
```

**安全建议**：
- 将 AppSecret 存储在环境变量中
- 不要将 AppSecret 提交到代码仓库
- 在生产环境中使用配置文件管理敏感信息

### 4. 数据库迁移

确保数据库中的 `users` 表包含微信相关字段。如果是现有项目，需要执行数据库迁移：

```sql
ALTER TABLE users ADD COLUMN nickname VARCHAR(100);
ALTER TABLE users ADD COLUMN wechat_open_id VARCHAR(128) UNIQUE;
ALTER TABLE users ADD COLUMN wechat_union_id VARCHAR(128);
ALTER TABLE users ADD COLUMN wechat_nickname VARCHAR(100);
ALTER TABLE users ADD COLUMN wechat_avatar VARCHAR(255);
```

## 使用说明

### 前端使用

1. 用户点击"微信登录"按钮
2. 系统检查微信是否已安装
3. 调用微信授权接口
4. 获取授权码后调用后端登录接口
5. 登录成功后跳转到主页

### 后端处理流程

1. 接收前端传来的微信授权码
2. 通过授权码获取微信访问令牌
3. 使用访问令牌获取用户信息
4. 查找或创建用户账户
5. 生成 JWT 令牌返回给前端

## 测试

### 开发环境测试

1. 确保使用真机测试（微信登录不支持模拟器）
2. 安装微信客户端
3. 使用测试账号进行登录测试

### 生产环境部署

1. 使用正式的微信应用配置
2. 确保应用签名与微信开放平台一致
3. 配置正确的后端 API 地址

## 常见问题

### Q: 微信登录失败，提示"应用未注册"
A: 检查 AppID 是否正确，包名和签名是否与微信开放平台一致

### Q: 获取用户信息失败
A: 检查 AppSecret 是否正确，网络是否正常

### Q: 登录成功但无法创建用户
A: 检查数据库连接和用户表结构是否正确

## 安全注意事项

1. **AppSecret 保护**：绝不在客户端存储 AppSecret
2. **令牌验证**：后端必须验证微信返回的访问令牌
3. **用户信息**：妥善处理和存储用户隐私信息
4. **HTTPS**：生产环境必须使用 HTTPS

## 相关文档

- [微信开放平台文档](https://developers.weixin.qq.com/doc/)
- [fluwx 插件文档](https://pub.dev/packages/fluwx)
- [Flutter 官方文档](https://flutter.dev/docs)