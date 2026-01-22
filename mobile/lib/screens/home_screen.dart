import 'package:flutter/material.dart';
import 'package:hd_psi_mobile/theme/app_colors.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

/// 首页界面
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _headerAnimationController;
  late AnimationController _pulseAnimationController;
  late AnimationController _counterAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _headerRotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _salesCountAnimation;
  late Animation<double> _orderCountAnimation;

  @override
  void initState() {
    super.initState();

    // 主动画控制器
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    // 头部图标旋转动画
    _headerAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _headerRotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // 脉冲动画控制器
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // 数字计数动画控制器
    _counterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _salesCountAnimation = Tween<double>(begin: 0.0, end: 12580.0).animate(
      CurvedAnimation(
        parent: _counterAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _orderCountAnimation = Tween<double>(begin: 0.0, end: 28.0).animate(
      CurvedAnimation(
        parent: _counterAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    // 启动动画
    _animationController.forward();
    _headerAnimationController.repeat();
    _pulseAnimationController.repeat(reverse: true);

    // 延迟启动计数动画
    Future.delayed(const Duration(milliseconds: 800), () {
      _counterAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _headerAnimationController.dispose();
    _pulseAnimationController.dispose();
    _counterAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF9F4E6), Color(0xFFFFFBF0), Color(0xFFF5F0E8)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // 现代化顶部区域
                  SliverToBoxAdapter(child: _buildModernHeader()),

                  // 欢迎卡片
                  SliverToBoxAdapter(child: _buildWelcomeCard()),

                  // 数据统计卡片 - 移到快捷功能上方
                  SliverToBoxAdapter(child: _buildStatsCards()),

                  // 快捷功能区
                  SliverToBoxAdapter(child: _buildQuickActions()),

                  // 主要功能区
                  SliverToBoxAdapter(child: _buildMainFeatures()),

                  // 最近活动
                  SliverToBoxAdapter(child: _buildRecentActivity()),

                  // 底部间距
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 构建现代化头部
  Widget _buildModernHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // 带旋转动画的图标
          AnimatedBuilder(
            animation: _headerRotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _headerRotationAnimation.value * 0.1, // 轻微旋转
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.primaryColor,
                        AppColors.primaryLightColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.store, color: Colors.white, size: 28),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 打字机效果的标题
                AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      '服装进销存',
                      textStyle: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryColor,
                        letterSpacing: 0.5,
                      ),
                      speed: const Duration(milliseconds: 100),
                    ),
                  ],
                  totalRepeatCount: 1,
                  displayFullTextOnTap: true,
                ),
                const SizedBox(height: 4),
                // 渐变文字效果
                AnimatedTextKit(
                  animatedTexts: [
                    FadeAnimatedText(
                      '智能管理系统',
                      textStyle: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondaryColor,
                        letterSpacing: 0.3,
                      ),
                      duration: const Duration(milliseconds: 1500),
                    ),
                  ],
                  totalRepeatCount: 1,
                ),
              ],
            ),
          ),
          // 带脉冲动画的通知图标
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.notifications_outlined,
                    color: AppColors.textSecondaryColor,
                    size: 24,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 构建欢迎卡片
  Widget _buildWelcomeCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryColor, AppColors.primaryLightColor],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '欢迎回来！',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '管理员',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '今日营业中',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(Icons.person, size: 40, color: Colors.white),
          ),
        ],
      ),
    );
  }

  /// 构建快捷功能区
  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '快捷功能',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 16),
          // 使用交错动画包装快捷功能项
          AnimationLimiter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 375),
                childAnimationBuilder:
                    (widget) => SlideAnimation(
                      horizontalOffset: 50.0,
                      child: FadeInAnimation(child: widget),
                    ),
                children: [
                  _buildQuickActionItem(
                    icon: Icons.add_shopping_cart_outlined,
                    title: '添加商品',
                    color: AppColors.primaryColor,
                    onTap:
                        () => Navigator.of(context).pushNamed('/products/add'),
                  ),
                  _buildQuickActionItem(
                    icon: Icons.qr_code_scanner_outlined,
                    title: '扫码出库',
                    color: AppColors.accentColor,
                    onTap:
                        () => Navigator.of(context).pushNamed('/scan-checkout'),
                  ),
                  _buildQuickActionItem(
                    icon: Icons.person_add_outlined,
                    title: '添加会员',
                    color: AppColors.chineseJade,
                    onTap:
                        () => Navigator.of(context).pushNamed('/members/add'),
                  ),
                  _buildQuickActionItem(
                    icon: Icons.inventory_outlined,
                    title: '库存查询',
                    color: AppColors.chineseLotus,
                    onTap: () => Navigator.of(context).pushNamed('/inventory'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建快捷功能项
  Widget _buildQuickActionItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 1.0, end: 1.0),
      duration: const Duration(milliseconds: 200),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTapDown: (_) {
              // 点击时缩小
              (context as Element).markNeedsBuild();
            },
            onTapUp: (_) {
              // 释放时恢复
              (context as Element).markNeedsBuild();
            },
            onTap: onTap,
            child: SizedBox(
              width: 70,
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: color.withValues(alpha: 0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 构建主要功能区
  Widget _buildMainFeatures() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '主要功能',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 16),
          // 使用交错动画包装功能卡片
          AnimationLimiter(
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 375),
                childAnimationBuilder:
                    (widget) => SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(child: widget),
                    ),
                children: [
                  _buildFeatureCard(
                    title: '商品管理',
                    subtitle: '管理所有商品信息',
                    icon: Icons.inventory_2_outlined,
                    color: AppColors.primaryColor,
                    onTap: () => Navigator.of(context).pushNamed('/products'),
                  ),
                  _buildFeatureCard(
                    title: '会员管理',
                    subtitle: '管理会员信息和积分',
                    icon: Icons.people_outline,
                    color: AppColors.chineseJade,
                    onTap: () => Navigator.of(context).pushNamed('/members'),
                  ),
                  _buildFeatureCard(
                    title: '供应商管理',
                    subtitle: '管理供应商信息',
                    icon: Icons.business_outlined,
                    color: AppColors.chinesePorcelain,
                    onTap: () => Navigator.of(context).pushNamed('/suppliers'),
                  ),
                  _buildFeatureCard(
                    title: '销售统计',
                    subtitle: '查看销售数据报表',
                    icon: Icons.analytics_outlined,
                    color: AppColors.chineseLotus,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建功能卡片
  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    // 根据不同功能设置不同的渐变背景
    List<Color> gradientColors = _getGradientColors(title, color);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 1.0, end: 1.0),
      duration: const Duration(milliseconds: 200),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTapDown: (_) {
              // 点击时轻微缩小
              (context as Element).markNeedsBuild();
            },
            onTapUp: (_) {
              // 释放时恢复
              (context as Element).markNeedsBuild();
            },
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                  stops: const [0.0, 0.7, 1.0],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // 背景装饰图案
                  Positioned(
                    right: -10,
                    top: -10,
                    child: Opacity(
                      opacity: 0.1,
                      child: Icon(icon, size: 80, color: Colors.white),
                    ),
                  ),
                  // 卡片内容
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(icon, color: color, size: 24),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 2,
                              color: Colors.black26,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.9),
                          shadows: const [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 2,
                              color: Colors.black26,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 根据功能类型获取渐变颜色
  List<Color> _getGradientColors(String title, Color baseColor) {
    switch (title) {
      case '商品管理':
        return [
          const Color(0xFF667eea),
          const Color(0xFF764ba2),
          const Color(0xFF8B5CF6),
        ];
      case '会员管理':
        return [
          const Color(0xFF11998e),
          const Color(0xFF38ef7d),
          const Color(0xFF10B981),
        ];
      case '供应商管理':
        return [
          const Color(0xFF3B82F6),
          const Color(0xFF1E40AF),
          const Color(0xFF1E3A8A),
        ];
      case '销售统计':
        return [
          const Color(0xFFf093fb),
          const Color(0xFFf5576c),
          const Color(0xFFEF4444),
        ];
      default:
        return [
          baseColor.withValues(alpha: 0.8),
          baseColor,
          baseColor.withValues(alpha: 1.2),
        ];
    }
  }

  /// 构建数据统计卡片
  Widget _buildStatsCards() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8FAFC), Color(0xFFFFFFFF), Color(0xFFF1F5F9)],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.8),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.primaryColor,
                      AppColors.primaryLightColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.analytics_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '今日概览',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryColor,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.successColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.successColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.trending_up,
                      size: 14,
                      color: AppColors.successColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '营业中',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.successColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // 使用交错动画包装统计卡片
          AnimationLimiter(
            child: Column(
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 375),
                childAnimationBuilder:
                    (widget) => SlideAnimation(
                      verticalOffset: 30.0,
                      child: FadeInAnimation(child: widget),
                    ),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AnimatedBuilder(
                          animation: _salesCountAnimation,
                          builder: (context, child) {
                            return _buildStatCard(
                              title: '今日销售',
                              value:
                                  '¥${_salesCountAnimation.value.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                              icon: Icons.trending_up,
                              color: AppColors.successColor,
                              trend: '+12.5%',
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AnimatedBuilder(
                          animation: _orderCountAnimation,
                          builder: (context, child) {
                            return _buildStatCard(
                              title: '订单数量',
                              value:
                                  _orderCountAnimation.value.toInt().toString(),
                              icon: Icons.receipt_long,
                              color: AppColors.accentColor,
                              trend: '+8.3%',
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: '新增会员',
                          value: '15',
                          icon: Icons.person_add_outlined,
                          color: AppColors.chineseJade,
                          trend: '+25.0%',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          title: '库存预警',
                          value: '3',
                          icon: Icons.warning_outlined,
                          color: AppColors.chineseLotus,
                          trend: '-5.2%',
                          isWarning: true,
                        ),
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

  /// 构建统计卡片
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? trend,
    bool isWarning = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondaryColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isWarning ? AppColors.chineseLotus : color,
            ),
          ),
          if (trend != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  trend.startsWith('+')
                      ? Icons.trending_up
                      : Icons.trending_down,
                  size: 14,
                  color:
                      trend.startsWith('+')
                          ? AppColors.successColor
                          : AppColors.chineseLotus,
                ),
                const SizedBox(width: 4),
                Text(
                  trend,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color:
                        trend.startsWith('+')
                            ? AppColors.successColor
                            : AppColors.chineseLotus,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '较昨日',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// 构建最近活动
  Widget _buildRecentActivity() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '最近活动',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryColor,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  '查看全部',
                  style: TextStyle(fontSize: 14, color: AppColors.primaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 使用交错动画包装活动项
          AnimationLimiter(
            child: Column(
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 375),
                childAnimationBuilder:
                    (widget) => SlideAnimation(
                      horizontalOffset: 50.0,
                      child: FadeInAnimation(child: widget),
                    ),
                children: [
                  _buildActivityItem(
                    icon: Icons.add_circle_outline,
                    title: '添加新商品',
                    subtitle: '春季新款连衣裙',
                    time: '2分钟前',
                    color: AppColors.primaryColor,
                  ),
                  _buildActivityItem(
                    icon: Icons.person_add_outlined,
                    title: '新会员注册',
                    subtitle: '张小姐',
                    time: '15分钟前',
                    color: AppColors.chineseJade,
                  ),
                  _buildActivityItem(
                    icon: Icons.inventory_outlined,
                    title: '商品出库',
                    subtitle: '牛仔裤 x2',
                    time: '1小时前',
                    color: AppColors.accentColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建活动项
  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondaryColor),
          ),
        ],
      ),
    );
  }
}
