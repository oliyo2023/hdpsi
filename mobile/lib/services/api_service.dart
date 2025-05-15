import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/config.dart';
import '../utils/logger.dart';
import 'error_interceptor.dart';

class ApiService {
  late Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // 单例模式
  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    _initDio();
  }

  // 初始化Dio
  void _initDio() {
    BaseOptions options = BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: Duration(milliseconds: AppConfig.connectTimeout),
      receiveTimeout: Duration(milliseconds: AppConfig.receiveTimeout),
      headers: {'Content-Type': 'application/json'},
    );

    _dio = Dio(options);

    // 添加拦截器
    _dio.interceptors.addAll([
      // 认证拦截器
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 获取令牌并添加到请求头
          final token = await _secureStorage.read(key: AppConfig.tokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          // 处理401错误（未授权）
          if (e.response?.statusCode == 401) {
            // 尝试刷新令牌
            bool refreshed = await _refreshToken();
            if (refreshed) {
              // 重试原始请求
              return handler.resolve(await _retry(e.requestOptions));
            }
          }
          return handler.next(e);
        },
      ),
      // 错误处理拦截器
      ErrorInterceptor(),
    ]);
  }

  // 重试请求
  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final token = await _secureStorage.read(key: AppConfig.tokenKey);
    final options = Options(
      method: requestOptions.method,
      headers: {'Authorization': 'Bearer $token'},
    );

    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  // 刷新令牌
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(
        key: AppConfig.refreshTokenKey,
      );
      if (refreshToken == null) {
        return false;
      }

      final response = await Dio().post(
        '${AppConfig.apiBaseUrl}/api/auth/refresh-token',
        data: jsonEncode({'refresh_token': refreshToken}),
      );

      if (response.statusCode == 200) {
        await _secureStorage.write(
          key: AppConfig.tokenKey,
          value: response.data['token'],
        );
        await _secureStorage.write(
          key: AppConfig.refreshTokenKey,
          value: response.data['refresh_token'],
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // GET请求
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // POST请求
  Future<dynamic> post(String path, {dynamic data}) async {
    try {
      Logger.i('ApiService', '发送POST请求: $path, 数据: $data');
      final response = await _dio.post(path, data: data);
      Logger.i(
        'ApiService',
        '收到POST响应: ${response.statusCode}, 数据: ${response.data}',
      );
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // PUT请求
  Future<dynamic> put(String path, {dynamic data}) async {
    try {
      Logger.i('ApiService', '发送PUT请求: $path, 数据: $data');
      final response = await _dio.put(path, data: data);
      Logger.i(
        'ApiService',
        '收到PUT响应: ${response.statusCode}, 数据: ${response.data}',
      );
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // DELETE请求
  Future<dynamic> delete(String path) async {
    try {
      final response = await _dio.delete(path);
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // 错误处理
  void _handleError(DioException e) {
    // 错误已经由 ErrorInterceptor 处理，这里只记录一个简短的日志
    Logger.e('ApiService', '请求失败: ${e.requestOptions.path}');
  }
}
