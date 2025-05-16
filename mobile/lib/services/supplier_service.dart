import 'package:hd_psi_mobile/models/supplier.dart';
import 'package:hd_psi_mobile/utils/config.dart';
import 'package:hd_psi_mobile/utils/logger.dart';
import 'package:hd_psi_mobile/services/api_service.dart';

class SupplierService {
  final ApiService _apiService = ApiService();

  // 获取供应商列表
  Future<List<Supplier>> getSuppliers({
    String? name,
    String? code,
    SupplierType? type,
    bool? status,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.get(
        AppConfig.suppliersPath,
        queryParameters: {
          'name': name,
          'code': code,
          'type': type?.toJson(),
          'status': status,
          'page': page,
          'limit': limit,
        },
      );

      // 检查响应格式
      if (response == null) {
        throw Exception('API返回了空响应');
      }

      if (!response.containsKey('items') || response['items'] is! List) {
        throw Exception('API响应格式不正确: ${response.toString()}');
      }

      // 安全地转换每个项目
      final List<Supplier> suppliers = [];
      for (var item in response['items'] as List) {
        try {
          // 确保ID字段存在且为数字
          if (item['ID'] == null) {
            Logger.w('SupplierService', '警告: 供应商数据缺少ID字段: $item');
            continue;
          }

          // 尝试转换为Supplier对象
          suppliers.add(Supplier.fromJson(item));
        } catch (e) {
          Logger.e('SupplierService', '解析供应商数据时出错: $e, 数据: $item');
          // 继续处理下一个项目
        }
      }

      return suppliers;
    } catch (e) {
      Logger.e('SupplierService', '获取供应商列表时出错: $e');
      rethrow;
    }
  }

  // 获取供应商详情
  Future<Supplier> getSupplier(int id) async {
    try {
      final response = await _apiService.get('${AppConfig.suppliersPath}/$id');

      if (response == null) {
        throw Exception('API返回了空响应');
      }

      return Supplier.fromJson(response);
    } catch (e) {
      Logger.e('SupplierService', '获取供应商详情时出错: $e');
      rethrow;
    }
  }

  // 创建供应商
  Future<Supplier> createSupplier(Supplier supplier) async {
    // 将 Supplier 对象转换为 JSON，并确保字段名称正确
    final Map<String, dynamic> data = {
      'name': supplier.name,
      'code': supplier.code,
      'type': supplier.type.toJson(),
      'contact_person': supplier.contactPerson,
      'contact_phone': supplier.contactPhone,
      'email': supplier.email,
      'address': supplier.address,
      'city': supplier.city,
      'rating': supplier.rating?.toString().split('.').last,
      'qualification': supplier.qualification,
      'payment_terms': supplier.paymentTerms,
      'delivery_terms': supplier.deliveryTerms,
      'status': supplier.status,
      'note': supplier.note,
    };

    Logger.i('SupplierService', '创建供应商数据: $data');

    final response = await _apiService.post(
      AppConfig.suppliersPath,
      data: data,
    );
    return Supplier.fromJson(response);
  }

  // 更新供应商
  Future<Supplier> updateSupplier(Supplier supplier) async {
    // 将 Supplier 对象转换为 JSON，并确保字段名称正确
    final Map<String, dynamic> data = {
      'name': supplier.name,
      'code': supplier.code,
      'type': supplier.type.toJson(),
      'contact_person': supplier.contactPerson,
      'contact_phone': supplier.contactPhone,
      'email': supplier.email,
      'address': supplier.address,
      'city': supplier.city,
      'rating': supplier.rating?.toString().split('.').last,
      'qualification': supplier.qualification,
      'payment_terms': supplier.paymentTerms,
      'delivery_terms': supplier.deliveryTerms,
      'status': supplier.status,
      'note': supplier.note,
    };

    Logger.i('SupplierService', '更新供应商数据: $data');

    final response = await _apiService.put(
      '${AppConfig.suppliersPath}/${supplier.id}',
      data: data,
    );
    return Supplier.fromJson(response);
  }

  // 删除供应商
  Future<void> deleteSupplier(int id) async {
    await _apiService.delete('${AppConfig.suppliersPath}/$id');
  }
}
