import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();

    final savedTheme = prefs.getString(_themeKey);

    if (savedTheme == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }

    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;

    notifyListeners();

    await _saveTheme();
  }

  Future<void> setLightMode() async {
    _themeMode = ThemeMode.light;

    notifyListeners();

    await _saveTheme();
  }

  Future<void> setDarkMode() async {
    _themeMode = ThemeMode.dark;

    notifyListeners();

    await _saveTheme();
  }

  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _themeKey,
      _themeMode == ThemeMode.dark ? 'dark' : 'light',
    );
  }
}
