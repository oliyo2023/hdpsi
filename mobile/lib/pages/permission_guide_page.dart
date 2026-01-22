import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/permission_service.dart';
import 'privacy_policy_page.dart';

/// 权限引导页面
/// 在应用首次启动时展示，说明权限用途并引导用户授权
class PermissionGuidePage extends StatefulWidget {
  const PermissionGuidePage({super.key});

  @override
  State<PermissionGuidePage> createState() => _PermissionGuidePageState();
}

class _PermissionGuidePageState extends State<PermissionGuidePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<PermissionGuideItem> _guideItems = [
    PermissionGuideItem(
      icon: Icons.security,
      title: '隐私保护',
      description: '我们严格保护您的隐私和数据安全\n仅收集必要的业务信息',
      color: Colors.blue,
    ),
    PermissionGuideItem(
      icon: Icons.camera_alt,
      title: '相机权限',
      description: '用于扫描商品条码\n快速录入商品信息',
      color: Colors.green,
    ),
    PermissionGuideItem(
      icon: Icons.photo_library,
      title: '相册权限',
      description: '用于选择商品图片\n让商品信息更完整',
      color: Colors.orange,
    ),
    PermissionGuideItem(
      icon: Icons.storage,
      title: '存储权限',
      description: '用于保存应用数据\n确保数据安全存储',
      color: Colors.purple,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 顶部标题
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Image.asset(
                    'assets/icons/icon.png',
                    width: 80,
                    height: 80,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.store,
                          color: Colors.white,
                          size: 40,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '欢迎使用宏店',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '专业的进销存管理系统',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),

            // 引导内容
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _guideItems.length,
                itemBuilder: (context, index) {
                  final item = _guideItems[index];
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: item.color.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: item.color.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: Icon(item.icon, size: 60, color: item.color),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: item.color,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          item.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // 页面指示器
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _guideItems.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color:
                        _currentPage == index
                            ? Colors.blue
                            : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            // 底部按钮
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          _currentPage == _guideItems.length - 1
                              ? _showPermissionDialog
                              : _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _currentPage == _guideItems.length - 1 ? '开始使用' : '下一步',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Get.to(() => const PrivacyPolicyPage());
                    },
                    child: const Text(
                      '查看隐私政策',
                      style: TextStyle(
                        color: Colors.grey,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _showPermissionDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('权限授权'),
        content: const Text(
          '为了提供完整的功能体验，宏店需要获取一些必要的权限。\n\n'
          '您可以选择现在授权，或在使用相关功能时再进行授权。',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              _completeGuide();
            },
            child: const Text('稍后授权'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _requestPermissions();
            },
            child: const Text('立即授权'),
          ),
        ],
      ),
    );
  }

  void _requestPermissions() async {
    final permissionService = PermissionService.to;
    await permissionService.requestAllPermissions();
    _completeGuide();
  }

  void _completeGuide() {
    // 标记引导完成
    // 这里可以保存到本地存储，下次启动时不再显示
    // SharedPreferences.getInstance().then((prefs) {
    //   prefs.setBool('permission_guide_completed', true);
    // });

    // 跳转到主页面
    Get.offAllNamed('/login'); // 或者其他主页面路由
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

/// 权限引导项数据模型
class PermissionGuideItem {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  PermissionGuideItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
