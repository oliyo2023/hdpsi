import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../utils/formatters.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_display.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // 加载商品详情
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(
        context,
        listen: false,
      ).getProduct(widget.productId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('商品详情'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(
                context,
              ).pushNamed('/products/edit', arguments: widget.productId);
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteConfirmation();
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('删除商品'),
                  ),
                ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: '基本信息'), Tab(text: '变体'), Tab(text: '图片')],
        ),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          if (productProvider.isLoading) {
            return const LoadingIndicator(message: '加载商品详情中...');
          }

          if (productProvider.error != null) {
            return ErrorDisplay(
              error: productProvider.error!,
              onRetry: () => productProvider.getProduct(widget.productId),
            );
          }

          final product = productProvider.selectedProduct;
          if (product == null) {
            return const Center(child: Text('商品不存在或已被删除'));
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // 基本信息
              _buildBasicInfoTab(product),

              // 变体
              _buildVariantsTab(product),

              // 图片
              _buildImagesTab(product),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBasicInfoTab(Product product) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 商品状态
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 6.0,
            ),
            decoration: BoxDecoration(
              color: product.status ? Colors.green[100] : Colors.red[100],
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Text(
              product.status ? '上架中' : '已下架',
              style: TextStyle(
                color: product.status ? Colors.green[800] : Colors.red[800],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16.0),

          // 商品名称
          Text(
            product.name,
            style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),

          // SKU
          Text(
            'SKU: ${product.sku}',
            style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16.0),

          // 价格
          Row(
            children: [
              Text(
                Formatters.formatPrice(product.retailPrice),
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: 16.0),
              Text(
                '成本: ${Formatters.formatPrice(product.costPrice)}',
                style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 24.0),

          // 分类和品牌
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.category, color: Colors.blue),
                      const SizedBox(width: 8.0),
                      Text(
                        '分类: ${product.category?['Name'] ?? '未分类'}',
                        style: const TextStyle(fontSize: 16.0),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  Row(
                    children: [
                      const Icon(Icons.branding_watermark, color: Colors.blue),
                      const SizedBox(width: 8.0),
                      Text(
                        '品牌: ${product.brand?['Name'] ?? '无品牌'}',
                        style: const TextStyle(fontSize: 16.0),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16.0),

          // 商品描述
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '商品描述',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 8.0),
                  Text(
                    product.description.isNotEmpty
                        ? product.description
                        : '暂无商品描述',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16.0),

          // 创建和更新时间
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.blue),
                      const SizedBox(width: 8.0),
                      Text(
                        '创建时间: ${Formatters.formatDateTime(product.createdAt)}',
                        style: const TextStyle(fontSize: 14.0),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      const Icon(Icons.update, color: Colors.blue),
                      const SizedBox(width: 8.0),
                      Text(
                        '更新时间: ${Formatters.formatDateTime(product.updatedAt)}',
                        style: const TextStyle(fontSize: 14.0),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVariantsTab(Product product) {
    final variants = product.variants;

    if (variants == null || variants.isEmpty) {
      return const Center(child: Text('暂无商品变体'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: variants.length,
      itemBuilder: (context, index) {
        final variant = variants[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '变体 #${index + 1}',
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color:
                            variant.status
                                ? Colors.green[100]
                                : Colors.red[100],
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Text(
                        variant.status ? '上架中' : '已下架',
                        style: TextStyle(
                          fontSize: 12.0,
                          color:
                              variant.status
                                  ? Colors.green[800]
                                  : Colors.red[800],
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8.0),

                // SKU
                Text(
                  'SKU: ${variant.sku}',
                  style: const TextStyle(fontSize: 16.0),
                ),
                const SizedBox(height: 8.0),

                // 颜色和尺码
                Row(
                  children: [
                    if (variant.color != null)
                      Chip(
                        label: Text('颜色: ${variant.color!['Name']}'),
                        backgroundColor: Colors.blue[50],
                      ),
                    const SizedBox(width: 8.0),
                    if (variant.size != null)
                      Chip(
                        label: Text('尺码: ${variant.size!['Name']}'),
                        backgroundColor: Colors.green[50],
                      ),
                  ],
                ),
                const SizedBox(height: 8.0),

                // 条形码和二维码
                Text(
                  '条形码: ${variant.barcode}',
                  style: const TextStyle(fontSize: 16.0),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'QR码: ${variant.qrCode}',
                  style: const TextStyle(fontSize: 16.0),
                ),
                const SizedBox(height: 8.0),

                // 价格
                Row(
                  children: [
                    Text(
                      '零售价: ${Formatters.formatPrice(variant.retailPrice)}',
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Text(
                      '成本价: ${Formatters.formatPrice(variant.costPrice)}',
                      style: TextStyle(fontSize: 14.0, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImagesTab(Product product) {
    if (product.images.isEmpty) {
      return const Center(child: Text('暂无商品图片'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
      ),
      itemCount: product.images.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            _showImageFullScreen(product.images[index]);
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              product.images[index],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showImageFullScreen(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          child: Stack(
            fit: StackFit.expand,
            children: [
              InteractiveViewer(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.black,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 100,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('删除商品'),
          content: const Text('确定要删除这个商品吗？此操作不可恢复。'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('取消'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                // 先获取需要的对象和值，然后关闭对话框
                final productProvider = Provider.of<ProductProvider>(
                  context,
                  listen: false,
                );
                final productId = widget.productId;

                // 关闭确认对话框
                Navigator.of(context).pop();

                // 执行删除操作
                _deleteProduct(productProvider, productId);
              },
              child: const Text('删除'),
            ),
          ],
        );
      },
    );
  }

  // 处理商品删除的异步方法
  Future<void> _deleteProduct(ProductProvider provider, int productId) async {
    final success = await provider.deleteProduct(productId);

    // 检查组件是否仍然挂载
    if (success && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('商品已删除')));
      Navigator.of(context).pop(); // 返回上一页
    }
  }
}
