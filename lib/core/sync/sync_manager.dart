import 'dart:async';
import 'dart:convert';

import 'package:logger/logger.dart';

import '../database/app_database.dart';
import '../database/datasources/pending_sync_local_datasource.dart';
import '../database/datasources/sync_log_local_datasource.dart';
import '../../features/account/data/datasources/account_local_datasource.dart';
import '../../features/account/data/datasources/account_remote_datasource.dart';
import '../../features/budget/data/datasources/budget_local_datasource.dart';
import '../../features/budget/data/datasources/budget_remote_datasource.dart';
import '../../features/budget/data/datasources/budget_member_local_datasource.dart';
import '../../features/category/data/datasources/category_local_datasource.dart';
import '../../features/category/data/datasources/category_remote_datasource.dart';
import '../../features/credit_card/data/datasources/credit_card_local_datasource.dart';
import '../../features/credit_card/data/datasources/credit_card_remote_datasource.dart';
import '../../features/transaction/data/datasources/transaction_local_datasource.dart';
import '../../features/transaction/data/datasources/transaction_remote_datasource.dart';
import '../../features/transaction/data/datasources/installment_group_local_datasource.dart';
import '../../features/auth/data/datasources/user_local_datasource.dart';
import '../di/injection.dart';
import '../notifications/notification_service.dart';
import 'connectivity_monitor.dart';
import 'sync_model_registry.dart';

/// Orchestrates push/pull synchronization between local Drift DB and remote API.
///
/// Listens to connectivity changes and automatically triggers a full sync
/// when the device comes back online. Uses a mutex guard to prevent
/// concurrent sync operations.
class SyncManager {
  final PendingSyncLocalDataSource _pendingSyncDataSource;
  final SyncLogLocalDataSource _syncLogDataSource;
  final ConnectivityMonitor _connectivityMonitor;

  // Remote datasources
  final AccountRemoteDataSource _accountRemoteDataSource;
  final BudgetRemoteDataSource _budgetRemoteDataSource;
  final CategoryRemoteDataSource _categoryRemoteDataSource;
  final CreditCardRemoteDataSource _creditCardRemoteDataSource;
  final TransactionRemoteDataSource _transactionRemoteDataSource;

  // Local datasources
  final AccountLocalDataSource _accountLocalDataSource;
  final BudgetLocalDataSource _budgetLocalDataSource;
  final BudgetMemberLocalDataSource _budgetMemberLocalDataSource;
  final CategoryLocalDataSource _categoryLocalDataSource;
  final CreditCardLocalDataSource _creditCardLocalDataSource;
  final TransactionLocalDataSource _transactionLocalDataSource;
  final InstallmentGroupLocalDataSource _installmentGroupLocalDataSource;
  final UserLocalDataSource _userLocalDataSource;

  final Logger _logger = Logger();

  bool _isSyncing = false;
  StreamSubscription<bool>? _connectivitySubscription;

  final StreamController<List<PendingSync>> _failedItemsController =
      StreamController<List<PendingSync>>.broadcast();

