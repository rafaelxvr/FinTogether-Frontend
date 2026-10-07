import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/fixed_expense_summary.dart';
import 'recurring_transaction_template_model.dart';

part 'fixed_expense_summary_model.g.dart';

@JsonSerializable()
class FixedExpenseSummaryModel {
  @JsonKey(name: 'total_monthly_amount')
  final double totalMonthlyAmount;

  @JsonKey(name: 'expense_count')
  final int expenseCount;

  final List<RecurringTransactionTemplateModel> expenses;

  const FixedExpenseSummaryModel({
    required this.totalMonthlyAmount,
    required this.expenseCount,
    required this.expenses,
  });

  factory FixedExpenseSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$FixedExpenseSummaryModelFromJson(json);

  Map<String, dynamic> toJson() => _$FixedExpenseSummaryModelToJson(this);

  FixedExpenseSummary toEntity() => FixedExpenseSummary(
        totalMonthlyAmount: totalMonthlyAmount,
        expenseCount: expenseCount,
        expenses: expenses.map((e) => e.toEntity()).toList(),
      );
}
