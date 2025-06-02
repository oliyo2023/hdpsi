# Android 应用签名配置指南

## 🔐 **当前问题**
构建时出现警告：
```
警告: 签名配置不完整，将使用调试签名
keyAlias: null
keyPassword: 未设置
storeFile: null
storePassword: 未设置
```

## 🛠️ **解决方案**

### 1. **生成发布密钥库**

#### Windows 用户
```powershell
cd mobile/android
.\generate-keystore.ps1
```

#### Linux/macOS 用户
```bash
cd mobile/android
chmod +x generate-keystore.sh
./generate-keystore.sh
```

### 2. **填写信息示例**
```
密钥库密码: [输入强密码，至少8位]
确认密钥库密码: [重复输入]
密钥别名: hdpsi-release
密钥密码: [可以与密钥库密码相同]
您的姓名: 张三
组织单位: IT部门
组织名称: 宏达服装
城市: 广州
省份: 广东
国家代码: CN
```

### 3. **验证配置**

生成成功后，会创建以下文件：
- `android/release-key.keystore` - 密钥库文件
- `android/key.properties` - 签名配置文件

### 4. **重新构建应用**

```powershell
# 清理并重新构建
flutter clean
flutter pub get

# 构建发布版本
flutter build apk --release --shrink --obfuscate --split-debug-info=build/app/outputs/symbols --target-platform android-arm64
```

## 🔒 **安全注意事项**

### ✅ **必须做的**
1. **备份密钥库文件**到安全位置
2. **记录密码**并妥善保管
3. **不要**将密钥文件提交到 Git
4. **定期备份**密钥库文件

### ❌ **绝对不要**
1. 将 `key.properties` 提交到版本控制
2. 将 `*.keystore` 文件提交到版本控制
3. 在公开场所分享密钥库密码
4. 丢失密钥库文件（无法恢复）

## 📁 **文件结构**

```
mobile/
├── android/
│   ├── key.properties          # 签名配置 (不提交到Git)
│   ├── release-key.keystore    # 密钥库文件 (不提交到Git)
│   ├── generate-keystore.ps1   # Windows生成脚本
│   └── generate-keystore.sh    # Linux/macOS生成脚本
└── .gitignore                  # 已配置忽略密钥文件
```

## 🚀 **构建命令**

### 发布版本 (有签名)
```bash
flutter build apk --release --shrink --obfuscate --split-debug-info=build/app/outputs/symbols --target-platform android-arm64
```

### App Bundle (推荐用于 Google Play)
```bash
flutter build appbundle --release --shrink --obfuscate --split-debug-info=build/app/outputs/symbols
```

## 🔍 **验证签名**

### 检查 APK 签名
```bash
# 使用 Android SDK 工具
apksigner verify --verbose app-release.apk

# 或使用 keytool
keytool -printcert -jarfile app-release.apk
```

### 检查密钥库信息
```bash
keytool -list -v -keystore release-key.keystore -alias hdpsi-release
```

## 🆘 **常见问题**

### Q: 忘记密钥库密码怎么办？
A: 无法恢复，需要重新生成密钥库。但这意味着无法更新已发布的应用。

### Q: 密钥库文件丢失怎么办？
A: 无法恢复，需要重新生成。建议立即备份新生成的密钥库。

### Q: 可以更改密钥库密码吗？
A: 可以，使用以下命令：
```bash
keytool -storepasswd -keystore release-key.keystore
```

### Q: 如何备份密钥库？
A: 将 `release-key.keystore` 和密码信息保存到：
- 云存储（加密）
- 离线存储设备
- 公司安全服务器

## 📋 **检查清单**

- [ ] 生成密钥库文件
- [ ] 创建 key.properties 配置
- [ ] 验证 .gitignore 配置
- [ ] 备份密钥库文件
- [ ] 记录密码信息
- [ ] 测试发布构建
- [ ] 验证 APK 签名

## 🎯 **下一步**

1. **立即执行**：运行密钥库生成脚本
2. **验证构建**：重新构建应用检查签名
3. **备份密钥**：将密钥库文件备份到安全位置
4. **文档记录**：记录密钥信息供团队使用

完成签名配置后，您的应用就可以正式发布到 Google Play Store 了！
