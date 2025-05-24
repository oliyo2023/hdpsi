import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hd_psi_mobile/controllers/auth_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // 延迟执行，确保Widget已经完全构建
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatus();
    });
  }

  // 检查登录状态
  Future<void> _checkLoginStatus() async {
    // 给用户一些时间看到启动画面
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authController = Get.find<AuthController>();

    // 如果已经登录，直接进入主页
    if (authController.isLoggedIn) {
      Get.offNamed('/home');
    } else {
      // 否则显示登录按钮
      setState(() {
        _showLoginButton = true;
      });
    }
  }

  bool _showLoginButton = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 应用图标
            const Icon(Icons.shopping_bag, size: 100, color: Colors.blue),
            const SizedBox(height: 24),

            // 应用名称
            const Text(
              '服装进销存系统',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 版本信息
            Text(
              '移动端 v1.0.0',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 48),

            // 登录按钮或加载指示器
            if (_showLoginButton)
              ElevatedButton(
                onPressed: () {
                  Get.offNamed('/login');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text('进入系统', style: TextStyle(fontSize: 18)),
              )
            else
              const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
