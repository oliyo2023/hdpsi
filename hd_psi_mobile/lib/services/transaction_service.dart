import '../models/transaction.dart';
import '../utils/config.dart';
import 'api_service.dart';

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
      'pageSize': pageSize.toString(),
      'memberId': memberId.toString(),
    };

    if (type != null) queryParams['type'] = type;
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    final response = await _apiService.get(
      '${AppConfig.apiBaseUrl}/api/transactions',
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
      'memberId': memberId,
      'points': points,
      'type': 'points_adjustment',
      'note': note,
    };

    final response = await _apiService.post(
      '${AppConfig.apiBaseUrl}/api/transactions/adjust-points',
      data: data,
    );
    return Transaction.fromJson(response);
  }
}
