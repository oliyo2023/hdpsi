import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/member_controller.dart';

/// GetX演示页面
/// 展示GetX状态管理的优势
class GetXDemoScreen extends StatelessWidget {
  const GetXDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GetX 状态管理演示')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'GetX 优势演示',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 1. 不依赖BuildContext
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '1. 不依赖BuildContext',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('GetX可以在任何地方访问状态，无需传递context'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => _demonstrateContextFree(),
                      child: const Text('演示无Context访问'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 2. 响应式UI更新
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '2. 响应式UI更新',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('使用Obx自动响应状态变化'),
                    const SizedBox(height: 8),
                    Obx(() {
                      final controller = Get.find<MemberController>();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('会员总数: ${controller.totalMembers}'),
                          Text('当前页: ${controller.currentPage}'),
                          Text('加载状态: ${controller.isLoading ? "加载中" : "空闲"}'),
                          if (controller.error != null)
                            Text(
                              '错误: ${controller.error}',
                              style: const TextStyle(color: Colors.red),
                            ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 3. 简洁的状态管理
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '3. 简洁的状态管理',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('无需Provider包装，直接使用Get.find获取控制器'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => _demonstrateSimpleAccess(),
                      child: const Text('演示简洁访问'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 4. 内存管理
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '4. 内存管理',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('GetX提供了灵活的依赖注入和内存管理'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () => _checkControllerStatus(),
                          child: const Text('检查控制器状态'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _demonstrateMemoryManagement(),
                          child: const Text('内存管理演示'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 演示无Context访问
  void _demonstrateContextFree() {
    // 在任何地方都可以访问GetX控制器，无需context
    final controller = Get.find<MemberController>();

    // 显示消息
    Get.snackbar(
      '无Context访问',
      '成功访问MemberController，当前会员数: ${controller.totalMembers}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// 演示简洁访问
  void _demonstrateSimpleAccess() {
    final controller = Get.find<MemberController>();

    // 清除错误（如果有的话）
    controller.clearError();

    Get.snackbar(
      '简洁访问',
      '直接调用控制器方法，无需Provider.of或Consumer',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// 检查控制器状态
  void _checkControllerStatus() {
    final isRegistered = Get.isRegistered<MemberController>();

    Get.dialog(
      AlertDialog(
        title: const Text('控制器状态'),
        content: Text('MemberController 已注册: $isRegistered'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('确定')),
        ],
      ),
    );
  }

  /// 演示内存管理
  void _demonstrateMemoryManagement() {
    Get.dialog(
      AlertDialog(
        title: const Text('内存管理'),
        content: const Text(
          'GetX控制器使用permanent: true注册，'
          '确保在应用生命周期内持续存在。'
          '也可以使用Get.delete()手动删除控制器。',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('确定')),
        ],
      ),
    );
  }
}
