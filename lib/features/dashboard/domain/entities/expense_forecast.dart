import 'package:equatable/equatable.dart';

class ExpenseForecast extends Equatable {
  final double currentMonthExpense;
  final double projectedMonthEndExpense;
  final double dailyAverage;
  final int daysElapsed;
  final int daysRemaining;
  final double lastMonthTotal;
  final double projectedVsLastMonth;

  const ExpenseForecast({
    required this.currentMonthExpense,
    required this.projectedMonthEndExpense,
    required this.dailyAverage,
    required this.daysElapsed,
    required this.daysRemaining,
    required this.lastMonthTotal,
    required this.projectedVsLastMonth,
  });

  bool get isProjectedHigher => projectedVsLastMonth > 0;

  double get progressPercentage {
    if (projectedMonthEndExpense == 0) return 0;
    return (currentMonthExpense / projectedMonthEndExpense).clamp(0.0, 1.0);
  }

  @override
  List<Object?> get props => [
        currentMonthExpense, projectedMonthEndExpense, dailyAverage,
        daysElapsed, daysRemaining, lastMonthTotal, projectedVsLastMonth,
      ];
}
