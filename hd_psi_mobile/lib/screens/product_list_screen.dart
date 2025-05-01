import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_display.dart';
import '../widgets/empty_data.dart';
import '../utils/formatters.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // 加载商品列表
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(
        context,
        listen: false,
      ).loadProducts(refresh: true);
    });

    // 添加滚动监听器，用于加载更多
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // 滚动到底部时加载更多
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );
      if (!productProvider.isLoading && productProvider.hasMorePages) {
        productProvider.loadMoreProducts(
          name:
              _searchController.text.isNotEmpty ? _searchController.text : null,
        );
      }
    }
  }

  // 搜索商品
  void _searchProducts() {
    Provider.of<ProductProvider>(context, listen: false).loadProducts(
      refresh: true,
      name: _searchController.text.isNotEmpty ? _searchController.text : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('商品管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed('/products/add');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索栏
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索商品名称',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _searchProducts();
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _searchProducts(),
            ),
          ),

          // 商品列表
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, productProvider, child) {
                if (productProvider.isLoading &&
                    productProvider.products.isEmpty) {
                  return const LoadingIndicator(message: '加载商品中...');
                }

                if (productProvider.error != null &&
                    productProvider.products.isEmpty) {
                  return ErrorDisplay(
                    error: productProvider.error!,
                    onRetry: () => productProvider.loadProducts(refresh: true),
                  );
                }

                if (productProvider.products.isEmpty) {
                  return EmptyData(
                    message: '暂无商品数据',
                    icon: Icons.inventory,
                    onAction:
                        () => Navigator.of(context).pushNamed('/products/add'),
                    actionLabel: '添加商品',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => productProvider.loadProducts(refresh: true),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount:
                        productProvider.products.length +
                        (productProvider.hasMorePages ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == productProvider.products.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final product = productProvider.products[index];
                      return _buildProductItem(context, product);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(BuildContext context, Product product) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: () {
          Navigator.of(
            context,
          ).pushNamed('/products/detail', arguments: product.id);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 商品图片
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  image: DecorationImage(
                    image:
                        product.image.isNotEmpty
                            ? NetworkImage(product.image)
                            : const AssetImage('assets/images/no_image.png')
                                as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16.0),

              // 商品信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'SKU: ${product.sku}',
                      style: TextStyle(fontSize: 14.0, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      '类别: ${product.category?['Name'] ?? '未分类'}',
                      style: TextStyle(fontSize: 14.0, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          Formatters.formatPrice(product.retailPrice),
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          decoration: BoxDecoration(
                            color:
                                product.status
                                    ? Colors.green[100]
                                    : Colors.red[100],
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Text(
                            product.status ? '上架中' : '已下架',
                            style: TextStyle(
                              fontSize: 12.0,
                              color:
                                  product.status
                                      ? Colors.green[800]
                                      : Colors.red[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
