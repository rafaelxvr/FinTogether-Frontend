import 'package:dartz/dartz.dart';

import '../../../../core/utils/failure.dart';
import '../entities/recurring_transaction_template.dart';
import '../repositories/recurring_transaction_repository.dart';

class CreateRecurringTemplateUseCase {
  final RecurringTransactionRepository repository;

  CreateRecurringTemplateUseCase(this.repository);

  Future<Either<Failure, RecurringTransactionTemplate>> call({
    required String budgetId,
    required double amount,
    required RecurringTransactionType type,
    required String description,
    required RecurrenceFrequency frequency,
    int interval = 1,
    int? dayOfMonth,
    required DateTime startDate,
    DateTime? endDate,
    bool isFixedExpense = false,
    String? categoryId,
  }) async {
    if (budgetId.trim().isEmpty) {
      return const Left(ValidationFailure('Budget ID is required'));
    }

    if (amount <= 0) {
      return const Left(
        ValidationFailure('Amount must be greater than zero'),
      );
    }

    if (description.trim().isEmpty) {
      return const Left(ValidationFailure('Description is required'));
    }

    if (description.length > 500) {
      return const Left(
        ValidationFailure('Description must not exceed 500 characters'),
      );
    }

    if (interval < 1 || interval > 365) {
      return const Left(
        ValidationFailure('Interval must be between 1 and 365'),
      );
    }

    if (dayOfMonth != null && (dayOfMonth < 1 || dayOfMonth > 31)) {
      return const Left(
        ValidationFailure('Day of month must be between 1 and 31'),
      );
    }

    if (endDate != null && endDate.isBefore(startDate)) {
      return const Left(
        ValidationFailure('End date must be after start date'),
      );
    }

    return await repository.createTemplate(
      budgetId: budgetId.trim(),
      amount: amount,
      type: type,
      description: description.trim(),
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
