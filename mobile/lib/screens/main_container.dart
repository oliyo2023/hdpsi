import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/custom_bottom_navigation.dart';
import 'home_screen.dart';
import 'product_list_screen.dart';
import 'scan_checkout_screen.dart';
import 'member_list_screen.dart';
import 'profile_screen.dart';

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  // 延迟初始化页面，避免重复创建
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // 在initState中初始化页面，确保只创建一次
    _pages = [
      const HomeScreen(),
      const ProductListScreen(),
      const ScanCheckoutScreen(),
      const MemberListScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onNavTap(int index) {
    // 特殊处理扫码页面，直接打开扫码界面
    if (index == 2) {
      Get.toNamed('/scan-checkout');
      return;
    }

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const NeverScrollableScrollPhysics(), // 禁止滑动切换，只能通过底部导航栏切换
        children: [
          _pages[0],
          _pages[1],
          Container(), // 扫码页面占位，实际上不会显示
          _pages[3],
          _pages[4], // Profile screen page
        ],
      ),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
      floatingActionButton:
          _currentIndex == 1 || _currentIndex == 3
              ? FloatingActionButton(
                onPressed: () {
                  if (_currentIndex == 1) {
                    Get.toNamed('/products/add');
                  } else if (_currentIndex == 3) {
                    Get.toNamed('/members/add');
                  }
                },
                child: const Icon(Icons.add),
              )
              : null,
    );
  }
}
