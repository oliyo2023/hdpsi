import 'package:hd_psi_mobile/models/transaction.dart';
import 'package:hd_psi_mobile/utils/config.dart';
import 'package:hd_psi_mobile/services/api_service.dart';

class TransactionService {
  final ApiService _apiService = ApiService();

  // 获取会员交易记录
  Future<Map<String, dynamic>> getMemberTransactions({
    required int memberId,
    int page = 1,
    int pageSize = 10,
    String? type,
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': pageSize.toString(), // 后端使用limit而不是pageSize
    };

    if (type != null) queryParams['type'] = type;
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    final response = await _apiService.get(
      '${AppConfig.apiBaseUrl}/api/members/$memberId/points/transactions',
      queryParameters: queryParams,
    );

    final List<Transaction> transactions =
        (response['items'] as List)
            .map((item) => Transaction.fromJson(item))
            .toList();

    return {
      'items': transactions,
      'total': response['total'],
      'page': response['page'],
      'pageSize': response['pageSize'],
    };
  }

  // 获取单个交易详情
  Future<Transaction> getTransaction(int id) async {
    final response = await _apiService.get(
      '${AppConfig.apiBaseUrl}/api/transactions/$id',
    );
    return Transaction.fromJson(response);
  }

  // 创建新交易
  Future<Transaction> createTransaction(Map<String, dynamic> data) async {
    final response = await _apiService.post(
      '${AppConfig.apiBaseUrl}/api/transactions',
      data: data,
    );
    return Transaction.fromJson(response);
  }

  // 创建积分调整交易
  Future<Transaction> adjustPoints({
    required int memberId,
    required int points,
    String? note,
  }) async {
    final data = {
      'points': points.abs(), // 使用绝对值，API会根据正负处理
      'type': 'points_adjustment',
      'note': note,
    };

    // 根据积分正负选择不同的API端点
    final endpoint =
        points >= 0
            ? '${AppConfig.apiBaseUrl}/api/members/$memberId/points/add'
            : '${AppConfig.apiBaseUrl}/api/members/$memberId/points/deduct';

    final response = await _apiService.post(endpoint, data: data);

    // 构造一个Transaction对象
    return Transaction(
      id: response['ID'] ?? 0,
      memberId: memberId,
      memberName: '',
      type: 'points_adjustment',
      amount: 0,
      pointsEarned: points > 0 ? points : 0,
      pointsUsed: points < 0 ? -points : 0,
      note: note,
      createdAt: DateTime.now().toIso8601String(),
    );
  }
}
