import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/supplier_provider.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_display.dart';
import 'supplier_detail_screen.dart';
import 'supplier_edit_screen.dart';

class SupplierListScreen extends StatefulWidget {
  const SupplierListScreen({super.key});

  @override
  State<SupplierListScreen> createState() => _SupplierListScreenState();
}

class _SupplierListScreenState extends State<SupplierListScreen> {
  @override
  void initState() {
    super.initState();
    // 使用 addPostFrameCallback 确保在构建完成后再加载数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SupplierProvider>(context, listen: false).fetchSuppliers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('供应商列表'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SupplierEditScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<SupplierProvider>(
        builder: (context, supplierProvider, child) {
          if (supplierProvider.isLoading) {
            return const LoadingIndicator();
          } else if (supplierProvider.errorMessage != null) {
            return ErrorDisplay(error: supplierProvider.errorMessage!);
          } else if (supplierProvider.suppliers.isEmpty) {
            return const Center(child: Text('没有供应商数据'));
          } else {
            return ListView.builder(
              itemCount: supplierProvider.suppliers.length,
              itemBuilder: (context, index) {
                final supplier = supplierProvider.suppliers[index];
                return ListTile(
                  title: Text(supplier.name),
                  subtitle: Text(supplier.contactPerson ?? ''),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                SupplierDetailScreen(supplierId: supplier.id),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
