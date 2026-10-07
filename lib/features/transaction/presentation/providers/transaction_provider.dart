import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/usecases/create_transaction_usecase.dart';
import '../../domain/usecases/delete_transaction_usecase.dart';
import '../../domain/usecases/get_transaction_by_id_usecase.dart';
import '../../domain/usecases/get_transactions_usecase.dart';
import '../../domain/usecases/update_transaction_usecase.dart';
import 'transaction_state.dart';

class TransactionNotifier extends StateNotifier<TransactionState> {
  final GetTransactionsUseCase getTransactionsUseCase;
  final GetTransactionByIdUseCase getTransactionByIdUseCase;
  final CreateTransactionUseCase createTransactionUseCase;
  final UpdateTransactionUseCase updateTransactionUseCase;
  final DeleteTransactionUseCase deleteTransactionUseCase;

  List<Transaction> _transactions = [];

  TransactionNotifier({
    required this.getTransactionsUseCase,
    required this.getTransactionByIdUseCase,
    required this.createTransactionUseCase,
    required this.updateTransactionUseCase,
    required this.deleteTransactionUseCase,
  }) : super(TransactionInitial());

  Future<void> loadTransactions({
    required String budgetId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    state = TransactionLoading();
    final result = await getTransactionsUseCase(
      budgetId: budgetId,
      startDate: startDate,
      endDate: endDate,
    );
    result.fold(
      (failure) => state = TransactionError(failure.message),
      (transactions) {
        _transactions = transactions;
        state = TransactionsLoaded(transactions);
      },
    );
  }

  Future<void> createTransaction({
    required String budgetId,
    required DateTime transactionDate,
    required double amount,
    required TransactionType type,
    String? accountId,
    String? categoryId,
    String? description,
    String? notes,
  }) async {
    state = TransactionLoading();
    final result = await createTransactionUseCase(
      budgetId: budgetId,
      transactionDate: transactionDate,
      amount: amount,
      type: type,
      accountId: accountId,
      categoryId: categoryId,
      description: description,
      notes: notes,
    );
    result.fold(
      (failure) => state = TransactionError(failure.message),
      (transaction) {
        _transactions = [transaction, ..._transactions];
        state = TransactionCreated(transaction);
        loadTransactions(budgetId: budgetId);
      },
    );
  }

  Future<void> updateTransaction({
    required String budgetId,
    required String id,
    required DateTime transactionDate,
    required double amount,
    String? description,
    String? notes,
    String? categoryId,
  }) async {
    state = TransactionLoading();
    final result = await updateTransactionUseCase(
      id: id,
      transactionDate: transactionDate,
      amount: amount,
      description: description,
      notes: notes,
      categoryId: categoryId,
    );
    result.fold(
      (failure) => state = TransactionError(failure.message),
      (transaction) {
        _transactions = _transactions
            .map((t) => t.id == transaction.id ? transaction : t)
            .toList();
        state = TransactionUpdated(transaction);
        loadTransactions(budgetId: budgetId);
      },
    );
  }

  Future<void> deleteTransaction({
    required String budgetId,
    required String id,
  }) async {
    state = TransactionLoading();
    final result = await deleteTransactionUseCase(id);
    result.fold(
      (failure) => state = TransactionError(failure.message),
      (_) {
        _transactions = _transactions.where((t) => t.id != id).toList();
        state = TransactionDeleted();
        loadTransactions(budgetId: budgetId);
      },
    );
  }

  List<Transaction> get transactions => _transactions;
}

final transactionProvider =
    StateNotifierProvider<TransactionNotifier, TransactionState>(
  (ref) => TransactionNotifier(
    getTransactionsUseCase: getIt<GetTransactionsUseCase>(),
    getTransactionByIdUseCase: getIt<GetTransactionByIdUseCase>(),
    createTransactionUseCase: getIt<CreateTransactionUseCase>(),
    updateTransactionUseCase: getIt<UpdateTransactionUseCase>(),
    deleteTransactionUseCase: getIt<DeleteTransactionUseCase>(),
  ),
);
