import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../providers/member_provider.dart';
import '../utils/formatters.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_display.dart';
import '../widgets/empty_data.dart';

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
          if (_selectedType != null || _dateRange != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              color: Theme.of(context).colorScheme.surface,
              child: Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8.0,
                      children: [
                        if (_selectedType != null)
                          Chip(
                            label: Text(_formatTransactionType(_selectedType!)),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            onDeleted: () {
                              setState(() {
                                _selectedType = null;
                              });
                              _filterTransactions();
                            },
                          ),
                        if (_dateRange != null)
                          Chip(
                            label: Text(
                              '${DateFormat('yyyy-MM-dd').format(_dateRange!.start)} 至 ${DateFormat('yyyy-MM-dd').format(_dateRange!.end)}',
                            ),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            onDeleted: () {
                              setState(() {
                                _dateRange = null;
                              });
                              _filterTransactions();
                            },
                          ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _clearFilters,
                    child: const Text('清除全部'),
                  ),
                ],
              ),
            ),

          // 交易记录列表
          Expanded(
            child: Consumer<TransactionProvider>(
              builder: (context, transactionProvider, child) {
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

                      final transaction =
                          transactionProvider.transactions[index];
                      return _buildTransactionItem(context, transaction);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showPointsAdjustmentDialog();
        },
        tooltip: '调整积分',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, Transaction transaction) {
    final Color typeColor = _getTypeColor(transaction.type);
    final String typeText = _formatTransactionType(transaction.type);
    final bool isPositive =
        transaction.type == 'purchase' ||
        (transaction.type == 'points_adjustment' &&
            transaction.pointsEarned > 0);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: () {
          _showTransactionDetails(transaction);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 交易类型标签
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: typeColor.withAlpha(51),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Text(
                      typeText,
                      style: TextStyle(
                        fontSize: 12.0,
                        color: typeColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // 交易时间
                  Text(
                    Formatters.formatDateTime(transaction.createdAt),
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),

              // 交易金额和积分
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (transaction.amount > 0)
                        Text(
                          '金额: ¥${transaction.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (transaction.pointsEarned > 0 ||
                          transaction.pointsUsed > 0)
                        Text(
                          transaction.type == 'points_adjustment'
                              ? '积分: ${isPositive ? '+' : '-'}${transaction.pointsEarned > 0 ? transaction.pointsEarned : transaction.pointsUsed}'
                              : '积分: +${transaction.pointsEarned} / -${transaction.pointsUsed}',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: isPositive ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),

                  // 右侧箭头
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),

              // 备注
              if (transaction.note != null && transaction.note!.isNotEmpty) ...[
                const SizedBox(height: 8.0),
                Text(
                  '备注: ${transaction.note}',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('筛选交易记录'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 交易类型筛选
                  const Text('交易类型'),
                  const SizedBox(height: 8.0),
                  Wrap(
                    spacing: 8.0,
                    children: [
                      _buildFilterChip(
                        label: '全部',
                        selected: _selectedType == null,
                        onSelected: (selected) {
                          setState(() {
                            _selectedType = null;
                          });
                        },
                      ),
                      _buildFilterChip(
                        label: '购买',
                        selected: _selectedType == 'purchase',
                        onSelected: (selected) {
                          setState(() {
                            _selectedType = selected ? 'purchase' : null;
                          });
                        },
                      ),
                      _buildFilterChip(
                        label: '退款',
                        selected: _selectedType == 'refund',
                        onSelected: (selected) {
                          setState(() {
                            _selectedType = selected ? 'refund' : null;
                          });
                        },
                      ),
                      _buildFilterChip(
                        label: '积分调整',
                        selected: _selectedType == 'points_adjustment',
                        onSelected: (selected) {
                          setState(() {
                            _selectedType =
                                selected ? 'points_adjustment' : null;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),

                  // 日期范围筛选
                  const Text('日期范围'),
                  const SizedBox(height: 8.0),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      _dateRange != null
                          ? '${DateFormat('yyyy-MM-dd').format(_dateRange!.start)} 至 ${DateFormat('yyyy-MM-dd').format(_dateRange!.end)}'
                          : '选择日期范围',
                    ),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await _selectDateRange();
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('取消'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _filterTransactions();
                  },
                  child: const Text('应用'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required Function(bool) onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: Theme.of(context).primaryColor.withAlpha(51),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }

  void _showTransactionDetails(Transaction transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                  ),
                  Text('交易详情', style: Theme.of(context).textTheme.titleLarge),
                  const Divider(),

                  // 基本信息
                  _buildDetailItem(
                    '交易类型',
                    _formatTransactionType(transaction.type),
                  ),
                  _buildDetailItem(
                    '交易时间',
                    Formatters.formatDateTime(transaction.createdAt),
                  ),
                  if (transaction.staffName != null)
                    _buildDetailItem('操作员', transaction.staffName!),

                  // 金额和积分
                  if (transaction.amount > 0)
                    _buildDetailItem(
                      '交易金额',
                      '¥${transaction.amount.toStringAsFixed(2)}',
                    ),
                  if (transaction.pointsEarned > 0)
                    _buildDetailItem(
                      '获得积分',
                      transaction.pointsEarned.toString(),
                    ),
                  if (transaction.pointsUsed > 0)
                    _buildDetailItem('使用积分', transaction.pointsUsed.toString()),

                  // 备注
                  if (transaction.note != null && transaction.note!.isNotEmpty)
                    _buildDetailItem('备注', transaction.note!),

                  // 商品列表
                  if (transaction.items != null &&
                      transaction.items!.isNotEmpty) ...[
                    const SizedBox(height: 16.0),
                    const Text(
                      '商品明细',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    ...transaction.items!.map((item) => _buildItemDetail(item)),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.0,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemDetail(TransactionItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.productName,
                    style: const TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '¥${item.subtotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${item.quantity} x ¥${item.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                if (item.discount > 0)
                  Text(
                    '优惠: ¥${item.discount.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 12.0, color: Colors.red),
                  ),
              ],
            ),
            if (item.productSku != null && item.productSku!.isNotEmpty)
              Text(
                'SKU: ${item.productSku}',
                style: TextStyle(
                  fontSize: 12.0,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showPointsAdjustmentDialog() {
    final formKey = GlobalKey<FormState>();
    int points = 0;
    String note = '';
    bool isPositive = true;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('积分调整'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 积分调整方向
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('增加'),
                        value: true,
                        groupValue: isPositive,
                        onChanged: (value) {
                          setState(() {
                            isPositive = value!;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('减少'),
                        value: false,
                        groupValue: isPositive,
                        onChanged: (value) {
                          setState(() {
                            isPositive = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                // 积分数量
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: '积分数量',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入积分数量';
                    }
                    if (int.tryParse(value) == null || int.parse(value) <= 0) {
                      return '请输入有效的积分数量';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    points = int.parse(value!);
                  },
                ),
                const SizedBox(height: 16.0),

                // 备注
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: '备注',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  onSaved: (value) {
                    note = value ?? '';
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('取消'),
            ),
            Consumer<TransactionProvider>(
              builder: (context, provider, child) {
                return ElevatedButton(
                  onPressed:
                      provider.isLoading
                          ? null
                          : () async {
                            if (formKey.currentState!.validate()) {
                              formKey.currentState!.save();

                              // 根据选择的方向调整积分值
                              final adjustedPoints =
                                  isPositive ? points : -points;

                              final success = await provider.adjustPoints(
                                memberId: widget.memberId,
                                points: adjustedPoints,
                                note: note,
                              );

                              if (success) {
                                // 保存当前状态
                                final isPositiveValue = isPositive;

                                // 关闭对话框
                                if (mounted) {
                                  Navigator.of(context).pop();
                                }

                                // 显示成功消息
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '积分${isPositiveValue ? '增加' : '减少'}成功',
                                      ),
                                    ),
                                  );
                                }

                                // 刷新会员信息以更新积分
                                if (mounted) {
                                  Provider.of<MemberProvider>(
                                    context,
                                    listen: false,
                                  ).getMember(widget.memberId);
                                }
                              }
                            }
                          },
                  child:
                      provider.isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('确认'),
                );
              },
            ),
          ],
        );
      },
    );
  }

  String _formatTransactionType(String type) {
    return Formatters.formatMemberTransactionType(type);
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'purchase':
        return Colors.green;
      case 'refund':
        return Colors.orange;
      case 'points_adjustment':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
