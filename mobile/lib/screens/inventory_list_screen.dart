import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../widgets/animated_header.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_display.dart';
import '../widgets/empty_data.dart';
import '../utils/app_theme.dart';
import 'inventory_detail_screen.dart';

class InventoryListScreen extends StatefulWidget {
  const InventoryListScreen({super.key});

  @override
  State<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends State<InventoryListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // 加载库存数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InventoryProvider>(
        context,
        listen: false,
      ).loadInventories(refresh: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        flexibleSpace: const AnimatedHeader(title: '库存管理', height: 120.0),
        toolbarHeight: 120.0,
        backgroundColor: Colors.transparent, // 使 AppBar 背景透明，显示 AnimatedHeader
        elevation: 0, // 移除 AppBar 的阴影
      ),
      body: Column(
        children: [
          // 搜索栏
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索商品名称或SKU',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _searchQuery.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // 库存列表
          Expanded(
            child: Consumer<InventoryProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const LoadingIndicator();
                }

                if (provider.error != null) {
                  return ErrorDisplay(
                    error: provider.error!,
                    onRetry: () => provider.loadInventories(refresh: true),
                  );
                }

                final inventories = provider.inventories;
                if (inventories.isEmpty) {
                  return const EmptyData(
                    message: '暂无库存数据',
                    icon: Icons.inventory_2_outlined,
                  );
                }

                // 过滤库存数据
                final filteredInventories =
                    inventories.where((inventory) {
                      if (_searchQuery.isEmpty) return true;

                      final productName =
                          inventory.productVariant?['Product']?['Name']
                              as String? ??
                          '';
                      final sku =
                          inventory.productVariant?['SKU'] as String? ?? '';

                      return productName.toLowerCase().contains(
                            _searchQuery.toLowerCase(),
                          ) ||
                          sku.toLowerCase().contains(
                            _searchQuery.toLowerCase(),
                          );
                    }).toList();

                if (filteredInventories.isEmpty) {
                  return const EmptyData(
                    message: '没有找到匹配的库存数据',
                    icon: Icons.search_off,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(AppTheme.spacing),
                  itemCount: filteredInventories.length,
                  itemBuilder: (context, index) {
                    final inventory = filteredInventories[index];
                    final productName =
                        inventory.productVariant?['Product']?['Name']
                            as String? ??
                        '未知商品';
                    final sku =
                        inventory.productVariant?['SKU'] as String? ?? '无SKU';
                    final storeName =
                        inventory.store?['Name'] as String? ?? '未知店铺';

                    return Card(
                      margin: const EdgeInsets.only(bottom: AppTheme.spacing),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.borderRadius,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingMedium,
                          vertical: AppTheme.spacing,
                        ),
                        title: Text(
                          productName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: AppTheme.fontSizeMedium,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('SKU: $sku'),
                            Text('店铺: $storeName'),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                _buildInventoryTag(
                                  '库存: ${inventory.quantity}',
                                  inventory.quantity > inventory.alertQuantity
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                                const SizedBox(width: 8),
                                _buildInventoryTag(
                                  '预警: ${inventory.alertQuantity}',
                                  Colors.grey,
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) => InventoryDetailScreen(
                                    inventoryId: inventory.id,
                                  ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(128)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: AppTheme.fontSizeSmall,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
