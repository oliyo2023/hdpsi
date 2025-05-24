import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hd_psi_mobile/models/supplier.dart';
import 'package:hd_psi_mobile/services/supplier_service_adapter.dart';
import 'package:hd_psi_mobile/utils/logger.dart';

/// 供应商控制器 (GetX)
///
/// 管理供应商相关的状态和业务逻辑
class SupplierController extends GetxController {
  final SupplierServiceAdapter _supplierService = SupplierServiceAdapter();

  // 响应式状态
  final RxList<Supplier> _suppliers = <Supplier>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final Rx<Supplier?> _currentSupplier = Rx<Supplier?>(null);

  // Getters
  List<Supplier> get suppliers => _suppliers;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  bool get hasError => _error.value.isNotEmpty;
  Supplier? get currentSupplier => _currentSupplier.value;

  /// 获取供应商列表
  Future<void> fetchSuppliers({
    String? name,
    String? code,
    SupplierType? type,
    bool? status,
    int page = 1,
    int limit = 10,
    bool refresh = false,
  }) async {
    try {
      if (refresh) {
        _suppliers.clear();
      }

      _isLoading.value = true;
      _error.value = '';

      final supplierList = await _supplierService.getSuppliers(
        name: name,
        code: code,
        type: type,
        status: status,
        page: page,
        limit: limit,
      );

      if (refresh || page == 1) {
        _suppliers.assignAll(supplierList);
      } else {
        _suppliers.addAll(supplierList);
      }

      Logger.i('SupplierController', '成功获取 ${supplierList.length} 个供应商');
    } catch (e) {
      _error.value = '获取供应商失败: ${e.toString()}';
      Logger.e('SupplierController', '获取供应商失败: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  /// 根据ID获取供应商详情
  Future<Supplier?> getSupplier(int id) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final supplier = await _supplierService.getSupplier(id);
      _currentSupplier.value = supplier;

      Logger.i('SupplierController', '成功获取供应商详情: ${supplier.name}');
      return supplier;
    } catch (e) {
      _error.value = '获取供应商详情失败: ${e.toString()}';
      Logger.e('SupplierController', '获取供应商详情失败: $e');
      return null;
    } finally {
      _isLoading.value = false;
    }
  }

  /// 创建供应商
  Future<bool> createSupplier(Supplier supplier) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final createdSupplier = await _supplierService.createSupplier(supplier);

      // 将新创建的供应商添加到列表开头
      _suppliers.insert(0, createdSupplier);

      Logger.i('SupplierController', '成功创建供应商: ${createdSupplier.name}');

      // 显示成功消息
      if (Get.context != null) {
        ScaffoldMessenger.of(
          Get.context!,
        ).showSnackBar(const SnackBar(content: Text('供应商创建成功')));
      }

      return true;
    } catch (e) {
      _error.value = '创建供应商失败: ${e.toString()}';
      Logger.e('SupplierController', '创建供应商失败: $e');

      // 显示错误消息
      if (Get.context != null) {
        ScaffoldMessenger.of(
          Get.context!,
        ).showSnackBar(SnackBar(content: Text('创建供应商失败: ${e.toString()}')));
      }

      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// 更新供应商
  Future<bool> updateSupplier(Supplier supplier) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final updatedSupplier = await _supplierService.updateSupplier(supplier);

      // 更新列表中的供应商
      final index = _suppliers.indexWhere((s) => s.id == supplier.id);
      if (index != -1) {
        _suppliers[index] = updatedSupplier;
      }

      // 更新当前供应商
      if (_currentSupplier.value?.id == supplier.id) {
        _currentSupplier.value = updatedSupplier;
      }

      Logger.i('SupplierController', '成功更新供应商: ${updatedSupplier.name}');

      // 显示成功消息 - 使用传统的SnackBar避免GetX导航上下文问题
      if (Get.context != null) {
        ScaffoldMessenger.of(
          Get.context!,
        ).showSnackBar(const SnackBar(content: Text('供应商更新成功')));
      }

      return true;
    } catch (e) {
      _error.value = '更新供应商失败: ${e.toString()}';
      Logger.e('SupplierController', '更新供应商失败: $e');

      // 显示错误消息
      if (Get.context != null) {
        ScaffoldMessenger.of(
          Get.context!,
        ).showSnackBar(SnackBar(content: Text('更新供应商失败: ${e.toString()}')));
      }

      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// 删除供应商
  Future<bool> deleteSupplier(int id) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      await _supplierService.deleteSupplier(id);

      // 从列表中移除供应商
      _suppliers.removeWhere((s) => s.id == id);

      // 如果删除的是当前供应商，清空当前供应商
      if (_currentSupplier.value?.id == id) {
        _currentSupplier.value = null;
      }

      Logger.i('SupplierController', '成功删除供应商: $id');

      // 显示成功消息
      if (Get.context != null) {
        ScaffoldMessenger.of(
          Get.context!,
        ).showSnackBar(const SnackBar(content: Text('供应商删除成功')));
      }

      return true;
    } catch (e) {
      _error.value = '删除供应商失败: ${e.toString()}';
      Logger.e('SupplierController', '删除供应商失败: $e');

      // 显示错误消息
      if (Get.context != null) {
        ScaffoldMessenger.of(
          Get.context!,
        ).showSnackBar(SnackBar(content: Text('删除供应商失败: ${e.toString()}')));
      }

      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// 清除错误信息
  void clearError() {
    _error.value = '';
  }

  /// 清除当前供应商
  void clearCurrentSupplier() {
    _currentSupplier.value = null;
  }

  /// 刷新供应商列表
  Future<void> refreshSuppliers() async {
    await fetchSuppliers(refresh: true);
  }

  /// 搜索供应商
  Future<void> searchSuppliers(String keyword) async {
    await fetchSuppliers(name: keyword, refresh: true);
  }
}
