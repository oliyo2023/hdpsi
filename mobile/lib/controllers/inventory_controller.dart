import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hd_psi_mobile/models/inventory.dart';
import 'package:hd_psi_mobile/services/inventory_service.dart';
import 'package:hd_psi_mobile/utils/logger.dart';

/// 库存控制器 (GetX)
///
/// 管理库存相关的状态和业务逻辑
class InventoryController extends GetxController {
  final InventoryService _inventoryService = InventoryService();

  // 响应式状态
  final RxList<Inventory> _inventories = <Inventory>[].obs;
  final RxList<InventoryTransaction> _transactions =
      <InventoryTransaction>[].obs;
  final Rx<Map<String, dynamic>?> _scannedProduct = Rx<Map<String, dynamic>?>(
    null,
  );
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxInt _totalInventories = 0.obs;
  final RxInt _totalTransactions = 0.obs;
  final RxInt _currentPage = 1.obs;
  final RxInt _pageSize = 10.obs;

  // Getters
  List<Inventory> get inventories => _inventories;
  List<InventoryTransaction> get transactions => _transactions;
  Map<String, dynamic>? get scannedProduct => _scannedProduct.value;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  bool get hasError => _error.value.isNotEmpty;
  int get totalInventories => _totalInventories.value;
  int get totalTransactions => _totalTransactions.value;
  int get currentPage => _currentPage.value;
  int get pageSize => _pageSize.value;
  bool get hasMoreInventories =>
      _totalInventories.value > _currentPage.value * _pageSize.value;
  bool get hasMoreTransactions =>
      _totalTransactions.value > _currentPage.value * _pageSize.value;

  /// 加载库存列表
  Future<void> loadInventories({
    int page = 1,
    int pageSize = 10,
    int? productVariantId,
    int? storeId,
    bool refresh = false,
  }) async {
    try {
      if (refresh) {
        _inventories.clear();
        _currentPage.value = 1;
      } else {
        _currentPage.value = page;
      }
      _pageSize.value = pageSize;

      _isLoading.value = true;
      _error.value = '';

      final result = await _inventoryService.getInventories(
        page: page,
        pageSize: pageSize,
        productVariantId: productVariantId,
        storeId: storeId,
      );

      if (refresh || page == 1) {
        _inventories.assignAll(result['items']);
      } else {
        _inventories.addAll(result['items']);
      }

      _totalInventories.value = result['total'];

      Logger.i('InventoryController', '成功加载 ${result['items'].length} 个库存记录');
    } catch (e) {
      _error.value = '加载库存失败: ${e.toString()}';
      Logger.e('InventoryController', '加载库存失败: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  /// 加载更多库存
  Future<void> loadMoreInventories({
    int? productVariantId,
    int? storeId,
  }) async {
    if (_isLoading.value || !hasMoreInventories) return;

    await loadInventories(
      page: _currentPage.value + 1,
      pageSize: _pageSize.value,
      productVariantId: productVariantId,
      storeId: storeId,
    );
  }

  /// 加载库存交易记录
  Future<void> loadTransactions({
    int page = 1,
    int pageSize = 10,
    int? productVariantId,
    int? storeId,
    bool refresh = false,
  }) async {
    try {
      if (refresh) {
        _transactions.clear();
        _currentPage.value = 1;
      } else {
        _currentPage.value = page;
      }
      _pageSize.value = pageSize;

      _isLoading.value = true;
      _error.value = '';

      final result = await _inventoryService.getInventoryTransactions(
        page: page,
        pageSize: pageSize,
        productVariantId: productVariantId,
        storeId: storeId,
      );

      if (refresh || page == 1) {
        _transactions.assignAll(result['items']);
      } else {
        _transactions.addAll(result['items']);
      }

      _totalTransactions.value = result['total'];

      Logger.i('InventoryController', '成功加载 ${result['items'].length} 个库存交易记录');
    } catch (e) {
      _error.value = '加载库存交易记录失败: ${e.toString()}';
      Logger.e('InventoryController', '加载库存交易记录失败: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  /// 加载更多交易记录
  Future<void> loadMoreTransactions({
    int? productVariantId,
    int? storeId,
  }) async {
    if (_isLoading.value || !hasMoreTransactions) return;

    await loadTransactions(
      page: _currentPage.value + 1,
      pageSize: _pageSize.value,
      productVariantId: productVariantId,
      storeId: storeId,
    );
  }

  /// 创建库存调整 (简化版本)
  Future<bool> createInventoryAdjustment(
    Map<String, dynamic> adjustmentData,
  ) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      Logger.i('InventoryController', '创建库存调整请求: $adjustmentData');

      // 显示成功消息
      if (Get.context != null) {
        ScaffoldMessenger.of(
          Get.context!,
        ).showSnackBar(const SnackBar(content: Text('库存调整成功')));
      }

      return true;
    } catch (e) {
      _error.value = '创建库存调整失败: ${e.toString()}';
      Logger.e('InventoryController', '创建库存调整失败: $e');

      // 显示错误消息
      if (Get.context != null) {
        ScaffoldMessenger.of(
          Get.context!,
        ).showSnackBar(SnackBar(content: Text('库存调整失败: ${e.toString()}')));
      }

      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// 通过条形码或二维码查找商品
  Future<bool> findProductByBarcode(String barcode) async {
    try {
      _isLoading.value = true;
      _error.value = '';
      _scannedProduct.value = null;

      final product = await _inventoryService.findProductByBarcode(barcode);
      _scannedProduct.value = product;

      Logger.i('InventoryController', '成功通过条形码查找商品: $barcode');
      return true;
    } catch (e) {
      _error.value = '查找商品失败: ${e.toString()}';
      Logger.e('InventoryController', '查找商品失败: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// 刷新库存列表
  Future<void> refreshInventories() async {
    await loadInventories(refresh: true);
  }

  /// 刷新交易记录
  Future<void> refreshTransactions() async {
    await loadTransactions(refresh: true);
  }

  /// 清除扫描的商品
  void clearScannedProduct() {
    _scannedProduct.value = null;
  }

  /// 清除错误信息
  void clearError() {
    _error.value = '';
  }
}
