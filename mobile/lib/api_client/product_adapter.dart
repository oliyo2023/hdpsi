import 'api_adapter.dart';
import 'package:hd_psi_mobile/api_client/generated/lib/api.dart' as api;

/// 商品API适配器
class ProductApiAdapter extends BaseApiAdapter {
  // 单例模式
  static final ProductApiAdapter _instance = ProductApiAdapter._internal();
  factory ProductApiAdapter() => _instance;
  ProductApiAdapter._internal() : super();

  /// 获取商品列表
  Future<List<api.ModelsProduct>> getProducts({
    String? name,
    String? code,
    String? category,
    String? brand,
    bool? status,
    int page = 1,
    int pageSize = 10,
  }) async {
    final path = '/products';
    logRequest('GET', path);

    try {
      // 构建查询参数
      final queryParams = <api.QueryParam>[];
      if (name != null) queryParams.add(api.QueryParam('name', name));
      if (code != null) queryParams.add(api.QueryParam('code', code));
      if (category != null)
        queryParams.add(api.QueryParam('category', category));
      if (brand != null) queryParams.add(api.QueryParam('brand', brand));
      if (status != null)
        queryParams.add(api.QueryParam('status', status.toString()));
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

      // 解析响应
      final decoded =
          await apiClient.deserializeAsync(
                response.body,
                'ProductsGet200Response',
              )
              as api.ProductsGet200Response?;

      logResponse('GET', path, decoded);

      return decoded?.items ?? [];
    } catch (e) {
      logError('GET', path, e);
      rethrow;
    }
  }

  /// 获取商品详情
  Future<api.ModelsProduct?> getProduct(int id) async {
    final path = '/products/$id';
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

      // 解析响应
      final decoded =
          await apiClient.deserializeAsync(response.body, 'ModelsProduct')
              as api.ModelsProduct?;

      logResponse('GET', path, decoded);

      return decoded;
    } catch (e) {
      logError('GET', path, e);
      rethrow;
    }
  }

  /// 创建商品
  Future<api.ModelsProduct?> createProduct(api.ModelsProduct product) async {
    final path = '/products';
    logRequest('POST', path, product);

    try {
      // 发送请求
      final response = await apiClient.invokeAPI(
        path,
        'POST',
        <api.QueryParam>[],
        product,
        <String, String>{},
        <String, String>{},
        'application/json',
      );

      // 解析响应
      final decoded =
          await apiClient.deserializeAsync(response.body, 'ModelsProduct')
              as api.ModelsProduct?;

      logResponse('POST', path, decoded);

      return decoded;
    } catch (e) {
      logError('POST', path, e);
      rethrow;
    }
  }

  /// 更新商品
  Future<api.ModelsProduct?> updateProduct(
    int id,
    api.ModelsProduct product,
  ) async {
    final path = '/products/$id';
    logRequest('PUT', path, product);

    try {
      // 发送请求
      final response = await apiClient.invokeAPI(
        path,
        'PUT',
        <api.QueryParam>[],
        product,
        <String, String>{},
        <String, String>{},
        'application/json',
      );

      // 解析响应
      final decoded =
          await apiClient.deserializeAsync(response.body, 'ModelsProduct')
              as api.ModelsProduct?;

      logResponse('PUT', path, decoded);

      return decoded;
    } catch (e) {
      logError('PUT', path, e);
      rethrow;
    }
  }

  /// 删除商品
  Future<void> deleteProduct(int id) async {
    final path = '/products/$id';
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
