import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/dashboard_summary.dart';

part 'dashboard_summary_model.g.dart';

/// Dashboard Summary Model
/// Data layer model for JSON serialization/deserialization
@JsonSerializable(explicitToJson: true)
class DashboardSummaryModel {
  final String budgetId;
  final String period;
  final double totalIncome;
  final double totalExpense;
  final double netCashFlow;
  final double accountsBalance;
  final List<CategorySpendingModel> categoryBreakdown;
  final List<TransactionSummaryModel> recentTransactions;

  const DashboardSummaryModel({
    required this.budgetId,
    required this.period,
    required this.totalIncome,
    required this.totalExpense,
    required this.netCashFlow,
    required this.accountsBalance,
    required this.categoryBreakdown,
    required this.recentTransactions,
  });

  /// Create model from JSON
  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$DashboardSummaryModelFromJson(json);

  /// Convert model to JSON
  Map<String, dynamic> toJson() => _$DashboardSummaryModelToJson(this);

  /// Convert model to domain entity
  DashboardSummary toEntity() {
    return DashboardSummary(
      budgetId: budgetId,
      period: period,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      netCashFlow: netCashFlow,
      accountsBalance: accountsBalance,
      categoryBreakdown:
          categoryBreakdown.map((model) => model.toEntity()).toList(),
      recentTransactions:
          recentTransactions.map((model) => model.toEntity()).toList(),
    );
  }

  /// Create model from domain entity
  factory DashboardSummaryModel.fromEntity(DashboardSummary entity) {
    return DashboardSummaryModel(
      budgetId: entity.budgetId,
      period: entity.period,
      totalIncome: entity.totalIncome,
      totalExpense: entity.totalExpense,
      netCashFlow: entity.netCashFlow,
      accountsBalance: entity.accountsBalance,
      categoryBreakdown: entity.categoryBreakdown
          .map((e) => CategorySpendingModel.fromEntity(e))
          .toList(),
      recentTransactions: entity.recentTransactions
          .map((e) => TransactionSummaryModel.fromEntity(e))
          .toList(),
    );
  }
}

/// Category Spending Model
@JsonSerializable()
class CategorySpendingModel {
  final String categoryId;
  final String categoryName;
  final String categoryType;
  final double amount;
  final double percentage;
  final int transactionCount;
  final String? color;
  final String? icon;

  const CategorySpendingModel({
    required this.categoryId,
    required this.categoryName,
    required this.categoryType,
    required this.amount,
    required this.percentage,
    required this.transactionCount,
    this.color,
    this.icon,
  });

  factory CategorySpendingModel.fromJson(Map<String, dynamic> json) =>
      _$CategorySpendingModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategorySpendingModelToJson(this);

  CategorySpending toEntity() {
    return CategorySpending(
      categoryId: categoryId,
      categoryName: categoryName,
      categoryType: categoryType,
      amount: amount,
      percentage: percentage,
      transactionCount: transactionCount,
      color: color,
      icon: icon,
    );
  }

  factory CategorySpendingModel.fromEntity(CategorySpending entity) {
    return CategorySpendingModel(
      categoryId: entity.categoryId,
      categoryName: entity.categoryName,
      categoryType: entity.categoryType,
      amount: entity.amount,
      percentage: entity.percentage,
      transactionCount: entity.transactionCount,
      color: entity.color,
      icon: entity.icon,
    );
  }
}

/// Transaction Summary Model
@JsonSerializable()
class TransactionSummaryModel {
  final String id;
  final String date; // Will be parsed to DateTime
  final String description;
  final double amount;
  final String type;
  final String? categoryName;
  final String? accountName;

  const TransactionSummaryModel({
    required this.id,
    required this.date,
    required this.description,
    required this.amount,
    required this.type,
    this.categoryName,
    this.accountName,
  });

  factory TransactionSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionSummaryModelFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionSummaryModelToJson(this);

  TransactionSummary toEntity() {
    return TransactionSummary(
      id: id,
      date: DateTime.parse(date),
      description: description,
      amount: amount,
      type: type,
      categoryName: categoryName,
      accountName: accountName,
    );
  }

  factory TransactionSummaryModel.fromEntity(TransactionSummary entity) {
    return TransactionSummaryModel(
      id: entity.id,
      date: entity.date.toIso8601String().substring(0, 10),
      description: entity.description,
      amount: entity.amount,
      type: entity.type,
      categoryName: entity.categoryName,
      accountName: entity.accountName,
    );
  }
}
