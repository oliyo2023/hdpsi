import 'package:flutter/material.dart';
import '../models/inventory.dart';
import '../services/inventory_service.dart';

class InventoryProvider extends ChangeNotifier {
  final InventoryService _inventoryService = InventoryService();
  
  List<Inventory> _inventories = [];
  List<InventoryTransaction> _transactions = [];
  Map<String, dynamic>? _scannedProduct;
  bool _isLoading = false;
  String? _error;
  int _totalInventories = 0;
  int _totalTransactions = 0;
  int _currentPage = 1;
  int _pageSize = 10;
  
  List<Inventory> get inventories => _inventories;
  List<InventoryTransaction> get transactions => _transactions;
  Map<String, dynamic>? get scannedProduct => _scannedProduct;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalInventories => _totalInventories;
  int get totalTransactions => _totalTransactions;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  bool get hasMoreInventories => _totalInventories > _currentPage * _pageSize;
  bool get hasMoreTransactions => _totalTransactions > _currentPage * _pageSize;
  
  // 加载库存列表
  Future<void> loadInventories({
    int page = 1,
    int pageSize = 10,
    int? productVariantId,
    int? storeId,
    bool refresh = false,
  }) async {
    if (refresh) {
      _inventories = [];
      _currentPage = 1;
    } else {
      _currentPage = page;
    }
    _pageSize = pageSize;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final result = await _inventoryService.getInventories(
        page: page,
        pageSize: pageSize,
        productVariantId: productVariantId,
        storeId: storeId,
      );
      
      if (refresh || page == 1) {
        _inventories = result['items'];
      } else {
        _inventories.addAll(result['items']);
      }
      
      _totalInventories = result['total'];
      _error = null;
    } catch (e) {
      _error = '加载库存失败: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 加载更多库存
  Future<void> loadMoreInventories({
    int? productVariantId,
    int? storeId,
  }) async {
    if (_isLoading || !hasMoreInventories) return;
    
    await loadInventories(
      page: _currentPage + 1,
      pageSize: _pageSize,
      productVariantId: productVariantId,
      storeId: storeId,
    );
  }
  
  // 加载库存交易记录
  Future<void> loadTransactions({
    int page = 1,
    int pageSize = 10,
    int? productVariantId,
    int? storeId,
    bool refresh = false,
  }) async {
    if (refresh) {
      _transactions = [];
      _currentPage = 1;
    } else {
      _currentPage = page;
    }
    _pageSize = pageSize;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final result = await _inventoryService.getInventoryTransactions(
        page: page,
        pageSize: pageSize,
        productVariantId: productVariantId,
        storeId: storeId,
      );
      
      if (refresh || page == 1) {
        _transactions = result['items'];
      } else {
        _transactions.addAll(result['items']);
      }
      
      _totalTransactions = result['total'];
      _error = null;
    } catch (e) {
      _error = '加载库存交易记录失败: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 加载更多交易记录
  Future<void> loadMoreTransactions({
    int? productVariantId,
    int? storeId,
  }) async {
    if (_isLoading || !hasMoreTransactions) return;
    
    await loadTransactions(
      page: _currentPage + 1,
      pageSize: _pageSize,
      productVariantId: productVariantId,
      storeId: storeId,
    );
  }
  
  // 创建库存交易记录（出库/入库）
  Future<bool> createTransaction(Map<String, dynamic> transactionData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final newTransaction = await _inventoryService.createInventoryTransaction(transactionData);
      _transactions.insert(0, newTransaction);
      _totalTransactions += 1;
      _error = null;
      return true;
    } catch (e) {
      _error = '创建库存交易记录失败: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 通过条形码或二维码查找商品
  Future<bool> findProductByBarcode(String barcode) async {
    _isLoading = true;
    _error = null;
    _scannedProduct = null;
    notifyListeners();
    
    try {
      _scannedProduct = await _inventoryService.findProductByBarcode(barcode);
      _error = null;
      return true;
    } catch (e) {
      _error = '查找商品失败: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 清除扫描的商品
  void clearScannedProduct() {
    _scannedProduct = null;
    notifyListeners();
  }
  
  // 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
