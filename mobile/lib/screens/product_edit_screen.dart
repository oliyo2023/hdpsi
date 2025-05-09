import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hd_psi_mobile/utils/logger.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../utils/validators.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_display.dart';

class ProductEditScreen extends StatefulWidget {
  final int productId;

  const ProductEditScreen({super.key, required this.productId});

  @override
  State<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends State<ProductEditScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final List<File> _newImages = [];
  final List<Map<String, dynamic>> _variants = [];
  bool _isBasicInfoExpanded = true;
  bool _isPricingExpanded = false;
  bool _isVariantsExpanded = false;
  bool _isImagesExpanded = false;

  @override
  void initState() {
    super.initState();

    // 加载商品详情
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProductDetails();
    });
  }

  Future<void> _loadProductDetails() async {
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );
    await productProvider.getProduct(widget.productId);

    final product = productProvider.selectedProduct;
    if (product != null && mounted) {
      Logger.d('ProductEdit', 'Product object after fromJson: $product');
      // 初始化变体列表
      if (product.variants != null) {
        setState(() {
          _variants.clear();
          for (final variant in product.variants!) {
            _variants.add({
              'id': variant.id,
              'productId': variant.productId,
              'sku': variant.sku,
              'colorId': variant.colorId,
              'sizeId': variant.sizeId,
              'seasonId': variant.seasonId,
              'fabricId': variant.fabricId,
              'barcode': variant.barcode,
              'qrCode': variant.qrCode,
              'costPrice': variant.costPrice,
              'retailPrice': variant.retailPrice,
              'status': variant.status,
              'color': variant.color,
              'size': variant.size,
              'season': variant.season,
              'fabric': variant.fabric,
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('编辑商品')),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          if (productProvider.isLoading) {
            return const LoadingIndicator(message: '加载商品详情中...');
          }

          if (productProvider.error != null) {
            return ErrorDisplay(
              error: productProvider.error!,
              onRetry: _loadProductDetails,
            );
          }

          final product = productProvider.selectedProduct;
          if (product == null) {
            return const Center(child: Text('商品不存在或已被删除'));
          }

          // Data is loaded, build the form
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: FormBuilder(
              key: _formKey,
              initialValue: {
                'name': product.name,
                'sku': product.sku,
                'categoryId': product.categoryId,
                'brandId': product.brandId,
                'description': product.description,
                'costPrice': product.costPrice.toString(),
                'retailPrice': product.retailPrice.toString(),
                'status': product.status,
              },
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
                      // 现有图片预览
                      if (product.images.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '现有图片:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            SizedBox(
                              height: 120,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: product.images.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Image.network(
                                      product.images[index],
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Container(
                                          width: 100,
                                          height: 100,
                                          color: Colors.grey[200],
                                          child: const Center(
                                            child: Icon(
                                              Icons.broken_image,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 16.0),
                          ],
                        ),

                      // 新图片预览
                      if (_newImages.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '新添加图片:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            SizedBox(
                              height: 120,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _newImages.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Stack(
                                      children: [
                                        Image.file(
                                          _newImages[index],
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
                                                _newImages.removeAt(index);
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
                          ],
                        ),

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
                  if (productProvider.error != null) // Removed _isLoaded check
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        productProvider.error!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // 提交按钮
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed:
                          productProvider.isLoading
                              ? null
                              : () => _submitForm(
                                product,
                              ), // product is guaranteed non-null here
                      child:
                          productProvider.isLoading
                              ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Text(
                                '保存修改',
                                style: TextStyle(fontSize: 16),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
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
                  Row(
                    children: [
                      Switch(
                        value: variant['status'] as bool,
                        onChanged: (value) {
                          setState(() {
                            _variants[index]['status'] = value;
                          });
                        },
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
          _newImages.add(File(pickedFile.path));
        }
      });
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _newImages.add(File(pickedFile.path));
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
                      'id': 0, // 新变体，ID为0
                      'productId': widget.productId,
                      'sku': formData['sku'],
                      'colorId': formData['colorId'],
                      'sizeId': formData['sizeId'],
                      'barcode': formData['barcode'] ?? '',
                      'qrCode': '',
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

  Future<void> _submitForm(Product product) async {
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

      // 创建更新后的商品对象
      final updatedProduct = Product(
        id: product.id,
        sku: formData['sku'],
        name: formData['name'],
        categoryId: int.tryParse(formData['categoryId']?.toString() ?? ''),
        brandId: int.tryParse(formData['brandId']?.toString() ?? ''),
        image: product.image,
        images: product.images,
        description: formData['description'] ?? '',
        costPrice: costPrice,
        retailPrice: retailPrice,
        status: formData['status'] ?? true,
        createdAt: product.createdAt,
        updatedAt: DateTime.now().toUtc().toIso8601String(),
      );

      // 创建变体列表
      final variants =
          _variants.map((v) {
            return ProductVariant(
              id: v['id'] ?? 0,
              productId: product.id,
              sku: v['sku'],
              colorId: v['colorId'],
              sizeId: v['sizeId'],
              barcode: v['barcode'] ?? '',
              qrCode: v['qrCode'] ?? '',
              costPrice: v['costPrice'],
              retailPrice: v['retailPrice'],
              status: v['status'] ?? true,
            );
          }).toList();

      // 提交商品更新
      final success = await Provider.of<ProductProvider>(
        context,
        listen: false,
      ).updateProduct(
        product.id,
        updatedProduct,
        variants,
        newImages: _newImages,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('商品更新成功')));
        Navigator.of(context).pop();
      }
    }
  }
}
