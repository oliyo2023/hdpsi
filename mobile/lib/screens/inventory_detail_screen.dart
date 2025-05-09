import 'package:flutter/material.dart';
import '../models/inventory.dart';
import '../services/inventory_service.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_display.dart';
import 'scan_checkin_screen.dart';
import 'scan_checkout_screen.dart';
import 'inventory_adjustment_screen.dart';

class InventoryDetailScreen extends StatefulWidget {
  final int inventoryId;

  const InventoryDetailScreen({super.key, required this.inventoryId});

  @override
  State<InventoryDetailScreen> createState() => _InventoryDetailScreenState();
}

class _InventoryDetailScreenState extends State<InventoryDetailScreen> {
  final InventoryService _inventoryService = InventoryService();
  Inventory? _inventory;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchInventoryDetails();
  }

  // 获取库存详情
  Future<void> _fetchInventoryDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final inventory = await _inventoryService.getInventory(
        widget.inventoryId,
      );
      setState(() {
        _inventory = inventory;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = '获取库存详情失败: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('库存详情'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchInventoryDetails,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingIndicator(message: '加载库存详情...');
    }

    if (_error != null) {
      return ErrorDisplay(error: _error!, onRetry: _fetchInventoryDetails);
    }

    if (_inventory == null) {
      return const Center(child: Text('未找到库存信息'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInventoryCard(),
          const SizedBox(height: 16),
          _buildProductCard(),
          const SizedBox(height: 16),
          _buildStoreCard(),
          const SizedBox(height: 16),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildInventoryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '库存信息',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildInfoRow('当前库存', '${_inventory!.quantity} 件'),
            _buildInfoRow('预警库存', '${_inventory!.alertQuantity} 件'),
            _buildInfoRow(
              '库存状态',
              _getInventoryStatus(
                _inventory!.quantity,
                _inventory!.alertQuantity,
              ),
              _getInventoryStatusColor(
                _inventory!.quantity,
                _inventory!.alertQuantity,
              ),
            ),
            _buildInfoRow('最后盘点时间', _inventory!.lastCheckTime ?? '未盘点'),
            _buildInfoRow('创建时间', _formatDateTime(_inventory!.createdAt)),
            _buildInfoRow('更新时间', _formatDateTime(_inventory!.updatedAt)),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard() {
    final productVariant = _inventory!.productVariant;
    if (productVariant == null) {
      return const Card(
        child: Padding(padding: EdgeInsets.all(16.0), child: Text('无商品信息')),
      );
    }

    final product = productVariant['Product'] as Map<String, dynamic>?;
    final productName = product?['Name'] as String? ?? '未知商品';
    final sku = productVariant['SKU'] as String? ?? '无SKU';
    final barcode = productVariant['Barcode'] as String? ?? '无条码';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '商品信息',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildInfoRow('商品名称', productName),
            _buildInfoRow('SKU', sku),
            _buildInfoRow('条形码', barcode),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreCard() {
    final store = _inventory!.store;
    if (store == null) {
      return const Card(
        child: Padding(padding: EdgeInsets.all(16.0), child: Text('无店铺信息')),
      );
    }

    final storeName = store['Name'] as String? ?? '未知店铺';
    final storeCode = store['Code'] as String? ?? '无编码';
    final storeAddress = store['Address'] as String? ?? '无地址';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '店铺信息',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildInfoRow('店铺名称', storeName),
            _buildInfoRow('店铺编码', storeCode),
            _buildInfoRow('店铺地址', storeAddress),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ScanCheckinScreen(),
              ),
            );
          },
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('入库'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ScanCheckoutScreen(),
              ),
            );
          },
          icon: const Icon(Icons.remove_circle_outline),
          label: const Text('出库'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        ),
        ElevatedButton.icon(
          onPressed:
              _inventory == null
                  ? null
                  : () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (context) => InventoryAdjustmentScreen(
                              inventory: _inventory!,
                            ),
                      ),
                    );
                    if (result == true && mounted) {
                      _fetchInventoryDetails(); // 刷新数据
                    }
                  },
          icon: const Icon(Icons.edit),
          label: const Text('调整'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontWeight: valueColor != null ? FontWeight.bold : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getInventoryStatus(int quantity, int alertQuantity) {
    if (quantity <= 0) {
      return '缺货';
    } else if (quantity <= alertQuantity) {
      return '库存不足';
    } else {
      return '库存充足';
    }
  }

  Color _getInventoryStatusColor(int quantity, int alertQuantity) {
    if (quantity <= 0) {
      return Colors.red;
    } else if (quantity <= alertQuantity) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  String _formatDateTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeStr;
    }
  }
}
