import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/app_database.dart';
import '../database/datasources/pending_sync_local_datasource.dart';
import '../notifications/notification_initializer.dart';
import '../notifications/notification_permission_handler.dart';
import '../notifications/notification_service.dart';
import '../database/datasources/sync_log_local_datasource.dart';
import '../sync/connectivity_monitor.dart';
import '../sync/sync_manager.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/datasources/user_local_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/forgot_password_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/reset_password_usecase.dart';
import '../../features/budget/data/datasources/budget_local_datasource.dart';
import '../../features/budget/data/datasources/budget_member_local_datasource.dart';
import '../../features/budget/data/datasources/budget_remote_datasource.dart';
import '../../features/budget/data/repositories/budget_repository_impl.dart';
import '../../features/budget/domain/repositories/budget_repository.dart';
import '../../features/budget/domain/usecases/add_budget_member_usecase.dart';
import '../../features/budget/domain/usecases/create_budget_usecase.dart';
import '../../features/budget/domain/usecases/delete_budget_usecase.dart';
import '../../features/budget/domain/usecases/get_budget_members_usecase.dart';
import '../../features/budget/domain/usecases/get_budgets_usecase.dart';
import '../../features/budget/domain/usecases/remove_budget_member_usecase.dart';
import '../../features/budget/domain/usecases/update_budget_usecase.dart';
import '../../features/account/data/datasources/account_local_datasource.dart';
import '../../features/account/data/datasources/account_remote_datasource.dart';
import '../../features/account/data/repositories/account_repository_impl.dart';
import '../../features/account/domain/repositories/account_repository.dart';
import '../../features/account/domain/usecases/create_account_usecase.dart';
import '../../features/account/domain/usecases/delete_account_usecase.dart';
import '../../features/account/domain/usecases/get_account_by_id_usecase.dart';
import '../../features/account/domain/usecases/get_accounts_usecase.dart';
import '../../features/account/domain/usecases/toggle_account_status_usecase.dart';
import '../../features/account/domain/usecases/transfer_usecase.dart';
import '../../features/account/domain/usecases/update_account_usecase.dart';
import '../../features/category/data/datasources/category_local_datasource.dart';
import '../../features/category/data/datasources/category_remote_datasource.dart';
import '../../features/category/data/repositories/category_repository_impl.dart';
import '../../features/category/domain/repositories/category_repository.dart';
import '../../features/category/domain/usecases/archive_category_usecase.dart';
import '../../features/category/domain/usecases/create_category_usecase.dart';
import '../../features/category/domain/usecases/delete_category_usecase.dart';
import '../../features/category/domain/usecases/get_categories_usecase.dart';
import '../../features/category/domain/usecases/get_category_by_id_usecase.dart';
import '../../features/category/domain/usecases/get_root_categories_usecase.dart';
import '../../features/category/domain/usecases/unarchive_category_usecase.dart';
import '../../features/category/domain/usecases/update_category_usecase.dart';
import '../../features/transaction/data/datasources/transaction_local_datasource.dart';
import '../../features/transaction/data/datasources/transaction_remote_datasource.dart';
import '../../features/transaction/data/datasources/installment_group_local_datasource.dart';
import '../../features/transaction/data/repositories/transaction_repository_impl.dart';
import '../../features/transaction/data/repositories/installment_group_repository_impl.dart';
import '../../features/transaction/domain/repositories/transaction_repository.dart';
import '../../features/transaction/domain/repositories/installment_group_repository.dart';
import '../../features/transaction/domain/usecases/create_transaction_usecase.dart';
import '../../features/transaction/domain/usecases/delete_transaction_usecase.dart';
import '../../features/transaction/domain/usecases/get_transaction_by_id_usecase.dart';
import '../../features/transaction/domain/usecases/get_transactions_usecase.dart';
import '../../features/transaction/domain/usecases/search_transactions_usecase.dart';
import '../../features/transaction/domain/usecases/update_transaction_usecase.dart';
import '../../features/transaction/domain/usecases/create_installment_group_usecase.dart';
import '../../features/transaction/domain/usecases/delete_installment_group_usecase.dart';
import '../../features/transaction/domain/usecases/get_installment_groups_usecase.dart';
import '../../features/transaction/domain/usecases/get_installment_progress_usecase.dart';
import '../../features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/dashboard/domain/usecases/get_cashflow_trend_usecase.dart';
import '../../features/dashboard/domain/usecases/get_dashboard_summary_usecase.dart';
import '../../features/dashboard/domain/usecases/get_essential_breakdown_usecase.dart';
import '../../features/dashboard/domain/usecases/get_member_spending_usecase.dart';
import '../../features/dashboard/domain/usecases/get_expense_forecast_usecase.dart';
import '../../features/dashboard/domain/usecases/get_dashboard_alerts_usecase.dart';
import '../../features/dashboard/domain/usecases/get_income_by_member_usecase.dart';
import '../../features/credit_card/data/datasources/credit_card_local_datasource.dart';
import '../../features/credit_card/data/datasources/credit_card_remote_datasource.dart';
import '../../features/credit_card/data/repositories/credit_card_repository_impl.dart';
import '../../features/credit_card/domain/repositories/credit_card_repository.dart';
import '../../features/credit_card/domain/usecases/credit_card_usecases.dart';
import '../../features/credit_card/domain/usecases/credit_card_invoice_usecases.dart';
import '../../features/merchant/data/datasources/merchant_local_datasource.dart';
import '../../features/merchant/data/datasources/merchant_remote_datasource.dart';
import '../../features/merchant/data/repositories/merchant_repository_impl.dart';
import '../../features/merchant/domain/repositories/merchant_repository.dart';
import '../../features/merchant/domain/usecases/archive_merchant_usecase.dart';
import '../../features/merchant/domain/usecases/create_merchant_usecase.dart';
import '../../features/merchant/domain/usecases/delete_merchant_usecase.dart';
import '../../features/merchant/domain/usecases/get_merchant_by_id_usecase.dart';
import '../../features/merchant/domain/usecases/get_merchants_usecase.dart';
import '../../features/merchant/domain/usecases/get_top_merchants_usecase.dart';
import '../../features/merchant/domain/usecases/search_merchants_usecase.dart';
import '../../features/merchant/domain/usecases/unarchive_merchant_usecase.dart';
import '../../features/merchant/domain/usecases/update_merchant_usecase.dart';
import '../../features/recurring/data/datasources/recurring_transaction_remote_datasource.dart';
import '../../features/recurring/data/repositories/recurring_transaction_repository_impl.dart';
import '../../features/recurring/domain/repositories/recurring_transaction_repository.dart';
import '../../features/recurring/domain/usecases/create_recurring_template_usecase.dart';
import '../../features/recurring/domain/usecases/deactivate_recurring_template_usecase.dart';
import '../../features/recurring/domain/usecases/delete_recurring_template_usecase.dart';
import '../../features/recurring/domain/usecases/get_fixed_expense_summary_usecase.dart';
import '../../features/recurring/domain/usecases/get_recurring_templates_usecase.dart';
import '../../features/recurring/domain/usecases/update_recurring_template_usecase.dart';
import '../../features/budget_allocation/data/datasources/budget_allocation_remote_datasource.dart';
import '../../features/budget_allocation/data/repositories/budget_allocation_repository_impl.dart';
import '../../features/budget_allocation/domain/repositories/budget_allocation_repository.dart';
import '../../features/budget_allocation/domain/usecases/get_allocations_usecase.dart';
import '../../features/budget_allocation/domain/usecases/set_allocations_usecase.dart';
// mark_invoice_paid_usecase and get_payment_suggestion_usecase
// will be added when Feature #20 (Invoice Payment Tracking) is completed
import '../../features/savings_goal/data/datasources/savings_goal_local_datasource.dart';
import '../../features/savings_goal/data/datasources/savings_goal_remote_datasource.dart';
import '../../features/savings_goal/data/repositories/savings_goal_repository_impl.dart';
import '../../features/savings_goal/domain/repositories/savings_goal_repository.dart';
import '../../features/savings_goal/domain/usecases/create_savings_goal_usecase.dart';
import '../../features/savings_goal/domain/usecases/contribute_to_savings_goal_usecase.dart';
import '../../features/savings_goal/domain/usecases/delete_savings_goal_usecase.dart';
import '../../features/savings_goal/domain/usecases/get_contributions_usecase.dart';
import '../../features/savings_goal/domain/usecases/get_savings_goal_by_id_usecase.dart';
import '../../features/savings_goal/domain/usecases/get_savings_goals_usecase.dart';
import '../../features/savings_goal/domain/usecases/update_savings_goal_usecase.dart';
import '../../features/savings_goal/domain/usecases/withdraw_from_savings_goal_usecase.dart';
import '../../features/transaction/data/datasources/transaction_template_local_datasource.dart';
import '../network/dio_client.dart';

final getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  FlutterSecureStorage? secureStorage;
  if (!kIsWeb) {
    secureStorage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );
    getIt.registerSingleton<FlutterSecureStorage>(secureStorage);
  }

  // Network
  getIt.registerSingleton<DioClient>(
    DioClient(
      secureStorage: secureStorage,
      sharedPreferences: sharedPreferences,
    ),
  );

  // Database
  final database = await AppDatabase.create();
  getIt.registerSingleton<AppDatabase>(database);

  // Local datasources
  getIt.registerLazySingleton(() => PendingSyncLocalDataSource(getIt<AppDatabase>()));
  getIt.registerLazySingleton(() => SyncLogLocalDataSource(getIt<AppDatabase>()));
  getIt.registerLazySingleton(() => UserLocalDataSource(getIt<AppDatabase>()));
  getIt.registerLazySingleton(() => BudgetLocalDataSource(getIt<AppDatabase>()));
  getIt.registerLazySingleton(() => BudgetMemberLocalDataSource(getIt<AppDatabase>()));
  getIt.registerLazySingleton(() => AccountLocalDataSource(getIt<AppDatabase>()));
  getIt.registerLazySingleton(() => CategoryLocalDataSource(getIt<AppDatabase>()));
  getIt.registerLazySingleton(() => CreditCardLocalDataSource(getIt<AppDatabase>()));
  getIt.registerLazySingleton(() => TransactionLocalDataSource(getIt<AppDatabase>()));
  getIt.registerLazySingleton(() => InstallmentGroupLocalDataSource(getIt<AppDatabase>()));
  getIt.registerLazySingleton(() => MerchantLocalDataSource(getIt<AppDatabase>()));
  getIt.registerLazySingleton(() => SavingsGoalLocalDataSource(getIt<AppDatabase>()));

  // Transaction template (local only)
  getIt.registerLazySingleton(() => TransactionTemplateLocalDatasource(
    prefs: getIt<SharedPreferences>(),
  ));

  // Sync
  getIt.registerLazySingleton(() => ConnectivityMonitor());

  // Register auth feature
  await _registerAuthFeature();

  // Register budget feature
  await _registerBudgetFeature();

  // Register account feature
  await _registerAccountFeature();

  // Register category feature
  await _registerCategoryFeature();

  // Register transaction feature
  await _registerTransactionFeature();

  // Register dashboard feature
  await _registerDashboardFeature();

  // Register credit card feature
  await _registerCreditCardFeature();

  // Register savings goal feature
  await _registerSavingsGoalFeature();

  // Register merchant feature
  await _registerMerchantFeature();

  // Register recurring feature
  await _registerRecurringFeature();

  // Register budget allocation feature
  await _registerBudgetAllocationFeature();

  // SyncManager (after all features are registered)
  getIt.registerLazySingleton(() => SyncManager(
    pendingSyncDataSource: getIt<PendingSyncLocalDataSource>(),
    syncLogDataSource: getIt<SyncLogLocalDataSource>(),
    connectivityMonitor: getIt<ConnectivityMonitor>(),
    userLocalDataSource: getIt<UserLocalDataSource>(),
    budgetLocalDataSource: getIt<BudgetLocalDataSource>(),
    budgetMemberLocalDataSource: getIt<BudgetMemberLocalDataSource>(),
    accountLocalDataSource: getIt<AccountLocalDataSource>(),
    categoryLocalDataSource: getIt<CategoryLocalDataSource>(),
    creditCardLocalDataSource: getIt<CreditCardLocalDataSource>(),
    transactionLocalDataSource: getIt<TransactionLocalDataSource>(),
    installmentGroupLocalDataSource: getIt<InstallmentGroupLocalDataSource>(),
    accountRemoteDataSource: getIt<AccountRemoteDataSource>(),
    budgetRemoteDataSource: getIt<BudgetRemoteDataSource>(),
    categoryRemoteDataSource: getIt<CategoryRemoteDataSource>(),
    creditCardRemoteDataSource: getIt<CreditCardRemoteDataSource>(),
    transactionRemoteDataSource: getIt<TransactionRemoteDataSource>(),
  ));

  // Register notification feature (not supported on web)
  if (!kIsWeb) {
    await _registerNotificationFeature();
  }
}

