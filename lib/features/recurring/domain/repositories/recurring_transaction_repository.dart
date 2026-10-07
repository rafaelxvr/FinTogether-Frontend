import 'package:dartz/dartz.dart';

import '../../../../core/utils/failure.dart';
import '../entities/fixed_expense_summary.dart';
import '../entities/recurring_transaction_template.dart';

/// Repository interface for recurring transaction operations.
abstract class RecurringTransactionRepository {
  Future<Either<Failure, List<RecurringTransactionTemplate>>> getTemplates(
    String budgetId,
  );

  Future<Either<Failure, RecurringTransactionTemplate>> createTemplate({
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
  });

  Future<Either<Failure, RecurringTransactionTemplate>> updateTemplate({
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
  });

  Future<Either<Failure, void>> deactivateTemplate(String id);

  Future<Either<Failure, void>> deleteTemplate(String id);

  Future<Either<Failure, RecurringTransactionTemplate>> getTemplateById(
    String id,
  );

  Future<Either<Failure, List<RecurringTransactionTemplate>>> getFixedExpenses(
    String budgetId,
  );

  Future<Either<Failure, FixedExpenseSummary>> getFixedExpenseSummary(
    String budgetId,
  );
}
