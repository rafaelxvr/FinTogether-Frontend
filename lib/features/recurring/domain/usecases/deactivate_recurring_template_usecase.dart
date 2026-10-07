import 'package:dartz/dartz.dart';

import '../../../../core/utils/failure.dart';
import '../repositories/recurring_transaction_repository.dart';

class DeactivateRecurringTemplateUseCase {
  final RecurringTransactionRepository repository;

  DeactivateRecurringTemplateUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    if (id.trim().isEmpty) {
      return const Left(ValidationFailure('Template ID is required'));
    }

    return await repository.deactivateTemplate(id.trim());
  }
}