  SyncManager({
    required PendingSyncLocalDataSource pendingSyncDataSource,
    required SyncLogLocalDataSource syncLogDataSource,
    required ConnectivityMonitor connectivityMonitor,
    required AccountRemoteDataSource accountRemoteDataSource,
    required BudgetRemoteDataSource budgetRemoteDataSource,
    required CategoryRemoteDataSource categoryRemoteDataSource,
    required CreditCardRemoteDataSource creditCardRemoteDataSource,
    required TransactionRemoteDataSource transactionRemoteDataSource,
    required AccountLocalDataSource accountLocalDataSource,
    required BudgetLocalDataSource budgetLocalDataSource,
    required BudgetMemberLocalDataSource budgetMemberLocalDataSource,
    required CategoryLocalDataSource categoryLocalDataSource,
    required CreditCardLocalDataSource creditCardLocalDataSource,
    required TransactionLocalDataSource transactionLocalDataSource,
    required InstallmentGroupLocalDataSource installmentGroupLocalDataSource,
    required UserLocalDataSource userLocalDataSource,
  })  : _pendingSyncDataSource = pendingSyncDataSource,
        _syncLogDataSource = syncLogDataSource,
        _connectivityMonitor = connectivityMonitor,
        _accountRemoteDataSource = accountRemoteDataSource,
        _budgetRemoteDataSource = budgetRemoteDataSource,
        _categoryRemoteDataSource = categoryRemoteDataSource,
        _creditCardRemoteDataSource = creditCardRemoteDataSource,
        _transactionRemoteDataSource = transactionRemoteDataSource,
        _accountLocalDataSource = accountLocalDataSource,
        _budgetLocalDataSource = budgetLocalDataSource,
        _budgetMemberLocalDataSource = budgetMemberLocalDataSource,
        _categoryLocalDataSource = categoryLocalDataSource,
        _creditCardLocalDataSource = creditCardLocalDataSource,
        _transactionLocalDataSource = transactionLocalDataSource,
        _installmentGroupLocalDataSource = installmentGroupLocalDataSource,
        _userLocalDataSource = userLocalDataSource {
    _startListening();
  }

  /// Stream of failed sync items, emitted after each sync attempt.
  Stream<List<PendingSync>> get failedItems => _failedItemsController.stream;

  /// Starts listening to connectivity changes. Triggers [syncAll] when
  /// the device transitions from offline to online.
  void _startListening() {
    _connectivitySubscription =
        _connectivityMonitor.onConnectivityChanged.listen((isOnline) {
      if (isOnline) {
        _logger.i('Device is back online — triggering syncAll');
        syncAll();
      }
    });
  }

  /// Runs a full push-then-pull sync cycle.
  ///
  /// Uses a mutex guard so that concurrent calls are silently ignored
  /// while a sync is already in progress.
  Future<void> syncAll() async {
    if (_isSyncing) {
      _logger.d('Sync already in progress — skipping');
      return;
    }

    _isSyncing = true;
    _logger.i('Starting full sync cycle');

    try {
      await _pushPendingChanges();
      await _pullLatestData();

      // Emit current failed items after sync
      final failed = await _pendingSyncDataSource.getFailedEntries();
      _failedItemsController.add(failed);

      _logger.i('Full sync cycle completed');

      // Reschedule notifications to reflect latest synced data
      try {
        await getIt<NotificationService>().rescheduleAll();
      } catch (e) {
        _logger.w('Failed to reschedule notifications after sync', error: e);
      }
    } catch (e, stackTrace) {
      _logger.e('Sync cycle failed', error: e, stackTrace: stackTrace);
    } finally {
      _isSyncing = false;
    }
  }

  /// Pushes all pending local changes to the remote API.
  ///
  /// Iterates through entity types in [SyncModelRegistry.pushOrder] for
  /// create/update operations, then [SyncModelRegistry.deleteOrder] for
  /// delete operations.
  Future<void> _pushPendingChanges() async {
    _logger.i('Push phase started');

    // Push creates and updates in dependency order
    for (final entityType in SyncModelRegistry.pushOrder) {
      final entries =
          await _pendingSyncDataSource.getEntriesByEntityType(entityType);
      final nonDeleteEntries =
          entries.where((e) => e.operation != 'delete').toList();

      for (final entry in nonDeleteEntries) {
        await _pushEntry(entry);
      }
    }

    // Push deletes in reverse dependency order
    for (final entityType in SyncModelRegistry.deleteOrder) {
      final entries =
          await _pendingSyncDataSource.getEntriesByEntityType(entityType);
      final deleteEntries =
          entries.where((e) => e.operation == 'delete').toList();

      for (final entry in deleteEntries) {
        await _pushEntry(entry);
      }
    }

    _logger.i('Push phase completed');
  }

