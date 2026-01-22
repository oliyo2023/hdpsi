import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:get/get.dart';

// GetX控制器
import 'package:hd_psi_mobile/controllers/auth_controller.dart';
import 'package:hd_psi_mobile/controllers/product_controller.dart';
import 'package:hd_psi_mobile/controllers/inventory_controller.dart';
import 'package:hd_psi_mobile/controllers/transaction_controller.dart';
import 'package:hd_psi_mobile/controllers/member_controller.dart';
import 'package:hd_psi_mobile/controllers/supplier_controller.dart';

// 服务
import 'package:hd_psi_mobile/services/permission_service.dart';
import 'package:hd_psi_mobile/services/app_initialization_service.dart';
import 'package:hd_psi_mobile/services/wechat_service.dart';

import 'package:hd_psi_mobile/routes/app_router.dart';
import 'package:hd_psi_mobile/theme/app_theme.dart';
import 'package:hd_psi_mobile/utils/config.dart';

// 页面导入
import 'package:hd_psi_mobile/screens/splash_screen.dart';
import 'package:hd_psi_mobile/pages/permission_guide_page.dart';
import 'package:hd_psi_mobile/pages/privacy_policy_page.dart';
import 'package:hd_psi_mobile/screens/main_container.dart';
import 'package:hd_psi_mobile/screens/login_screen.dart';
import 'package:hd_psi_mobile/screens/product_list_screen.dart';
import 'package:hd_psi_mobile/screens/product_add_screen.dart';
import 'package:hd_psi_mobile/screens/product_detail_screen.dart';
import 'package:hd_psi_mobile/screens/product_edit_screen.dart';
import 'package:hd_psi_mobile/screens/member_list_screen.dart';
import 'package:hd_psi_mobile/screens/member_add_screen.dart';
import 'package:hd_psi_mobile/screens/member_detail_screen.dart';
import 'package:hd_psi_mobile/screens/member_edit_screen.dart';
import 'package:hd_psi_mobile/screens/member_transactions_screen.dart';
import 'package:hd_psi_mobile/screens/scan_checkout_screen.dart';
import 'package:hd_psi_mobile/screens/scan_checkin_screen.dart';
import 'package:hd_psi_mobile/screens/inventory_list_screen.dart';
import 'package:hd_psi_mobile/screens/settings_screen.dart';
import 'package:hd_psi_mobile/screens/sku_generator_screen.dart';
import 'package:hd_psi_mobile/screens/supplier_list_screen.dart';
import 'package:hd_psi_mobile/screens/supplier_detail_screen.dart';
import 'package:hd_psi_mobile/screens/supplier_edit_screen.dart';
import 'package:hd_psi_mobile/screens/inventory_detail_screen.dart';
import 'package:hd_psi_mobile/models/supplier.dart';

void main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化日期格式化
  initializeDateFormatting('zh_CN');

  // 初始化应用配置
  initializeAppConfig();

  // 初始化微信SDK
  await WechatService.init();

  // 初始化所有GetX控制器
  _initializeControllers();

  runApp(const MyApp());
}

/// 初始化所有GetX控制器和服务
void _initializeControllers() {
  // 首先注册服务
  Get.put(PermissionService(), permanent: true);
  Get.put(AppInitializationService(), permanent: true);

  // 注册所有控制器为永久实例
  Get.put(AuthController(), permanent: true);
  Get.put(ProductController(), permanent: true);
  Get.put(InventoryController(), permanent: true);
  Get.put(TransactionController(), permanent: true);
  Get.put(MemberController(), permanent: true);
  Get.put(SupplierController(), permanent: true);

  // 打印调试信息
  debugPrint('GetX控制器和服务注册完成');
  debugPrint(
    'PermissionService是否已注册: ${Get.isRegistered<PermissionService>()}',
  );
  debugPrint(
    'AppInitializationService是否已注册: ${Get.isRegistered<AppInitializationService>()}',
  );
  debugPrint('MemberController是否已注册: ${Get.isRegistered<MemberController>()}');
  debugPrint(
    'SupplierController是否已注册: ${Get.isRegistered<SupplierController>()}',
  );
}

