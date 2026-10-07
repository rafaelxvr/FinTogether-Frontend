import 'package:equatable/equatable.dart';

import 'recurring_transaction_template.dart';

/// Summary of fixed monthly expenses for a budget.
class FixedExpenseSummary extends Equatable {
  final double totalMonthlyAmount;
  final int expenseCount;
  final List<RecurringTransactionTemplate> expenses;

  const FixedExpenseSummary({
    required this.totalMonthlyAmount,
    required this.expenseCount,
    required this.expenses,
  });

  @override
  List<Object?> get props => [totalMonthlyAmount, expenseCount, expenses];
}
