import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/recurring_transaction_template.dart';

part 'recurring_transaction_template_model.g.dart';

@JsonSerializable()
class RecurringTransactionTemplateModel {
  final String id;

  @JsonKey(name: 'budget_id')
  final String budgetId;

  final double amount;

  final String type;

  final String description;

  final String frequency;

  final int interval;

  @JsonKey(name: 'day_of_month')
  final int? dayOfMonth;

  @JsonKey(name: 'start_date')
  final DateTime startDate;

  @JsonKey(name: 'end_date')
  final DateTime? endDate;

  @JsonKey(name: 'next_due_date')
  final DateTime? nextDueDate;

  @JsonKey(name: 'is_fixed_expense')
  final bool isFixedExpense;

  @JsonKey(name: 'is_active')
  final bool isActive;

  @JsonKey(name: 'category_id')
  final String? categoryId;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const RecurringTransactionTemplateModel({
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

  factory RecurringTransactionTemplateModel.fromJson(
          Map<String, dynamic> json) =>
      _$RecurringTransactionTemplateModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$RecurringTransactionTemplateModelToJson(this);

  RecurringTransactionTemplate toEntity() => RecurringTransactionTemplate(
        id: id,
        budgetId: budgetId,
        amount: amount,
        type: _parseType(type),
        description: description,
        frequency: _parseFrequency(frequency),
        interval: interval,
        dayOfMonth: dayOfMonth,
        startDate: startDate,
        endDate: endDate,
        nextDueDate: nextDueDate,
        isFixedExpense: isFixedExpense,
        isActive: isActive,
        categoryId: categoryId,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  factory RecurringTransactionTemplateModel.fromEntity(
      RecurringTransactionTemplate entity) {
    return RecurringTransactionTemplateModel(
      id: entity.id,
      budgetId: entity.budgetId,
      amount: entity.amount,
      type: entity.type.name.toUpperCase(),
      description: entity.description,
      frequency: entity.frequency.name.toUpperCase(),
      interval: entity.interval,
      dayOfMonth: entity.dayOfMonth,
      startDate: entity.startDate,
      endDate: entity.endDate,
      nextDueDate: entity.nextDueDate,
      isFixedExpense: entity.isFixedExpense,
      isActive: entity.isActive,
      categoryId: entity.categoryId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  static RecurringTransactionType _parseType(String value) {
    switch (value.toLowerCase()) {
      case 'income':
        return RecurringTransactionType.income;
      case 'expense':
      default:
        return RecurringTransactionType.expense;
    }
  }

  static RecurrenceFrequency _parseFrequency(String value) {
    switch (value.toLowerCase()) {
      case 'weekly':
        return RecurrenceFrequency.weekly;
      case 'yearly':
        return RecurrenceFrequency.yearly;
      case 'monthly':
      default:
        return RecurrenceFrequency.monthly;
    }
  }
}
