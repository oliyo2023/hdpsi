import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../controllers/product_controller.dart';
import '../utils/validators.dart';

class ProductAddScreen extends StatefulWidget {
  const ProductAddScreen({super.key});

  @override
  State<ProductAddScreen> createState() => _ProductAddScreenState();
}

class _ProductAddScreenState extends State<ProductAddScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final List<File> _selectedImages = [];
  final List<Map<String, dynamic>> _variants = [];
  bool _isBasicInfoExpanded = true;
  bool _isPricingExpanded = false;
  bool _isVariantsExpanded = false;
  bool _isImagesExpanded = false;
  late final ProductController _productController;

  @override
  void initState() {
    super.initState();
    // 获取ProductController实例
    _productController = Get.find<ProductController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('添加商品')),
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 基本信息
                _buildExpandableSection(
                  title: '基本信息',
                  isExpanded: _isBasicInfoExpanded,
                  onExpansionChanged: (value) {
                    setState(() {
                      _isBasicInfoExpanded = value;
                    });
                  },
                  children: [
                    // 商品名称
                    FormBuilderTextField(
                      name: 'name',
                      decoration: const InputDecoration(
                        labelText: '商品名称',
                        border: OutlineInputBorder(),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(errorText: '请输入商品名称'),
                      ]),
                    ),
                    const SizedBox(height: 16.0),

                    // SKU
                    FormBuilderTextField(
                      name: 'sku',
                      decoration: const InputDecoration(
                        labelText: 'SKU',
                        border: OutlineInputBorder(),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(errorText: '请输入SKU'),
                      ]),
                    ),
                    const SizedBox(height: 16.0),

                    // 商品分类
                    FormBuilderDropdown<int>(
                      name: 'categoryId',
                      decoration: const InputDecoration(
                        labelText: '商品分类',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('上衣')),
                        DropdownMenuItem(value: 2, child: Text('裤子')),
                        DropdownMenuItem(value: 3, child: Text('裙子')),
                        DropdownMenuItem(value: 4, child: Text('外套')),
                        DropdownMenuItem(value: 5, child: Text('鞋子')),
                        DropdownMenuItem(value: 6, child: Text('配饰')),
                      ],
                    ),
                    const SizedBox(height: 16.0),

                    // 品牌
                    FormBuilderDropdown<int>(
                      name: 'brandId',
                      decoration: const InputDecoration(
                        labelText: '品牌',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('品牌A')),
                        DropdownMenuItem(value: 2, child: Text('品牌B')),
                        DropdownMenuItem(value: 3, child: Text('品牌C')),
                      ],
                    ),
                    const SizedBox(height: 16.0),

                    // 商品描述
                    FormBuilderTextField(
                      name: 'description',
                      decoration: const InputDecoration(
                        labelText: '商品描述',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                    ),
                    const SizedBox(height: 16.0),

                    // 商品状态
                    FormBuilderSwitch(
                      name: 'status',
                      title: const Text('商品状态（开启/关闭）'),
                      initialValue: true,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),

                // 价格信息
                _buildExpandableSection(
                  title: '价格信息',
                  isExpanded: _isPricingExpanded,
                  onExpansionChanged: (value) {
                    setState(() {
                      _isPricingExpanded = value;
                    });
                  },
                  children: [
                    // 成本价
                    FormBuilderTextField(
                      name: 'costPrice',
                      decoration: const InputDecoration(
                        labelText: '成本价',
                        border: OutlineInputBorder(),
                        prefixText: '¥',
                      ),
                      keyboardType: TextInputType.number,
                      validator:
                          (value) => Validators.validatePrice(value, '成本价'),
                    ),
                    const SizedBox(height: 16.0),

                    // 零售价
                    FormBuilderTextField(
                      name: 'retailPrice',
                      decoration: const InputDecoration(
                        labelText: '零售价',
                        border: OutlineInputBorder(),
                        prefixText: '¥',
                      ),
                      keyboardType: TextInputType.number,
                      validator:
                          (value) => Validators.validatePrice(value, '零售价'),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),

                // 商品图片
                _buildExpandableSection(
                  title: '商品图片',
                  isExpanded: _isImagesExpanded,
                  onExpansionChanged: (value) {
                    setState(() {
                      _isImagesExpanded = value;
                    });
                  },
                  children: [
                    // 已选图片预览
                    if (_selectedImages.isNotEmpty)
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedImages.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Stack(
                                children: [
                                  Image.file(
                                    _selectedImages[index],
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedImages.removeAt(index);
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 16.0),

                    // 添加图片按钮
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.photo_library),
                            label: const Text('从相册选择'),
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _takePhoto,
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('拍照'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),

                // 商品变体
                _buildExpandableSection(
                  title: '商品变体',
                  isExpanded: _isVariantsExpanded,
                  onExpansionChanged: (value) {
                    setState(() {
                      _isVariantsExpanded = value;
                    });
                  },
                  children: [
                    // 变体列表
                    ..._buildVariantsList(),
                    const SizedBox(height: 16.0),

                    // 添加变体按钮
                    ElevatedButton.icon(
                      onPressed: _showAddVariantDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('添加变体'),
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),

                // 错误信息
                if (_productController.hasError)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _productController.error,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // 提交按钮
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed:
                        _productController.isLoading ? null : _submitForm,
                    child:
                        _productController.isLoading
                            ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Text(
                              '保存商品',
                              style: TextStyle(fontSize: 16),
                            ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required bool isExpanded,
    required ValueChanged<bool> onExpansionChanged,
    required List<Widget> children,
  }) {
    return Card(
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        initiallyExpanded: isExpanded,
        onExpansionChanged: onExpansionChanged,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildVariantsList() {
    if (_variants.isEmpty) {
      return [
        const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('暂无商品变体，请点击下方按钮添加'),
          ),
        ),
      ];
    }

    return _variants.asMap().entries.map((entry) {
      final index = entry.key;
      final variant = entry.value;

      return Card(
        margin: const EdgeInsets.only(bottom: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '变体 #${index + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _variants.removeAt(index);
                      });
                    },
                  ),
                ],
              ),
              const Divider(),
              Text('SKU: ${variant['sku']}'),
              const SizedBox(height: 4),
              Text('颜色: ${_getColorName(variant['colorId'])}'),
              const SizedBox(height: 4),
              Text('尺码: ${_getSizeName(variant['sizeId'])}'),
              const SizedBox(height: 4),
              Text('条形码: ${variant['barcode']}'),
              const SizedBox(height: 4),
              Text('成本价: ¥${variant['costPrice']}'),
              const SizedBox(height: 4),
              Text('零售价: ¥${variant['retailPrice']}'),
            ],
          ),
        ),
      );
    }).toList();
  }

  String _getColorName(int? colorId) {
    if (colorId == null) return '无';

    final colors = {1: '红色', 2: '蓝色', 3: '黑色', 4: '白色', 5: '灰色'};

    return colors[colorId] ?? '未知';
  }

  String _getSizeName(int? sizeId) {
    if (sizeId == null) return '无';

    final sizes = {1: 'S', 2: 'M', 3: 'L', 4: 'XL', 5: 'XXL'};

    return sizes[sizeId] ?? '未知';
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles.isNotEmpty) {
      setState(() {
        for (final pickedFile in pickedFiles) {
          _selectedImages.add(File(pickedFile.path));
        }
      });
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _selectedImages.add(File(pickedFile.path));
      });
    }
  }

  void _showAddVariantDialog() {
    final formKey = GlobalKey<FormBuilderState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('添加商品变体'),
          content: SingleChildScrollView(
            child: FormBuilder(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // SKU
                  FormBuilderTextField(
                    name: 'sku',
                    decoration: const InputDecoration(
                      labelText: 'SKU',
                      border: OutlineInputBorder(),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(errorText: '请输入SKU'),
                    ]),
                  ),
                  const SizedBox(height: 16.0),

                  // 颜色
                  FormBuilderDropdown<int>(
                    name: 'colorId',
                    decoration: const InputDecoration(
                      labelText: '颜色',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('红色')),
                      DropdownMenuItem(value: 2, child: Text('蓝色')),
                      DropdownMenuItem(value: 3, child: Text('黑色')),
                      DropdownMenuItem(value: 4, child: Text('白色')),
                      DropdownMenuItem(value: 5, child: Text('灰色')),
                    ],
                  ),
                  const SizedBox(height: 16.0),

                  // 尺码
                  FormBuilderDropdown<int>(
                    name: 'sizeId',
                    decoration: const InputDecoration(
                      labelText: '尺码',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('S')),
                      DropdownMenuItem(value: 2, child: Text('M')),
                      DropdownMenuItem(value: 3, child: Text('L')),
                      DropdownMenuItem(value: 4, child: Text('XL')),
                      DropdownMenuItem(value: 5, child: Text('XXL')),
                    ],
                  ),
                  const SizedBox(height: 16.0),

                  // 条形码
                  FormBuilderTextField(
                    name: 'barcode',
                    decoration: const InputDecoration(
                      labelText: '条形码',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // 成本价
                  FormBuilderTextField(
                    name: 'costPrice',
                    decoration: const InputDecoration(
                      labelText: '成本价',
                      border: OutlineInputBorder(),
                      prefixText: '¥',
                    ),
                    keyboardType: TextInputType.number,
                    validator:
                        (value) => Validators.validatePrice(value, '成本价'),
                  ),
                  const SizedBox(height: 16.0),

                  // 零售价
                  FormBuilderTextField(
                    name: 'retailPrice',
                    decoration: const InputDecoration(
                      labelText: '零售价',
                      border: OutlineInputBorder(),
                      prefixText: '¥',
                    ),
                    keyboardType: TextInputType.number,
                    validator:
                        (value) => Validators.validatePrice(value, '零售价'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.saveAndValidate()) {
                  final formData = formKey.currentState!.value;

                  // 转换价格字段为double
                  double costPrice = 0.0;
                  double retailPrice = 0.0;

                  if (formData['costPrice'] != null &&
                      formData['costPrice'].toString().isNotEmpty) {
                    costPrice = double.parse(formData['costPrice'].toString());
                  }

                  if (formData['retailPrice'] != null &&
                      formData['retailPrice'].toString().isNotEmpty) {
                    retailPrice = double.parse(
                      formData['retailPrice'].toString(),
                    );
                  }

                  setState(() {
                    _variants.add({
                      'sku': formData['sku'],
                      'colorId': formData['colorId'],
                      'sizeId': formData['sizeId'],
                      'barcode': formData['barcode'] ?? '',
                      'costPrice': costPrice,
                      'retailPrice': retailPrice,
                      'status': true,
                    });
                  });

                  Navigator.of(context).pop();
                }
              },
              child: const Text('添加'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.saveAndValidate()) {
      final formData = _formKey.currentState!.value;

      // 检查是否有变体
      if (_variants.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('请至少添加一个商品变体')));
        return;
      }

      // 转换价格字段为double
      double costPrice = 0.0;
      double retailPrice = 0.0;

      if (formData['costPrice'] != null &&
          formData['costPrice'].toString().isNotEmpty) {
        costPrice = double.parse(formData['costPrice'].toString());
      }

      if (formData['retailPrice'] != null &&
          formData['retailPrice'].toString().isNotEmpty) {
        retailPrice = double.parse(formData['retailPrice'].toString());
      }

      // 创建商品对象
      final product = Product(
        id: 0, // 新商品，ID为0
        sku: formData['sku'],
        name: formData['name'],
        categoryId: formData['categoryId'],
        brandId: formData['brandId'],
        image: '', // 图片会在后端处理
        images: [], // 图片会在后端处理
        description: formData['description'] ?? '',
        costPrice: costPrice,
        retailPrice: retailPrice,
        status: formData['status'] ?? true,
        createdAt: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        updatedAt: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      );

      // 创建变体列表
      final variants =
          _variants.map((v) {
            return ProductVariant(
              id: 0, // 新变体，ID为0
              productId: 0, // 新商品，ID为0
              sku: v['sku'],
              colorId: v['colorId'],
              sizeId: v['sizeId'],
              barcode: v['barcode'] ?? '',
              qrCode: '', // 二维码会在后端生成
              costPrice: v['costPrice'],
              retailPrice: v['retailPrice'],
              status: v['status'] ?? true,
            );
          }).toList();

      // 提交商品
      final success = await _productController.createProduct(
        product,
        variants,
        images: _selectedImages,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('商品创建成功')));
        Navigator.of(context).pop();
      }
    }
  }
}
