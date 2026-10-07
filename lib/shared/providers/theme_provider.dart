import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/di/injection.dart';

/// Manages the theme mode, persisting to SharedPreferences.
class ThemeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences _prefs;
  static const _key = 'theme_mode';

  ThemeNotifier({required SharedPreferences prefs})
      : _prefs = prefs,
        super(ThemeMode.system) {
    final stored = _prefs.getString(_key);
    if (stored != null) {
      state = _fromString(stored);
    }
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
    _prefs.setString(_key, _toString(mode));
  }

  static ThemeMode _fromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static String _toString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier(prefs: getIt<SharedPreferences>());
});
