import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import '../controllers/supplier_controller.dart';
import '../models/supplier.dart';
import '../utils/logger.dart';
import '../widgets/form_section_card.dart';

class SupplierEditScreen extends StatefulWidget {
  final Supplier? supplier;

  const SupplierEditScreen({super.key, this.supplier});

  @override
  State<SupplierEditScreen> createState() => _SupplierEditScreenState();
}

class _SupplierEditScreenState extends State<SupplierEditScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  late final SupplierController _supplierController;

  @override
  void initState() {
    super.initState();
    _supplierController = Get.find<SupplierController>(
      tag: 'supplier_controller',
    );
  }

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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveSupplier,
        icon: const Icon(Icons.save),
        label: const Text('保存'),
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
              // 基本信息卡片
              FormSectionCard(
                title: '基本信息',
                icon: Icons.business,
                children: [
                  FormBuilderTextField(
                    name: 'name',
                    decoration: const InputDecoration(
                      labelText: '供应商名称',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入供应商名称';
                      }
                      return null;
                    },
                  ),
                  FormBuilderTextField(
                    name: 'code',
                    decoration: const InputDecoration(
                      labelText: '供应商编码',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入供应商编码';
                      }
                      return null;
                    },
                  ),
                  FormBuilderDropdown<SupplierType>(
                    name: 'type',
                    decoration: const InputDecoration(
                      labelText: '供应商类型',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
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
                ],
              ),

              // 联系信息卡片
              FormSectionCard(
                title: '联系信息',
                icon: Icons.contact_phone,
                children: [
                  FormBuilderTextField(
                    name: 'contactPerson',
                    decoration: const InputDecoration(
                      labelText: '联系人',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  FormBuilderTextField(
                    name: 'contactPhone',
                    decoration: const InputDecoration(
                      labelText: '联系电话',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  FormBuilderTextField(
                    name: 'email',
                    decoration: const InputDecoration(
                      labelText: '邮箱',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ],
              ),

              // 地址信息卡片
              FormSectionCard(
                title: '地址信息',
                icon: Icons.location_on,
                children: [
                  FormBuilderTextField(
                    name: 'address',
                    decoration: const InputDecoration(
                      labelText: '地址',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  FormBuilderTextField(
                    name: 'city',
                    decoration: const InputDecoration(
                      labelText: '城市',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ],
              ),

              // 评级与资质卡片
              FormSectionCard(
                title: '评级与资质',
                icon: Icons.star,
                children: [
                  FormBuilderDropdown<SupplierRating>(
                    name: 'rating',
                    decoration: const InputDecoration(
                      labelText: '评级',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
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
                    decoration: const InputDecoration(
                      labelText: '资质',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ],
              ),

              // 交易条款卡片
              FormSectionCard(
                title: '交易条款',
                icon: Icons.description,
                children: [
                  FormBuilderTextField(
                    name: 'paymentTerms',
                    decoration: const InputDecoration(
                      labelText: '付款条款',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  FormBuilderTextField(
                    name: 'deliveryTerms',
                    decoration: const InputDecoration(
                      labelText: '交货条款',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ],
              ),

              // 其他信息卡片
              FormSectionCard(
                title: '其他信息',
                icon: Icons.more_horiz,
                children: [
                  FormBuilderSwitch(
                    name: 'status',
                    title: const Text('状态（启用/禁用）'),
                    initialValue: widget.supplier?.status ?? true,
                    activeColor: Theme.of(context).primaryColor,
                  ),
                  FormBuilderTextField(
                    name: 'note',
                    decoration: const InputDecoration(
                      labelText: '备注',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    maxLines: 3,
                  ),
                ],
              ),

              // 底部间距
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _saveSupplier() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState!.value;

      // 添加调试日志
      Logger.i('SupplierEditScreen', '表单数据: $formData');
      Logger.i('SupplierEditScreen', '联系人: ${formData['contactPerson']}');
      Logger.i('SupplierEditScreen', '联系电话: ${formData['contactPhone']}');

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

      bool success;
      if (widget.supplier == null) {
        success = await _supplierController.createSupplier(supplier);
      } else {
        success = await _supplierController.updateSupplier(supplier);
      }

      if (success && mounted) {
        Get.back(result: true); // 返回上一页，传递成功标志
      }
    }
  }
}
