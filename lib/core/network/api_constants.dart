class ApiConstants {
  // Base URL - Change this based on environment
  static const String baseUrl = 'http://localhost:8080';

  // API Version
  static const String apiVersion = '/api';

  // Authentication Endpoints
  static const String register = '$apiVersion/auth/register';
  static const String login = '$apiVersion/auth/login';
  static const String refresh = '$apiVersion/auth/refresh';
  static const String me = '$apiVersion/auth/me';
  static const String forgotPassword = '$apiVersion/auth/forgot-password';
  static const String resetPassword = '$apiVersion/auth/reset-password';

  // Budget Endpoints
  static const String budgets = '$apiVersion/budgets';
  static String budgetById(String id) => '$budgets/$id';
  static String budgetMembers(String id) => '$budgets/$id/members';

  // Account Endpoints
  static String budgetAccounts(String budgetId) => '$apiVersion/budgets/$budgetId/accounts';
  static String accountById(String id) => '$apiVersion/accounts/$id';
  static const String accountTransfer = '$apiVersion/accounts/transfer';

  // Category Endpoints
  static String budgetCategories(String budgetId) => '$apiVersion/budgets/$budgetId/categories';
  static String categoryById(String id) => '$apiVersion/categories/$id';

  // Transaction Endpoints
  static String budgetTransactions(String budgetId) => '$apiVersion/budgets/$budgetId/transactions';
  static String transactionById(String id) => '$apiVersion/transactions/$id';
  static const String transactionBatch = '$apiVersion/transactions/batch';

  // Credit Card Endpoints
  static String budgetCards(String budgetId) => '$apiVersion/budgets/$budgetId/cards';
  static String cardById(String id) => '$apiVersion/cards/$id';
  static String cardStatements(String id) => '$apiVersion/cards/$id/statements';

  // Import Endpoints
  static const String importUpload = '$apiVersion/import/upload';
  static const String importParse = '$apiVersion/import/parse';
  static const String importValidate = '$apiVersion/import/validate';
  static const String importCommit = '$apiVersion/import/commit';

  // Sync Endpoints
  static const String syncChanges = '$apiVersion/sync/changes';
  static const String syncPush = '$apiVersion/sync/push';
  static const String syncPull = '$apiVersion/sync/pull';

  // Report Endpoints
  static const String reportDashboard = '$apiVersion/reports/dashboard';
  static const String reportCategories = '$apiVersion/reports/categories';
  static const String reportCashflow = '$apiVersion/reports/cashflow';

  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
}
