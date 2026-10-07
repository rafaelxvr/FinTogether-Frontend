import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/di/injection.dart';

/// Manages the app locale, persisting to SharedPreferences.
class LocaleNotifier extends StateNotifier<Locale> {
  final SharedPreferences _prefs;
  static const _key = 'app_locale';

  LocaleNotifier({required SharedPreferences prefs})
      : _prefs = prefs,
        super(const Locale('pt')) {
    final stored = _prefs.getString(_key);
    if (stored != null) {
      state = Locale(stored);
    }
  }

  void setLocale(Locale locale) {
    state = locale;
    _prefs.setString(_key, locale.languageCode);
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier(prefs: getIt<SharedPreferences>());
});
