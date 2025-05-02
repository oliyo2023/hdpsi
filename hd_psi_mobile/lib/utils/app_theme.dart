// 此文件已被重构，现在只是一个桥接文件
// 请使用新的主题文件：
// - theme/app_colors.dart - 颜色定义
// - theme/app_dimensions.dart - 尺寸和间距
// - theme/text_themes.dart - 文本样式
// - theme/light_theme.dart - 亮色主题
// - theme/dark_theme.dart - 暗色主题
// - theme/app_theme.dart - 主题入口点

import 'package:flutter/material.dart';
import '../theme/app_theme.dart' as new_theme;
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

// 为了向后兼容，保留原有的静态方法
class AppTheme {
  // 颜色 - 从app_colors.dart转发
  static const Color primaryColor = AppColors.primaryColor;
  static const Color primaryLightColor = AppColors.primaryLightColor;
  static const Color primaryDarkColor = AppColors.primaryDarkColor;
  static const Color accentColor = AppColors.accentColor;
  static const Color accentLightColor = AppColors.accentLightColor;
  static const Color accentDarkColor = AppColors.accentDarkColor;
  static const Color backgroundColor = AppColors.backgroundColor;
  static const Color cardColor = AppColors.cardColor;
  static const Color scaffoldBackgroundColor =
      AppColors.scaffoldBackgroundColor;
  static const Color textPrimaryColor = AppColors.textPrimaryColor;
  static const Color textSecondaryColor = AppColors.textSecondaryColor;
  static const Color textLightColor = AppColors.textLightColor;
  static const Color successColor = AppColors.successColor;
  static const Color warningColor = AppColors.warningColor;
  static const Color errorColor = AppColors.errorColor;
  static const Color infoColor = AppColors.infoColor;
  static const Color dividerColor = AppColors.dividerColor;
  static const Color borderColor = AppColors.borderColor;

  // 尺寸 - 从app_dimensions.dart转发
  static List<BoxShadow> get cardShadow => AppDimensions.cardShadow;
  static const double borderRadius = AppDimensions.borderRadius;
  static BorderRadius get defaultBorderRadius =>
      AppDimensions.defaultBorderRadius;
  static const double spacing = AppDimensions.spacing;
  static const double spacingSmall = AppDimensions.spacingSmall;
  static const double spacingMedium = AppDimensions.spacingMedium;
  static const double spacingLarge = AppDimensions.spacingLarge;
  static const double spacingExtraLarge = AppDimensions.spacingExtraLarge;
  static const double fontSizeSmall = AppDimensions.fontSizeSmall;
  static const double fontSizeNormal = AppDimensions.fontSizeNormal;
  static const double fontSizeMedium = AppDimensions.fontSizeMedium;
  static const double fontSizeLarge = AppDimensions.fontSizeLarge;
  static const double fontSizeExtraLarge = AppDimensions.fontSizeExtraLarge;
  static const double fontSizeHuge = AppDimensions.fontSizeHuge;

  // 主题方法 - 从新的app_theme.dart转发
  static ThemeData lightTheme() => new_theme.AppTheme.lightTheme();
  static ThemeData darkTheme() => new_theme.AppTheme.darkTheme();
}
