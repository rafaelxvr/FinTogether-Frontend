import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class CreateTransactionUseCase {
  final TransactionRepository repository;

  CreateTransactionUseCase(this.repository);

  Future<Either<Failure, Transaction>> call({
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
  }) async {
    // Validate budget ID
    if (budgetId.trim().isEmpty) {
      return const Left(ValidationFailure('Budget ID is required'));
    }

    // Validate amount
    if (amount <= 0) {
      return const Left(
          ValidationFailure('Amount must be greater than zero'));
    }
    if (amount.isNaN || amount.isInfinite) {
      return const Left(ValidationFailure('Invalid amount'));
    }

    // Validate date (not in far future)
    final futureLimit = DateTime.now().add(const Duration(days: 365));
    if (transactionDate.isAfter(futureLimit)) {
      return const Left(
          ValidationFailure('Transaction date cannot be more than 1 year in the future'));
    }

    // Validate description length
    if (description != null && description.length > 500) {
      return const Left(
          ValidationFailure('Description must not exceed 500 characters'));
    }

    // Validate notes length
    if (notes != null && notes.length > 1000) {
      return const Left(
          ValidationFailure('Notes must not exceed 1000 characters'));
    }

    return await repository.createTransaction(
      budgetId: budgetId.trim(),
      transactionDate: transactionDate,
      amount: amount,
      type: type,
      accountId: accountId?.trim(),
      categoryId: categoryId?.trim(),
      description: description?.trim(),
      notes: notes?.trim(),
      tags: tags,
      visibility: visibility,
    );
  }
}
