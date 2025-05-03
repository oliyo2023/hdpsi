import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/main_container.dart';
import '../screens/product_list_screen.dart';
import '../screens/product_add_screen.dart';
import '../screens/product_detail_screen.dart';
import '../screens/product_edit_screen.dart';
import '../screens/scan_checkout_screen.dart';
import '../screens/member_list_screen.dart';
import '../screens/member_add_screen.dart';
import '../screens/member_detail_screen.dart';
import '../screens/member_edit_screen.dart';
import '../screens/member_transactions_screen.dart';

/// 应用路由配置
class AppRouter {
  /// 路由名称常量
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String products = '/products';
  static const String productAdd = '/products/add';
  static const String productDetail = '/products/detail';
  static const String productEdit = '/products/edit';
  static const String scanCheckout = '/scan-checkout';
  static const String members = '/members';
  static const String memberAdd = '/members/add';
  static const String memberDetail = '/members/detail';
  static const String memberEdit = '/members/edit';
  static const String memberTransactions = '/members/transactions';

  /// 获取应用路由表
  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    home: (context) => const MainContainer(),
    products: (context) => const ProductListScreen(),
    productAdd: (context) => const ProductAddScreen(),
    scanCheckout: (context) => const ScanCheckoutScreen(),
    members: (context) => const MemberListScreen(),
    memberAdd: (context) => const MemberAddScreen(),
  };

  /// 处理需要参数的路由
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case productDetail:
        final productId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (context) => ProductDetailScreen(productId: productId),
        );
      case productEdit:
        final productId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (context) => ProductEditScreen(productId: productId),
        );
      case memberDetail:
        final memberId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (context) => MemberDetailScreen(memberId: memberId),
        );
      case memberEdit:
        final memberId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (context) => MemberEditScreen(memberId: memberId),
        );
      case memberTransactions:
        final memberId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (context) => MemberTransactionsScreen(memberId: memberId),
        );
      default:
        return null;
    }
  }

  /// 导航到指定路由
  static Future<T?> navigateTo<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(context).pushNamed(routeName, arguments: arguments);
  }

  /// 替换当前路由
  static Future<T?> replaceTo<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(
      context,
    ).pushReplacementNamed(routeName, arguments: arguments);
  }

  /// 清除所有路由并导航到指定路由
  static Future<T?> navigateAndRemoveUntil<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(context).pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }
}
