import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/recurring_transaction_template.dart';
import '../../domain/usecases/create_recurring_template_usecase.dart';
import '../../domain/usecases/deactivate_recurring_template_usecase.dart';
import '../../domain/usecases/delete_recurring_template_usecase.dart';
import '../../domain/usecases/get_fixed_expense_summary_usecase.dart';
import '../../domain/usecases/get_recurring_templates_usecase.dart';
import '../../domain/usecases/update_recurring_template_usecase.dart';
import 'recurring_transaction_state.dart';

/// Recurring Transaction Notifier
class RecurringTransactionNotifier
    extends StateNotifier<RecurringTransactionState> {
  final GetRecurringTemplatesUseCase getRecurringTemplatesUseCase;
  final CreateRecurringTemplateUseCase createRecurringTemplateUseCase;
  final UpdateRecurringTemplateUseCase updateRecurringTemplateUseCase;
  final DeactivateRecurringTemplateUseCase deactivateRecurringTemplateUseCase;
  final DeleteRecurringTemplateUseCase deleteRecurringTemplateUseCase;
  final GetFixedExpenseSummaryUseCase getFixedExpenseSummaryUseCase;

  RecurringTransactionNotifier({
    required this.getRecurringTemplatesUseCase,
    required this.createRecurringTemplateUseCase,
    required this.updateRecurringTemplateUseCase,
    required this.deactivateRecurringTemplateUseCase,
    required this.deleteRecurringTemplateUseCase,
    required this.getFixedExpenseSummaryUseCase,
  }) : super(const RecurringInitial());

  /// Load all recurring templates for a budget.
  Future<void> loadTemplates(String budgetId) async {
    state = const RecurringLoading();

    final result = await getRecurringTemplatesUseCase(budgetId);

    result.fold(
      (failure) => state = RecurringError(failure.message),
      (templates) => state = TemplatesLoaded(templates),
    );
  }

  /// Create a new recurring template.
  Future<void> createTemplate({
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
    state = const RecurringLoading();

    final result = await createRecurringTemplateUseCase(
      budgetId: budgetId,
      amount: amount,
      type: type,
      description: description,
      frequency: frequency,
      interval: interval,
      dayOfMonth: dayOfMonth,
      startDate: startDate,
      endDate: endDate,
      isFixedExpense: isFixedExpense,
      categoryId: categoryId,
    );

    result.fold(
      (failure) => state = RecurringError(failure.message),
      (template) {
        state = TemplateCreated(template);
        loadTemplates(budgetId);
      },
    );
  }

  /// Update an existing recurring template.
  Future<void> updateTemplate({
    required String id,
    required String budgetId,
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
    state = const RecurringLoading();

    final result = await updateRecurringTemplateUseCase(
      id: id,
      amount: amount,
      type: type,
      description: description,
      frequency: frequency,
      interval: interval,
      dayOfMonth: dayOfMonth,
      startDate: startDate,
      endDate: endDate,
      isFixedExpense: isFixedExpense,
      categoryId: categoryId,
    );

    result.fold(
      (failure) => state = RecurringError(failure.message),
      (template) {
        state = TemplateCreated(template);
        loadTemplates(budgetId);
      },
    );
  }

  /// Deactivate a recurring template.
  Future<void> deactivateTemplate(
    String id, {
    String? budgetId,
  }) async {
    state = const RecurringLoading();

    final result = await deactivateRecurringTemplateUseCase(id);

    result.fold(
      (failure) => state = RecurringError(failure.message),
      (_) {
        if (budgetId != null) {
          loadTemplates(budgetId);
        } else {
          state = const RecurringInitial();
        }
      },
    );
  }

  /// Delete a recurring template.
  Future<void> deleteTemplate(
    String id, {
    String? budgetId,
  }) async {
    state = const RecurringLoading();

    final result = await deleteRecurringTemplateUseCase(id);

    result.fold(
      (failure) => state = RecurringError(failure.message),
      (_) {
        if (budgetId != null) {
          loadTemplates(budgetId);
        } else {
          state = const RecurringInitial();
        }
      },
    );
  }

  /// Load fixed expense summary for a budget.
  Future<void> loadFixedExpenseSummary(String budgetId) async {
    state = const RecurringLoading();

    final result = await getFixedExpenseSummaryUseCase(budgetId);

    result.fold(
      (failure) => state = RecurringError(failure.message),
      (summary) => state = FixedExpenseSummaryLoaded(summary),
    );
  }

  /// Reset to initial state.
  void reset() {
    state = const RecurringInitial();
  }
}

/// Recurring Transaction Provider
final recurringTransactionProvider = StateNotifierProvider<
    RecurringTransactionNotifier, RecurringTransactionState>(
  (ref) {
    return RecurringTransactionNotifier(
      getRecurringTemplatesUseCase: getIt<GetRecurringTemplatesUseCase>(),
      createRecurringTemplateUseCase: getIt<CreateRecurringTemplateUseCase>(),
      updateRecurringTemplateUseCase: getIt<UpdateRecurringTemplateUseCase>(),
      deactivateRecurringTemplateUseCase:
          getIt<DeactivateRecurringTemplateUseCase>(),
      deleteRecurringTemplateUseCase: getIt<DeleteRecurringTemplateUseCase>(),
      getFixedExpenseSummaryUseCase: getIt<GetFixedExpenseSummaryUseCase>(),
    );
  },
);
