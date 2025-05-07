import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;

          return CustomScrollView(
            slivers: [
              // 顶部应用栏
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    user?.name ?? '我的账户',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.primaryDarkColor,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            child: Text(
                              user?.name.isNotEmpty == true
                                  ? user!.name[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 用户信息
              SliverToBoxAdapter(
                child: Card(
                  margin: const EdgeInsets.all(AppTheme.spacingMedium),
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '账户信息',
                          style: TextStyle(
                            fontSize: AppTheme.fontSizeLarge,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        _buildInfoItem(
                          context,
                          icon: Icons.person,
                          title: '用户名',
                          value: user?.username ?? '未登录',
                        ),
                        _buildInfoItem(
                          context,
                          icon: Icons.badge,
                          title: '角色',
                          value: _formatRole(user?.role),
                        ),
                        _buildInfoItem(
                          context,
                          icon: Icons.email,
                          title: '邮箱',
                          value: user?.email ?? '未设置',
                        ),
                        _buildInfoItem(
                          context,
                          icon: Icons.phone,
                          title: '手机',
                          value: user?.phone ?? '未设置',
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 功能列表
              SliverToBoxAdapter(
                child: Card(
                  margin: const EdgeInsets.all(AppTheme.spacingMedium),
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '系统设置',
                          style: TextStyle(
                            fontSize: AppTheme.fontSizeLarge,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        _buildSettingItem(
                          context,
                          icon: Icons.dark_mode,
                          title: '深色模式',
                          trailing: Switch(
                            value:
                                Theme.of(context).brightness == Brightness.dark,
                            onChanged: (value) {
                              // 切换主题
                            },
                          ),
                        ),
                        _buildSettingItem(
                          context,
                          icon: Icons.language,
                          title: '语言设置',
                          onTap: () {
                            // 打开语言设置
                          },
                        ),
                        _buildSettingItem(
                          context,
                          icon: Icons.notifications,
                          title: '通知设置',
                          onTap: () {
                            // 打开通知设置
                          },
                        ),
                        _buildSettingItem(
                          context,
                          icon: Icons.security,
                          title: '隐私设置',
                          onTap: () {
                            // 打开隐私设置
                          },
                        ),
                        _buildSettingItem(
                          context,
                          icon: Icons.settings,
                          title: '系统设置',
                          onTap: () {
                            Navigator.of(context).pushNamed('/settings');
                          },
                        ),
                        _buildSettingItem(
                          context,
                          icon: Icons.info,
                          title: '关于我们',
                          onTap: () {
                            // 打开关于页面
                          },
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 退出登录按钮
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingMedium),
                  child: ElevatedButton(
                    onPressed: () async {
                      await authProvider.logout();
                      if (context.mounted) {
                        Navigator.of(context).pushReplacementNamed('/login');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      '退出登录',
                      style: TextStyle(
                        fontSize: AppTheme.fontSizeMedium,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              // 底部空白
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.primaryColor, size: 24),
              const SizedBox(width: AppTheme.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: AppTheme.fontSizeNormal,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: AppTheme.fontSizeMedium,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1),
      ],
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    bool isLast = false,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing),
            child: Row(
              children: [
                Icon(icon, color: AppTheme.primaryColor, size: 24),
                const SizedBox(width: AppTheme.spacingMedium),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: AppTheme.fontSizeMedium,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                trailing ??
                    Icon(
                      Icons.chevron_right,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
              ],
            ),
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
