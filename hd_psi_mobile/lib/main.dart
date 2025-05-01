import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/member_provider.dart';
import 'providers/inventory_provider.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/product_list_screen.dart';
import 'screens/product_add_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/product_edit_screen.dart';
import 'screens/scan_checkout_screen.dart';
import 'screens/member_list_screen.dart';
import 'screens/member_add_screen.dart';

void main() {
  // 初始化日期格式化
  initializeDateFormatting('zh_CN');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => MemberProvider()),
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '服装进销存系统',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/products': (context) => const ProductListScreen(),
        '/products/add': (context) => const ProductAddScreen(),
        '/scan-checkout': (context) => const ScanCheckoutScreen(),
        '/members': (context) => const MemberListScreen(),
        '/members/add': (context) => const MemberAddScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/products/detail') {
          final productId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => ProductDetailScreen(productId: productId),
          );
        }
        if (settings.name == '/products/edit') {
          final productId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => ProductEditScreen(productId: productId),
          );
        }
        return null;
      },
    );
  }
}
