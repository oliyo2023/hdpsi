import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'permission_service.dart';

/// 应用初始化服务
/// 负责应用启动时的初始化工作，包括权限检查、首次启动引导等
class AppInitializationService extends GetxService {
  static AppInitializationService get to => Get.find();

  // 响应式状态
  final RxBool isFirstLaunch = true.obs;
  final RxBool isPermissionGuideCompleted = false.obs;
  final RxBool isInitialized = false.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initialize();
  }

  /// 初始化应用
  Future<void> _initialize() async {
    try {
      // 检查是否首次启动
      await _checkFirstLaunch();

      // 检查权限引导是否完成
      await _checkPermissionGuideStatus();

      // 初始化权限服务
      await _initializePermissionService();

      isInitialized.value = true;
    } catch (e) {
      print('应用初始化失败: $e');
      isInitialized.value = true; // 即使失败也标记为已初始化，避免卡住
    }
  }

  /// 检查是否首次启动
  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final hasLaunchedBefore = prefs.getBool('has_launched_before') ?? false;

    isFirstLaunch.value = !hasLaunchedBefore;

    if (isFirstLaunch.value) {
      // 标记已启动过
      await prefs.setBool('has_launched_before', true);
    }
  }

  /// 检查权限引导状态
  Future<void> _checkPermissionGuideStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool('permission_guide_completed') ?? false;
    isPermissionGuideCompleted.value = completed;
  }

  /// 初始化权限服务
  Future<void> _initializePermissionService() async {
    // 确保权限服务已注册
    if (!Get.isRegistered<PermissionService>()) {
      Get.put(PermissionService());
    }
  }

  /// 标记权限引导已完成
  Future<void> markPermissionGuideCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('permission_guide_completed', true);
    isPermissionGuideCompleted.value = true;
  }

  /// 重置首次启动状态（用于测试）
  Future<void> resetFirstLaunchStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_launched_before', false);
    await prefs.setBool('permission_guide_completed', false);
    isFirstLaunch.value = true;
    isPermissionGuideCompleted.value = false;
  }

  /// 获取应用启动路由
  String getInitialRoute() {
    if (isFirstLaunch.value || !isPermissionGuideCompleted.value) {
      return '/permission-guide';
    }
    return '/login';
  }

  /// 检查是否需要显示权限引导
  bool shouldShowPermissionGuide() {
    return isFirstLaunch.value || !isPermissionGuideCompleted.value;
  }

  /// 获取权限状态摘要
  Future<Map<String, bool>> getPermissionSummary() async {
    final permissionService = PermissionService.to;

    // 这里可以添加具体的权限检查逻辑
    // 由于permission_handler的限制，这里只是示例
    return {
      'camera': false, // await Permission.camera.isGranted,
      'storage': false, // await Permission.storage.isGranted,
      'photos': false, // await Permission.photos.isGranted,
    };
  }

  /// 显示权限状态
  void showPermissionStatus() async {
    final summary = await getPermissionSummary();

    Get.dialog(
      AlertDialog(
        title: const Text('权限状态'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPermissionStatusItem('相机权限', summary['camera'] ?? false),
            _buildPermissionStatusItem('存储权限', summary['storage'] ?? false),
            _buildPermissionStatusItem('相册权限', summary['photos'] ?? false),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('确定')),
          if (summary.values.any((granted) => !granted))
            ElevatedButton(
              onPressed: () {
                Get.back();
                // 重新请求权限
                PermissionService.to.requestAllPermissions();
              },
              child: const Text('重新授权'),
            ),
        ],
      ),
    );
  }

  /// 构建权限状态项
  Widget _buildPermissionStatusItem(String name, bool granted) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            granted ? Icons.check_circle : Icons.cancel,
            color: granted ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(name),
          const Spacer(),
          Text(
            granted ? '已授权' : '未授权',
            style: TextStyle(
              color: granted ? Colors.green : Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
