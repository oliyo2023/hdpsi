import 'dart:convert';
import 'package:hd_psi_mobile/utils/logger.dart';
import 'package:hd_psi_mobile/utils/config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:hd_psi_mobile/api_client/generated/lib/api.dart' as api;
import 'json_adapter.dart';

/// API适配器基类
///
/// 所有API适配器的基类，提供通用功能
abstract class BaseApiAdapter {
  // API基础URL
  static String get baseUrl => AppConfig.apiBaseUrl;

  // 安全存储
  final _secureStorage = const FlutterSecureStorage();

  // API客户端
  late final api.ApiClient apiClient;

  // 默认API
  late final api.DefaultApi defaultApi;

  // 构造函数
  BaseApiAdapter() {
    _initApiClient();
  }

  /// 初始化API客户端
  Future<void> _initApiClient() async {
    // 创建API客户端
    apiClient = api.ApiClient(basePath: baseUrl);

    // 获取令牌
    final token = await _secureStorage.read(key: AppConfig.tokenKey);
    if (token != null) {
      apiClient.addDefaultHeader('Authorization', 'Bearer $token');
    }

    // 创建默认API
    defaultApi = api.DefaultApi(apiClient);

    // 添加日志
    _addLogging();
  }

  /// 添加日志记录
  void _addLogging() {
    // 由于生成的API客户端使用http包而不是dio，我们无法直接添加拦截器
    // 但我们可以在每个适配器方法中添加日志记录
  }

  /// 更新认证令牌
  Future<void> updateToken(String token) async {
    await _secureStorage.write(key: AppConfig.tokenKey, value: token);
    apiClient.addDefaultHeader('Authorization', 'Bearer $token');
  }

  /// 清除认证令牌
  Future<void> clearToken() async {
    await _secureStorage.delete(key: AppConfig.tokenKey);
    apiClient.addDefaultHeader('Authorization', '');
  }

  /// 记录请求日志
  void logRequest(String method, String path, [dynamic data]) {
    Logger.i('API', '发送$method请求: $path');
    if (data != null) {
      Logger.i('API', '请求数据: $data');
    }
  }

  /// 记录响应日志
  void logResponse(String method, String path, dynamic response) {
    Logger.i('API', '收到$method响应: $path');
    Logger.i('API', '响应数据: $response');
  }

  /// 记录错误日志
  void logError(String method, String path, dynamic error) {
    Logger.e('API', '$method请求错误: $path');
    Logger.e('API', '错误信息: $error');
  }
}

/// 供应商API适配器
class SupplierApiAdapter extends BaseApiAdapter {
  // 单例模式
  static final SupplierApiAdapter _instance = SupplierApiAdapter._internal();
  factory SupplierApiAdapter() => _instance;
  SupplierApiAdapter._internal() : super();

  /// 获取供应商列表
  Future<List<api.ModelsSupplier>> getSuppliers({
    String? name,
    String? code,
    String? type,
    int page = 1,
    int pageSize = 10,
  }) async {
    final path = AppConfig.suppliersPath;
    logRequest('GET', path);

    try {
      // 构建查询参数
      final queryParams = <api.QueryParam>[];
      if (name != null) queryParams.add(api.QueryParam('name', name));
      if (code != null) queryParams.add(api.QueryParam('code', code));
      if (type != null) queryParams.add(api.QueryParam('type', type));
      queryParams.add(api.QueryParam('page', page.toString()));
      queryParams.add(api.QueryParam('pageSize', pageSize.toString()));

      // 发送请求
      final response = await apiClient.invokeAPI(
        path,
        'GET',
        queryParams,
        null,
        <String, String>{},
        <String, String>{},
        'application/json',
      );

      // 打印原始JSON响应
      Logger.i('API', '原始JSON响应: ${response.body}');

      // 转换JSON字段名称
      final adaptedJson = JsonAdapter.parseJson(response.body);
      final adaptedJsonString = jsonEncode(adaptedJson);
      Logger.i('API', '转换后的JSON: $adaptedJsonString');

      // 解析响应
      final decoded =
          await apiClient.deserializeAsync(
                adaptedJsonString,
                'SuppliersGet200Response',
              )
              as api.SuppliersGet200Response?;

      logResponse('GET', path, decoded);

      return decoded?.items ?? [];
    } catch (e) {
      logError('GET', path, e);
      rethrow;
    }
  }

