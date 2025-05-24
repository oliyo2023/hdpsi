import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/supplier_controller.dart';
import '../models/supplier.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_display.dart';
import 'supplier_edit_screen.dart';

class SupplierDetailScreen extends StatefulWidget {
  final int supplierId;

  const SupplierDetailScreen({super.key, required this.supplierId});

  @override
  State<SupplierDetailScreen> createState() => _SupplierDetailScreenState();
}

class _SupplierDetailScreenState extends State<SupplierDetailScreen> {
  late final SupplierController _supplierController;

  @override
  void initState() {
    super.initState();
    // 获取SupplierController实例
    _supplierController = Get.find<SupplierController>(
      tag: 'supplier_controller',
    );
    // 使用addPostFrameCallback确保在构建完成后再加载数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchSupplierDetails();
    });
  }

  // 获取供应商详情
  Future<void> _fetchSupplierDetails() async {
    await _supplierController.getSupplier(widget.supplierId);
  }

  // 删除供应商
  Future<void> _deleteSupplier() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个供应商吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _supplierController.deleteSupplier(
        widget.supplierId,
      );
      if (success) {
        Get.back(); // 返回上一页
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('供应商详情'),
        actions: [
          Obx(
            () => IconButton(
              icon: const Icon(Icons.edit),
              onPressed:
                  _supplierController.currentSupplier == null
                      ? null
                      : () async {
                        final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (context) => SupplierEditScreen(
                                  supplier: _supplierController.currentSupplier,
                                ),
                          ),
                        );
                        if (result == true && mounted) {
                          _fetchSupplierDetails(); // 刷新数据
                        }
                      },
            ),
          ),
          Obx(
            () => IconButton(
              icon: const Icon(Icons.delete),
              onPressed:
                  _supplierController.currentSupplier == null
                      ? null
                      : _deleteSupplier,
            ),
          ),
        ],
      ),
      body: Obx(() => _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_supplierController.isLoading) {
      return const LoadingIndicator(message: '加载供应商详情...');
    }

    if (_supplierController.hasError) {
      return ErrorDisplay(
        error: _supplierController.error,
        onRetry: _fetchSupplierDetails,
      );
    }

    final supplier = _supplierController.currentSupplier;
    if (supplier == null) {
      return const Center(child: Text('未找到供应商信息'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(supplier),
          const SizedBox(height: 16),
          _buildContactCard(supplier),
          const SizedBox(height: 16),
          _buildBusinessCard(supplier),
        ],
      ),
    );
  }

  Widget _buildInfoCard(Supplier supplier) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '基本信息',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildInfoRow('供应商名称', supplier.name),
            _buildInfoRow('供应商编码', supplier.code),
            _buildInfoRow('供应商类型', _getSupplierTypeText(supplier.type)),
            _buildInfoRow('状态', supplier.status ? '启用' : '禁用'),
            _buildInfoRow(
              '评级',
              supplier.rating?.toString().split('.').last ?? '无',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(Supplier supplier) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '联系信息',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildInfoRow('联系人', supplier.contactPerson ?? '无'),
            _buildInfoRow('联系电话', supplier.contactPhone ?? '无'),
            _buildInfoRow('电子邮箱', supplier.email ?? '无'),
            _buildInfoRow('地址', supplier.address ?? '无'),
            _buildInfoRow('城市', supplier.city ?? '无'),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessCard(Supplier supplier) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '业务信息',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildInfoRow('资质', supplier.qualification ?? '无'),
            _buildInfoRow('付款条款', supplier.paymentTerms ?? '无'),
            _buildInfoRow('交货条款', supplier.deliveryTerms ?? '无'),
            _buildInfoRow('备注', supplier.note ?? '无'),
            _buildInfoRow('创建时间', _formatDateTime(supplier.createdAt)),
            _buildInfoRow('更新时间', _formatDateTime(supplier.updatedAt)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
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
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _getSupplierTypeText(SupplierType type) {
    switch (type) {
      case SupplierType.manufacturer:
        return '生产厂商';
      case SupplierType.distributor:
        return '批发商';
      case SupplierType.wholesaler:
        return '批发商';
      case SupplierType.retailer:
        return '零售商';
      case SupplierType.other:
        return '其他';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
