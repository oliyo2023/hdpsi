import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/inventory_controller.dart';
import '../controllers/auth_controller.dart';
import '../utils/scanner_util.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_display.dart';
import '../utils/formatters.dart';

class ScanCheckinScreen extends StatefulWidget {
  const ScanCheckinScreen({super.key});

  @override
  State<ScanCheckinScreen> createState() => _ScanCheckinScreenState();
}

class _ScanCheckinScreenState extends State<ScanCheckinScreen> {
  final TextEditingController _quantityController = TextEditingController(
    text: '1',
  );
  final TextEditingController _noteController = TextEditingController();
  final int _selectedStoreId = 1; // 默认店铺ID，实际应该从配置或用户选择获取

  late final InventoryController _inventoryController;
  late final AuthController _authController;

  @override
  void initState() {
    super.initState();
    // 获取控制器实例
    _inventoryController = Get.find<InventoryController>();
    _authController = Get.find<AuthController>();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // 扫描条形码或二维码
  Future<void> _scanBarcode() async {
    final barcode = await ScannerUtil.scanBarcode(context);
    if (barcode != null) {
      // 查找商品
      if (mounted) {
        await _inventoryController.findProductByBarcode(barcode);
      }
    }
  }

  // 提交入库
  Future<void> _submitCheckin() async {
    final scannedProduct = _inventoryController.scannedProduct;
    if (scannedProduct == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请先扫描商品')));
      return;
    }

    // 获取数量
    int quantity;
    try {
      quantity = int.parse(_quantityController.text);
      if (quantity <= 0) throw Exception('数量必须大于0');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入有效的数量')));
      return;
    }

    final user = _authController.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('用户信息获取失败')));
      return;
    }

    // 创建入库交易
    final success = await _inventoryController.createInventoryAdjustment({
      'TransactionType': 'purchase_in',
      'ProductVariantID': scannedProduct['ProductVariantID'],
      'StoreID': _selectedStoreId,
      'Quantity': quantity, // 正数表示入库
      'OperatorID': user.id,
      'Note': _noteController.text,
    });

    if (success && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('入库成功')));

      // 清除扫描的商品
      _inventoryController.clearScannedProduct();

      // 清空表单
      _quantityController.text = '1';
      _noteController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('扫码入库')),
      body: Obx(() {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 扫描按钮
              ElevatedButton.icon(
                onPressed: _inventoryController.isLoading ? null : _scanBarcode,
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('扫描商品条码'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
              ),
              const SizedBox(height: 24.0),

              // 加载中
              if (_inventoryController.isLoading)
                const LoadingIndicator(message: '查找商品中...'),

              // 错误信息
              if (_inventoryController.hasError)
                ErrorDisplay(
                  error: _inventoryController.error,
                  onRetry: () {
                    _inventoryController.clearError();
                  },
                ),

              // 扫描结果
              if (_inventoryController.scannedProduct != null) ...[
                _buildScannedProductCard(_inventoryController.scannedProduct!),
                const SizedBox(height: 16.0),
                _buildCheckinForm(),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: _submitCheckin,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('确认入库'),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildScannedProductCard(Map<String, dynamic> product) {
    final productName = product['Product']?['Name'] as String? ?? '未知商品';
    final sku = product['SKU'] as String? ?? '无SKU';
    final barcode = product['Barcode'] as String? ?? '无条码';

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
            Text('条码: $barcode'),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckinForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '入库信息',
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16.0),
        TextField(
          controller: _quantityController,
          decoration: const InputDecoration(
            labelText: '入库数量',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [NumericInputFormatter()],
        ),
        const SizedBox(height: 16.0),
        TextField(
          controller: _noteController,
          decoration: const InputDecoration(
            labelText: '备注',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
      ],
    );
  }
}
