import 'package:equatable/equatable.dart';

/// Dashboard Summary Entity
/// Represents comprehensive financial overview for a budget period
class DashboardSummary extends Equatable {
  final String budgetId;
  final String period; // "2025-11"
  final double totalIncome;
  final double totalExpense;
  final double netCashFlow;
  final double accountsBalance;
  final List<CategorySpending> categoryBreakdown;
  final List<TransactionSummary> recentTransactions;

  const DashboardSummary({
    required this.budgetId,
    required this.period,
    required this.totalIncome,
    required this.totalExpense,
    required this.netCashFlow,
    required this.accountsBalance,
    required this.categoryBreakdown,
    required this.recentTransactions,
  });

  /// Calculate savings rate percentage
  double get savingsRate {
    if (totalIncome == 0) return 0.0;
    return (netCashFlow / totalIncome) * 100;
  }

  /// Check if cash flow is positive
  bool get isPositiveCashFlow => netCashFlow >= 0;

  /// Get expense ratio
  double get expenseRatio {
    if (totalIncome == 0) return 0.0;
    return (totalExpense / totalIncome) * 100;
  }

  @override
  List<Object?> get props => [
        budgetId,
        period,
        totalIncome,
        totalExpense,
        netCashFlow,
        accountsBalance,
        categoryBreakdown,
        recentTransactions,
      ];
}

/// Category Spending Entity
/// Represents spending/earning for a specific category
class CategorySpending extends Equatable {
  final String categoryId;
  final String categoryName;
  final String categoryType; // INCOME, EXPENSE, TRANSFER
  final double amount;
  final double percentage;
  final int transactionCount;
  final String? color;
  final String? icon;

  const CategorySpending({
    required this.categoryId,
    required this.categoryName,
    required this.categoryType,
    required this.amount,
    required this.percentage,
    required this.transactionCount,
    this.color,
    this.icon,
  });

  /// Check if this is an expense category
  bool get isExpense => categoryType == 'EXPENSE';

  /// Check if this is an income category
  bool get isIncome => categoryType == 'INCOME';

  @override
  List<Object?> get props => [
        categoryId,
        categoryName,
        categoryType,
        amount,
        percentage,
        transactionCount,
        color,
        icon,
      ];
}

/// Transaction Summary Entity
/// Lightweight transaction info for recent activity
class TransactionSummary extends Equatable {
  final String id;
  final DateTime date;
  final String description;
  final double amount;
  final String type; // INCOME, EXPENSE, TRANSFER
  final String? categoryName;
  final String? accountName;

  const TransactionSummary({
    required this.id,
    required this.date,
    required this.description,
    required this.amount,
    required this.type,
    this.categoryName,
    this.accountName,
  });

  /// Check if transaction is income
  bool get isIncome => type == 'INCOME';

  /// Check if transaction is expense
  bool get isExpense => type == 'EXPENSE';

  /// Check if transaction is transfer
  bool get isTransfer => type == 'TRANSFER';

  @override
  List<Object?> get props => [
        id,
        date,
        description,
        amount,
        type,
        categoryName,
        accountName,
      ];
}
