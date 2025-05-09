import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/main_container.dart';
import '../screens/product_list_screen.dart';
import '../screens/product_add_screen.dart';
import '../screens/product_detail_screen.dart';
import '../screens/product_edit_screen.dart';
import '../screens/scan_checkout_screen.dart';
import '../screens/scan_checkin_screen.dart';
import '../screens/inventory_detail_screen.dart';
import '../screens/inventory_adjustment_screen.dart';
import '../screens/member_list_screen.dart';
import '../screens/member_add_screen.dart';
import '../screens/member_detail_screen.dart';
import '../screens/member_edit_screen.dart';
import '../screens/member_transactions_screen.dart';
import '../screens/inventory_list_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/sku_generator_screen.dart';
import '../screens/supplier_list_screen.dart';
import '../screens/supplier_detail_screen.dart';
import '../screens/supplier_edit_screen.dart';
import '../models/supplier.dart'; // Import Supplier model

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
  static const String scanCheckin = '/scan-checkin';
  static const String members = '/members';
  static const String memberAdd = '/members/add';
  static const String memberDetail = '/members/detail';
  static const String memberEdit = '/members/edit';
  static const String memberTransactions = '/members/transactions';
  static const String inventory = '/inventory';
  static const String inventoryDetail = '/inventory/detail';
  static const String inventoryAdjustment = '/inventory/adjustment';
  static const String settings = '/settings';
  static const String skuGenerator = '/sku-generator';
  static const String suppliers = '/suppliers';
  static const String supplierDetail = '/suppliers/detail';
  static const String supplierEdit = '/suppliers/edit';
  static const String supplierAdd = '/suppliers/add';

  /// 获取应用路由表
  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    home: (context) => const MainContainer(),
    products: (context) => const ProductListScreen(),
    productAdd: (context) => const ProductAddScreen(),
    scanCheckout: (context) => const ScanCheckoutScreen(),
    scanCheckin: (context) => const ScanCheckinScreen(),
    members: (context) => const MemberListScreen(),
    memberAdd: (context) => const MemberAddScreen(),
    inventory: (context) => const InventoryListScreen(),
    settings: (context) => const SettingsScreen(),
    skuGenerator: (context) => const SkuGeneratorScreen(),
    suppliers: (context) => const SupplierListScreen(),
    supplierAdd:
        (context) => const SupplierEditScreen(), // Use edit screen for add
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
      case supplierDetail:
        final supplierId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (context) => SupplierDetailScreen(supplierId: supplierId),
        );
      case supplierEdit:
        final supplier = settings.arguments as Supplier;
        return MaterialPageRoute(
          builder: (context) => SupplierEditScreen(supplier: supplier),
        );
      case inventoryDetail:
        final inventoryId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (context) => InventoryDetailScreen(inventoryId: inventoryId),
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
