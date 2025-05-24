import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hd_psi_mobile/services/api_service.dart';
import 'package:hd_psi_mobile/utils/config.dart';
import 'package:hd_psi_mobile/models/user.dart';
import 'package:hd_psi_mobile/api_client/api_adapter.dart';

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

      // 处理统一API响应格式
      final responseData = _processApiResponse(response);

      // 保存令牌
      final token = responseData['token'];
      await _secureStorage.write(key: AppConfig.tokenKey, value: token);
      await _secureStorage.write(
        key: AppConfig.refreshTokenKey,
        value: responseData['refresh_token'],
      );

      // 更新API适配器的认证头
      final supplierAdapter = SupplierApiAdapter();
      await supplierAdapter.updateToken(token);

      // 保存用户信息
      final user = User.fromJson(responseData['user']);
      await _secureStorage.write(
        key: AppConfig.userKey,
        value: jsonEncode(user.toJson()),
      );

      return user;
    } catch (e) {
      rethrow;
    }
  }

  // 处理统一API响应格式
  dynamic _processApiResponse(dynamic response) {
    // 检查是否是新的统一响应格式
    if (response is Map &&
        response.containsKey('code') &&
        response.containsKey('data')) {
      // 检查是否是成功响应码
      final code = response['code'];
      if (code >= 20000 && code < 30000) {
        // 返回data字段
        return response['data'];
      } else {
        // 如果是错误响应码，抛出错误
        final message = response['message'] ?? '请求失败';
        throw Exception(message);
      }
    }

    // 如果不是新的统一响应格式，直接返回数据
    return response;
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
