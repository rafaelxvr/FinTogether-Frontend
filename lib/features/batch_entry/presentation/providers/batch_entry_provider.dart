import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import '../../../transaction/domain/entities/transaction.dart';
import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../../domain/entities/batch_entry_item.dart';
import '../../domain/entities/batch_session.dart';
import '../../domain/entities/bulk_create_result.dart';
import 'batch_entry_state.dart';

class BatchEntryNotifier extends StateNotifier<BatchEntryState> {
  final TransactionRepository _transactionRepository;

  BatchSession _session = BatchSession.empty('');

  BatchEntryNotifier({
    required TransactionRepository transactionRepository,
  })  : _transactionRepository = transactionRepository,
        super(BatchEntryIdle(BatchSession.empty('')));

  BatchSession get session => _session;

  void startSession(String budgetId) {
    _session = BatchSession.empty(budgetId);
    state = BatchEntryIdle(_session);
  }

  void addItem(BatchEntryItem item) {
    _session = _session.addItem(item);
    state = BatchEntryIdle(_session);
  }

  void removeItem(String localId) {
    _session = _session.removeItem(localId);
    state = BatchEntryIdle(_session);
  }

  void updateItem(String localId, BatchEntryItem updated) {
    _session = _session.updateItem(localId, updated);
    state = BatchEntryIdle(_session);
  }

  void clearSession() {
    _session = _session.clear();
    state = BatchEntryIdle(_session);
  }

  Future<void> submitBatch() async {
    if (_session.isEmpty) return;

    state = BatchEntrySubmitting(_session);

    try {
      final createdTransactions = <Transaction>[];
      final failedItems = <BulkCreateError>[];

      for (var i = 0; i < _session.items.length; i++) {
        final item = _session.items[i];
        final result = await _transactionRepository.createTransaction(
          budgetId: _session.budgetId,
          transactionDate: item.date,
          amount: item.amount,
          type: item.transactionType,
          accountId: item.accountId,
          categoryId: item.categoryId,
          description: item.description,
          visibility: item.visibility,
        );

        result.fold(
          (failure) => failedItems.add(
            BulkCreateError(index: i, error: failure.message),
          ),
          (transaction) => createdTransactions.add(transaction),
        );
      }

      final bulkResult = BulkCreateResult(
        created: createdTransactions,
        failed: failedItems,
      );

      if (bulkResult.allSucceeded) {
        _session = _session.clear();
      }

      state = BatchEntryCompleted(
        result: bulkResult,
        session: _session,
      );
    } catch (e) {
      state = BatchEntryError(
        message: 'Failed to submit batch: ${e.toString()}',
        session: _session,
      );
    }
  }
}

final batchEntryProvider =
    StateNotifierProvider<BatchEntryNotifier, BatchEntryState>(
  (ref) => BatchEntryNotifier(
    transactionRepository: getIt<TransactionRepository>(),
  ),
);
