class AppConstants {
  // App Info
  static const String appName = 'FinTogether';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyUserEmail = 'user_email';
  static const String keyUserName = 'user_name';
  static const String keyLocale = 'locale';
  static const String keyThemeMode = 'theme_mode';
  static const String keySelectedBudgetId = 'selected_budget_id';

  // Database
  static const String databaseName = 'fintogether.db';
  static const int databaseVersion = 1;

  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 255;

  // Pagination
  static const int defaultPageSize = 20;

  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String displayDateFormat = 'dd/MM/yyyy';
  static const String displayDateTimeFormat = 'dd/MM/yyyy HH:mm';

  // Currency
  static const String defaultCurrency = 'BRL';
  static const String defaultLocale = 'pt-BR';

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
}
