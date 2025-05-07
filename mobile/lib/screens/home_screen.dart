import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/animated_header.dart';
import '../utils/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      body: Column(
        children: [
          // 动画顶部
          const AnimatedHeader(title: '服装进销存系统', height: 160.0),

          // 内容区域
          Expanded(
            child: CustomScrollView(
              slivers: [
                // 欢迎信息
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingMedium),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.borderRadius,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(AppTheme.spacingMedium),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: AppTheme.primaryColor,
                              child: Text(
                                user != null && user.name.isNotEmpty
                                    ? user.name[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacingMedium),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '欢迎回来，${user?.name ?? '用户'}',
                                    style: const TextStyle(
                                      fontSize: AppTheme.fontSizeLarge,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '角色: ${_formatRole(user?.role)}',
                                    style: TextStyle(
                                      fontSize: AppTheme.fontSizeNormal,
                                      color:
                                          Theme.of(
                                            context,
                                          ).textTheme.bodyMedium?.color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // 快捷功能
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingMedium,
                      vertical: AppTheme.spacing,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '快捷功能',
                          style: TextStyle(
                            fontSize: AppTheme.fontSizeLarge,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingMedium),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildQuickAction(
                              context,
                              icon: Icons.add_shopping_cart,
                              title: '添加商品',
                              color: AppTheme.primaryColor,
                              onTap:
                                  () => Navigator.of(
                                    context,
                                  ).pushNamed('/products/add'),
                            ),
                            _buildQuickAction(
                              context,
                              icon: Icons.qr_code_scanner,
                              title: '扫码出库',
                              color: AppTheme.accentColor,
                              onTap:
                                  () => Navigator.of(
                                    context,
                                  ).pushNamed('/scan-checkout'),
                            ),
                            _buildQuickAction(
                              context,
                              icon: Icons.person_add,
                              title: '添加会员',
                              color: Colors.green,
                              onTap:
                                  () => Navigator.of(
                                    context,
                                  ).pushNamed('/members/add'),
                            ),
                            _buildQuickAction(
                              context,
                              icon: Icons.search,
                              title: '库存查询',
                              color: Colors.orange,
                              onTap:
                                  () => Navigator.of(
                                    context,
                                  ).pushNamed('/inventory'),
                            ),
                            _buildQuickAction(
                              context,
                              icon: Icons.qr_code,
                              title: 'SKU生成',
                              color: Colors.purple,
                              onTap:
                                  () => Navigator.of(
                                    context,
                                  ).pushNamed('/sku-generator'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // 主要功能
                SliverPadding(
                  padding: const EdgeInsets.all(AppTheme.spacingMedium),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.2,
                          crossAxisSpacing: AppTheme.spacingMedium,
                          mainAxisSpacing: AppTheme.spacingMedium,
                        ),
                    delegate: SliverChildListDelegate([
                      _buildFeatureCard(
                        context,
                        '商品管理',
                        Icons.inventory,
                        AppTheme.primaryColor,
                        '管理所有商品信息',
                        () => Navigator.of(context).pushNamed('/products'),
                      ),
                      _buildFeatureCard(
                        context,
                        '会员管理',
                        Icons.people,
                        Colors.purple,
                        '管理会员信息和积分',
                        () => Navigator.of(context).pushNamed('/members'),
                      ),
                      _buildFeatureCard(
                        context,
                        '库存管理',
                        Icons.inventory_2,
                        Colors.teal,
                        '管理商品库存和出入库',
                        () => Navigator.of(context).pushNamed('/inventory'),
                      ),
                      _buildFeatureCard(
                        context,
                        '销售统计',
                        Icons.bar_chart,
                        Colors.amber.shade800,
                        '查看销售数据和报表',
                        () {},
                      ),
                      _buildFeatureCard(
                        context,
                        'SKU生成器',
                        Icons.qr_code,
                        Colors.purple,
                        '生成商品SKU编码',
                        () => Navigator.of(context).pushNamed('/sku-generator'),
                      ),
                    ]),
                  ),
                ),

                // 最近活动
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingMedium),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.borderRadius,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.spacingMedium),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '最近活动',
                              style: TextStyle(
                                fontSize: AppTheme.fontSizeLarge,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(),
                            _buildActivityItem(
                              context,
                              icon: Icons.shopping_bag,
                              title: '添加了新商品',
                              subtitle: '夏季新款连衣裙',
                              time: '10分钟前',
                            ),
                            _buildActivityItem(
                              context,
                              icon: Icons.person,
                              title: '新会员注册',
                              subtitle: '张女士',
                              time: '30分钟前',
                            ),
                            _buildActivityItem(
                              context,
                              icon: Icons.inventory_2,
                              title: '商品出库',
                              subtitle: '牛仔裤 x 2',
                              time: '1小时前',
                            ),
                            _buildActivityItem(
                              context,
                              icon: Icons.inventory,
                              title: '商品入库',
                              subtitle: '夏季T恤 x 20',
                              time: '2小时前',
                              isLast: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // 底部空白
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: AppTheme.fontSizeNormal,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String description,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(height: AppTheme.spacing),
              Text(
                title,
                style: const TextStyle(
                  fontSize: AppTheme.fontSizeMedium,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: AppTheme.fontSizeSmall,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                ),
                child: Icon(icon, size: 20, color: AppTheme.primaryColor),
              ),
              const SizedBox(width: AppTheme.spacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: AppTheme.fontSizeNormal,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: AppTheme.fontSizeSmall,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  fontSize: AppTheme.fontSizeSmall,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1),
      ],
    );
  }

  String _formatRole(String? role) {
    if (role == null) return '未知';

    switch (role) {
      case 'admin':
        return '管理员';
      case 'manager':
        return '经理';
      case 'staff':
        return '员工';
      case 'cashier':
        return '收银员';
      default:
        return role;
    }
  }
}
