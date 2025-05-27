# 宏店应用权限管理指南

## 📱 权限管理概述

宏店应用已集成完整的权限管理系统，包括权限请求、用户引导、隐私政策展示等功能，确保符合Google Play政策要求。

## 🔐 权限列表

### 必需权限

| 权限 | 用途 | 说明 |
|------|------|------|
| 网络权限 | 数据同步、API调用 | 连接后端服务器进行数据交换 |
| 网络状态 | 检查网络连接 | 确保网络可用性 |

### 可选权限

| 权限 | 用途 | 说明 | 拒绝后果 |
|------|------|------|---------|
| 相机权限 | 扫描条码、拍摄商品图片 | 提高录入效率 | 无法使用扫码和拍照功能 |
| 存储权限 | 保存应用数据、导出报表 | 数据持久化 | 无法保存文件和导出数据 |
| 相册权限 | 选择商品图片 | 丰富商品信息 | 无法从相册选择图片 |

## 🚀 权限管理架构

### 核心组件

1. **PermissionService** - 权限管理服务
2. **PermissionHelper** - 权限工具类
3. **AppInitializationService** - 应用初始化服务
4. **PermissionGuidePage** - 权限引导页面
5. **PrivacyPolicyPage** - 隐私政策页面

### 权限流程

```
应用启动 → 检查首次启动 → 显示权限引导 → 用户同意 → 请求权限 → 进入主应用
```

## 📋 使用指南

### 1. 基础权限检查

```dart
// 检查相机权限
final hasCamera = await PermissionHelper.checkCameraForScanning();
if (hasCamera) {
  // 执行扫码功能
}

// 检查存储权限
final hasStorage = await PermissionHelper.checkStoragePermission();
if (hasStorage) {
  // 执行文件保存
}
```

### 2. 带用户引导的权限请求

```dart
// 扫码功能权限请求
PermissionHelper.requestScanPermission(() {
  // 权限获取成功后的回调
  startScanning();
});

// 图片选择权限请求
PermissionHelper.requestGalleryPermission(() {
  // 权限获取成功后的回调
  pickImage();
});
```

### 3. 使用预制组件

```dart
// 扫码按钮
ScanButtonWidget(
  onScanSuccess: () {
    // 扫码成功处理
  },
  buttonText: '扫描条码',
)

// 图片选择按钮
ImagePickerButtonWidget(
  onImageSelected: (imagePath) {
    // 图片选择处理
  },
  showCamera: true,
  showGallery: true,
)

// 文件保存按钮
SaveFileButtonWidget(
  onSaveSuccess: () {
    // 保存成功处理
  },
)
```

## 🎯 权限策略

### 渐进式权限请求

1. **应用启动时**：仅展示权限说明，不强制请求
2. **功能使用时**：在用户尝试使用相关功能时请求权限
3. **权限被拒绝**：提供清晰的说明和设置入口

### 用户体验优化

1. **权限说明**：清楚解释每个权限的用途
2. **优雅降级**：权限被拒绝时提供替代方案
3. **重新请求**：提供重新授权的便捷入口

## 📱 Android配置

### AndroidManifest.xml

```xml
<!-- 网络权限 -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

<!-- 相机权限 -->
<uses-permission android:name="android.permission.CAMERA" />

<!-- 存储权限 -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" 
                 android:maxSdkVersion="28" />

<!-- 图片选择权限 -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />

<!-- 功能声明 -->
<uses-feature android:name="android.hardware.camera" android:required="false" />
<uses-feature android:name="android.hardware.camera.autofocus" android:required="false" />
```

## 🔧 自定义配置

### 修改权限引导内容

编辑 `lib/pages/permission_guide_page.dart`：

```dart
final List<PermissionGuideItem> _guideItems = [
  PermissionGuideItem(
    icon: Icons.your_icon,
    title: '您的权限标题',
    description: '您的权限描述',
    color: Colors.your_color,
  ),
  // 添加更多权限项
];
```

### 自定义权限请求对话框

编辑 `lib/services/permission_service.dart` 中的对话框内容。

### 修改隐私政策

编辑以下文件：
- `lib/pages/privacy_policy_page.dart` - 应用内隐私政策页面
- `privacy_policy.html` - 网页版隐私政策（用于Google Play）

## 🚨 常见问题

### Q: 权限被永久拒绝怎么办？
A: 应用会自动检测并引导用户到系统设置页面手动开启权限。

### Q: 如何测试权限流程？
A: 可以使用以下方法重置权限状态：
```dart
// 重置首次启动状态
AppInitializationService.to.resetFirstLaunchStatus();

// 卸载重装应用
// 或在设备设置中清除应用数据
```

### Q: 如何添加新的权限？
A: 
1. 在 `AndroidManifest.xml` 中添加权限声明
2. 在 `PermissionService` 中添加权限请求方法
3. 在 `PermissionHelper` 中添加便捷方法
4. 更新权限引导页面内容

## 📚 相关文件

### 核心文件
- `lib/services/permission_service.dart` - 权限管理服务
- `lib/utils/permission_helper.dart` - 权限工具类
- `lib/services/app_initialization_service.dart` - 应用初始化
- `lib/pages/permission_guide_page.dart` - 权限引导页面
- `lib/pages/privacy_policy_page.dart` - 隐私政策页面

### 配置文件
- `android/app/src/main/AndroidManifest.xml` - Android权限配置
- `privacy_policy.html` - 网页版隐私政策
- `pubspec.yaml` - 依赖配置

### 示例组件
- `lib/widgets/scan_button_widget.dart` - 权限集成组件示例

## 🎉 最佳实践

1. **最小权限原则**：只请求必要的权限
2. **透明度**：清楚说明权限用途
3. **用户控制**：允许用户选择是否授权
4. **优雅处理**：权限被拒绝时提供替代方案
5. **及时更新**：定期更新隐私政策和权限说明

## 📞 技术支持

如果在权限管理方面遇到问题，请参考：
1. Flutter官方文档：https://flutter.dev/docs
2. permission_handler插件文档：https://pub.dev/packages/permission_handler
3. Android权限指南：https://developer.android.com/guide/topics/permissions

---

**注意**：权限管理是应用发布到Google Play的重要要求，请确保严格遵循相关政策。
