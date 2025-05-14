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
              padding: const EdgeInsets.all(8.0), // Add padding around the list
              itemCount: supplierProvider.suppliers.length,
              itemBuilder: (context, index) {
                final supplier = supplierProvider.suppliers[index];
                return Card(
                  elevation: 2.0, // Add a slight shadow
                  margin: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 4.0,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColorLight,
                      child: Text(
                        supplier.name.isNotEmpty
                            ? supplier.name[0].toUpperCase()
                            : 'S',
                        style: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                        ),
                      ),
                    ),
                    title: Text(
                      supplier.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (supplier.contactPerson != null &&
                            supplier.contactPerson!.isNotEmpty)
                          Text('联系人: ${supplier.contactPerson}'),
                        if (supplier
                            .code
                            .isNotEmpty) // Assuming supplier model has a 'code' field
                          Text('编码: ${supplier.code}'),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16.0),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  SupplierDetailScreen(supplierId: supplier.id),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
