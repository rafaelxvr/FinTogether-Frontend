import 'package:equatable/equatable.dart';

class MemberSpending extends Equatable {
  final String userId;
  final String userName;
  final double totalExpense;
  final double totalIncome;
  final int transactionCount;
  final double percentage;

  const MemberSpending({
    required this.userId,
    required this.userName,
    required this.totalExpense,
    required this.totalIncome,
    required this.transactionCount,
    required this.percentage,
  });

  @override
  List<Object?> get props => [userId, userName, totalExpense, totalIncome, transactionCount, percentage];
}

class MemberSpendingReport extends Equatable {
  final String budgetId;
  final String period;
  final List<MemberSpending> members;
  final double totalBudgetExpense;

  const MemberSpendingReport({
    required this.budgetId,
    required this.period,
    required this.members,
    required this.totalBudgetExpense,
  });

  bool get isSharedBudget => members.length > 1;

  @override
  List<Object?> get props => [budgetId, period, members, totalBudgetExpense];
}
