import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';
import '../utils/config.dart';
import '../models/user.dart';
import '../api_client/api_adapter.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // 登录
  Future<User> login(String username, String password) async {
    try {
      final response = await _apiService.post(
        AppConfig.loginPath,
        data: {'username': username, 'password': password},
      );

      // 保存令牌
      final token = response['token'];
      await _secureStorage.write(key: AppConfig.tokenKey, value: token);
      await _secureStorage.write(
        key: AppConfig.refreshTokenKey,
        value: response['refresh_token'],
      );

      // 更新API适配器的认证头
      final supplierAdapter = SupplierApiAdapter();
      await supplierAdapter.updateToken(token);

      // 保存用户信息
      final user = User.fromJson(response['user']);
      await _secureStorage.write(
        key: AppConfig.userKey,
        value: jsonEncode(user.toJson()),
      );

      return user;
    } catch (e) {
      rethrow;
    }
  }

  // 检查是否已登录
  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.read(key: AppConfig.tokenKey);
    return token != null;
  }

  // 获取当前用户
  Future<User?> getCurrentUser() async {
    try {
      final userJson = await _secureStorage.read(key: AppConfig.userKey);
      if (userJson != null) {
        return User.fromJson(jsonDecode(userJson));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // 登出
  Future<void> logout() async {
    await _secureStorage.delete(key: AppConfig.tokenKey);
    await _secureStorage.delete(key: AppConfig.refreshTokenKey);
    await _secureStorage.delete(key: AppConfig.userKey);

    // 清除API适配器的认证头
    final supplierAdapter = SupplierApiAdapter();
    await supplierAdapter.clearToken();
  }
}
