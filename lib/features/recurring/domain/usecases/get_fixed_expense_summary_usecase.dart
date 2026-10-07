import 'package:dartz/dartz.dart';

import '../../../../core/utils/failure.dart';
import '../entities/fixed_expense_summary.dart';
import '../repositories/recurring_transaction_repository.dart';

class GetFixedExpenseSummaryUseCase {
  final RecurringTransactionRepository repository;

  GetFixedExpenseSummaryUseCase(this.repository);

  Future<Either<Failure, FixedExpenseSummary>> call(String budgetId) async {
    if (budgetId.trim().isEmpty) {
      return const Left(ValidationFailure('Budget ID is required'));
    }

    return await repository.getFixedExpenseSummary(budgetId);
  }
}