// 初始化应用配置
void initializeAppConfig() {
  // 根据不同环境设置API基础URL
  const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'dev',
  );

  // 如果环境变量中有API_BASE_URL，则使用环境变量中的值
  const String envApiBaseUrl = String.fromEnvironment('API_BASE_URL');
  if (envApiBaseUrl.isNotEmpty) {
    AppConfig.setApiBaseUrl(envApiBaseUrl);
  } else {
    // 否则使用预定义的环境配置
    AppConfig.setEnvironment(environment);
  }

  // 打印当前使用的API基础URL，方便调试
  debugPrint('当前API基础URL: ${AppConfig.apiBaseUrl}');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '服装进销存系统',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.system, // 跟随系统设置
      initialRoute: AppRouter.splash,
      getPages: [
        // 基础页面
        GetPage(name: AppRouter.splash, page: () => const SplashScreen()),
        GetPage(
          name: '/permission-guide',
          page: () => const PermissionGuidePage(),
        ),
        GetPage(name: '/privacy-policy', page: () => const PrivacyPolicyPage()),
        GetPage(name: AppRouter.login, page: () => const LoginScreen()),
        GetPage(name: AppRouter.home, page: () => const MainContainer()),

        // 商品相关页面
        GetPage(
          name: AppRouter.products,
          page: () => const ProductListScreen(),
        ),
        GetPage(
          name: AppRouter.productAdd,
          page: () => const ProductAddScreen(),
        ),
        GetPage(
          name: AppRouter.productDetail,
          page: () => ProductDetailScreen(productId: Get.arguments as int),
        ),
        GetPage(
          name: AppRouter.productEdit,
          page: () => ProductEditScreen(productId: Get.arguments as int),
        ),

        // 会员相关页面
        GetPage(name: AppRouter.members, page: () => const MemberListScreen()),
        GetPage(name: AppRouter.memberAdd, page: () => const MemberAddScreen()),
        GetPage(
          name: AppRouter.memberDetail,
          page: () => MemberDetailScreen(memberId: Get.arguments as int),
        ),
        GetPage(
          name: AppRouter.memberEdit,
          page: () => MemberEditScreen(memberId: Get.arguments as int),
        ),
        GetPage(
          name: AppRouter.memberTransactions,
          page: () => MemberTransactionsScreen(memberId: Get.arguments as int),
        ),

        // 其他页面
        GetPage(
          name: AppRouter.scanCheckout,
          page: () => const ScanCheckoutScreen(),
        ),
        GetPage(
          name: AppRouter.scanCheckin,
          page: () => const ScanCheckinScreen(),
        ),
        GetPage(
          name: AppRouter.inventory,
          page: () => const InventoryListScreen(),
        ),
        GetPage(name: AppRouter.settings, page: () => const SettingsScreen()),
        GetPage(
          name: AppRouter.skuGenerator,
          page: () => const SkuGeneratorScreen(),
        ),
        GetPage(
          name: AppRouter.suppliers,
          page: () => const SupplierListScreen(),
        ),
        GetPage(
          name: AppRouter.supplierAdd,
          page: () => const SupplierEditScreen(),
        ),
        GetPage(
          name: AppRouter.supplierDetail,
          page: () => SupplierDetailScreen(supplierId: Get.arguments as int),
        ),
        GetPage(
          name: AppRouter.supplierEdit,
          page: () => SupplierEditScreen(supplier: Get.arguments as Supplier),
        ),
        GetPage(
          name: AppRouter.inventoryDetail,
          page: () => InventoryDetailScreen(inventoryId: Get.arguments as int),
        ),
      ],
      unknownRoute: GetPage(
        name: '/notfound',
        page: () => const SplashScreen(),
      ),
    );
  }
}
