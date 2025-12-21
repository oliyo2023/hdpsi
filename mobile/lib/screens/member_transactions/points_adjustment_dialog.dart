import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/transaction_controller.dart';

class PointsAdjustmentDialog extends StatefulWidget {
  final int memberId;
  final Function({
    required TransactionController controller,
    required int memberId,
    required int points,
    required String note,
    required bool isPositive,
  })
  onAdjustPoints;

  const PointsAdjustmentDialog({
    super.key,
    required this.memberId,
    required this.onAdjustPoints,
  });

  @override
  State<PointsAdjustmentDialog> createState() => _PointsAdjustmentDialogState();
}

class _PointsAdjustmentDialogState extends State<PointsAdjustmentDialog> {
  final formKey = GlobalKey<FormState>();
  int points = 0;
  String note = '';
  bool isPositive = true;

  late final TransactionController _transactionController;

  @override
  void initState() {
    super.initState();
    _transactionController = Get.find<TransactionController>();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('积分调整'),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 积分调整方向
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(
                  value: true,
                  label: Text('增加'),
                  icon: Icon(Icons.add),
                ),
                ButtonSegment<bool>(
                  value: false,
                  label: Text('减少'),
                  icon: Icon(Icons.remove),
                ),
              ],
              selected: {isPositive},
              onSelectionChanged: (Set<bool> newSelection) {
                setState(() {
                  isPositive = newSelection.first;
                });
              },
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
        Obx(() {
          return ElevatedButton(
            onPressed:
                _transactionController.isLoading
                    ? null
                    : () {
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();

                        // 根据选择的方向调整积分值
                        final adjustedPoints = isPositive ? points : -points;

                        // 在异步操作前保存必要的变量
                        final bool currentIsPositive = isPositive;
                        final int currentMemberId = widget.memberId;

                        // 使用回调处理异步操作
                        widget.onAdjustPoints(
                          controller: _transactionController,
                          memberId: currentMemberId,
                          points: adjustedPoints,
                          note: note,
                          isPositive: currentIsPositive,
                        );

                        // 立即关闭对话框
                        Navigator.of(context).pop();
                      }
                    },
            child:
                _transactionController.isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Text('确认'),
          );
        }),
      ],
    );
  }
}
