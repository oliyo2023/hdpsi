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

import 'package:hd_psi_mobile/routes/app_router.dart';
import 'package:hd_psi_mobile/theme/app_theme.dart';
import 'package:hd_psi_mobile/utils/config.dart';

void main() {
  // 初始化日期格式化
  initializeDateFormatting('zh_CN');

  // 初始化应用配置
  initializeAppConfig();

  // 初始化所有GetX控制器
  _initializeControllers();

  runApp(const MyApp());
}

/// 初始化所有GetX控制器
void _initializeControllers() {
  // 注册所有控制器为永久实例
  Get.put(AuthController(), permanent: true);
  Get.put(ProductController(), permanent: true);
  Get.put(InventoryController(), permanent: true);
  Get.put(TransactionController(), permanent: true);
  Get.put(MemberController(), permanent: true);
  Get.put(SupplierController(), permanent: true);
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
      navigatorKey: navigatorKey, // 添加全局导航键
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.system, // 跟随系统设置
      initialRoute: AppRouter.splash,
      getPages: [], // GetX路由，暂时为空，我们仍使用传统路由
      routes: AppRouter.routes,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
