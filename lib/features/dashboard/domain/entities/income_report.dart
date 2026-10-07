import 'package:equatable/equatable.dart';

class IncomeSource extends Equatable {
  final String categoryId;
  final String categoryName;
  final double amount;
  final double percentage;

  const IncomeSource({
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.percentage,
  });

  @override
  List<Object?> get props => [categoryId, categoryName, amount, percentage];
}

class MemberIncome extends Equatable {
  final String userId;
  final String userName;
  final double totalIncome;
  final double percentage;
  final int transactionCount;
  final List<IncomeSource> topSources;

  const MemberIncome({
    required this.userId,
    required this.userName,
    required this.totalIncome,
    required this.percentage,
    required this.transactionCount,
    required this.topSources,
  });

  @override
  List<Object?> get props => [userId, userName, totalIncome, percentage, transactionCount, topSources];
}

class IncomeByMemberReport extends Equatable {
  final String budgetId;
  final String period;
  final double totalBudgetIncome;
  final List<MemberIncome> members;

  const IncomeByMemberReport({
    required this.budgetId,
    required this.period,
    required this.totalBudgetIncome,
    required this.members,
  });

  bool get isSharedBudget => members.length > 1;

  @override
  List<Object?> get props => [budgetId, period, totalBudgetIncome, members];
}
