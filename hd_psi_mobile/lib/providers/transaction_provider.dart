import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/transaction_service.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionService _transactionService = TransactionService();
  
  List<Transaction> _transactions = [];
  Transaction? _selectedTransaction;
  bool _isLoading = false;
  String? _error;
  int _totalTransactions = 0;
  int _currentPage = 1;
  int _pageSize = 10;
  
  List<Transaction> get transactions => _transactions;
  Transaction? get selectedTransaction => _selectedTransaction;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalTransactions => _totalTransactions;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  bool get hasMorePages => _totalTransactions > _currentPage * _pageSize;
  
  // 加载会员交易记录
  Future<void> loadMemberTransactions({
    required int memberId,
    int page = 1,
    int pageSize = 10,
    String? type,
    String? startDate,
    String? endDate,
    bool refresh = false,
  }) async {
    if (refresh) {
      _transactions = [];
      _currentPage = 1;
    } else {
      _currentPage = page;
    }
    _pageSize = pageSize;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final result = await _transactionService.getMemberTransactions(
        memberId: memberId,
        page: page,
        pageSize: pageSize,
        type: type,
        startDate: startDate,
        endDate: endDate,
      );
      
      if (refresh || page == 1) {
        _transactions = result['items'];
      } else {
        _transactions.addAll(result['items']);
      }
      
      _totalTransactions = result['total'];
      _error = null;
    } catch (e) {
      _error = '加载交易记录失败: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 加载更多交易记录
  Future<void> loadMoreTransactions({
    required int memberId,
    String? type,
    String? startDate,
    String? endDate,
  }) async {
    if (_isLoading || !hasMorePages) return;
    
    await loadMemberTransactions(
      memberId: memberId,
      page: _currentPage + 1,
      pageSize: _pageSize,
      type: type,
      startDate: startDate,
      endDate: endDate,
    );
  }
  
  // 获取单个交易详情
  Future<void> getTransaction(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _selectedTransaction = await _transactionService.getTransaction(id);
      _error = null;
    } catch (e) {
      _error = '获取交易详情失败: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 创建积分调整
  Future<bool> adjustPoints({
    required int memberId,
    required int points,
    String? note,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final transaction = await _transactionService.adjustPoints(
        memberId: memberId,
        points: points,
        note: note,
      );
      
      // 将新交易添加到列表开头
      _transactions.insert(0, transaction);
      _totalTransactions += 1;
      _error = null;
      return true;
    } catch (e) {
      _error = '积分调整失败: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 清除选中的交易
  void clearSelectedTransaction() {
    _selectedTransaction = null;
    notifyListeners();
  }
  
  // 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
