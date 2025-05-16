import 'package:hd_psi_mobile/models/inventory.dart';
import 'package:hd_psi_mobile/utils/config.dart';
import 'package:hd_psi_mobile/services/api_service.dart';

class InventoryService {
  final ApiService _apiService = ApiService();

  // 获取库存列表
  Future<Map<String, dynamic>> getInventories({
    int page = 1,
    int pageSize = 10,
    int? productVariantId,
    int? storeId,
  }) async {
    try {
      Map<String, dynamic> params = {'page': page, 'pageSize': pageSize};

      if (productVariantId != null) {
        params['product_variant_id'] = productVariantId;
      }

      if (storeId != null) {
        params['store_id'] = storeId;
      }

      final response = await _apiService.get(
        AppConfig.inventoryPath,
        queryParameters: params,
      );

      List<Inventory> inventories = [];
      if (response is List) {
        // 后端返回的是数组，直接解析
        inventories = List<Inventory>.from(
          response.map((item) => Inventory.fromJson(item)),
        );
      } else if (response is Map && response['items'] != null) {
        // 兼容分页格式
        inventories = List<Inventory>.from(
          response['items'].map((item) => Inventory.fromJson(item)),
        );
      }

      return {
        'items': inventories,
        'total':
            response is Map
                ? (response['total'] ?? inventories.length)
                : inventories.length,
        'page': response is Map ? (response['page'] ?? page) : page,
        'pageSize':
            response is Map ? (response['pageSize'] ?? pageSize) : pageSize,
      };
    } catch (e) {
      rethrow;
    }
  }

  // 获取单个库存
  Future<Inventory> getInventory(int id) async {
    try {
      final response = await _apiService.get('${AppConfig.inventoryPath}/$id');

      return Inventory.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // 更新库存
  Future<Inventory> updateInventory(
    int id,
    Map<String, dynamic> inventoryData,
  ) async {
    try {
      final response = await _apiService.put(
        '${AppConfig.inventoryPath}/$id',
        data: inventoryData,
      );

      return Inventory.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // 获取库存交易记录
  Future<Map<String, dynamic>> getInventoryTransactions({
    int page = 1,
    int pageSize = 10,
    int? productVariantId,
    int? storeId,
  }) async {
    try {
      Map<String, dynamic> params = {'page': page, 'pageSize': pageSize};

      if (productVariantId != null) {
        params['product_variant_id'] = productVariantId;
      }

      if (storeId != null) {
        params['store_id'] = storeId;
      }

      final response = await _apiService.get(
        AppConfig.inventoryTransactionsPath,
        queryParameters: params,
      );

      List<InventoryTransaction> transactions = [];
      if (response['items'] != null) {
        transactions = List<InventoryTransaction>.from(
          response['items'].map((item) => InventoryTransaction.fromJson(item)),
        );
      }

      return {
        'items': transactions,
        'total': response['total'] ?? 0,
        'page': response['page'] ?? 1,
        'pageSize': response['pageSize'] ?? 10,
      };
    } catch (e) {
      rethrow;
    }
  }

  // 创建库存交易记录（出库/入库）
  Future<InventoryTransaction> createInventoryTransaction(
    Map<String, dynamic> transactionData,
  ) async {
    try {
      final response = await _apiService.post(
        AppConfig.inventoryTransactionsPath,
        data: transactionData,
      );

      return InventoryTransaction.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // 通过条形码或二维码查找商品
  Future<Map<String, dynamic>> findProductByBarcode(String barcode) async {
    try {
      final response = await _apiService.get(
        '${AppConfig.inventoryPath}/barcode/$barcode',
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }
}
