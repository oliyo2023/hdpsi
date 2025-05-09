import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/supplier_provider.dart';
import '../models/supplier.dart';
import '../services/supplier_service.dart';
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
  final SupplierService _supplierService = SupplierService();
  Supplier? _supplier;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchSupplierDetails();
  }

  // 获取供应商详情
  Future<void> _fetchSupplierDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final supplier = await _supplierService.getSupplier(widget.supplierId);
      setState(() {
        _supplier = supplier;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = '获取供应商详情失败: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // 删除供应商
  Future<void> _deleteSupplier() async {
    // 获取供应商提供者，避免在异步间隙使用BuildContext
    final supplierProvider = Provider.of<SupplierProvider>(
      context,
      listen: false,
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('确认删除'),
            content: const Text('确定要删除这个供应商吗？此操作不可撤销。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('删除'),
              ),
            ],
          ),
    );

    if (confirmed == true && mounted) {
      try {
        await supplierProvider.deleteSupplier(widget.supplierId);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('供应商已删除')));
          Navigator.of(context).pop(); // 返回上一页
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('删除失败: ${e.toString()}')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('供应商详情'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed:
                _supplier == null
                    ? null
                    : () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  SupplierEditScreen(supplier: _supplier),
                        ),
                      );
                      if (result == true && mounted) {
                        _fetchSupplierDetails(); // 刷新数据
                      }
                    },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _supplier == null ? null : _deleteSupplier,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingIndicator(message: '加载供应商详情...');
    }

    if (_error != null) {
      return ErrorDisplay(error: _error!, onRetry: _fetchSupplierDetails);
    }

    if (_supplier == null) {
      return const Center(child: Text('未找到供应商信息'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(),
          const SizedBox(height: 16),
          _buildContactCard(),
          const SizedBox(height: 16),
          _buildBusinessCard(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
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
            _buildInfoRow('供应商名称', _supplier!.name),
            _buildInfoRow('供应商编码', _supplier!.code),
            _buildInfoRow('供应商类型', _getSupplierTypeText(_supplier!.type)),
            _buildInfoRow('状态', _supplier!.status ? '启用' : '禁用'),
            _buildInfoRow(
              '评级',
              _supplier!.rating?.toString().split('.').last ?? '无',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard() {
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
            _buildInfoRow('联系人', _supplier!.contactPerson ?? '无'),
            _buildInfoRow('联系电话', _supplier!.contactPhone ?? '无'),
            _buildInfoRow('电子邮箱', _supplier!.email ?? '无'),
            _buildInfoRow('地址', _supplier!.address ?? '无'),
            _buildInfoRow('城市', _supplier!.city ?? '无'),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessCard() {
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
            _buildInfoRow('资质', _supplier!.qualification ?? '无'),
            _buildInfoRow('付款条款', _supplier!.paymentTerms ?? '无'),
            _buildInfoRow('交货条款', _supplier!.deliveryTerms ?? '无'),
            _buildInfoRow('备注', _supplier!.note ?? '无'),
            _buildInfoRow('创建时间', _formatDateTime(_supplier!.createdAt)),
            _buildInfoRow('更新时间', _formatDateTime(_supplier!.updatedAt)),
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
