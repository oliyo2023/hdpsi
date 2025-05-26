import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

/// 权限管理服务
/// 负责处理应用所需的各种权限请求和管理
class PermissionService extends GetxService {
  static PermissionService get to => Get.find();

  /// 检查相机权限状态（不请求权限）
  /// 返回当前相机权限是否已授权
  Future<bool> checkCameraPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  /// 检查并请求相机权限
  /// 用于扫描商品条码功能
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      // 显示权限说明对话框
      final shouldRequest = await _showPermissionDialog(
        title: '相机权限',
        content: '宏店需要使用相机权限来扫描商品条码，这将帮助您快速录入商品信息。',
        permission: '相机',
        usage: '扫描商品条码、拍摄商品图片',
      );

      if (!shouldRequest) return false;

      final result = await Permission.camera.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      await _showSettingsDialog(
        title: '相机权限被拒绝',
        content: '请在设置中手动开启相机权限，以便使用扫码功能。',
      );
      return false;
    }

    return false;
  }

  /// 检查存储权限状态（不请求权限）
  /// 返回当前存储权限是否已授权
  Future<bool> checkStoragePermission() async {
    // Android 13+ 使用新的权限模型
    Permission permission = Permission.storage;
    if (await _isAndroid13OrHigher()) {
      permission = Permission.photos;
    }

    final status = await permission.status;
    return status.isGranted;
  }

  /// 检查并请求存储权限
  /// 用于保存应用数据和图片
  Future<bool> requestStoragePermission() async {
    // Android 13+ 使用新的权限模型
    Permission permission = Permission.storage;
    if (await _isAndroid13OrHigher()) {
      permission = Permission.photos;
    }

    final status = await permission.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final shouldRequest = await _showPermissionDialog(
        title: '存储权限',
        content: '宏店需要存储权限来保存商品图片和应用数据，确保您的数据安全存储。',
        permission: '存储',
        usage: '保存商品图片、缓存数据、导出报表',
      );

      if (!shouldRequest) return false;

      final result = await permission.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      await _showSettingsDialog(
        title: '存储权限被拒绝',
        content: '请在设置中手动开启存储权限，以便保存数据和图片。',
      );
      return false;
    }

    return false;
  }

  /// 检查相册权限状态（不请求权限）
  /// 返回当前相册权限是否已授权
  Future<bool> checkPhotosPermission() async {
    final status = await Permission.photos.status;
    return status.isGranted;
  }

  /// 检查并请求图片选择权限
  /// 用于从相册选择商品图片
  Future<bool> requestPhotosPermission() async {
    Permission permission = Permission.photos;

    final status = await permission.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final shouldRequest = await _showPermissionDialog(
        title: '相册权限',
        content: '宏店需要访问您的相册来选择商品图片，让商品信息更加完整。',
        permission: '相册',
        usage: '选择商品图片、上传商品照片',
      );

      if (!shouldRequest) return false;

      final result = await permission.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      await _showSettingsDialog(
        title: '相册权限被拒绝',
        content: '请在设置中手动开启相册权限，以便选择商品图片。',
      );
      return false;
    }

    return false;
  }

  /// 一次性请求所有必要权限
  /// 在应用首次启动时调用
  Future<void> requestAllPermissions() async {
    await _showPrivacyPolicyDialog();
  }

  /// 显示隐私政策对话框
  Future<void> _showPrivacyPolicyDialog() async {
    await Get.dialog(
      AlertDialog(
        title: const Text('隐私政策与权限说明'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '欢迎使用宏店！',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              const Text(
                '为了为您提供更好的服务体验，宏店需要获取以下权限：',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              _buildPermissionItem(
                icon: Icons.camera_alt,
                title: '相机权限',
                description: '用于扫描商品条码和拍摄商品图片',
              ),
              _buildPermissionItem(
                icon: Icons.photo_library,
                title: '相册权限',
                description: '用于选择和上传商品图片',
              ),
              _buildPermissionItem(
                icon: Icons.storage,
                title: '存储权限',
                description: '用于保存应用数据和缓存图片',
              ),
              const SizedBox(height: 12),
              const Text(
                '我们承诺：',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              const Text(
                '• 仅在必要时使用相关权限\n'
                '• 不会收集与业务无关的个人信息\n'
                '• 所有数据仅用于进销存管理功能\n'
                '• 严格保护您的隐私和数据安全',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              // 用户拒绝，可以选择退出应用或限制功能
            },
            child: const Text('暂不同意'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _requestPermissionsSequentially();
            },
            child: const Text('同意并继续'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// 依次请求权限
  Future<void> _requestPermissionsSequentially() async {
    // 这里可以根据需要依次请求权限
    // 或者在用户使用相关功能时再请求
  }

  /// 显示权限请求对话框
  Future<bool> _showPermissionDialog({
    required String title,
    required String content,
    required String permission,
    required String usage,
  }) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(content),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '权限用途：',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(usage, style: TextStyle(color: Colors.blue.shade600)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('拒绝'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('允许'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// 显示设置对话框
  Future<void> _showSettingsDialog({
    required String title,
    required String content,
  }) async {
    await Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('取消')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              openAppSettings();
            },
            child: const Text('去设置'),
          ),
        ],
      ),
    );
  }

  /// 构建权限说明项
  Widget _buildPermissionItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 检查是否为Android 13或更高版本
  Future<bool> _isAndroid13OrHigher() async {
    // 这里可以添加平台版本检查逻辑
    return false; // 简化实现
  }
}
