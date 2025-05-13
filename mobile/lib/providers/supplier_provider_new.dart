import 'package:flutter/material.dart';
import '../api_client/api_adapter.dart';
import '../api_client/generated/lib/api.dart' as api;
import '../utils/logger.dart';

/// 供应商提供者
/// 
/// 使用API适配器获取和管理供应商数据
class SupplierProvider with ChangeNotifier {
  final SupplierApiAdapter _supplierAdapter = SupplierApiAdapter();

  List<api.ModelsSupplier> _suppliers = [];
  List<api.ModelsSupplier> get suppliers => _suppliers;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// 获取供应商列表
  Future<void> fetchSuppliers({
    String? name,
    String? code,
    String? type,
    int page = 1,
    int pageSize = 10,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _suppliers = await _supplierAdapter.getSuppliers(
        name: name,
        code: code,
        type: type,
        page: page,
        pageSize: pageSize,
      );
      Logger.i('SupplierProvider', '成功获取 ${_suppliers.length} 个供应商');
    } catch (e) {
      _errorMessage = '获取供应商失败: ${e.toString()}';
      Logger.e('SupplierProvider', '获取供应商失败: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 获取供应商详情
  Future<api.ModelsSupplier?> getSupplier(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final supplier = await _supplierAdapter.getSupplier(id);
      _isLoading = false;
      notifyListeners();
      return supplier;
    } catch (e) {
      _errorMessage = '获取供应商详情失败: ${e.toString()}';
      Logger.e('SupplierProvider', '获取供应商详情失败: $e');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// 创建供应商
  Future<bool> createSupplier(api.ModelsSupplier supplier) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _supplierAdapter.createSupplier(supplier);
      // 创建成功后刷新列表
      await fetchSuppliers();
      return true;
    } catch (e) {
      _errorMessage = '创建供应商失败: ${e.toString()}';
      Logger.e('SupplierProvider', '创建供应商失败: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 更新供应商
  Future<bool> updateSupplier(int id, api.ModelsSupplier supplier) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _supplierAdapter.updateSupplier(id, supplier);
      // 更新成功后刷新列表
      await fetchSuppliers();
      return true;
    } catch (e) {
      _errorMessage = '更新供应商失败: ${e.toString()}';
      Logger.e('SupplierProvider', '更新供应商失败: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 删除供应商
  Future<bool> deleteSupplier(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _supplierAdapter.deleteSupplier(id);
      // 删除成功后刷新列表
      await fetchSuppliers();
      return true;
    } catch (e) {
      _errorMessage = '删除供应商失败: ${e.toString()}';
      Logger.e('SupplierProvider', '删除供应商失败: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
