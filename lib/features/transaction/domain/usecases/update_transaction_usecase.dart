import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class UpdateTransactionUseCase {
  final TransactionRepository repository;

  UpdateTransactionUseCase(this.repository);

  Future<Either<Failure, Transaction>> call({
    required String id,
    required DateTime transactionDate,
    required double amount,
    String? description,
    String? notes,
    List<String>? tags,
    String? categoryId,
    TransactionVisibility? visibility,
  }) async {
    // Validate transaction ID
    if (id.trim().isEmpty) {
      return const Left(ValidationFailure('Transaction ID is required'));
    }

    // Validate amount
    if (amount <= 0) {
      return const Left(
          ValidationFailure('Amount must be greater than zero'));
    }
    if (amount.isNaN || amount.isInfinite) {
      return const Left(ValidationFailure('Invalid amount'));
    }

    // Validate date
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

    return await repository.updateTransaction(
      id: id.trim(),
      transactionDate: transactionDate,
      amount: amount,
      description: description?.trim(),
      notes: notes?.trim(),
      tags: tags,
      categoryId: categoryId?.trim(),
      visibility: visibility,
    );
  }
}