  /// Dispatches a single pending sync entry to the appropriate remote
  /// datasource based on [entry.entityType] and [entry.operation].
  ///
  /// On success the entry is removed from the pending queue.
  /// On failure the retry count is incremented (auto-marks as failed
  /// after 5 retries).
  Future<void> _pushEntry(PendingSync entry) async {
    try {
      final payload = jsonDecode(entry.payload) as Map<String, dynamic>;
      final operation = entry.operation;
      final entityId = entry.entityId;

      switch (entry.entityType) {
        case 'account':
          await _pushAccount(operation, entityId, payload);
          break;
        case 'budget':
          await _pushBudget(operation, entityId, payload);
          break;
        case 'budget_member':
          await _pushBudgetMember(operation, entityId, payload);
          break;
        case 'category':
          await _pushCategory(operation, entityId, payload);
          break;
        case 'credit_card':
          await _pushCreditCard(operation, entityId, payload);
          break;
        case 'transaction':
          await _pushTransaction(operation, entityId, payload);
          break;
        default:
          // For entity types without direct remote support (e.g. user,
          // installment_group), remove the pending entry best-effort.
          _logger.w(
            'No remote handler for entity type "${entry.entityType}" '
            '— removing pending entry',
          );
          break;
      }

      await _pendingSyncDataSource.deleteEntry(entry.id);
      _logger.d(
        'Pushed ${entry.entityType}/${entry.entityId} '
        '(${entry.operation}) successfully',
      );
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to push ${entry.entityType}/${entry.entityId} '
        '(${entry.operation})',
        error: e,
        stackTrace: stackTrace,
      );
      await _pendingSyncDataSource.incrementRetryCount(entry.id);
    }
  }

  Future<void> _pushAccount(
    String operation,
    String entityId,
    Map<String, dynamic> payload,
  ) async {
    switch (operation) {
      case 'create':
        final budgetId = payload['budgetId'] as String? ??
            payload['budget_id'] as String;
        await _accountRemoteDataSource.createAccount(budgetId, payload);
        break;
      case 'update':
        await _accountRemoteDataSource.updateAccount(entityId, payload);
        break;
      case 'delete':
        await _accountRemoteDataSource.deleteAccount(entityId);
        break;
    }
  }

  Future<void> _pushBudget(
    String operation,
    String entityId,
    Map<String, dynamic> payload,
  ) async {
    switch (operation) {
      case 'create':
        await _budgetRemoteDataSource.createBudget(payload);
        break;
      case 'update':
        await _budgetRemoteDataSource.updateBudget(entityId, payload);
        break;
      case 'delete':
        await _budgetRemoteDataSource.deleteBudget(entityId);
        break;
    }
  }

  Future<void> _pushBudgetMember(
    String operation,
    String entityId,
    Map<String, dynamic> payload,
  ) async {
    final budgetId = payload['budgetId'] as String? ??
        payload['budget_id'] as String;

    switch (operation) {
      case 'create':
        await _budgetRemoteDataSource.addBudgetMember(budgetId, payload);
        break;
      case 'delete':
        await _budgetRemoteDataSource.removeBudgetMember(
          budgetId,
          entityId,
        );
        break;
      // Budget members typically don't support update — treat as no-op
    }
  }

  Future<void> _pushCategory(
    String operation,
    String entityId,
    Map<String, dynamic> payload,
  ) async {
    switch (operation) {
      case 'create':
        final budgetId = payload['budgetId'] as String? ??
            payload['budget_id'] as String;
        await _categoryRemoteDataSource.createCategory(budgetId, payload);
        break;
      case 'update':
        await _categoryRemoteDataSource.updateCategory(entityId, payload);
        break;
      case 'delete':
        await _categoryRemoteDataSource.deleteCategory(entityId);
        break;
    }
  }

  Future<void> _pushCreditCard(
    String operation,
    String entityId,
    Map<String, dynamic> payload,
  ) async {
    switch (operation) {
      case 'create':
        await _creditCardRemoteDataSource.createCreditCard(payload);
        break;
      case 'update':
        await _creditCardRemoteDataSource.updateCreditCard(entityId, payload);
        break;
      case 'delete':
        await _creditCardRemoteDataSource.deleteCreditCard(entityId);
        break;
    }
  }

  Future<void> _pushTransaction(
    String operation,
    String entityId,
    Map<String, dynamic> payload,
  ) async {
    switch (operation) {
      case 'create':
        final budgetId = payload['budgetId'] as String? ??
            payload['budget_id'] as String;
        await _transactionRemoteDataSource.createTransaction(
          budgetId,
          payload,
        );
        break;
      case 'update':
        await _transactionRemoteDataSource.updateTransaction(
          entityId,
          payload,
        );
        break;
      case 'delete':
        await _transactionRemoteDataSource.deleteTransaction(entityId);
        break;
    }
  }

  // ---------------------------------------------------------------------------
  // Pull phase
  // ---------------------------------------------------------------------------

  /// Pulls latest data from the remote API into the local database.
  ///
  /// Iterates entity types in dependency order. For each type, reads the last
  /// sync timestamp from [SyncLog], fetches records updated since that
  /// timestamp, upserts into local DB, and updates the sync log on success.
  /// Each entity type is pulled independently so failures do not block others.
  Future<void> _pullLatestData() async {
    _logger.i('Pull phase started');

    // Step 1: Pull budgets first (no budget context needed)
    await _pullBudgets();

    // Step 2: Get all local budgets to know which budgets to pull for
    final budgets = await _budgetLocalDataSource.getBudgets();
    final budgetIds = budgets.map((b) => b.id).toList();

    if (budgetIds.isEmpty) {
      _logger.i('No budgets found locally — skipping entity pulls');
      _logger.i('Pull phase completed');
      return;
    }

    // Step 3: Pull budget-scoped entities in dependency order
    for (final budgetId in budgetIds) {
      await _pullBudgetMembers(budgetId);
      await _pullAccounts(budgetId);
      await _pullCategories(budgetId);
      await _pullCreditCards(budgetId);
      await _pullTransactions(budgetId);
    }

    _logger.i('Pull phase completed');
  }

  Future<void> _pullBudgets() async {
    const entityType = 'budget';
    try {
      final lastSynced = await _syncLogDataSource.getLastSyncedAt(entityType);
      final updatedSince = lastSynced?.toUtc().toIso8601String();
      final syncStart = DateTime.now().toUtc();

      final response = await _budgetRemoteDataSource.getBudgets(updatedSince);
      final budgets = response.data ?? [];

      for (final budget in budgets) {
        if (budget.deletedAt != null) {
          await _budgetLocalDataSource.hardDelete(budget.id);
        } else {
          await _budgetLocalDataSource.saveBudget(budget, isSynced: true);
        }
      }

      await _syncLogDataSource.upsertLastSyncedAt(entityType, syncStart);
      _logger.d('Pulled ${budgets.length} budgets');
    } catch (e, stackTrace) {
      _logger.e('Failed to pull budgets', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> _pullBudgetMembers(String budgetId) async {
    const entityType = 'budget_member';
    try {
      final syncStart = DateTime.now().toUtc();

      // Budget members endpoint returns all members for a budget.
      // No updatedSince support yet -- full pull each time (small dataset).
      final response =
          await _budgetRemoteDataSource.getBudgetMembers(budgetId);
      final members = response.data ?? [];

      for (final member in members) {
        await _budgetMemberLocalDataSource.saveMember(member, isSynced: true);
      }

      await _syncLogDataSource.upsertLastSyncedAt(entityType, syncStart);
      _logger
          .d('Pulled ${members.length} budget members for budget $budgetId');
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to pull budget members for budget $budgetId',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _pullAccounts(String budgetId) async {
    const entityType = 'account';
    try {
      final lastSynced = await _syncLogDataSource.getLastSyncedAt(entityType);
      final updatedSince = lastSynced?.toUtc().toIso8601String();
      final syncStart = DateTime.now().toUtc();

      final response = await _accountRemoteDataSource.getAccounts(
        budgetId,
        updatedSince,
      );
      final accounts = response.data ?? [];

      for (final account in accounts) {
        if (account.deletedAt != null) {
          await _accountLocalDataSource.hardDelete(account.id);
        } else {
          await _accountLocalDataSource.saveAccount(account, isSynced: true);
        }
      }

      await _syncLogDataSource.upsertLastSyncedAt(entityType, syncStart);
      _logger.d('Pulled ${accounts.length} accounts for budget $budgetId');
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to pull accounts for budget $budgetId',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _pullCategories(String budgetId) async {
    const entityType = 'category';
    try {
      final lastSynced = await _syncLogDataSource.getLastSyncedAt(entityType);
      final updatedSince = lastSynced?.toUtc().toIso8601String();
      final syncStart = DateTime.now().toUtc();

      final response = await _categoryRemoteDataSource.getCategories(
        budgetId,
        null, // type filter
        updatedSince,
      );
      final categories = response.data ?? [];

      for (final category in categories) {
        if (category.deletedAt != null) {
          await _categoryLocalDataSource.hardDelete(category.id);
        } else {
          await _categoryLocalDataSource.saveCategory(category,
              isSynced: true);
        }
      }

      await _syncLogDataSource.upsertLastSyncedAt(entityType, syncStart);
      _logger
          .d('Pulled ${categories.length} categories for budget $budgetId');
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to pull categories for budget $budgetId',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _pullCreditCards(String budgetId) async {
    const entityType = 'credit_card';
    try {
      final lastSynced = await _syncLogDataSource.getLastSyncedAt(entityType);
      final updatedSince = lastSynced?.toUtc().toIso8601String();
      final syncStart = DateTime.now().toUtc();

      final cards = await _creditCardRemoteDataSource.getCreditCards(
        budgetId,
        false, // activeOnly
        updatedSince,
      );

      for (final card in cards) {
        if (card.deletedAt != null) {
          await _creditCardLocalDataSource.hardDelete(card.id);
        } else {
          await _creditCardLocalDataSource.saveCreditCard(card,
              isSynced: true);
        }
      }

      await _syncLogDataSource.upsertLastSyncedAt(entityType, syncStart);
      _logger.d('Pulled ${cards.length} credit cards for budget $budgetId');
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to pull credit cards for budget $budgetId',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _pullTransactions(String budgetId) async {
    const entityType = 'transaction';
    try {
      final lastSynced = await _syncLogDataSource.getLastSyncedAt(entityType);
      final updatedSince = lastSynced?.toUtc().toIso8601String();
      final syncStart = DateTime.now().toUtc();

      final response = await _transactionRemoteDataSource.getTransactions(
        budgetId,
        null, // startDate
        null, // endDate
        updatedSince,
      );
      final transactions = response.data ?? [];

      for (final txn in transactions) {
        if (txn.deletedAt != null) {
          await _transactionLocalDataSource.hardDelete(txn.id);
        } else {
          await _transactionLocalDataSource.saveTransaction(txn,
              isSynced: true);
        }
      }

      await _syncLogDataSource.upsertLastSyncedAt(entityType, syncStart);
      _logger.d(
          'Pulled ${transactions.length} transactions for budget $budgetId');
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to pull transactions for budget $budgetId',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Performs a full initial pull: clears all local data first, then
  /// pulls the latest state from the remote API.
  Future<void> initialFullPull() async {
    _logger.i('Starting initial full pull');
    await clearAllData();
    await _pullLatestData();
    _logger.i('Initial full pull completed');
  }

  /// Clears all data from every local datasource and the pending sync queue.
  Future<void> clearAllData() async {
    _logger.i('Clearing all local data');

    await _transactionLocalDataSource.clearAll();
    await _installmentGroupLocalDataSource.clearAll();
    await _creditCardLocalDataSource.clearAll();
    await _categoryLocalDataSource.clearAll();
    await _accountLocalDataSource.clearAll();
    await _budgetMemberLocalDataSource.clearAll();
    await _budgetLocalDataSource.clearAll();
    await _userLocalDataSource.clearAll();
    await _pendingSyncDataSource.clearAll();
    await _syncLogDataSource.clearAll();

    _logger.i('All local data cleared');
  }

  /// Releases all resources held by this manager.
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    _failedItemsController.close();
    _logger.i('SyncManager disposed');
  }
}
