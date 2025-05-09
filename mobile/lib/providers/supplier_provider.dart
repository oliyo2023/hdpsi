import 'package:flutter/material.dart';
import '../models/supplier.dart';
import '../services/supplier_service.dart';
import '../utils/logger.dart';

class SupplierProvider with ChangeNotifier {
  final SupplierService _supplierService;

  List<Supplier> _suppliers = [];
  List<Supplier> get suppliers => _suppliers;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  SupplierProvider(this._supplierService);

  Future<void> fetchSuppliers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _suppliers = await _supplierService.getSuppliers();
      Logger.i('SupplierProvider', '成功获取 ${_suppliers.length} 个供应商');
    } catch (e) {
      _errorMessage = '获取供应商失败: ${e.toString()}';
      Logger.e('SupplierProvider', '获取供应商失败: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createSupplier(Supplier supplier) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _supplierService.createSupplier(supplier);
      // After creating, refresh the list
      fetchSuppliers();
    } catch (e) {
      _errorMessage = 'Failed to create supplier: ${e.toString()}';
      _isLoading = false; // Stop loading on error
      notifyListeners();
    }
  }

  Future<void> updateSupplier(Supplier supplier) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _supplierService.updateSupplier(supplier);
      // After updating, refresh the list
      fetchSuppliers();
    } catch (e) {
      _errorMessage = 'Failed to update supplier: ${e.toString()}';
      _isLoading = false; // Stop loading on error
      notifyListeners();
    }
  }

  Future<void> deleteSupplier(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _supplierService.deleteSupplier(id);
      // 删除成功后刷新列表
      fetchSuppliers();
    } catch (e) {
      _errorMessage = '删除供应商失败: ${e.toString()}';
      _isLoading = false; // 出错时停止加载
      notifyListeners();
    }
  }
}
