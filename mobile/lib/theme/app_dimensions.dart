import 'package:flutter/material.dart';

/// 应用尺寸定义
class AppDimensions {
  // 圆角
  static const double borderRadius = 8.0;
  static BorderRadius defaultBorderRadius = BorderRadius.circular(borderRadius);

  // 间距
  static const double spacing = 8.0;
  static const double spacingSmall = 4.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingExtraLarge = 32.0;

  // 字体大小
  static const double fontSizeSmall = 12.0;
  static const double fontSizeNormal = 14.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 18.0;
  static const double fontSizeExtraLarge = 24.0;
  static const double fontSizeHuge = 32.0;

  // 阴影
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withAlpha(26),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
}
