import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class GetTransactionsUseCase {
  final TransactionRepository repository;

  GetTransactionsUseCase(this.repository);

  Future<Either<Failure, List<Transaction>>> call({
    required String budgetId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (budgetId.trim().isEmpty) {
      return const Left(ValidationFailure('Budget ID is required'));
    }

    if (startDate != null && endDate != null && startDate.isAfter(endDate)) {
      return const Left(
          ValidationFailure('Start date must be before or equal to end date'));
    }

    return await repository.getTransactions(
      budgetId: budgetId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
