import 'package:flutter/material.dart';
import 'package:hd_psi_mobile/theme/app_colors.dart';
import 'package:hd_psi_mobile/theme/app_dimensions.dart';

/// 文本主题定义
class TextThemes {
  /// 亮色主题文本样式
  static const TextTheme lightTextTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: AppDimensions.fontSizeHuge,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimaryColor,
    ),
    displayMedium: TextStyle(
      fontSize: AppDimensions.fontSizeExtraLarge,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimaryColor,
    ),
    displaySmall: TextStyle(
      fontSize: AppDimensions.fontSizeLarge,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimaryColor,
    ),
    headlineMedium: TextStyle(
      fontSize: AppDimensions.fontSizeMedium,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimaryColor,
    ),
    titleLarge: TextStyle(
      fontSize: AppDimensions.fontSizeMedium,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimaryColor,
    ),
    bodyLarge: TextStyle(
      fontSize: AppDimensions.fontSizeNormal,
      color: AppColors.textPrimaryColor,
    ),
    bodyMedium: TextStyle(
      fontSize: AppDimensions.fontSizeNormal,
      color: AppColors.textSecondaryColor,
    ),
  );

  /// 暗色主题文本样式
  static const TextTheme darkTextTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: AppDimensions.fontSizeHuge,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    displayMedium: TextStyle(
      fontSize: AppDimensions.fontSizeExtraLarge,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    displaySmall: TextStyle(
      fontSize: AppDimensions.fontSizeLarge,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    headlineMedium: TextStyle(
      fontSize: AppDimensions.fontSizeMedium,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    titleLarge: TextStyle(
      fontSize: AppDimensions.fontSizeMedium,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    bodyLarge: TextStyle(
      fontSize: AppDimensions.fontSizeNormal,
      color: Colors.white,
    ),
    bodyMedium: TextStyle(
      fontSize: AppDimensions.fontSizeNormal,
      color: Colors.white70,
    ),
  );
}
