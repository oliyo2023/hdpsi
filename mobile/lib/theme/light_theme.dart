import 'package:flutter/material.dart';
import 'package:hd_psi_mobile/theme/app_colors.dart';
import 'package:hd_psi_mobile/theme/app_dimensions.dart';
import 'package:hd_psi_mobile/theme/text_themes.dart';

/// 亮色主题配置
class LightTheme {
  /// 创建亮色主题
  static ThemeData create() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryColor,
        onPrimary: Colors.white,
        secondary: AppColors.accentColor,
        onSecondary: Colors.white,
        error: AppColors.errorColor,
        onError: Colors.white,
        surface: AppColors.backgroundColor,
        onSurface: AppColors.textPrimaryColor,
      ),
      scaffoldBackgroundColor: AppColors.scaffoldBackgroundColor,
      cardTheme: _buildCardTheme(),
      appBarTheme: _buildAppBarTheme(),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      outlinedButtonTheme: _buildOutlinedButtonTheme(),
      textButtonTheme: _buildTextButtonTheme(),
      inputDecorationTheme: _buildInputDecorationTheme(),
      textTheme: TextThemes.lightTextTheme,
      dividerTheme: _buildDividerTheme(),
      tabBarTheme: _buildTabBarTheme(),
      bottomNavigationBarTheme: _buildBottomNavigationBarTheme(),
      floatingActionButtonTheme: _buildFloatingActionButtonTheme(),
      progressIndicatorTheme: _buildProgressIndicatorTheme(),
      checkboxTheme: _buildCheckboxTheme(),
      switchTheme: _buildSwitchTheme(),
      radioTheme: _buildRadioTheme(),
      chipTheme: _buildChipTheme(),
    );
  }

  // 卡片主题
  static CardThemeData _buildCardTheme() {
    return CardThemeData(
      color: AppColors.cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
      ),
      margin: const EdgeInsets.symmetric(
        vertical: AppDimensions.spacing,
        horizontal: AppDimensions.spacing,
      ),
    );
  }

  // 应用栏主题
  static AppBarTheme _buildAppBarTheme() {
    return AppBarTheme(
      backgroundColor: AppColors.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppDimensions.borderRadius),
        ),
      ),
    );
  }

  // 凸起按钮主题
  static ElevatedButtonThemeData _buildElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.spacing * 1.5,
          horizontal: AppDimensions.spacingMedium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        ),
      ),
    );
  }

  // 轮廓按钮主题
  static OutlinedButtonThemeData _buildOutlinedButtonTheme() {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryColor,
        side: const BorderSide(color: AppColors.primaryColor),
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.spacing * 1.5,
          horizontal: AppDimensions.spacingMedium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        ),
      ),
    );
  }

  // 文本按钮主题
  static TextButtonThemeData _buildTextButtonTheme() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryColor,
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.spacing,
          horizontal: AppDimensions.spacingMedium,
        ),
      ),
    );
  }

  // 输入装饰主题
  static InputDecorationTheme _buildInputDecorationTheme() {
    return InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        vertical: AppDimensions.spacing * 1.5,
        horizontal: AppDimensions.spacingMedium,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        borderSide: const BorderSide(color: AppColors.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        borderSide: const BorderSide(color: AppColors.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        borderSide: const BorderSide(color: AppColors.errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        borderSide: const BorderSide(color: AppColors.errorColor, width: 2),
      ),
      labelStyle: TextStyle(color: AppColors.textSecondaryColor),
      hintStyle: TextStyle(color: AppColors.textLightColor),
    );
  }

  // 分隔线主题
  static DividerThemeData _buildDividerTheme() {
    return const DividerThemeData(
      color: AppColors.dividerColor,
      thickness: 1,
      space: AppDimensions.spacing * 2,
    );
  }

  // 标签栏主题
  static TabBarThemeData _buildTabBarTheme() {
    return TabBarThemeData(
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white.withAlpha(179),
      indicator: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white, width: 3)),
      ),
    );
  }

  // 底部导航栏主题
  static BottomNavigationBarThemeData _buildBottomNavigationBarTheme() {
    return const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primaryColor,
      unselectedItemColor: AppColors.textSecondaryColor,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    );
  }

  // 浮动操作按钮主题
  static FloatingActionButtonThemeData _buildFloatingActionButtonTheme() {
    return const FloatingActionButtonThemeData(
      backgroundColor: AppColors.accentColor,
      foregroundColor: Colors.white,
    );
  }

  // 进度指示器主题
  static ProgressIndicatorThemeData _buildProgressIndicatorTheme() {
    return const ProgressIndicatorThemeData(color: AppColors.primaryColor);
  }

  // 复选框主题
  static CheckboxThemeData _buildCheckboxTheme() {
    return CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryColor;
        }
        return Colors.transparent;
      }),
      side: const BorderSide(color: AppColors.borderColor),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    );
  }

  // 开关主题
  static SwitchThemeData _buildSwitchTheme() {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryColor;
        }
        return Colors.grey;
      }),
      trackColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryLightColor;
        }
        return Colors.grey.withAlpha(128);
      }),
    );
  }

  // 单选按钮主题
  static RadioThemeData _buildRadioTheme() {
    return RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryColor;
        }
        return AppColors.textSecondaryColor;
      }),
    );
  }

  // 标签主题
  static ChipThemeData _buildChipTheme() {
    return ChipThemeData(
      backgroundColor: Colors.grey.shade200,
      disabledColor: Colors.grey.shade300,
      selectedColor: AppColors.primaryLightColor,
      secondarySelectedColor: AppColors.primaryLightColor,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing,
        vertical: AppDimensions.spacingSmall,
      ),
      labelStyle: const TextStyle(color: AppColors.textPrimaryColor),
      secondaryLabelStyle: const TextStyle(color: Colors.white),
      brightness: Brightness.light,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}
