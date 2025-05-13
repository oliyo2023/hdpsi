import '../utils/logger.dart';
import 'api_adapter.dart';
import 'generated/lib/api.dart' as api;

/// 会员API适配器
class MemberApiAdapter extends BaseApiAdapter {
  // 单例模式
  static final MemberApiAdapter _instance = MemberApiAdapter._internal();
  factory MemberApiAdapter() => _instance;
  MemberApiAdapter._internal() : super();
  
  /// 获取会员列表
  Future<List<api.ModelsMember>> getMembers({
    String? name,
    String? phone,
    String? level,
    int page = 1,
    int pageSize = 10,
  }) async {
    final path = '/members';
    logRequest('GET', path);
    
    try {
      // 构建查询参数
      final queryParams = <api.QueryParam>[];
      if (name != null) queryParams.add(api.QueryParam('name', name));
      if (phone != null) queryParams.add(api.QueryParam('phone', phone));
      if (level != null) queryParams.add(api.QueryParam('level', level));
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
      final decoded = await apiClient.deserializeAsync(
        response.body,
        'MembersGet200Response',
      ) as api.MembersGet200Response?;
      
      logResponse('GET', path, decoded);
      
      return decoded?.items ?? [];
    } catch (e) {
      logError('GET', path, e);
      rethrow;
    }
  }
  
  /// 获取会员详情
  Future<api.ModelsMember?> getMember(int id) async {
    final path = '/members/$id';
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
      final decoded = await apiClient.deserializeAsync(
        response.body,
        'ModelsMember',
      ) as api.ModelsMember?;
      
      logResponse('GET', path, decoded);
      
      return decoded;
    } catch (e) {
      logError('GET', path, e);
      rethrow;
    }
  }
  
  /// 创建会员
  Future<api.ModelsMember?> createMember(api.ModelsMember member) async {
    final path = '/members';
    logRequest('POST', path, member);
    
    try {
      // 发送请求
      final response = await apiClient.invokeAPI(
        path,
        'POST',
        <api.QueryParam>[],
        member,
        <String, String>{},
        <String, String>{},
        'application/json',
      );
      
      // 解析响应
      final decoded = await apiClient.deserializeAsync(
        response.body,
        'MembersPost201Response',
      ) as api.MembersPost201Response?;
      
      logResponse('POST', path, decoded);
      
      return decoded?.data;
    } catch (e) {
      logError('POST', path, e);
      rethrow;
    }
  }
  
  /// 更新会员
  Future<api.ModelsMember?> updateMember(int id, api.ModelsMember member) async {
    final path = '/members/$id';
    logRequest('PUT', path, member);
    
    try {
      // 发送请求
      final response = await apiClient.invokeAPI(
        path,
        'PUT',
        <api.QueryParam>[],
        member,
        <String, String>{},
        <String, String>{},
        'application/json',
      );
      
      // 解析响应
      final decoded = await apiClient.deserializeAsync(
        response.body,
        'ModelsMember',
      ) as api.ModelsMember?;
      
      logResponse('PUT', path, decoded);
      
      return decoded;
    } catch (e) {
      logError('PUT', path, e);
      rethrow;
    }
  }
  
  /// 删除会员
  Future<void> deleteMember(int id) async {
    final path = '/members/$id';
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
