import 'package:dartz/dartz.dart';

import '../../../../core/utils/failure.dart';
import '../entities/recurring_transaction_template.dart';
import '../repositories/recurring_transaction_repository.dart';

class GetRecurringTemplatesUseCase {
  final RecurringTransactionRepository repository;

  GetRecurringTemplatesUseCase(this.repository);

  Future<Either<Failure, List<RecurringTransactionTemplate>>> call(
    String budgetId,
  ) async {
    if (budgetId.trim().isEmpty) {
      return const Left(ValidationFailure('Budget ID is required'));
    }

    return await repository.getTemplates(budgetId);
  }
}
