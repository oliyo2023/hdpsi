import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/scanner_util.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_display.dart';
import '../utils/formatters.dart';

class ScanCheckoutScreen extends StatefulWidget {
  const ScanCheckoutScreen({super.key});

  @override
  State<ScanCheckoutScreen> createState() => _ScanCheckoutScreenState();
}

class _ScanCheckoutScreenState extends State<ScanCheckoutScreen> {
  final _quantityController = TextEditingController(text: '1');
  final _noteController = TextEditingController();
  int? _selectedStoreId;

  @override
  void initState() {
    super.initState();

    // 获取用户所属店铺
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user =
          Provider.of<AuthProvider>(context, listen: false).currentUser;
      if (user != null && user.storeId != null) {
        setState(() {
          _selectedStoreId = user.storeId;
        });
      }
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // 扫描条形码或二维码
  Future<void> _scanBarcode() async {
    final barcode = await ScannerUtil.scanBarcode();
    if (barcode != null) {
      // 查找商品
      if (mounted) {
        await Provider.of<InventoryProvider>(
          context,
          listen: false,
        ).findProductByBarcode(barcode);
      }
    }
  }

  // 提交出库
  Future<void> _submitCheckout() async {
    if (_selectedStoreId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请选择店铺')));
      return;
    }

    final quantity = int.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入有效的数量')));
      return;
    }

    final inventoryProvider = Provider.of<InventoryProvider>(
      context,
      listen: false,
    );
    final scannedProduct = inventoryProvider.scannedProduct;
    if (scannedProduct == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请先扫描商品')));
      return;
    }

    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('用户信息获取失败')));
      return;
    }

    // 创建出库交易
    final success = await inventoryProvider.createTransaction({
      'TransactionType': 'sale_out',
      'ProductVariantID': scannedProduct['ProductVariantID'],
      'StoreID': _selectedStoreId,
      'Quantity': -quantity, // 负数表示出库
      'OperatorID': user.id,
      'Note': _noteController.text,
    });

    if (success && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('出库成功')));

      // 清除扫描的商品
      inventoryProvider.clearScannedProduct();

      // 清空表单
      _quantityController.text = '1';
      _noteController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('扫码出库')),
      body: Consumer<InventoryProvider>(
        builder: (context, inventoryProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 扫描按钮
                ElevatedButton.icon(
                  onPressed: inventoryProvider.isLoading ? null : _scanBarcode,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('扫描商品条码'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                ),
                const SizedBox(height: 24.0),

                // 加载中
                if (inventoryProvider.isLoading)
                  const LoadingIndicator(message: '查找商品中...'),

                // 错误信息
                if (inventoryProvider.error != null)
                  ErrorDisplay(
                    error: inventoryProvider.error!,
                    onRetry: _scanBarcode,
                  ),

                // 扫描结果
                if (inventoryProvider.scannedProduct != null)
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 商品信息卡片
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '商品信息',
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Divider(),
                                  const SizedBox(height: 8.0),

                                  // 商品名称
                                  Text(
                                    '名称: ${inventoryProvider.scannedProduct!['ProductName']}',
                                    style: const TextStyle(fontSize: 16.0),
                                  ),
                                  const SizedBox(height: 8.0),

                                  // SKU
                                  Text(
                                    'SKU: ${inventoryProvider.scannedProduct!['SKU']}',
                                    style: const TextStyle(fontSize: 16.0),
                                  ),
                                  const SizedBox(height: 8.0),

                                  // 价格
                                  Text(
                                    '价格: ${Formatters.formatPrice(inventoryProvider.scannedProduct!['RetailPrice'])}',
                                    style: const TextStyle(fontSize: 16.0),
                                  ),
                                  const SizedBox(height: 8.0),

                                  // 库存
                                  Text(
                                    '当前库存: ${inventoryProvider.scannedProduct!['Quantity']}',
                                    style: const TextStyle(fontSize: 16.0),
                                  ),
                                  const SizedBox(height: 8.0),

                                  // 颜色和尺码
                                  if (inventoryProvider
                                          .scannedProduct!['Color'] !=
                                      null)
                                    Text(
                                      '颜色: ${inventoryProvider.scannedProduct!['Color']['Name']}',
                                      style: const TextStyle(fontSize: 16.0),
                                    ),
                                  if (inventoryProvider
                                          .scannedProduct!['Size'] !=
                                      null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        '尺码: ${inventoryProvider.scannedProduct!['Size']['Name']}',
                                        style: const TextStyle(fontSize: 16.0),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16.0),

                          // 出库表单
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '出库信息',
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Divider(),
                                  const SizedBox(height: 16.0),

                                  // 店铺选择
                                  DropdownButtonFormField<int>(
                                    decoration: const InputDecoration(
                                      labelText: '出库店铺',
                                      border: OutlineInputBorder(),
                                    ),
                                    value: _selectedStoreId,
                                    items: const [
                                      DropdownMenuItem(
                                        value: 1,
                                        child: Text('总店'),
                                      ),
                                      DropdownMenuItem(
                                        value: 2,
                                        child: Text('分店1'),
                                      ),
                                      DropdownMenuItem(
                                        value: 3,
                                        child: Text('分店2'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedStoreId = value;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 16.0),

                                  // 出库数量
                                  TextFormField(
                                    controller: _quantityController,
                                    decoration: const InputDecoration(
                                      labelText: '出库数量',
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                  const SizedBox(height: 16.0),

                                  // 备注
                                  TextFormField(
                                    controller: _noteController,
                                    decoration: const InputDecoration(
                                      labelText: '备注',
                                      border: OutlineInputBorder(),
                                    ),
                                    maxLines: 3,
                                  ),
                                  const SizedBox(height: 24.0),

                                  // 提交按钮
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed:
                                          inventoryProvider.isLoading
                                              ? null
                                              : _submitCheckout,
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 16.0,
                                        ),
                                        child: Text(
                                          '确认出库',
                                          style: TextStyle(fontSize: 16.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
