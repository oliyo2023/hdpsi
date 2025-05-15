import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/chinese_style_header.dart';
import '../utils/app_theme.dart';
import '../theme/app_colors.dart';
import '../widgets/chinese_style_action.dart' hide PatternType;
import '../widgets/chinese_style_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.backgroundColor, Colors.white],
          ),
        ),
        child: Column(
          children: [
            // 中国风格动画顶部
            const ChineseStyleHeader(title: '服装进销存系统', height: 180.0),

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
                              ChineseStyleAction(
                                icon: Icons.add_shopping_cart,
                                title: '添加商品',
                                color: AppTheme.primaryColor,
                                shapeType: ShapeType.seal,
                                onTap:
                                    () => Navigator.of(
                                      context,
                                    ).pushNamed('/products/add'),
                              ),
                              ChineseStyleAction(
                                icon: Icons.qr_code_scanner,
                                title: '扫码出库',
                                color: AppTheme.accentColor,
                                shapeType: ShapeType.circle,
                                onTap:
                                    () => Navigator.of(
                                      context,
                                    ).pushNamed('/scan-checkout'),
                              ),
                              ChineseStyleAction(
                                icon: Icons.person_add,
                                title: '添加会员',
                                color: AppColors.chineseJade,
                                shapeType: ShapeType.seal,
                                onTap:
                                    () => Navigator.of(
                                      context,
                                    ).pushNamed('/members/add'),
                              ),
                              ChineseStyleAction(
                                icon: Icons.business_center,
                                title: '供应商',
                                color: AppColors.chinesePorcelain,
                                shapeType: ShapeType.circle,
                                onTap:
                                    () => Navigator.of(
                                      context,
                                    ).pushNamed('/suppliers'),
                              ),
                              ChineseStyleAction(
                                icon: Icons.search,
                                title: '库存查询',
                                color: AppColors.chineseLotus,
                                shapeType: ShapeType.seal,
                                onTap:
                                    () => Navigator.of(
                                      context,
                                    ).pushNamed('/inventory'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 主要功能标题
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: AppTheme.spacingMedium,
                        right: AppTheme.spacingMedium,
                        top: AppTheme.spacingLarge,
                        bottom: AppTheme.spacingSmall,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 20,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '主要功能',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 主要功能卡片
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingMedium,
                    ),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.2,
                            crossAxisSpacing: AppTheme.spacingMedium,
                            mainAxisSpacing: AppTheme.spacingMedium,
                          ),
                      delegate: SliverChildListDelegate([
                        _buildChineseStyleFeatureCard(
                          context,
                          '商品管理',
                          Icons.inventory,
                          AppTheme.primaryColor,
                          '管理所有商品信息',
                          PatternType.cloud,
                          () => Navigator.of(context).pushNamed('/products'),
                        ),
                        _buildChineseStyleFeatureCard(
                          context,
                          '会员管理',
                          Icons.people,
                          AppColors.chineseJade,
                          '管理会员信息和积分',
                          PatternType.flower,
                          () => Navigator.of(context).pushNamed('/members'),
                        ),
                        _buildChineseStyleFeatureCard(
                          context,
                          '供应商管理',
                          Icons.business,
                          AppColors.chinesePorcelain,
                          '管理供应商信息和采购',
                          PatternType.wave,
                          () => Navigator.of(context).pushNamed('/suppliers'),
                        ),
                        _buildChineseStyleFeatureCard(
                          context,
                          '库存管理',
                          Icons.inventory_2,
                          AppTheme.accentColor,
                          '管理商品库存和出入库',
                          PatternType.lattice,
                          () => Navigator.of(context).pushNamed('/inventory'),
                        ),
                        _buildChineseStyleFeatureCard(
                          context,
                          '销售统计',
                          Icons.bar_chart,
                          AppColors.chineseLotus,
                          '查看销售数据和报表',
                          PatternType.flower,
                          () {},
                        ),
                        _buildChineseStyleFeatureCard(
                          context,
                          'SKU生成器',
                          Icons.qr_code,
                          AppTheme.primaryDarkColor,
                          '生成商品SKU编码',
                          PatternType.cloud,
                          () =>
                              Navigator.of(context).pushNamed('/sku-generator'),
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

  // 中国风格功能卡片
  Widget _buildChineseStyleFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String description,
    PatternType patternType,
    VoidCallback onTap,
  ) {
    return ChineseStyleCard(
      elevation: 3.0,
      backgroundColor: Colors.white,
      borderColor: color.withAlpha(128),
      patternType: patternType,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图标和标题
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 描述
          Text(
            description,
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondaryColor),
          ),

          // 底部装饰线
          Expanded(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                height: 3,
                width: 60,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
