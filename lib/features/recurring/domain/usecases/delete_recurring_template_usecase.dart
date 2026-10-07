import 'package:dartz/dartz.dart';

import '../../../../core/utils/failure.dart';
import '../repositories/recurring_transaction_repository.dart';

class DeleteRecurringTemplateUseCase {
  final RecurringTransactionRepository repository;

  DeleteRecurringTemplateUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    if (id.trim().isEmpty) {
      return const Left(ValidationFailure('Template ID is required'));
    }

    return await repository.deleteTemplate(id.trim());
  }
}
