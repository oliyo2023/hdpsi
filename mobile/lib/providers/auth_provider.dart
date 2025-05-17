import 'package:flutter/material.dart';
import 'package:hd_psi_mobile/models/user.dart';
import 'package:hd_psi_mobile/services/auth_service.dart';
import 'package:hd_psi_mobile/utils/error_handler.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;

  AuthProvider() {
    // 自动加载用户信息
    _loadUser();
  }

  // 加载用户信息
  Future<void> _loadUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        _currentUser = user;
      }
    } catch (e) {
      _error = ErrorHandler.getFriendlyMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 登录
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _authService.login(username, password);
      return true;
    } catch (e) {
      // 使用错误处理工具获取友好的错误消息
      _error = ErrorHandler.getFriendlyMessage(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 登出
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _currentUser = null;
      _error = null;
    } catch (e) {
      _error = ErrorHandler.getFriendlyMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
