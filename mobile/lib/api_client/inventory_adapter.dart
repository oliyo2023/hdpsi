import 'api_adapter.dart';
import 'generated/lib/api.dart' as api;

/// 库存API适配器
class InventoryApiAdapter extends BaseApiAdapter {
  // 单例模式
  static final InventoryApiAdapter _instance = InventoryApiAdapter._internal();
  factory InventoryApiAdapter() => _instance;
  InventoryApiAdapter._internal() : super();

  /// 获取库存列表
  Future<List<api.ModelsInventory>> getInventories({
    int? productVariantId,
    int? storeId,
    int page = 1,
    int pageSize = 10,
  }) async {
    final path = '/inventory';
    logRequest('GET', path);

    try {
      // 构建查询参数
      final queryParams = <api.QueryParam>[];
      if (productVariantId != null)
        queryParams.add(
          api.QueryParam('product_variant_id', productVariantId.toString()),
        );
      if (storeId != null)
        queryParams.add(api.QueryParam('store_id', storeId.toString()));
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
                'InventoryGet200Response',
              )
              as api.InventoryGet200Response?;

      logResponse('GET', path, decoded);

      return decoded?.items ?? [];
    } catch (e) {
      logError('GET', path, e);
      rethrow;
    }
  }

  /// 获取库存详情
  Future<api.ModelsInventory?> getInventory(int id) async {
    final path = '/inventory/$id';
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
          await apiClient.deserializeAsync(response.body, 'ModelsInventory')
              as api.ModelsInventory?;

      logResponse('GET', path, decoded);

      return decoded;
    } catch (e) {
      logError('GET', path, e);
      rethrow;
    }
  }

  /// 创建库存
  Future<api.ModelsInventory?> createInventory(
    api.ModelsInventory inventory,
  ) async {
    final path = '/inventory';
    logRequest('POST', path, inventory);

    try {
      // 发送请求
      final response = await apiClient.invokeAPI(
        path,
        'POST',
        <api.QueryParam>[],
        inventory,
        <String, String>{},
        <String, String>{},
        'application/json',
      );

      // 解析响应
      final decoded =
          await apiClient.deserializeAsync(response.body, 'ModelsInventory')
              as api.ModelsInventory?;

      logResponse('POST', path, decoded);

      return decoded;
    } catch (e) {
      logError('POST', path, e);
      rethrow;
    }
  }

  /// 更新库存
  Future<api.ModelsInventory?> updateInventory(
    int id,
    api.ModelsInventory inventory,
  ) async {
    final path = '/inventory/$id';
    logRequest('PUT', path, inventory);

    try {
      // 发送请求
      final response = await apiClient.invokeAPI(
        path,
        'PUT',
        <api.QueryParam>[],
        inventory,
        <String, String>{},
        <String, String>{},
        'application/json',
      );

      // 解析响应
      final decoded =
          await apiClient.deserializeAsync(response.body, 'ModelsInventory')
              as api.ModelsInventory?;

      logResponse('PUT', path, decoded);

      return decoded;
    } catch (e) {
      logError('PUT', path, e);
      rethrow;
    }
  }

  /// 删除库存
  Future<void> deleteInventory(int id) async {
    final path = '/inventory/$id';
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
