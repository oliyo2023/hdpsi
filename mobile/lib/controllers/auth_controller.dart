import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hd_psi_mobile/models/user.dart';
import 'package:hd_psi_mobile/services/auth_service.dart';
import 'package:hd_psi_mobile/utils/error_handler.dart';
import 'package:hd_psi_mobile/utils/logger.dart';

/// 认证控制器 (GetX)
///
/// 管理用户认证相关的状态和业务逻辑
class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  // 响应式状态
  final Rx<User?> _currentUser = Rx<User?>(null);
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;

  // Getters
  User? get currentUser => _currentUser.value;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  bool get hasError => _error.value.isNotEmpty;
  bool get isLoggedIn => _currentUser.value != null;

  @override
  void onInit() {
    super.onInit();
    // 自动加载用户信息
    _loadUser();
  }

  /// 加载用户信息
  Future<void> _loadUser() async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final user = await _authService.getCurrentUser();
      if (user != null) {
        _currentUser.value = user;
        Logger.i('AuthController', '成功加载用户信息: ${user.username}');
      }
    } catch (e) {
      _error.value = ErrorHandler.getFriendlyMessage(e);
      Logger.e('AuthController', '加载用户信息失败: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  /// 用户登录
  Future<bool> login(String username, String password) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final user = await _authService.login(username, password);
      _currentUser.value = user;

      Logger.i('AuthController', '用户登录成功: ${user.username}');

      // 显示成功消息
      if (Get.context != null) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          const SnackBar(content: Text('登录成功')),
        );
      }

      return true;
    } catch (e) {
      _error.value = ErrorHandler.getFriendlyMessage(e);
      Logger.e('AuthController', '用户登录失败: $e');

      // 显示错误消息
      if (Get.context != null) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(content: Text('登录失败: ${_error.value}')),
        );
      }

      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// 用户登出
  Future<void> logout() async {
    try {
      _isLoading.value = true;
      _error.value = '';

      await _authService.logout();
      _currentUser.value = null;

      Logger.i('AuthController', '用户登出成功');

      // 显示成功消息
      if (Get.context != null) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          const SnackBar(content: Text('已退出登录')),
        );
      }
    } catch (e) {
      _error.value = ErrorHandler.getFriendlyMessage(e);
      Logger.e('AuthController', '用户登出失败: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  /// 刷新用户信息
  Future<void> refreshUser() async {
    await _loadUser();
  }

  /// 清除错误信息
  void clearError() {
    _error.value = '';
  }

  /// 更新用户信息
  void updateUser(User user) {
    _currentUser.value = user;
    Logger.i('AuthController', '更新用户信息: ${user.username}');
  }
}
