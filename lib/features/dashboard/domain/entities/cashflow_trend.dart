import 'package:equatable/equatable.dart';

/// Cashflow Trend Entity
/// Represents monthly income/expense trends over time
class CashflowTrend extends Equatable {
  final String budgetId;
  final List<MonthlyData> months;

  const CashflowTrend({
    required this.budgetId,
    required this.months,
  });

  /// Get highest income month
  MonthlyData? get highestIncomeMonth {
    if (months.isEmpty) return null;
    return months.reduce((a, b) => a.income > b.income ? a : b);
  }

  /// Get highest expense month
  MonthlyData? get highestExpenseMonth {
    if (months.isEmpty) return null;
    return months.reduce((a, b) => a.expense > b.expense ? a : b);
  }

  /// Calculate average monthly income
  double get averageIncome {
    if (months.isEmpty) return 0.0;
    return months.map((m) => m.income).reduce((a, b) => a + b) / months.length;
  }

  /// Calculate average monthly expense
  double get averageExpense {
    if (months.isEmpty) return 0.0;
    return months.map((m) => m.expense).reduce((a, b) => a + b) / months.length;
  }

  /// Calculate average net cash flow
  double get averageNet {
    if (months.isEmpty) return 0.0;
    return months.map((m) => m.net).reduce((a, b) => a + b) / months.length;
  }

  /// Check if trend is improving (last month better than average)
  bool get isImproving {
    if (months.isEmpty) return false;
    final lastMonth = months.last;
    return lastMonth.net > averageNet;
  }

  @override
  List<Object?> get props => [budgetId, months];
}

/// Monthly Data Entity
/// Income/Expense data for a single month
class MonthlyData extends Equatable {
  final String period; // "2025-11"
  final DateTime yearMonth;
  final double income;
  final double expense;
  final double net;
  final int transactionCount;

  const MonthlyData({
    required this.period,
    required this.yearMonth,
    required this.income,
    required this.expense,
    required this.net,
    required this.transactionCount,
  });

  /// Get month name (e.g., "November")
  String get monthName {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[yearMonth.month - 1];
  }

  /// Get short month name (e.g., "Nov")
  String get shortMonthName => monthName.substring(0, 3);

  /// Check if positive cash flow
  bool get isPositive => net >= 0;

  /// Calculate savings rate
  double get savingsRate {
    if (income == 0) return 0.0;
    return (net / income) * 100;
  }

  @override
  List<Object?> get props => [
        period,
        yearMonth,
        income,
        expense,
        net,
        transactionCount,
      ];
}
