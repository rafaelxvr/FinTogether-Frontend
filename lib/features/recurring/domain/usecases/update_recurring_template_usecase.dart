import 'package:dartz/dartz.dart';

import '../../../../core/utils/failure.dart';
import '../entities/recurring_transaction_template.dart';
import '../repositories/recurring_transaction_repository.dart';

class UpdateRecurringTemplateUseCase {
  final RecurringTransactionRepository repository;

  UpdateRecurringTemplateUseCase(this.repository);

  Future<Either<Failure, RecurringTransactionTemplate>> call({
    required String id,
    double? amount,
    RecurringTransactionType? type,
    String? description,
    RecurrenceFrequency? frequency,
    int? interval,
    int? dayOfMonth,
    DateTime? startDate,
    DateTime? endDate,
    bool? isFixedExpense,
    String? categoryId,
  }) async {
    if (id.trim().isEmpty) {
      return const Left(ValidationFailure('Template ID is required'));
    }

    if (amount != null && amount <= 0) {
      return const Left(
        ValidationFailure('Amount must be greater than zero'),
      );
    }

    if (description != null && description.trim().isEmpty) {
      return const Left(ValidationFailure('Description cannot be empty'));
    }

    if (description != null && description.length > 500) {
      return const Left(
        ValidationFailure('Description must not exceed 500 characters'),
      );
    }

    if (interval != null && (interval < 1 || interval > 365)) {
      return const Left(
        ValidationFailure('Interval must be between 1 and 365'),
      );
    }

    if (dayOfMonth != null && (dayOfMonth < 1 || dayOfMonth > 31)) {
      return const Left(
        ValidationFailure('Day of month must be between 1 and 31'),
      );
    }

    return await repository.updateTemplate(
      id: id.trim(),
      amount: amount,
      type: type,
      description: description?.trim(),
      frequency: frequency,
      interval: interval,
      dayOfMonth: dayOfMonth,
      startDate: startDate,
      endDate: endDate,
      isFixedExpense: isFixedExpense,
      categoryId: categoryId?.trim(),
    );
  }
}
