import 'package:flutter/material.dart';
import 'package:hd_psi_mobile/theme/app_colors.dart';
import 'package:hd_psi_mobile/theme/app_dimensions.dart';
import 'package:hd_psi_mobile/theme/text_themes.dart';

/// 暗色主题配置
class DarkTheme {
  /// 创建暗色主题
  static ThemeData create() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryLightColor,
        onPrimary: Colors.black,
        secondary: AppColors.accentLightColor,
        onSecondary: Colors.black,
        error: AppColors.errorColor,
        onError: Colors.black,
        surface: AppColors.darkSurface,
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      cardTheme: _buildCardTheme(),
      appBarTheme: _buildAppBarTheme(),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      outlinedButtonTheme: _buildOutlinedButtonTheme(),
      textButtonTheme: _buildTextButtonTheme(),
      inputDecorationTheme: _buildInputDecorationTheme(),
      textTheme: TextThemes.darkTextTheme,
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
  static CardTheme _buildCardTheme() {
    return CardTheme(
      color: AppColors.darkSurface,
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
      backgroundColor: AppColors.darkSurface,
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
        backgroundColor: AppColors.primaryLightColor,
        foregroundColor: Colors.black,
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
        foregroundColor: AppColors.primaryLightColor,
        side: const BorderSide(color: AppColors.primaryLightColor),
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
        foregroundColor: AppColors.primaryLightColor,
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
      fillColor: AppColors.darkInputFill,
      contentPadding: const EdgeInsets.symmetric(
        vertical: AppDimensions.spacing * 1.5,
        horizontal: AppDimensions.spacingMedium,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        borderSide: const BorderSide(
          color: AppColors.primaryLightColor,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        borderSide: const BorderSide(color: AppColors.errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        borderSide: const BorderSide(color: AppColors.errorColor, width: 2),
      ),
      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: const TextStyle(color: Colors.white38),
    );
  }

  // 分隔线主题
  static DividerThemeData _buildDividerTheme() {
    return const DividerThemeData(
      color: AppColors.darkBorder,
      thickness: 1,
      space: AppDimensions.spacing * 2,
    );
  }

  // 标签栏主题
  static TabBarTheme _buildTabBarTheme() {
    return TabBarTheme(
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white.withAlpha(179),
      indicator: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.primaryLightColor, width: 3),
        ),
      ),
    );
  }

  // 底部导航栏主题
  static BottomNavigationBarThemeData _buildBottomNavigationBarTheme() {
    return const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedItemColor: AppColors.primaryLightColor,
      unselectedItemColor: Colors.white70,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    );
  }

  // 浮动操作按钮主题
  static FloatingActionButtonThemeData _buildFloatingActionButtonTheme() {
    return const FloatingActionButtonThemeData(
      backgroundColor: AppColors.accentLightColor,
      foregroundColor: Colors.black,
    );
  }

  // 进度指示器主题
  static ProgressIndicatorThemeData _buildProgressIndicatorTheme() {
    return const ProgressIndicatorThemeData(color: AppColors.primaryLightColor);
  }

  // 复选框主题
  static CheckboxThemeData _buildCheckboxTheme() {
    return CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryLightColor;
        }
        return Colors.transparent;
      }),
      side: const BorderSide(color: Colors.white70),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    );
  }

  // 开关主题
  static SwitchThemeData _buildSwitchTheme() {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryLightColor;
        }
        return Colors.grey;
      }),
      trackColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryColor.withAlpha(128);
        }
        return Colors.grey.withAlpha(77);
      }),
    );
  }

  // 单选按钮主题
  static RadioThemeData _buildRadioTheme() {
    return RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryLightColor;
        }
        return Colors.white70;
      }),
    );
  }

  // 标签主题
  static ChipThemeData _buildChipTheme() {
    return ChipThemeData(
      backgroundColor: AppColors.darkInputFill,
      disabledColor: AppColors.darkBorder,
      selectedColor: AppColors.primaryColor,
      secondarySelectedColor: AppColors.primaryColor,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing,
        vertical: AppDimensions.spacingSmall,
      ),
      labelStyle: const TextStyle(color: Colors.white),
      secondaryLabelStyle: const TextStyle(color: Colors.black),
      brightness: Brightness.dark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}
