import 'package:flutter/material.dart';
import 'package:hd_psi_mobile/theme/light_theme.dart';
import 'package:hd_psi_mobile/theme/dark_theme.dart';

/// 应用主题管理
class AppTheme {
  /// 获取亮色主题
  static ThemeData lightTheme() => LightTheme.create();

  /// 获取暗色主题
  static ThemeData darkTheme() => DarkTheme.create();
}
