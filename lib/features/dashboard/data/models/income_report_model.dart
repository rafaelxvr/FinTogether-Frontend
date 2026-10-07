import '../../domain/entities/income_report.dart';

class IncomeSourceModel {
  final String categoryId;
  final String categoryName;
  final double amount;
  final double percentage;

  const IncomeSourceModel({
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.percentage,
  });

  factory IncomeSourceModel.fromJson(Map<String, dynamic> json) {
    return IncomeSourceModel(
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      amount: (json['amount'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
    );
  }

  IncomeSource toEntity() {
    return IncomeSource(
      categoryId: categoryId,
      categoryName: categoryName,
      amount: amount,
      percentage: percentage,
    );
  }
}

class MemberIncomeModel {
  final String userId;
  final String userName;
  final double totalIncome;
  final double percentage;
  final int transactionCount;
  final List<IncomeSourceModel> topSources;

  const MemberIncomeModel({
    required this.userId,
    required this.userName,
    required this.totalIncome,
    required this.percentage,
    required this.transactionCount,
    required this.topSources,
  });

  factory MemberIncomeModel.fromJson(Map<String, dynamic> json) {
    return MemberIncomeModel(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      totalIncome: (json['totalIncome'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
      transactionCount: json['transactionCount'] as int,
      topSources: (json['topSources'] as List)
          .map((e) => IncomeSourceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  MemberIncome toEntity() {
    return MemberIncome(
      userId: userId,
      userName: userName,
      totalIncome: totalIncome,
      percentage: percentage,
      transactionCount: transactionCount,
      topSources: topSources.map((s) => s.toEntity()).toList(),
    );
  }
}

class IncomeByMemberReportModel {
  final String budgetId;
  final String period;
  final double totalBudgetIncome;
  final List<MemberIncomeModel> members;

  const IncomeByMemberReportModel({
    required this.budgetId,
    required this.period,
    required this.totalBudgetIncome,
    required this.members,
  });

  factory IncomeByMemberReportModel.fromJson(Map<String, dynamic> json) {
    return IncomeByMemberReportModel(
      budgetId: json['budgetId'] as String,
      period: json['period'] as String,
      totalBudgetIncome: (json['totalBudgetIncome'] as num).toDouble(),
      members: (json['members'] as List)
          .map((e) => MemberIncomeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  IncomeByMemberReport toEntity() {
    return IncomeByMemberReport(
      budgetId: budgetId,
      period: period,
      totalBudgetIncome: totalBudgetIncome,
      members: members.map((m) => m.toEntity()).toList(),
    );
  }
}
