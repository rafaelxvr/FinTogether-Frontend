import '../../domain/entities/member_spending.dart';

class MemberSpendingModel {
  final String userId;
  final String userName;
  final double totalExpense;
  final double totalIncome;
  final int transactionCount;
  final double percentage;

  const MemberSpendingModel({
    required this.userId,
    required this.userName,
    required this.totalExpense,
    required this.totalIncome,
    required this.transactionCount,
    required this.percentage,
  });

  factory MemberSpendingModel.fromJson(Map<String, dynamic> json) {
    return MemberSpendingModel(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      totalExpense: (json['totalExpense'] as num).toDouble(),
      totalIncome: (json['totalIncome'] as num).toDouble(),
      transactionCount: json['transactionCount'] as int,
      percentage: (json['percentage'] as num).toDouble(),
    );
  }

  MemberSpending toEntity() {
    return MemberSpending(
      userId: userId,
      userName: userName,
      totalExpense: totalExpense,
      totalIncome: totalIncome,
      transactionCount: transactionCount,
      percentage: percentage,
    );
  }
}

class MemberSpendingReportModel {
  final String budgetId;
  final String period;
  final List<MemberSpendingModel> members;
  final double totalBudgetExpense;

  const MemberSpendingReportModel({
    required this.budgetId,
    required this.period,
    required this.members,
    required this.totalBudgetExpense,
  });

  factory MemberSpendingReportModel.fromJson(Map<String, dynamic> json) {
    return MemberSpendingReportModel(
      budgetId: json['budgetId'] as String,
      period: json['period'] as String,
      members: (json['members'] as List)
          .map((e) => MemberSpendingModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalBudgetExpense: (json['totalBudgetExpense'] as num).toDouble(),
    );
  }

  MemberSpendingReport toEntity() {
    return MemberSpendingReport(
      budgetId: budgetId,
      period: period,
      members: members.map((m) => m.toEntity()).toList(),
      totalBudgetExpense: totalBudgetExpense,
    );
  }
}
