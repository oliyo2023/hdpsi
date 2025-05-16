import 'package:hd_psi_mobile/api_client/api_adapter.dart';
import 'package:hd_psi_mobile/models/supplier.dart';
import 'package:hd_psi_mobile/utils/logger.dart';
import 'package:hd_psi_mobile/utils/model_converter.dart';
import 'package:hd_psi_mobile/services/supplier_service.dart';

/// 供应商服务适配器
///
/// 使用新的API适配器，但保持与旧代码的兼容性
class SupplierServiceAdapter implements SupplierService {
  final SupplierApiAdapter _supplierAdapter = SupplierApiAdapter();

  /// 获取供应商列表
  @override
  Future<List<Supplier>> getSuppliers({
    String? name,
    String? code,
    SupplierType? type,
    bool? status,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      // 使用新的API适配器获取供应商列表
      final apiSuppliers = await _supplierAdapter.getSuppliers(
        name: name,
        code: code,
        type: type?.toString().split('.').last,
        page: page,
        pageSize: limit,
      );

      // 将API供应商模型转换为应用供应商模型
      return apiSuppliers
          .map(
            (apiSupplier) =>
                ModelConverter.apiSupplierToAppSupplier(apiSupplier),
          )
          .toList();
    } catch (e) {
      Logger.e('SupplierServiceAdapter', '获取供应商列表失败: $e');
      rethrow;
    }
  }

  /// 获取供应商详情
  @override
  Future<Supplier> getSupplier(int id) async {
    try {
      // 使用新的API适配器获取供应商详情
      final apiSupplier = await _supplierAdapter.getSupplier(id);

      if (apiSupplier == null) {
        throw Exception('供应商不存在');
      }

      // 将API供应商模型转换为应用供应商模型
      return ModelConverter.apiSupplierToAppSupplier(apiSupplier);
    } catch (e) {
      Logger.e('SupplierServiceAdapter', '获取供应商详情失败: $e');
      rethrow;
    }
  }

  /// 创建供应商
  @override
  Future<Supplier> createSupplier(Supplier supplier) async {
    try {
      // 将应用供应商模型转换为API供应商模型
      final apiSupplier = ModelConverter.appSupplierToApiSupplier(supplier);

      // 使用新的API适配器创建供应商
      final createdApiSupplier = await _supplierAdapter.createSupplier(
        apiSupplier,
      );

      if (createdApiSupplier == null) {
        throw Exception('创建供应商失败');
      }

      // 将API供应商模型转换为应用供应商模型
      return ModelConverter.apiSupplierToAppSupplier(createdApiSupplier);
    } catch (e) {
      Logger.e('SupplierServiceAdapter', '创建供应商失败: $e');
      rethrow;
    }
  }

  /// 更新供应商
  @override
  Future<Supplier> updateSupplier(Supplier supplier) async {
    try {
      // 将应用供应商模型转换为API供应商模型
      final apiSupplier = ModelConverter.appSupplierToApiSupplier(supplier);

      // 使用新的API适配器更新供应商
      final updatedApiSupplier = await _supplierAdapter.updateSupplier(
        supplier.id,
        apiSupplier,
      );

      if (updatedApiSupplier == null) {
        throw Exception('更新供应商失败');
      }

      // 将API供应商模型转换为应用供应商模型
      return ModelConverter.apiSupplierToAppSupplier(updatedApiSupplier);
    } catch (e) {
      Logger.e('SupplierServiceAdapter', '更新供应商失败: $e');
      rethrow;
    }
  }

  /// 删除供应商
  @override
  Future<void> deleteSupplier(int id) async {
    try {
      // 使用新的API适配器删除供应商
      await _supplierAdapter.deleteSupplier(id);
    } catch (e) {
      Logger.e('SupplierServiceAdapter', '删除供应商失败: $e');
      rethrow;
    }
  }
}
