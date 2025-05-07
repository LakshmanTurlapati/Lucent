import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  // Key for storing theme preference
  static const String _themePreferenceKey = 'theme_preference';
  
  // Theme mode - default to dark
  ThemeMode _themeMode = ThemeMode.dark;
  
  // Getter for current theme mode
  ThemeMode get themeMode => _themeMode;
  
  // Getter to check if dark mode is active
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  // Constructor loads saved preference
  ThemeProvider() {
    _loadThemePreference();
  }
  
  // Load theme preference from shared preferences
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool(_themePreferenceKey) ?? true; // Default to dark
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    } catch (e) {
      // Fallback to dark theme if something goes wrong
      _themeMode = ThemeMode.dark;
      print('Error loading theme preference: $e');
    }
  }
  
  // Save theme preference to shared preferences
  Future<void> _saveThemePreference(bool isDark) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themePreferenceKey, isDark);
    } catch (e) {
      print('Error saving theme preference: $e');
    }
  }
  
  // Toggle between light and dark themes
  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await _saveThemePreference(_themeMode == ThemeMode.dark);
    notifyListeners();
  }
  
  // Set specific theme
  Future<void> setTheme(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    await _saveThemePreference(_themeMode == ThemeMode.dark);
    notifyListeners();
  }
} 