Future<void> _registerNotificationFeature() async {
  getIt.registerLazySingleton(() => FlutterLocalNotificationsPlugin());

  getIt.registerLazySingleton(() => NotificationInitializer(
        getIt<FlutterLocalNotificationsPlugin>(),
      ));

  getIt.registerLazySingleton(() => NotificationPermissionHandler(
        getIt<FlutterLocalNotificationsPlugin>(),
      ));

  getIt.registerLazySingleton(() => NotificationService(
        plugin: getIt<FlutterLocalNotificationsPlugin>(),
        prefs: getIt<SharedPreferences>(),
        creditCardLocalDataSource: getIt<CreditCardLocalDataSource>(),
        transactionLocalDataSource: getIt<TransactionLocalDataSource>(),
        savingsGoalLocalDataSource: getIt<SavingsGoalLocalDataSource>(),
      ));
}

Future<void> _registerAuthFeature() async {
  // Data sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(getIt<DioClient>().dio),
  );

  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSource(
      secureStorage: kIsWeb ? null : getIt<FlutterSecureStorage>(),
      sharedPreferences: getIt<SharedPreferences>(),
    ),
  );

  // Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      localDataSource: getIt<AuthLocalDataSource>(),
      userLocalDataSource: getIt<UserLocalDataSource>(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton(() => LoginUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => RegisterUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => LogoutUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => GetCurrentUserUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => ForgotPasswordUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => ResetPasswordUseCase(getIt<AuthRepository>()));
}

