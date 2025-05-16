import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 令牌管理器
/// 
/// 用于管理JWT令牌的存储和获取
class TokenManager {
  static final TokenManager _instance = TokenManager._internal();
  
  factory TokenManager() => _instance;
  
  TokenManager._internal();
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  static const String _tokenKey = 'jwt_token';
  static const String _refreshTokenKey = 'refresh_token';
  
  /// 保存令牌
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }
  
  /// 获取令牌
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }
  
  /// 保存刷新令牌
  Future<void> saveRefreshToken(String refreshToken) async {
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
  }
  
  /// 获取刷新令牌
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }
  
  /// 清除所有令牌
  Future<void> clearTokens() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
  }
}
