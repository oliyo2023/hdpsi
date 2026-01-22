import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/permission_service.dart';

/// 权限帮助工具类
/// 提供便捷的权限检查和请求方法
class PermissionHelper {
  static final PermissionService _permissionService = PermissionService.to;

  /// 检查并请求相机权限（用于扫码）
  /// 如果权限被拒绝，会显示说明对话框
  static Future<bool> checkCameraForScanning() async {
    final hasPermission = await _permissionService.requestCameraPermission();
    
    if (!hasPermission) {
      _showPermissionDeniedSnackbar(
        title: '相机权限被拒绝',
        message: '无法使用扫码功能，请在设置中开启相机权限',
      );
    }
    
    return hasPermission;
  }

  /// 检查并请求相机权限（用于拍照）
  static Future<bool> checkCameraForPhoto() async {
    final hasPermission = await _permissionService.requestCameraPermission();
    
    if (!hasPermission) {
      _showPermissionDeniedSnackbar(
        title: '相机权限被拒绝',
        message: '无法拍摄照片，请在设置中开启相机权限',
      );
    }
    
    return hasPermission;
  }

  /// 检查并请求相册权限
  static Future<bool> checkPhotosPermission() async {
    final hasPermission = await _permissionService.requestPhotosPermission();
    
    if (!hasPermission) {
      _showPermissionDeniedSnackbar(
        title: '相册权限被拒绝',
        message: '无法选择图片，请在设置中开启相册权限',
      );
    }
    
    return hasPermission;
  }

  /// 检查并请求存储权限
  static Future<bool> checkStoragePermission() async {
    final hasPermission = await _permissionService.requestStoragePermission();
    
    if (!hasPermission) {
      _showPermissionDeniedSnackbar(
        title: '存储权限被拒绝',
        message: '无法保存文件，请在设置中开启存储权限',
      );
    }
    
    return hasPermission;
  }

  /// 显示权限被拒绝的提示
  static void _showPermissionDeniedSnackbar({
    required String title,
    required String message,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange.shade100,
      colorText: Colors.orange.shade800,
      icon: const Icon(Icons.warning, color: Colors.orange),
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      mainButton: TextButton(
        onPressed: () {
          Get.closeCurrentSnackbar();
          _showPermissionSettingsDialog();
        },
        child: const Text('去设置'),
      ),
    );
  }

  /// 显示权限设置对话框
  static void _showPermissionSettingsDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('权限设置'),
        content: const Text(
          '为了正常使用应用功能，请在系统设置中开启相应权限。\n\n'
          '设置路径：设置 > 应用管理 > 宏店 > 权限',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // 打开应用设置页面
              // openAppSettings(); // 需要导入 permission_handler
            },
            child: const Text('去设置'),
          ),
        ],
      ),
    );
  }

  /// 显示功能说明对话框
  static void showFeatureExplanation({
    required String title,
    required String description,
    required String permission,
    required VoidCallback onConfirm,
  }) {
    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '需要$permission权限',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              onConfirm();
            },
            child: const Text('继续'),
          ),
        ],
      ),
    );
  }

  /// 扫码功能权限检查
  static Future<void> requestScanPermission(VoidCallback onGranted) async {
    showFeatureExplanation(
      title: '扫码功能',
      description: '扫描商品条码可以快速录入商品信息，提高工作效率。',
      permission: '相机',
      onConfirm: () async {
        final granted = await checkCameraForScanning();
        if (granted) {
          onGranted();
        }
      },
    );
  }

  /// 拍照功能权限检查
  static Future<void> requestPhotoPermission(VoidCallback onGranted) async {
    showFeatureExplanation(
      title: '拍照功能',
      description: '为商品拍摄照片，让商品信息更加完整和直观。',
      permission: '相机',
      onConfirm: () async {
        final granted = await checkCameraForPhoto();
        if (granted) {
          onGranted();
        }
      },
    );
  }

  /// 选择图片功能权限检查
  static Future<void> requestGalleryPermission(VoidCallback onGranted) async {
    showFeatureExplanation(
      title: '选择图片',
      description: '从相册中选择商品图片，丰富商品信息展示。',
      permission: '相册',
      onConfirm: () async {
        final granted = await checkPhotosPermission();
        if (granted) {
          onGranted();
        }
      },
    );
  }

  /// 文件保存功能权限检查
  static Future<void> requestSaveFilePermission(VoidCallback onGranted) async {
    showFeatureExplanation(
      title: '保存文件',
      description: '保存报表、导出数据等功能需要访问设备存储。',
      permission: '存储',
      onConfirm: () async {
        final granted = await checkStoragePermission();
        if (granted) {
          onGranted();
        }
      },
    );
  }
}
