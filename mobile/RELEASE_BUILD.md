# 宏店移动应用发布构建指南

本文档介绍如何为宏店移动应用配置签名证书、启用代码混淆并构建发布版本。

## 前置要求

1. Flutter SDK 已安装并配置
2. Android SDK 已安装
3. Java JDK 已安装
4. 已配置Android开发环境

## 1. 生成签名密钥库

### 方法一：使用提供的脚本（推荐）

```bash
cd mobile/android
chmod +x generate-keystore.sh
./generate-keystore.sh
```

按照提示输入以下信息：
- 密钥库密码（请使用强密码）
- 密钥别名（建议：hdpsi-release）
- 密钥密码
- 证书信息（姓名、组织、城市等）

### 方法二：手动生成

```bash
cd mobile/android
keytool -genkey -v -keystore release-key.keystore -alias hdpsi-release -keyalg RSA -keysize 2048 -validity 10000
```

## 2. 配置签名信息

编辑 `mobile/android/key.properties` 文件：

```properties
MYAPP_RELEASE_STORE_FILE=release-key.keystore
MYAPP_RELEASE_STORE_PASSWORD=你的密钥库密码
MYAPP_RELEASE_KEY_ALIAS=hdpsi-release
MYAPP_RELEASE_KEY_PASSWORD=你的密钥密码
```

**重要提醒：**
- 请妥善保管密钥库文件和密码
- 不要将 `key.properties` 文件提交到版本控制系统
- 建议备份密钥库文件到安全位置

## 3. 应用配置说明

### 混淆配置

应用已启用以下优化：
- **代码混淆** (`isMinifyEnabled = true`)
- **资源压缩** (`isShrinkResources = true`)
- **ProGuard规则** (见 `android/app/proguard-rules.pro`)

### 应用ID配置

- **生产版本**: `com.hdpsi.mobile`
- **调试版本**: `com.hdpsi.mobile.debug`

### SDK版本要求

- **最低SDK版本**: 23 (Android 6.0)
- **目标SDK版本**: 根据Flutter配置
- **NDK版本**: 27.0.12077973

## 4. 构建发布版本

### 方法一：使用构建脚本（推荐）

```bash
cd mobile
chmod +x build-release.sh
./build-release.sh
```

脚本会提供以下选项：
1. 构建APK（用于直接安装）
2. 构建AAB（用于Google Play Store）
3. 同时构建APK和AAB

### 方法二：手动构建

#### 构建APK
```bash
cd mobile
flutter clean
flutter pub get
flutter build apk --release
```

#### 构建AAB（推荐用于应用商店）
```bash
cd mobile
flutter clean
flutter pub get
flutter build appbundle --release
```

## 5. 输出文件位置

构建完成后，文件将位于：

- **APK**: `mobile/build/app/outputs/flutter-apk/app-release.apk`
- **AAB**: `mobile/build/app/outputs/bundle/release/app-release.aab`

## 6. 验证签名

### 验证APK签名
```bash
jarsigner -verify -verbose -certs build/app/outputs/flutter-apk/app-release.apk
```

### 验证AAB签名
```bash
jarsigner -verify -verbose -certs build/app/outputs/bundle/release/app-release.aab
```

### 查看签名信息
```bash
keytool -printcert -jarfile build/app/outputs/flutter-apk/app-release.apk
```

## 7. 发布前检查清单

- [ ] 应用功能测试完成
- [ ] 版本号已更新
- [ ] 应用权限配置正确
- [ ] 签名验证通过
- [ ] 文件大小合理
- [ ] 准备应用商店资料（图标、截图、描述等）

## 8. 常见问题

### Q: 构建时提示找不到密钥库文件
A: 确保 `key.properties` 文件中的路径正确，密钥库文件存在于指定位置。

### Q: 签名验证失败
A: 检查密钥库密码和密钥密码是否正确，确保密钥库文件未损坏。

### Q: 应用安装后闪退
A: 检查ProGuard规则是否正确，某些类可能被错误混淆。

### Q: 文件大小过大
A: 检查是否启用了资源压缩，考虑移除不必要的资源文件。

## 9. 安全建议

1. **密钥管理**：
   - 使用强密码保护密钥库
   - 定期备份密钥库文件
   - 不要在不安全的环境中使用密钥

2. **版本控制**：
   - 将密钥相关文件添加到 `.gitignore`
   - 使用环境变量存储敏感信息
   - 在CI/CD中安全地管理密钥

3. **发布流程**：
   - 在发布前进行充分测试
   - 使用分阶段发布策略
   - 监控应用性能和崩溃报告

## 10. 联系支持

如果在构建过程中遇到问题，请联系开发团队或查阅相关文档。
