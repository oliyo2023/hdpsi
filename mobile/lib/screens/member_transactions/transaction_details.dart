import 'package:flutter/material.dart';
import '../../models/transaction.dart';
import '../../utils/formatters.dart';

class TransactionDetails extends StatelessWidget {
  final Transaction transaction;
  final String Function(String) formatTransactionType;

  const TransactionDetails({
    super.key,
    required this.transaction,
    required this.formatTransactionType,
  });

  @override
  Widget build(BuildContext context) {
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
                context,
                '交易类型',
                formatTransactionType(transaction.type),
              ),
              _buildDetailItem(
                context,
                '交易时间',
                Formatters.formatDateTime(transaction.createdAt),
              ),
              if (transaction.staffName != null)
                _buildDetailItem(context, '操作员', transaction.staffName!),

              // 金额和积分
              if (transaction.amount > 0)
                _buildDetailItem(
                  context,
                  '交易金额',
                  '¥${transaction.amount.toStringAsFixed(2)}',
                ),
              if (transaction.pointsEarned > 0)
                _buildDetailItem(
                  context,
                  '获得积分',
                  transaction.pointsEarned.toString(),
                ),
              if (transaction.pointsUsed > 0)
                _buildDetailItem(
                  context,
                  '使用积分',
                  transaction.pointsUsed.toString(),
                ),

              // 备注
              if (transaction.note != null && transaction.note!.isNotEmpty)
                _buildDetailItem(context, '备注', transaction.note!),

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
                ...transaction.items!.map((item) => _buildItemDetail(context, item)),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(BuildContext context, String label, String value) {
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

  Widget _buildItemDetail(BuildContext context, TransactionItem item) {
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
                    style: const TextStyle(fontSize: 12.0, color: Colors.red),
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
}
