import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/supplier_provider.dart';

class SupplierDetailScreen extends StatefulWidget {
  final int supplierId;

  const SupplierDetailScreen({super.key, required this.supplierId});

  @override
  _SupplierDetailScreenState createState() => _SupplierDetailScreenState();
}

class _SupplierDetailScreenState extends State<SupplierDetailScreen> {
  @override
  void initState() {
    super.initState();
    // TODO: Fetch supplier details
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('供应商详情'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Navigate to Edit Supplier Screen
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              // TODO: Implement delete supplier logic
            },
          ),
        ],
      ),
      body: Consumer<SupplierProvider>(
        builder: (context, supplierProvider, child) {
          // TODO: Display supplier details
          return const Center(child: Text('供应商详情页面'));
        },
      ),
    );
  }
}
