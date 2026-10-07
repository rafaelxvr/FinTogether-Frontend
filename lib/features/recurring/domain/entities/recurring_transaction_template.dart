import 'package:equatable/equatable.dart';

/// Frequency options for recurring transactions.
enum RecurrenceFrequency { monthly, weekly, yearly }

/// Type of transaction (expense or income).
enum RecurringTransactionType { expense, income }

/// Domain entity representing a recurring transaction template.
class RecurringTransactionTemplate extends Equatable {
  final String id;
  final String budgetId;
  final double amount;
  final RecurringTransactionType type;
  final String description;
  final RecurrenceFrequency frequency;
  final int interval;
  final int? dayOfMonth;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? nextDueDate;
  final bool isFixedExpense;
  final bool isActive;
  final String? categoryId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const RecurringTransactionTemplate({
    required this.id,
    required this.budgetId,
    required this.amount,
    required this.type,
    required this.description,
    required this.frequency,
    this.interval = 1,
    this.dayOfMonth,
    required this.startDate,
    this.endDate,
    this.nextDueDate,
    this.isFixedExpense = false,
    this.isActive = true,
    this.categoryId,
    required this.createdAt,
    this.updatedAt,
  });

  /// Human-readable recurrence description.
  String get recurrenceDescription {
    final frequencyLabel = switch (frequency) {
      RecurrenceFrequency.monthly => 'month',
      RecurrenceFrequency.weekly => 'week',
      RecurrenceFrequency.yearly => 'year',
    };

    if (interval == 1) {
      if (frequency == RecurrenceFrequency.monthly && dayOfMonth != null) {
        return 'Every month on day $dayOfMonth';
      }
      return 'Every $frequencyLabel';
    }

    return 'Every $interval ${frequencyLabel}s';
  }

  /// Display label for the frequency.
  String get frequencyLabel => switch (frequency) {
    RecurrenceFrequency.monthly => 'Monthly',
    RecurrenceFrequency.weekly => 'Weekly',
    RecurrenceFrequency.yearly => 'Yearly',
  };

  @override
  List<Object?> get props => [
    id,
    budgetId,
    amount,
    type,
    description,
    frequency,
    interval,
    dayOfMonth,
    startDate,
    endDate,
    nextDueDate,
    isFixedExpense,
    isActive,
    categoryId,
    createdAt,
    updatedAt,
  ];

  RecurringTransactionTemplate copyWith({
    String? id,
    String? budgetId,
    double? amount,
    RecurringTransactionType? type,
    String? description,
    RecurrenceFrequency? frequency,
    int? interval,
    int? dayOfMonth,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? nextDueDate,
    bool? isFixedExpense,
    bool? isActive,
    String? categoryId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecurringTransactionTemplate(
      id: id ?? this.id,
      budgetId: budgetId ?? this.budgetId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      interval: interval ?? this.interval,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      isFixedExpense: isFixedExpense ?? this.isFixedExpense,
      isActive: isActive ?? this.isActive,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
