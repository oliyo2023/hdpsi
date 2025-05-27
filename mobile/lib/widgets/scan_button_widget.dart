import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/permission_helper.dart';

/// 扫码按钮组件
/// 集成了权限检查和用户引导的扫码功能按钮
class ScanButtonWidget extends StatelessWidget {
  final VoidCallback onScanSuccess;
  final String? buttonText;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final bool isFloatingActionButton;

  const ScanButtonWidget({
    super.key,
    required this.onScanSuccess,
    this.buttonText,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.isFloatingActionButton = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isFloatingActionButton) {
      return FloatingActionButton(
        onPressed: _handleScanTap,
        backgroundColor: backgroundColor ?? Colors.blue,
        foregroundColor: foregroundColor ?? Colors.white,
        child: Icon(icon ?? Icons.qr_code_scanner),
      );
    }

    return ElevatedButton.icon(
      onPressed: _handleScanTap,
      icon: Icon(icon ?? Icons.qr_code_scanner),
      label: Text(buttonText ?? '扫码'),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? Colors.blue,
        foregroundColor: foregroundColor ?? Colors.white,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _handleScanTap() {
    PermissionHelper.requestScanPermission(() {
      // 权限获取成功，执行扫码功能
      _startScanning();
    });
  }

  void _startScanning() {
    // 这里可以启动实际的扫码功能
    // 例如使用 mobile_scanner 包
    
    // 模拟扫码成功
    Get.snackbar(
      '扫码成功',
      '已获取商品信息',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade800,
      icon: const Icon(Icons.check_circle, color: Colors.green),
      duration: const Duration(seconds: 2),
    );
    
    onScanSuccess();
  }
}

/// 图片选择按钮组件
/// 集成了权限检查的图片选择功能
class ImagePickerButtonWidget extends StatelessWidget {
  final Function(String imagePath) onImageSelected;
  final String? buttonText;
  final IconData? icon;
  final bool showCamera;
  final bool showGallery;

  const ImagePickerButtonWidget({
    super.key,
    required this.onImageSelected,
    this.buttonText,
    this.icon,
    this.showCamera = true,
    this.showGallery = true,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _handleImagePickerTap,
      icon: Icon(icon ?? Icons.add_photo_alternate),
      label: Text(buttonText ?? '选择图片'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _handleImagePickerTap() {
    if (showCamera && showGallery) {
      _showImageSourceDialog();
    } else if (showCamera) {
      _requestCameraPermission();
    } else if (showGallery) {
      _requestGalleryPermission();
    }
  }

  void _showImageSourceDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('选择图片来源'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showCamera)
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text('拍照'),
                onTap: () {
                  Get.back();
                  _requestCameraPermission();
                },
              ),
            if (showGallery)
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green),
                title: const Text('从相册选择'),
                onTap: () {
                  Get.back();
                  _requestGalleryPermission();
                },
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  void _requestCameraPermission() {
    PermissionHelper.requestPhotoPermission(() {
      _takePhoto();
    });
  }

  void _requestGalleryPermission() {
    PermissionHelper.requestGalleryPermission(() {
      _pickFromGallery();
    });
  }

  void _takePhoto() {
    // 这里可以启动相机拍照功能
    // 例如使用 image_picker 包
    
    // 模拟拍照成功
    Get.snackbar(
      '拍照成功',
      '图片已保存',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade800,
      icon: const Icon(Icons.check_circle, color: Colors.green),
      duration: const Duration(seconds: 2),
    );
    
    onImageSelected('/path/to/camera/image.jpg');
  }

  void _pickFromGallery() {
    // 这里可以启动相册选择功能
    // 例如使用 image_picker 包
    
    // 模拟选择成功
    Get.snackbar(
      '选择成功',
      '图片已选择',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade800,
      icon: const Icon(Icons.check_circle, color: Colors.green),
      duration: const Duration(seconds: 2),
    );
    
    onImageSelected('/path/to/gallery/image.jpg');
  }
}

/// 文件保存按钮组件
/// 集成了权限检查的文件保存功能
class SaveFileButtonWidget extends StatelessWidget {
  final VoidCallback onSaveSuccess;
  final String? buttonText;
  final IconData? icon;

  const SaveFileButtonWidget({
    super.key,
    required this.onSaveSuccess,
    this.buttonText,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _handleSaveTap,
      icon: Icon(icon ?? Icons.save),
      label: Text(buttonText ?? '保存文件'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _handleSaveTap() {
    PermissionHelper.requestSaveFilePermission(() {
      _saveFile();
    });
  }

  void _saveFile() {
    // 这里可以执行实际的文件保存功能
    
    // 模拟保存成功
    Get.snackbar(
      '保存成功',
      '文件已保存到设备',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade800,
      icon: const Icon(Icons.check_circle, color: Colors.green),
      duration: const Duration(seconds: 2),
    );
    
    onSaveSuccess();
  }
}
