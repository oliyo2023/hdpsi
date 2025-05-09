import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/inventory.dart';
import '../providers/inventory_provider.dart';
import '../providers/auth_provider.dart';
import '../services/inventory_service.dart';
import '../widgets/loading_indicator.dart';

class InventoryAdjustmentScreen extends StatefulWidget {
  final Inventory inventory;

  const InventoryAdjustmentScreen({super.key, required this.inventory});

  @override
  State<InventoryAdjustmentScreen> createState() =>
      _InventoryAdjustmentScreenState();
}

class _InventoryAdjustmentScreenState extends State<InventoryAdjustmentScreen> {
  final InventoryService _inventoryService = InventoryService();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // 初始化数量为当前库存数量
    _quantityController.text = widget.inventory.quantity.toString();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  // 提交库存调整
  Future<void> _submitAdjustment() async {
    // 验证输入
    if (_reasonController.text.trim().isEmpty) {
      setState(() {
        _error = '请输入调整原因';
      });
      return;
    }

    int? newQuantity;
    try {
      newQuantity = int.parse(_quantityController.text);
      if (newQuantity < 0) throw Exception('数量不能为负数');
    } catch (e) {
      setState(() {
        _error = '请输入有效的数量';
      });
      return;
    }

    // 如果数量没有变化，提示用户
    if (newQuantity == widget.inventory.quantity) {
      setState(() {
        _error = '数量未发生变化，无需调整';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 获取当前用户
      final user =
          Provider.of<AuthProvider>(context, listen: false).currentUser;
      if (user == null) throw Exception('用户信息获取失败');

      // 更新库存
      await _inventoryService.updateInventory(widget.inventory.id, {
        'quantity': newQuantity,
        'reason': _reasonController.text,
      });

      // 创建库存调整记录
      final inventoryProvider = Provider.of<InventoryProvider>(
        context,
        listen: false,
      );

      // 保存BuildContext的引用
      final scaffoldMessenger = ScaffoldMessenger.of(context);

      await inventoryProvider.createTransaction({
        'TransactionType': 'adjustment',
        'ProductVariantID': widget.inventory.productVariantId,
        'StoreID': widget.inventory.storeId,
        'Quantity': newQuantity - widget.inventory.quantity, // 调整的差值
        'OperatorID': user.id,
        'Note': '库存调整: ${_reasonController.text}',
      });

      if (mounted) {
        scaffoldMessenger.showSnackBar(const SnackBar(content: Text('库存调整成功')));
        Navigator.of(context).pop(true); // 返回并传递成功标志
      }
    } catch (e) {
      setState(() {
        _error = '库存调整失败: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('库存调整')),
      body:
          _isLoading
              ? const LoadingIndicator(message: '正在提交...')
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProductInfo(),
                    const SizedBox(height: 24.0),
                    _buildAdjustmentForm(),
                    if (_error != null) ...[
                      const SizedBox(height: 16.0),
                      Text(
                        _error!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24.0),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitAdjustment,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                        ),
                        child: const Text('提交调整'),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildProductInfo() {
    final productVariant = widget.inventory.productVariant;
    final productName =
        productVariant?['Product']?['Name'] as String? ?? '未知商品';
    final sku = productVariant?['SKU'] as String? ?? '无SKU';
    final storeName = widget.inventory.store?['Name'] as String? ?? '未知店铺';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              productName,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text('SKU: $sku'),
            Text('店铺: $storeName'),
            const Divider(),
            Text(
              '当前库存: ${widget.inventory.quantity}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdjustmentForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '调整信息',
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16.0),
        TextField(
          controller: _quantityController,
          decoration: const InputDecoration(
            labelText: '新库存数量',
            border: OutlineInputBorder(),
            helperText: '输入调整后的库存数量',
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 16.0),
        TextField(
          controller: _reasonController,
          decoration: const InputDecoration(
            labelText: '调整原因',
            border: OutlineInputBorder(),
            helperText: '请详细说明库存调整的原因',
          ),
          maxLines: 3,
        ),
      ],
    );
  }
}
