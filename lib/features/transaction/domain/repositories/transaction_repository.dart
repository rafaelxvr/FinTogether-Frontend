import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/transaction.dart';
import '../entities/transaction_search_params.dart';

abstract class TransactionRepository {
  /// Get all transactions for a budget with optional date filter
  Future<Either<Failure, List<Transaction>>> getTransactions({
    required String budgetId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get transaction by ID
  Future<Either<Failure, Transaction>> getTransactionById(String id);

  /// Create new transaction
  Future<Either<Failure, Transaction>> createTransaction({
    required String budgetId,
    required DateTime transactionDate,
    required double amount,
    required TransactionType type,
    String? accountId,
    String? categoryId,
    String? description,
    String? notes,
    List<String>? tags,
    TransactionVisibility visibility = TransactionVisibility.shared,
  });

  /// Update existing transaction
  Future<Either<Failure, Transaction>> updateTransaction({
    required String id,
    required DateTime transactionDate,
    required double amount,
    String? description,
    String? notes,
    List<String>? tags,
    String? categoryId,
    TransactionVisibility? visibility,
  });

  /// Delete transaction
  Future<Either<Failure, void>> deleteTransaction(String id);

  /// Search transactions with text query and filters
  Future<Either<Failure, List<Transaction>>> searchTransactions({
    required String budgetId,
    required TransactionSearchParams params,
  });
}
