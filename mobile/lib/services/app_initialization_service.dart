import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';

/// 应用初始化服务
/// 负责应用启动时的初始化工作，包括权限检查、首次启动引导等
class AppInitializationService extends GetxService {
  static AppInitializationService get to => Get.find();

  // Logger标签
  static const String _tag = 'AppInitializationService';

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
      Logger.e(_tag, '应用初始化失败: $e');
      isInitialized.value = true; // 即使失败也标记为已初始化，避免卡住
    }
  }

  /// 检查是否首次启动
  Future<void> _checkFirstLaunch() async {
    // 实现检查首次启动的逻辑
  }

  /// 检查权限引导状态
  Future<void> _checkPermissionGuideStatus() async {
    // 实现检查权限引导状态的逻辑
  }

  /// 初始化权限服务
  Future<void> _initializePermissionService() async {
    // 实现初始化权限服务的逻辑
  }

  /// 重置首次启动状态（用于测试）
  Future<void> resetFirstLaunchStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // 清除所有存储的状态

      // 重置响应式状态
      isFirstLaunch.value = true;
      isPermissionGuideCompleted.value = false;
      isInitialized.value = false;

      Logger.i(_tag, '应用状态已重置');
    } catch (e) {
      Logger.e(_tag, '重置应用状态失败: $e');
    }
  }
}
