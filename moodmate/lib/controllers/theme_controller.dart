import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moodmate/models/colors.dart';

class ThemeController extends ChangeNotifier {
  ThemeController(this._colors);

  AppColors _colors;
  AppColors get colors => _colors;

  static const _prefsKey = 'selected_theme_title';

  Future<void> setTheme(AppColors newColors) async {
    _colors = newColors;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, newColors.title);
  }

  static Future<ThemeController> load() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTitle = prefs.getString(_prefsKey);

    final theme = AppColors.byTitle(savedTitle) ?? AppColors.calmBlue;
    return ThemeController(theme);
  }
}