Future<void> _registerBudgetFeature() async {
  // Data sources
  getIt.registerLazySingleton<BudgetRemoteDataSource>(
    () => BudgetRemoteDataSource(getIt<DioClient>().dio),
  );

  // Repository
  getIt.registerLazySingleton<BudgetRepository>(
    () => BudgetRepositoryImpl(
      remoteDataSource: getIt<BudgetRemoteDataSource>(),
      localDataSource: getIt<BudgetLocalDataSource>(),
      budgetMemberLocalDataSource: getIt<BudgetMemberLocalDataSource>(),
      pendingSyncDataSource: getIt<PendingSyncLocalDataSource>(),
      connectivityMonitor: getIt<ConnectivityMonitor>(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton(() => GetBudgetsUseCase(getIt<BudgetRepository>()));
  getIt.registerLazySingleton(() => CreateBudgetUseCase(getIt<BudgetRepository>()));
  getIt.registerLazySingleton(() => UpdateBudgetUseCase(getIt<BudgetRepository>()));
  getIt.registerLazySingleton(() => DeleteBudgetUseCase(getIt<BudgetRepository>()));
  getIt.registerLazySingleton(() => GetBudgetMembersUseCase(getIt<BudgetRepository>()));
  getIt.registerLazySingleton(() => AddBudgetMemberUseCase(getIt<BudgetRepository>()));
  getIt.registerLazySingleton(() => RemoveBudgetMemberUseCase(getIt<BudgetRepository>()));
}

Future<void> _registerAccountFeature() async {
  // Data sources
  getIt.registerLazySingleton<AccountRemoteDataSource>(
    () => AccountRemoteDataSource(getIt<DioClient>().dio),
  );

  // Repository
  getIt.registerLazySingleton<AccountRepository>(
    () => AccountRepositoryImpl(
      remoteDataSource: getIt<AccountRemoteDataSource>(),
      localDataSource: getIt<AccountLocalDataSource>(),
      pendingSyncDataSource: getIt<PendingSyncLocalDataSource>(),
      connectivityMonitor: getIt<ConnectivityMonitor>(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton(() => GetAccountsUseCase(getIt<AccountRepository>()));
  getIt.registerLazySingleton(() => GetAccountByIdUseCase(getIt<AccountRepository>()));
  getIt.registerLazySingleton(() => CreateAccountUseCase(getIt<AccountRepository>()));
  getIt.registerLazySingleton(() => UpdateAccountUseCase(getIt<AccountRepository>()));
  getIt.registerLazySingleton(() => DeleteAccountUseCase(getIt<AccountRepository>()));
  getIt.registerLazySingleton(() => TransferUseCase(getIt<AccountRepository>()));
  getIt.registerLazySingleton(() => ToggleAccountStatusUseCase(getIt<AccountRepository>()));
}

Future<void> _registerCategoryFeature() async {
  // Data sources
  getIt.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSource(getIt<DioClient>().dio),
  );

  // Repository
  getIt.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(
      remoteDataSource: getIt<CategoryRemoteDataSource>(),
      localDataSource: getIt<CategoryLocalDataSource>(),
      pendingSyncDataSource: getIt<PendingSyncLocalDataSource>(),
      connectivityMonitor: getIt<ConnectivityMonitor>(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton(() => GetCategoriesUseCase(getIt<CategoryRepository>()));
  getIt.registerLazySingleton(() => GetRootCategoriesUseCase(getIt<CategoryRepository>()));
  getIt.registerLazySingleton(() => GetCategoryByIdUseCase(getIt<CategoryRepository>()));
  getIt.registerLazySingleton(() => CreateCategoryUseCase(getIt<CategoryRepository>()));
  getIt.registerLazySingleton(() => UpdateCategoryUseCase(getIt<CategoryRepository>()));
  getIt.registerLazySingleton(() => DeleteCategoryUseCase(getIt<CategoryRepository>()));
  getIt.registerLazySingleton(() => ArchiveCategoryUseCase(getIt<CategoryRepository>()));
  getIt.registerLazySingleton(() => UnarchiveCategoryUseCase(getIt<CategoryRepository>()));
}

Future<void> _registerTransactionFeature() async {
  // Data sources
  getIt.registerLazySingleton<TransactionRemoteDataSource>(
    () => TransactionRemoteDataSource(getIt<DioClient>().dio),
  );
  getIt.registerLazySingleton<TransactionSearchRemoteDataSource>(
    () => TransactionSearchRemoteDataSource(getIt<DioClient>().dio),
  );

  // Repository
  getIt.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(
      remoteDataSource: getIt<TransactionRemoteDataSource>(),
      searchRemoteDataSource: getIt<TransactionSearchRemoteDataSource>(),
      localDataSource: getIt<TransactionLocalDataSource>(),
      pendingSyncDataSource: getIt<PendingSyncLocalDataSource>(),
      connectivityMonitor: getIt<ConnectivityMonitor>(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton(() => GetTransactionsUseCase(getIt<TransactionRepository>()));
  getIt.registerLazySingleton(() => GetTransactionByIdUseCase(getIt<TransactionRepository>()));
  getIt.registerLazySingleton(() => CreateTransactionUseCase(getIt<TransactionRepository>()));
  getIt.registerLazySingleton(() => UpdateTransactionUseCase(getIt<TransactionRepository>()));
  getIt.registerLazySingleton(() => DeleteTransactionUseCase(getIt<TransactionRepository>()));
  getIt.registerLazySingleton(() => SearchTransactionsUseCase(getIt<TransactionRepository>()));

  // Register installment feature
  await _registerInstallmentFeature();
}

Future<void> _registerInstallmentFeature() async {
  // Repository
  getIt.registerLazySingleton<InstallmentGroupRepository>(
    () => InstallmentGroupRepositoryImpl(
      localDataSource: getIt<InstallmentGroupLocalDataSource>(),
      transactionLocalDataSource: getIt<TransactionLocalDataSource>(),
      pendingSyncDataSource: getIt<PendingSyncLocalDataSource>(),
      connectivityMonitor: getIt<ConnectivityMonitor>(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton(() => CreateInstallmentGroupUseCase(getIt<InstallmentGroupRepository>()));
  getIt.registerLazySingleton(() => GetInstallmentGroupsUseCase(getIt<InstallmentGroupRepository>()));
  getIt.registerLazySingleton(() => GetInstallmentProgressUseCase(getIt<InstallmentGroupRepository>()));
  getIt.registerLazySingleton(() => DeleteInstallmentGroupUseCase(getIt<InstallmentGroupRepository>()));
}

Future<void> _registerDashboardFeature() async {
  // Data sources
  getIt.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSource(getIt<DioClient>().dio),
  );

  // Repository
  getIt.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(
      remoteDataSource: getIt<DashboardRemoteDataSource>(),
      accountLocalDataSource: getIt<AccountLocalDataSource>(),
      transactionLocalDataSource: getIt<TransactionLocalDataSource>(),
      connectivityMonitor: getIt<ConnectivityMonitor>(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton(() => GetDashboardSummaryUseCase(getIt<DashboardRepository>()));
  getIt.registerLazySingleton(() => GetCashflowTrendUseCase(getIt<DashboardRepository>()));
  getIt.registerLazySingleton(() => GetEssentialBreakdownUseCase(getIt<DashboardRepository>()));
  getIt.registerLazySingleton(() => GetMemberSpendingUseCase(getIt<DashboardRepository>()));
  getIt.registerLazySingleton(() => GetExpenseForecastUseCase(getIt<DashboardRepository>()));
  getIt.registerLazySingleton(() => GetDashboardAlertsUseCase(getIt<DashboardRepository>()));
  getIt.registerLazySingleton(() => GetIncomeByMemberUseCase(getIt<DashboardRepository>()));
}

Future<void> _registerCreditCardFeature() async {
  // Data sources
  getIt.registerLazySingleton<CreditCardRemoteDataSource>(
    () => CreditCardRemoteDataSource(getIt<DioClient>().dio),
  );

  // Repository
  getIt.registerLazySingleton<CreditCardRepository>(
    () => CreditCardRepositoryImpl(
      remoteDataSource: getIt<CreditCardRemoteDataSource>(),
      localDataSource: getIt<CreditCardLocalDataSource>(),
      pendingSyncDataSource: getIt<PendingSyncLocalDataSource>(),
      connectivityMonitor: getIt<ConnectivityMonitor>(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton(() => GetCreditCardsUseCase(getIt<CreditCardRepository>()));
  getIt.registerLazySingleton(() => CreateCreditCardUseCase(getIt<CreditCardRepository>()));
  getIt.registerLazySingleton(() => UpdateCreditCardUseCase(getIt<CreditCardRepository>()));
  getIt.registerLazySingleton(() => DeleteCreditCardUseCase(getIt<CreditCardRepository>()));
  getIt.registerLazySingleton(() => ToggleCreditCardStatusUseCase(getIt<CreditCardRepository>()));

  // Invoice use cases
  getIt.registerLazySingleton(() => GetCreditCardInvoiceUseCase(getIt<CreditCardRepository>()));
  getIt.registerLazySingleton(() => GetInvoiceSummariesUseCase(getIt<CreditCardRepository>()));
}

Future<void> _registerMerchantFeature() async {
  // Data sources
  getIt.registerLazySingleton<MerchantRemoteDataSource>(
    () => MerchantRemoteDataSource(getIt<DioClient>().dio),
  );

  // Repository
  getIt.registerLazySingleton<MerchantRepository>(
    () => MerchantRepositoryImpl(
      remoteDataSource: getIt<MerchantRemoteDataSource>(),
      localDataSource: getIt<MerchantLocalDataSource>(),
      pendingSyncDataSource: getIt<PendingSyncLocalDataSource>(),
      connectivityMonitor: getIt<ConnectivityMonitor>(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton(() => GetMerchantsUseCase(getIt<MerchantRepository>()));
  getIt.registerLazySingleton(() => GetMerchantByIdUseCase(getIt<MerchantRepository>()));
  getIt.registerLazySingleton(() => SearchMerchantsUseCase(getIt<MerchantRepository>()));
  getIt.registerLazySingleton(() => CreateMerchantUseCase(getIt<MerchantRepository>()));
  getIt.registerLazySingleton(() => UpdateMerchantUseCase(getIt<MerchantRepository>()));
  getIt.registerLazySingleton(() => DeleteMerchantUseCase(getIt<MerchantRepository>()));
  getIt.registerLazySingleton(() => ArchiveMerchantUseCase(getIt<MerchantRepository>()));
  getIt.registerLazySingleton(() => UnarchiveMerchantUseCase(getIt<MerchantRepository>()));
  getIt.registerLazySingleton(() => GetTopMerchantsUseCase(getIt<MerchantRepository>()));
}

Future<void> _registerRecurringFeature() async {
  // Data sources
  getIt.registerLazySingleton<RecurringTransactionRemoteDataSource>(
    () => RecurringTransactionRemoteDataSource(getIt<DioClient>().dio),
  );

  // Repository
  getIt.registerLazySingleton<RecurringTransactionRepository>(
    () => RecurringTransactionRepositoryImpl(
      remoteDataSource: getIt<RecurringTransactionRemoteDataSource>(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton(() => GetRecurringTemplatesUseCase(getIt<RecurringTransactionRepository>()));
  getIt.registerLazySingleton(() => CreateRecurringTemplateUseCase(getIt<RecurringTransactionRepository>()));
  getIt.registerLazySingleton(() => UpdateRecurringTemplateUseCase(getIt<RecurringTransactionRepository>()));
  getIt.registerLazySingleton(() => DeactivateRecurringTemplateUseCase(getIt<RecurringTransactionRepository>()));
  getIt.registerLazySingleton(() => DeleteRecurringTemplateUseCase(getIt<RecurringTransactionRepository>()));
  getIt.registerLazySingleton(() => GetFixedExpenseSummaryUseCase(getIt<RecurringTransactionRepository>()));
}

Future<void> _registerSavingsGoalFeature() async {
  // Data sources
  getIt.registerLazySingleton<SavingsGoalRemoteDataSource>(
    () => SavingsGoalRemoteDataSource(getIt<DioClient>().dio),
  );

  // Repository
  getIt.registerLazySingleton<SavingsGoalRepository>(
    () => SavingsGoalRepositoryImpl(
      remoteDataSource: getIt<SavingsGoalRemoteDataSource>(),
      localDataSource: getIt<SavingsGoalLocalDataSource>(),
      pendingSyncDataSource: getIt<PendingSyncLocalDataSource>(),
      connectivityMonitor: getIt<ConnectivityMonitor>(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton(() => GetSavingsGoalsUseCase(getIt<SavingsGoalRepository>()));
  getIt.registerLazySingleton(() => GetSavingsGoalByIdUseCase(getIt<SavingsGoalRepository>()));
  getIt.registerLazySingleton(() => CreateSavingsGoalUseCase(getIt<SavingsGoalRepository>()));
  getIt.registerLazySingleton(() => UpdateSavingsGoalUseCase(getIt<SavingsGoalRepository>()));
  getIt.registerLazySingleton(() => DeleteSavingsGoalUseCase(getIt<SavingsGoalRepository>()));
  getIt.registerLazySingleton(() => ContributeToSavingsGoalUseCase(getIt<SavingsGoalRepository>()));
  getIt.registerLazySingleton(() => WithdrawFromSavingsGoalUseCase(getIt<SavingsGoalRepository>()));
  getIt.registerLazySingleton(() => GetContributionsUseCase(getIt<SavingsGoalRepository>()));
}

Future<void> _registerBudgetAllocationFeature() async {
  // Data sources
  getIt.registerLazySingleton<BudgetAllocationRemoteDataSource>(
    () => BudgetAllocationRemoteDataSource(getIt<DioClient>().dio),
  );

  // Repository
  getIt.registerLazySingleton<BudgetAllocationRepository>(
    () => BudgetAllocationRepositoryImpl(
      remoteDataSource: getIt<BudgetAllocationRemoteDataSource>(),
      connectivityMonitor: getIt<ConnectivityMonitor>(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton(() => GetAllocationsUseCase(getIt<BudgetAllocationRepository>()));
  getIt.registerLazySingleton(() => SetAllocationsUseCase(getIt<BudgetAllocationRepository>()));
}

// Helper to reset dependencies (for testing)
Future<void> resetDependencies() async {
  await getIt.reset();
}
