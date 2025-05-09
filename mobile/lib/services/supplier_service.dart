import '../models/supplier.dart';
import 'api_service.dart';

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
    final response = await _apiService.get(
      '/api/suppliers',
      queryParameters: {
        'name': name,
        'code': code,
        'type': type?.toJson(),
        'status': status,
        'page': page,
        'limit': limit,
      },
    );
    final suppliers =
        (response['items'] as List)
            .map((json) => Supplier.fromJson(json))
            .toList();

    // 返回供应商列表
    return suppliers;
  }

  // 获取供应商详情
  Future<Supplier> getSupplier(int id) async {
    final response = await _apiService.get('/api/suppliers/$id');
    return Supplier.fromJson(response);
  }

  // 创建供应商
  Future<Supplier> createSupplier(Supplier supplier) async {
    final response = await _apiService.post(
      '/api/suppliers',
      data: supplier.toJson(),
    );
    return Supplier.fromJson(response);
  }

  // 更新供应商
  Future<Supplier> updateSupplier(Supplier supplier) async {
    final response = await _apiService.put(
      '/api/suppliers/${supplier.id}',
      data: supplier.toJson(),
    );
    return Supplier.fromJson(response);
  }

  // 删除供应商
  Future<void> deleteSupplier(int id) async {
    await _apiService.delete('/api/suppliers/$id');
  }
}
