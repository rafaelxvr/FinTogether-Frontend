import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/transaction.dart';
import '../entities/transaction_search_params.dart';
import '../repositories/transaction_repository.dart';

class SearchTransactionsUseCase {
  final TransactionRepository repository;

  SearchTransactionsUseCase(this.repository);

  Future<Either<Failure, List<Transaction>>> call({
    required String budgetId,
    required TransactionSearchParams params,
  }) async {
    if (budgetId.trim().isEmpty) {
      return const Left(ValidationFailure('Budget ID is required'));
    }

    if (params.query != null &&
        params.query!.isNotEmpty &&
        params.query!.length < 2) {
      return const Left(
          ValidationFailure('Search query must be at least 2 characters'));
    }

    if (params.minAmount != null &&
        params.maxAmount != null &&
        params.minAmount! > params.maxAmount!) {
      return const Left(ValidationFailure(
          'Minimum amount must be less than or equal to maximum amount'));
    }

    if (params.startDate != null &&
        params.endDate != null &&
        params.startDate!.isAfter(params.endDate!)) {
      return const Left(ValidationFailure(
          'Start date must be before or equal to end date'));
    }

    return await repository.searchTransactions(
      budgetId: budgetId,
      params: params,
    );
  }
}
