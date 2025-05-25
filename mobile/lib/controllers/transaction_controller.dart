import 'package:get/get.dart';
import 'package:hd_psi_mobile/models/transaction.dart';
import 'package:hd_psi_mobile/utils/logger.dart';

/// 交易控制器 (GetX)
///
/// 管理交易相关的状态和业务逻辑
class TransactionController extends GetxController {
  // 响应式状态
  final RxList<Transaction> _transactions = <Transaction>[].obs;
  final Rx<Transaction?> _selectedTransaction = Rx<Transaction?>(null);
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxInt _totalTransactions = 0.obs;
  final RxInt _currentPage = 1.obs;
  final RxInt _pageSize = 10.obs;

  // Getters
  List<Transaction> get transactions => _transactions;
  Transaction? get selectedTransaction => _selectedTransaction.value;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  bool get hasError => _error.value.isNotEmpty;
  int get totalTransactions => _totalTransactions.value;
  int get currentPage => _currentPage.value;
  int get pageSize => _pageSize.value;
  bool get hasMorePages =>
      _totalTransactions.value > _currentPage.value * _pageSize.value;

  /// 加载交易列表 (简化版本)
  Future<void> loadTransactions({
    int page = 1,
    int pageSize = 10,
    String? type,
    String? status,
    int? memberId,
    DateTime? startDate,
    DateTime? endDate,
    bool refresh = false,
  }) async {
    try {
      if (refresh) {
        _transactions.clear();
        _currentPage.value = 1;
      } else {
        _currentPage.value = page;
      }
      _pageSize.value = pageSize;

      _isLoading.value = true;
      _error.value = '';

      // 模拟数据加载
      Logger.i('TransactionController', '加载交易列表请求');

      // 这里应该调用实际的API
      _totalTransactions.value = 0;

      Logger.i('TransactionController', '成功加载交易记录');
    } catch (e) {
      _error.value = '加载交易记录失败: ${e.toString()}';
      Logger.e('TransactionController', '加载交易记录失败: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  /// 加载更多交易
  Future<void> loadMoreTransactions({
    String? type,
    String? status,
    int? memberId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (_isLoading.value || !hasMorePages) return;

    await loadTransactions(
      page: _currentPage.value + 1,
      pageSize: _pageSize.value,
      type: type,
      status: status,
      memberId: memberId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// 获取单个交易 (简化版本)
  Future<Transaction?> getTransaction(int id) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      Logger.i('TransactionController', '获取交易详情请求: $id');

      // 这里应该调用实际的API
      return null;
    } catch (e) {
      _error.value = '获取交易详情失败: ${e.toString()}';
      Logger.e('TransactionController', '获取交易详情失败: $e');
      return null;
    } finally {
      _isLoading.value = false;
    }
  }

  /// 搜索交易
  Future<void> searchTransactions({
    String? type,
    String? status,
    int? memberId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await loadTransactions(
      type: type,
      status: status,
      memberId: memberId,
      startDate: startDate,
      endDate: endDate,
      refresh: true,
    );
  }

  /// 刷新交易列表
  Future<void> refreshTransactions() async {
    await loadTransactions(refresh: true);
  }

  /// 清除错误信息
  void clearError() {
    _error.value = '';
  }

  /// 清除选中的交易
  void clearSelectedTransaction() {
    _selectedTransaction.value = null;
  }
}