  /// 获取供应商详情
  Future<api.ModelsSupplier?> getSupplier(int id) async {
    final path = '${AppConfig.suppliersPath}/$id';
    logRequest('GET', path);

    try {
      // 发送请求
      final response = await apiClient.invokeAPI(
        path,
        'GET',
        <api.QueryParam>[],
        null,
        <String, String>{},
        <String, String>{},
        'application/json',
      );

      // 打印原始JSON响应
      Logger.i('API', '原始JSON响应: ${response.body}');

      // 转换JSON字段名称
      final adaptedJson = JsonAdapter.parseJson(response.body);
      final adaptedJsonString = jsonEncode(adaptedJson);
      Logger.i('API', '转换后的JSON: $adaptedJsonString');

      // 解析响应
      final decoded =
          await apiClient.deserializeAsync(adaptedJsonString, 'ModelsSupplier')
              as api.ModelsSupplier?;

      logResponse('GET', path, decoded);

      return decoded;
    } catch (e) {
      logError('GET', path, e);
      rethrow;
    }
  }

  /// 创建供应商
  Future<api.ModelsSupplier?> createSupplier(
    api.ModelsSupplier supplier,
  ) async {
    final path = AppConfig.suppliersPath;
    logRequest('POST', path, supplier);

    try {
      // 发送请求
      final response = await apiClient.invokeAPI(
        path,
        'POST',
        <api.QueryParam>[],
        supplier,
        <String, String>{},
        <String, String>{},
        'application/json',
      );

      // 打印原始JSON响应
      Logger.i('API', '原始JSON响应: ${response.body}');

      // 转换JSON字段名称
      final adaptedJson = JsonAdapter.parseJson(response.body);
      final adaptedJsonString = jsonEncode(adaptedJson);
      Logger.i('API', '转换后的JSON: $adaptedJsonString');

      // 解析响应
      final decoded =
          await apiClient.deserializeAsync(adaptedJsonString, 'ModelsSupplier')
              as api.ModelsSupplier?;

      logResponse('POST', path, decoded);

      return decoded;
    } catch (e) {
      logError('POST', path, e);
      rethrow;
    }
  }

  /// 更新供应商
  Future<api.ModelsSupplier?> updateSupplier(
    int id,
    api.ModelsSupplier supplier,
  ) async {
    final path = '${AppConfig.suppliersPath}/$id';
    logRequest('PUT', path, supplier);

    try {
      // 发送请求
      final response = await apiClient.invokeAPI(
        path,
        'PUT',
        <api.QueryParam>[],
        supplier,
        <String, String>{},
        <String, String>{},
        'application/json',
      );

      // 打印原始JSON响应
      Logger.i('API', '原始JSON响应: ${response.body}');

      // 转换JSON字段名称
      final adaptedJson = JsonAdapter.parseJson(response.body);
      final adaptedJsonString = jsonEncode(adaptedJson);
      Logger.i('API', '转换后的JSON: $adaptedJsonString');

      // 解析响应
      final decoded =
          await apiClient.deserializeAsync(adaptedJsonString, 'ModelsSupplier')
              as api.ModelsSupplier?;

      logResponse('PUT', path, decoded);

      return decoded;
    } catch (e) {
      logError('PUT', path, e);
      rethrow;
    }
  }

  /// 删除供应商
  Future<void> deleteSupplier(int id) async {
    final path = '${AppConfig.suppliersPath}/$id';
    logRequest('DELETE', path);

    try {
      // 发送请求
      await apiClient.invokeAPI(
        path,
        'DELETE',
        <api.QueryParam>[],
        null,
        <String, String>{},
        <String, String>{},
        'application/json',
      );

      logResponse('DELETE', path, 'Success');
    } catch (e) {
      logError('DELETE', path, e);
      rethrow;
    }
  }
}
