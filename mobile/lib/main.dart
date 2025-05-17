import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:hd_psi_mobile/providers/auth_provider.dart';
import 'package:hd_psi_mobile/providers/product_provider.dart';
import 'package:hd_psi_mobile/providers/member_provider.dart';
import 'package:hd_psi_mobile/providers/inventory_provider.dart';
import 'package:hd_psi_mobile/providers/transaction_provider.dart';
import 'package:hd_psi_mobile/providers/supplier_provider.dart';
import 'package:hd_psi_mobile/services/supplier_service_adapter.dart';

import 'package:hd_psi_mobile/routes/app_router.dart';
import 'package:hd_psi_mobile/theme/app_theme.dart';
import 'package:hd_psi_mobile/utils/scanner_util.dart';
import 'package:hd_psi_mobile/utils/config.dart';

void main() {
  // 初始化日期格式化
  initializeDateFormatting('zh_CN');

  // 初始化应用配置
  initializeAppConfig();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => MemberProvider()),
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        // 使用新的供应商服务适配器
        ChangeNotifierProvider(
          create: (_) => SupplierProvider(SupplierServiceAdapter()),
        ),
      ],
      child: const MyApp(),
    ),
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
    return MaterialApp(
      title: '服装进销存系统',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey, // 添加全局导航键
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.system, // 跟随系统设置
      initialRoute: AppRouter.splash,
      routes: AppRouter.routes,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
