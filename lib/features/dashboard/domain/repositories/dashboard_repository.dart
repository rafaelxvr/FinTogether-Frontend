import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/dashboard_summary.dart';
import '../entities/cashflow_trend.dart';
import '../entities/essential_breakdown.dart';
import '../entities/member_spending.dart';
import '../entities/expense_forecast.dart';
import '../entities/dashboard_alerts.dart';
import '../entities/income_report.dart';

/// Dashboard Repository Interface
/// Defines operations for fetching dashboard analytics data
abstract class DashboardRepository {
  /// Get comprehensive dashboard summary for a budget and month
  ///
  /// [budgetId] - The budget to get summary for
  /// [yearMonth] - Optional month in format "YYYY-MM" (defaults to current month)
  ///
  /// Returns Either<Failure, DashboardSummary>
  Future<Either<Failure, DashboardSummary>> getDashboardSummary(
    String budgetId, {
    String? yearMonth,
  });

  /// Get cashflow trend data for multiple months
  ///
  /// [budgetId] - The budget to get trends for
  /// [monthsCount] - Number of months to include (default 6)
  ///
  /// Returns Either<Failure, CashflowTrend>
  Future<Either<Failure, CashflowTrend>> getCashflowTrend(
    String budgetId, {
    int monthsCount = 6,
  });

  /// Get essential vs non-essential spending breakdown
  Future<Either<Failure, EssentialBreakdown>> getEssentialBreakdown(
    String budgetId, {
    String? yearMonth,
  });

  /// Get per-member spending report for shared budgets
  Future<Either<Failure, MemberSpendingReport>> getMemberSpending(
    String budgetId, {
    String? yearMonth,
  });

  /// Get expense forecast for current month
  Future<Either<Failure, ExpenseForecast>> getExpenseForecast(
    String budgetId,
  );

  /// Get dashboard alerts
  Future<Either<Failure, DashboardAlertsReport>> getDashboardAlerts(
    String budgetId,
  );

  /// Get income distribution by member
  Future<Either<Failure, IncomeByMemberReport>> getIncomeByMember(
    String budgetId, {
    String? yearMonth,
  });
}
