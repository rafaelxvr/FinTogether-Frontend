import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/dashboard_summary_model.dart';
import '../models/cashflow_trend_model.dart';
import '../models/essential_breakdown_model.dart';
import '../models/member_spending_model.dart';
import '../models/expense_forecast_model.dart';
import '../models/income_report_model.dart';
import '../models/dashboard_alerts_model.dart';

part 'dashboard_remote_datasource.g.dart';

/// Dashboard Remote Data Source
/// Retrofit API client for dashboard analytics endpoints
@RestApi(baseUrl: "")
abstract class DashboardRemoteDataSource {
  factory DashboardRemoteDataSource(Dio dio, {String baseUrl}) =
      _DashboardRemoteDataSource;

  /// Get dashboard summary
  ///
  /// GET /api/dashboard/summary?budgetId={budgetId}&month={month}
  ///
  /// Returns comprehensive dashboard summary including:
  /// - Total income/expense
  /// - Net cash flow
  /// - Account balances
  /// - Category breakdown
  /// - Recent transactions
  @GET("/api/dashboard/summary")
  Future<DashboardSummaryModel> getDashboardSummary(
    @Query("budgetId") String budgetId,
    @Query("month") String? month,
  );

  /// Get cashflow trend
  ///
  /// GET /api/dashboard/cashflow?budgetId={budgetId}&months={months}
  ///
  /// Returns monthly income/expense data for trend charts
  @GET("/api/dashboard/cashflow")
  Future<CashflowTrendModel> getCashflowTrend(
    @Query("budgetId") String budgetId,
    @Query("months") int months,
  );

  /// Get essential vs non-essential spending breakdown
  ///
  /// GET /api/dashboard/essential-breakdown?budgetId={budgetId}&month={month}
  @GET("/api/dashboard/essential-breakdown")
  Future<EssentialBreakdownModel> getEssentialBreakdown(
    @Query("budgetId") String budgetId,
    @Query("month") String? month,
  );

  /// Get member spending report for shared budgets
  ///
  /// GET /api/dashboard/member-spending?budgetId={budgetId}&month={month}
  @GET("/api/dashboard/member-spending")
  Future<MemberSpendingReportModel> getMemberSpending(
    @Query("budgetId") String budgetId,
    @Query("month") String? month,
  );

  /// Get expense forecast for current month
  ///
  /// GET /api/dashboard/forecast?budgetId={budgetId}
  @GET("/api/dashboard/forecast")
  Future<ExpenseForecastModel> getExpenseForecast(
    @Query("budgetId") String budgetId,
  );

  /// Get dashboard alerts (low balance, category limits, credit card due)
  ///
  /// GET /api/dashboard/alerts?budgetId={budgetId}
  @GET("/api/dashboard/alerts")
  Future<DashboardAlertsReportModel> getDashboardAlerts(
    @Query("budgetId") String budgetId,
  );

  /// Get income distribution by member for shared budgets
  ///
  /// GET /api/dashboard/income-by-member?budgetId={budgetId}&month={month}
  @GET("/api/dashboard/income-by-member")
  Future<IncomeByMemberReportModel> getIncomeByMember(
    @Query("budgetId") String budgetId,
    @Query("month") String? month,
  );
}
