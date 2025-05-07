import '../models/member.dart';
import '../utils/config.dart';
import 'api_service.dart';

class MemberService {
  final ApiService _apiService = ApiService();
  
  // 获取会员列表
  Future<Map<String, dynamic>> getMembers({
    int page = 1,
    int pageSize = 10,
    String? name,
    String? phone,
    String? level,
  }) async {
    try {
      Map<String, dynamic> params = {
        'page': page,
        'pageSize': pageSize,
      };
      
      if (name != null && name.isNotEmpty) {
        params['name'] = name;
      }
      
      if (phone != null && phone.isNotEmpty) {
        params['phone'] = phone;
      }
      
      if (level != null && level.isNotEmpty) {
        params['level'] = level;
      }
      
      final response = await _apiService.get(AppConfig.membersPath, queryParameters: params);
      
      List<Member> members = [];
      if (response['items'] != null) {
        members = List<Member>.from(
          response['items'].map((item) => Member.fromJson(item))
        );
      }
      
      return {
        'items': members,
        'total': response['total'] ?? 0,
        'page': response['page'] ?? 1,
        'pageSize': response['pageSize'] ?? 10,
      };
    } catch (e) {
      rethrow;
    }
  }
  
  // 获取单个会员
  Future<Member> getMember(int id) async {
    try {
      final response = await _apiService.get('${AppConfig.membersPath}/$id');
      
      return Member.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
  
  // 创建会员
  Future<Member> createMember(Map<String, dynamic> memberData) async {
    try {
      final response = await _apiService.post(AppConfig.membersPath, data: memberData);
      
      return Member.fromJson(response['member']);
    } catch (e) {
      rethrow;
    }
  }
  
  // 更新会员
  Future<Member> updateMember(int id, Map<String, dynamic> memberData) async {
    try {
      final response = await _apiService.put('${AppConfig.membersPath}/$id', data: memberData);
      
      return Member.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
  
  // 删除会员
  Future<void> deleteMember(int id) async {
    try {
      await _apiService.delete('${AppConfig.membersPath}/$id');
    } catch (e) {
      rethrow;
    }
  }
  
  // 获取会员积分
  Future<Map<String, dynamic>> getMemberPoints(int id) async {
    try {
      final response = await _apiService.get('${AppConfig.membersPath}/$id/points');
      
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  // 获取会员积分交易记录
  Future<Map<String, dynamic>> getMemberPointsTransactions(int id, {int page = 1, int pageSize = 10}) async {
    try {
      Map<String, dynamic> params = {
        'page': page,
        'pageSize': pageSize,
      };
      
      final response = await _apiService.get(
        '${AppConfig.membersPath}/$id/points/transactions',
        queryParameters: params,
      );
      
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  // 添加会员积分
  Future<Map<String, dynamic>> addMemberPoints(int id, int points, String type, String note) async {
    try {
      Map<String, dynamic> data = {
        'points': points,
        'type': type,
        'note': note,
      };
      
      final response = await _apiService.post('${AppConfig.membersPath}/$id/points/add', data: data);
      
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
