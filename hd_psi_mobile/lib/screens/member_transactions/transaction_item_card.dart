import 'package:flutter/material.dart';
import '../../models/transaction.dart';
import '../../utils/formatters.dart';

class TransactionItemCard extends StatelessWidget {
  final Transaction transaction;
  final Function(Transaction) onTap;
  final Color typeColor;
  final String typeText;
  final bool isPositive;

  const TransactionItemCard({
    super.key,
    required this.transaction,
    required this.onTap,
    required this.typeColor,
    required this.typeText,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: () => onTap(transaction),
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
}
