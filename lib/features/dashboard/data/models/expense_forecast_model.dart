import '../../domain/entities/expense_forecast.dart';

class ExpenseForecastModel {
  final double currentMonthExpense;
  final double projectedMonthEndExpense;
  final double dailyAverage;
  final int daysElapsed;
  final int daysRemaining;
  final double lastMonthTotal;
  final double projectedVsLastMonth;

  const ExpenseForecastModel({
    required this.currentMonthExpense,
    required this.projectedMonthEndExpense,
    required this.dailyAverage,
    required this.daysElapsed,
    required this.daysRemaining,
    required this.lastMonthTotal,
    required this.projectedVsLastMonth,
  });

  factory ExpenseForecastModel.fromJson(Map<String, dynamic> json) {
    return ExpenseForecastModel(
      currentMonthExpense: (json['currentMonthExpense'] as num).toDouble(),
      projectedMonthEndExpense: (json['projectedMonthEndExpense'] as num).toDouble(),
      dailyAverage: (json['dailyAverage'] as num).toDouble(),
      daysElapsed: json['daysElapsed'] as int,
      daysRemaining: json['daysRemaining'] as int,
      lastMonthTotal: (json['lastMonthTotal'] as num).toDouble(),
      projectedVsLastMonth: (json['projectedVsLastMonth'] as num).toDouble(),
    );
  }

  ExpenseForecast toEntity() {
    return ExpenseForecast(
      currentMonthExpense: currentMonthExpense,
      projectedMonthEndExpense: projectedMonthEndExpense,
      dailyAverage: dailyAverage,
      daysElapsed: daysElapsed,
      daysRemaining: daysRemaining,
      lastMonthTotal: lastMonthTotal,
      projectedVsLastMonth: projectedVsLastMonth,
    );
  }
}
