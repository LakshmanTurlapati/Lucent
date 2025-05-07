import 'package:flutter/material.dart';

class AppThemes {
  // Dark theme colors
  static const Color _darkPrimaryColor = Color(0xFF2C2C2E);
  static const Color _darkScaffoldBackground = Color(0xFF1C1C1E);
  static const Color _darkAppBarColor = Color(0xFF2C2C2E);
  static const Color _darkCardColor = Color(0xFF2C2C2E);
  static const Color _darkTextColor = Colors.white;
  static const Color _darkSecondaryTextColor = Colors.grey;
  static const Color _darkDividerColor = Color(0xFF3C3C3E);
  static const Color _darkIconColor = Colors.white;
  static const Color _darkSettingsSidebarColor = Colors.black;
  static const Color _darkOverlayColor = Color(0xBF000000); // 75% opacity black

  // Light theme colors
  static const Color _lightPrimaryColor = Color(0xFF007AFF);
  static const Color _lightScaffoldBackground = Color(0xFFF2F2F7);
  static const Color _lightAppBarColor = Colors.white;
  static const Color _lightCardColor = Colors.white;
  static const Color _lightTextColor = Color(0xFF1C1C1E);
  static const Color _lightSecondaryTextColor = Color(0xFF6C6C70);
  static const Color _lightDividerColor = Color(0xFFD1D1D6);
  static const Color _lightIconColor = Color(0xFF1C1C1E);
  static const Color _lightSettingsSidebarColor = Color(0xFFE5E5EA);
  static const Color _lightOverlayColor = Color(0xBFFFFFFF); // 75% opacity white

  // Get dark theme
  static ThemeData getDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: _darkPrimaryColor,
      scaffoldBackgroundColor: _darkScaffoldBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: _darkAppBarColor,
        foregroundColor: _darkTextColor,
      ),
      cardColor: _darkCardColor,
      dividerColor: _darkDividerColor,
      iconTheme: const IconThemeData(
        color: _darkIconColor,
      ),
      textTheme: _getTextTheme(_darkTextColor, _darkSecondaryTextColor),
      colorScheme: ColorScheme.dark(
        primary: _darkPrimaryColor,
        secondary: _darkCardColor,
        surface: _darkCardColor,
        background: _darkScaffoldBackground,
        onSurface: _darkTextColor,
        onBackground: _darkTextColor,
      ),
      useMaterial3: true,
      extensions: [
        AppThemeExtension(
          settingsSidebarColor: _darkSettingsSidebarColor,
          overlayColor: _darkOverlayColor,
        ),
      ],
    );
  }

  // Get light theme
  static ThemeData getLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: _lightPrimaryColor,
      scaffoldBackgroundColor: _lightScaffoldBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: _lightAppBarColor,
        foregroundColor: _lightTextColor,
      ),
      cardColor: _lightCardColor,
      dividerColor: _lightDividerColor,
      iconTheme: const IconThemeData(
        color: _lightIconColor,
      ),
      textTheme: _getTextTheme(_lightTextColor, _lightSecondaryTextColor),
      colorScheme: ColorScheme.light(
        primary: _lightPrimaryColor,
        secondary: _lightPrimaryColor,
        surface: _lightCardColor,
        background: _lightScaffoldBackground,
        onSurface: _lightTextColor,
        onBackground: _lightTextColor,
      ),
      useMaterial3: true,
      extensions: [
        AppThemeExtension(
          settingsSidebarColor: _lightSettingsSidebarColor,
          overlayColor: _lightOverlayColor,
        ),
      ],
    );
  }
  
  // Text theme helper
  static TextTheme _getTextTheme(Color primaryTextColor, Color secondaryTextColor) {
    return TextTheme(
      displayLarge: TextStyle(color: primaryTextColor),
      displayMedium: TextStyle(color: primaryTextColor),
      displaySmall: TextStyle(color: primaryTextColor),
      headlineLarge: TextStyle(color: primaryTextColor),
      headlineMedium: TextStyle(color: primaryTextColor),
      headlineSmall: TextStyle(color: primaryTextColor),
      titleLarge: TextStyle(color: primaryTextColor),
      titleMedium: TextStyle(color: primaryTextColor),
      titleSmall: TextStyle(color: primaryTextColor),
      bodyLarge: TextStyle(color: primaryTextColor),
      bodyMedium: TextStyle(color: primaryTextColor),
      bodySmall: TextStyle(color: secondaryTextColor),
      labelLarge: TextStyle(color: primaryTextColor),
      labelMedium: TextStyle(color: secondaryTextColor),
      labelSmall: TextStyle(color: secondaryTextColor),
    );
  }
}

// Custom theme extension for app-specific colors
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color settingsSidebarColor;
  final Color overlayColor;

  const AppThemeExtension({
    required this.settingsSidebarColor,
    required this.overlayColor,
  });

  @override
  AppThemeExtension copyWith({
    Color? settingsSidebarColor,
    Color? overlayColor,
  }) {
    return AppThemeExtension(
      settingsSidebarColor: settingsSidebarColor ?? this.settingsSidebarColor,
      overlayColor: overlayColor ?? this.overlayColor,
    );
  }

  @override
  ThemeExtension<AppThemeExtension> lerp(covariant ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) {
      return this;
    }
    
    return AppThemeExtension(
      settingsSidebarColor: Color.lerp(settingsSidebarColor, other.settingsSidebarColor, t)!,
      overlayColor: Color.lerp(overlayColor, other.overlayColor, t)!,
    );
  }
} 