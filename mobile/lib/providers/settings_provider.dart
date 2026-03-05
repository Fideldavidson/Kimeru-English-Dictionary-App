import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  static const String _themeKey = 'is_dark_mode';
  static const String _fontSizeKey = 'font_size_multiplier';

  bool _isDarkMode = false;
  double _fontSizeMultiplier = 1.0;

  bool get isDarkMode => _isDarkMode;
  double get fontSizeMultiplier => _fontSizeMultiplier;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_themeKey) ?? false;
    _fontSizeMultiplier = prefs.getDouble(_fontSizeKey) ?? 1.0;
    notifyListeners();
  }

  Future<void> toggleTheme(bool value) async {
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, value);
    notifyListeners();
  }

  Future<void> setFontSizeMultiplier(double value) async {
    _fontSizeMultiplier = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, value);
    notifyListeners();
  }
}
