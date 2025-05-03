import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../providers/member_provider.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_display.dart';
import '../widgets/empty_data.dart';

// 导入拆分后的组件
import 'member_transactions/transaction_item_card.dart';
import 'member_transactions/transaction_details.dart';
import 'member_transactions/filter_dialog.dart';
import 'member_transactions/points_adjustment_dialog.dart';
import 'member_transactions/filter_chips_bar.dart';
import 'member_transactions/transaction_utils.dart';

class MemberTransactionsScreen extends StatefulWidget {
  final int memberId;

  const MemberTransactionsScreen({super.key, required this.memberId});

  @override
  State<MemberTransactionsScreen> createState() =>
      _MemberTransactionsScreenState();
}

class _MemberTransactionsScreenState extends State<MemberTransactionsScreen> {
  final _scrollController = ScrollController();
  String? _selectedType;
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();

    // 加载会员交易记录
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionProvider>(
        context,
        listen: false,
      ).loadMemberTransactions(memberId: widget.memberId, refresh: true);
    });

    // 添加滚动监听器，用于加载更多
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // 滚动到底部时加载更多
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      final transactionProvider = Provider.of<TransactionProvider>(
        context,
        listen: false,
      );
      if (!transactionProvider.isLoading && transactionProvider.hasMorePages) {
        transactionProvider.loadMoreTransactions(
          memberId: widget.memberId,
          type: _selectedType,
          startDate: _dateRange?.start.toIso8601String(),
          endDate: _dateRange?.end.toIso8601String(),
        );
      }
    }
  }

  // 筛选交易记录
  void _filterTransactions() {
    Provider.of<TransactionProvider>(
      context,
      listen: false,
    ).loadMemberTransactions(
      memberId: widget.memberId,
      refresh: true,
      type: _selectedType,
      startDate: _dateRange?.start.toIso8601String(),
      endDate: _dateRange?.end.toIso8601String(),
    );
  }

  // 选择日期范围
  Future<void> _selectDateRange() async {
    final initialDateRange =
        _dateRange ??
        DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 30)),
          end: DateTime.now(),
        );

    final newDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: Theme.of(context).primaryColor),
          ),
          child: child!,
        );
      },
    );

    if (newDateRange != null) {
      setState(() {
        _dateRange = newDateRange;
      });
      _filterTransactions();
    }
  }

  // 清除筛选条件
  void _clearFilters() {
    setState(() {
      _selectedType = null;
      _dateRange = null;
    });
    _filterTransactions();
  }

  @override
  Widget build(BuildContext context) {
    final memberProvider = Provider.of<MemberProvider>(context);
    final member = memberProvider.selectedMember;

    return Scaffold(
      appBar: AppBar(
        title: Text('${member?.name ?? '会员'}的交易记录'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // 筛选条件显示
          FilterChipsBar(
            selectedType: _selectedType,
            dateRange: _dateRange,
            formatTransactionType: TransactionUtils.formatTransactionType,
            onClearFilters: _clearFilters,
            onClearType: _clearTypeFilter,
            onClearDateRange: _clearDateRangeFilter,
          ),

          // 交易记录列表
          Expanded(child: _buildTransactionList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showPointsAdjustmentDialog,
        tooltip: '调整积分',
        child: const Icon(Icons.add),
      ),
    );
  }

  // 清除类型筛选
  void _clearTypeFilter() {
    setState(() {
      _selectedType = null;
    });
    _filterTransactions();
  }

  // 清除日期范围筛选
  void _clearDateRangeFilter() {
    setState(() {
      _dateRange = null;
    });
    _filterTransactions();
  }

  // 构建交易记录列表
  Widget _buildTransactionList() {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, _) {
        if (transactionProvider.isLoading &&
            transactionProvider.transactions.isEmpty) {
          return const LoadingIndicator(message: '加载交易记录中...');
        }

        if (transactionProvider.error != null &&
            transactionProvider.transactions.isEmpty) {
          return ErrorDisplay(
            error: transactionProvider.error!,
            onRetry:
                () => transactionProvider.loadMemberTransactions(
                  memberId: widget.memberId,
                  refresh: true,
                ),
          );
        }

        if (transactionProvider.transactions.isEmpty) {
          return EmptyData(
            message: '暂无交易记录',
            icon: Icons.receipt_long,
            onAction: () {
              Navigator.of(context).pop();
            },
            actionLabel: '返回会员详情',
          );
        }

        return RefreshIndicator(
          onRefresh:
              () => transactionProvider.loadMemberTransactions(
                memberId: widget.memberId,
                refresh: true,
                type: _selectedType,
                startDate: _dateRange?.start.toIso8601String(),
                endDate: _dateRange?.end.toIso8601String(),
              ),
          child: ListView.builder(
            controller: _scrollController,
            itemCount:
                transactionProvider.transactions.length +
                (transactionProvider.hasMorePages ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == transactionProvider.transactions.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final transaction = transactionProvider.transactions[index];
              final typeColor = TransactionUtils.getTypeColor(transaction.type);
              final typeText = TransactionUtils.formatTransactionType(
                transaction.type,
              );
              final isPositive = TransactionUtils.isPositiveTransaction(
                transaction.type,
                transaction.pointsEarned,
              );

              return TransactionItemCard(
                transaction: transaction,
                onTap: _showTransactionDetails,
                typeColor: typeColor,
                typeText: typeText,
                isPositive: isPositive,
              );
            },
          ),
        );
      },
    );
  }

  // 显示筛选对话框
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return FilterDialog(
          selectedType: _selectedType,
          dateRange: _dateRange,
          onTypeSelected: (type) {
            setState(() {
              _selectedType = type;
            });
          },
          onDateRangeSelected: (range) {
            setState(() {
              _dateRange = range;
            });
          },
          onApplyFilter: _filterTransactions,
          onSelectDateRange: _selectDateRange,
        );
      },
    );
  }

  // 显示交易详情
  void _showTransactionDetails(Transaction transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return TransactionDetails(
          transaction: transaction,
          formatTransactionType: TransactionUtils.formatTransactionType,
        );
      },
    );
  }

  // 显示积分调整对话框
  void _showPointsAdjustmentDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return PointsAdjustmentDialog(
          memberId: widget.memberId,
          onAdjustPoints: _processPointsAdjustment,
        );
      },
    );
  }

  // 处理积分调整的异步操作
  Future<void> _processPointsAdjustment({
    required TransactionProvider provider,
    required int memberId,
    required int points,
    required String note,
    required bool isPositive,
    required MemberProvider memberProvider,
  }) async {
    final success = await provider.adjustPoints(
      memberId: memberId,
      points: points,
      note: note,
    );

    if (success && mounted) {
      // 显示成功消息
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('积分${isPositive ? '增加' : '减少'}成功')),
      );

      // 刷新会员信息以更新积分
      memberProvider.getMember(memberId);
    }
  }
}
