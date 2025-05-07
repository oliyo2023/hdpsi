import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import '../providers/supplier_provider.dart';
import '../models/supplier.dart';

class SupplierEditScreen extends StatefulWidget {
  final Supplier? supplier;

  const SupplierEditScreen({super.key, this.supplier});

  @override
  State<SupplierEditScreen> createState() => _SupplierEditScreenState();
}

class _SupplierEditScreenState extends State<SupplierEditScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.supplier == null ? '添加供应商' : '编辑供应商'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              _saveSupplier();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _formKey,
          initialValue: {
            'name': widget.supplier?.name ?? '',
            'code': widget.supplier?.code ?? '',
            'type': widget.supplier?.type,
            'contactPerson': widget.supplier?.contactPerson ?? '',
            'contactPhone': widget.supplier?.contactPhone ?? '',
            'email': widget.supplier?.email ?? '',
            'address': widget.supplier?.address ?? '',
            'city': widget.supplier?.city ?? '',
            'rating': widget.supplier?.rating,
            'qualification': widget.supplier?.qualification ?? '',
            'paymentTerms': widget.supplier?.paymentTerms ?? '',
            'deliveryTerms': widget.supplier?.deliveryTerms ?? '',
            'status': widget.supplier?.status ?? true,
            'note': widget.supplier?.note ?? '',
          },
          child: ListView(
            children: [
              FormBuilderTextField(
                name: 'name',
                decoration: const InputDecoration(labelText: '供应商名称'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入供应商名称';
                  }
                  return null;
                },
              ),
              FormBuilderTextField(
                name: 'code',
                decoration: const InputDecoration(labelText: '供应商编码'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入供应商编码';
                  }
                  return null;
                },
              ),
              FormBuilderDropdown<SupplierType>(
                name: 'type',
                decoration: const InputDecoration(labelText: '供应商类型'),
                validator: (value) {
                  if (value == null) {
                    return '请选择供应商类型';
                  }
                  return null;
                },
                items:
                    SupplierType.values
                        .map(
                          (type) => DropdownMenuItem(
                            value: type,
                            child: Text(type.toString().split('.').last),
                          ),
                        )
                        .toList(),
              ),
              FormBuilderTextField(
                name: 'contactPerson',
                decoration: const InputDecoration(labelText: '联系人'),
              ),
              FormBuilderTextField(
                name: 'contactPhone',
                decoration: const InputDecoration(labelText: '联系电话'),
              ),
              FormBuilderTextField(
                name: 'email',
                decoration: const InputDecoration(labelText: '邮箱'),
              ),
              FormBuilderTextField(
                name: 'address',
                decoration: const InputDecoration(labelText: '地址'),
              ),
              FormBuilderTextField(
                name: 'city',
                decoration: const InputDecoration(labelText: '城市'),
              ),
              FormBuilderDropdown<SupplierRating>(
                name: 'rating',
                decoration: const InputDecoration(labelText: '评级'),
                items:
                    SupplierRating.values
                        .map(
                          (rating) => DropdownMenuItem(
                            value: rating,
                            child: Text(rating.toString().split('.').last),
                          ),
                        )
                        .toList(),
              ),
              FormBuilderTextField(
                name: 'qualification',
                decoration: const InputDecoration(labelText: '资质'),
              ),
              FormBuilderTextField(
                name: 'paymentTerms',
                decoration: const InputDecoration(labelText: '付款条款'),
              ),
              FormBuilderTextField(
                name: 'deliveryTerms',
                decoration: const InputDecoration(labelText: '交货条款'),
              ),
              FormBuilderSwitch(
                name: 'status',
                title: const Text('状态'),
                initialValue: widget.supplier?.status ?? true,
              ),
              FormBuilderTextField(
                name: 'note',
                decoration: const InputDecoration(labelText: '备注'),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveSupplier() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState!.value;
      final supplierProvider = Provider.of<SupplierProvider>(
        context,
        listen: false,
      );

      final supplier = Supplier(
        id: widget.supplier?.id ?? 0, // Use 0 for new supplier
        name: formData['name'],
        code: formData['code'],
        type: formData['type'],
        contactPerson: formData['contactPerson'],
        contactPhone: formData['contactPhone'],
        email: formData['email'],
        address: formData['address'],
        city: formData['city'],
        rating: formData['rating'],
        qualification: formData['qualification'],
        paymentTerms: formData['paymentTerms'],
        deliveryTerms: formData['deliveryTerms'],
        status: formData['status'] ?? true,
        note: formData['note'],
        createdAt: widget.supplier?.createdAt ?? DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      );

      try {
        if (widget.supplier == null) {
          await supplierProvider.createSupplier(supplier);
        } else {
          await supplierProvider.updateSupplier(supplier);
        }
        if (mounted) {
          Navigator.of(context).pop(); // Go back after saving
        }
      } catch (e) {
        // TODO: Show error message
        print('保存供应商失败: $e');
      }
    }
  }
}
