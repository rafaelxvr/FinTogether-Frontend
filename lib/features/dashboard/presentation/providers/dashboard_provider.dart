import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/cashflow_trend.dart';
import '../../domain/entities/essential_breakdown.dart';
import '../../domain/entities/member_spending.dart';
import '../../domain/entities/expense_forecast.dart';
import '../../domain/entities/dashboard_alerts.dart';
import '../../domain/entities/income_report.dart';
import '../../domain/usecases/get_dashboard_summary_usecase.dart';
import '../../domain/usecases/get_cashflow_trend_usecase.dart';
import '../../domain/usecases/get_essential_breakdown_usecase.dart';
import '../../domain/usecases/get_member_spending_usecase.dart';
import '../../domain/usecases/get_expense_forecast_usecase.dart';
import '../../domain/usecases/get_dashboard_alerts_usecase.dart';
import '../../domain/usecases/get_income_by_member_usecase.dart';
import 'dashboard_state.dart';

/// Dashboard State Notifier
///
/// Manages dashboard state and coordinates data fetching
class DashboardNotifier extends StateNotifier<DashboardState> {
  final GetDashboardSummaryUseCase getDashboardSummaryUseCase;
  final GetCashflowTrendUseCase getCashflowTrendUseCase;
  final GetEssentialBreakdownUseCase getEssentialBreakdownUseCase;
  final GetMemberSpendingUseCase getMemberSpendingUseCase;
  final GetExpenseForecastUseCase getExpenseForecastUseCase;
  final GetDashboardAlertsUseCase getDashboardAlertsUseCase;
  final GetIncomeByMemberUseCase getIncomeByMemberUseCase;

  DashboardNotifier({
    required this.getDashboardSummaryUseCase,
    required this.getCashflowTrendUseCase,
    required this.getEssentialBreakdownUseCase,
    required this.getMemberSpendingUseCase,
    required this.getExpenseForecastUseCase,
    required this.getDashboardAlertsUseCase,
    required this.getIncomeByMemberUseCase,
  }) : super(const DashboardInitial());

  /// Load dashboard data for a specific budget and month
  ///
  /// [budgetId] - The budget to load data for
  /// [yearMonth] - Optional month filter (YYYY-MM format)
  /// [loadCashflow] - Whether to also load cashflow trend data
  Future<void> loadDashboard(
    String budgetId, {
    String? yearMonth,
    bool loadCashflow = true,
    int cashflowMonths = 6,
  }) async {
    state = const DashboardLoading();

    // Fetch dashboard summary
    final summaryResult = await getDashboardSummaryUseCase(
      GetDashboardSummaryParams(
        budgetId: budgetId,
        yearMonth: yearMonth,
      ),
    );

    await summaryResult.fold(
      (failure) async {
        state = DashboardError(failure.message);
      },
      (summary) async {
        // Fetch cashflow trend
        CashflowTrend? trend;
        if (loadCashflow) {
          final trendResult = await getCashflowTrendUseCase(
            GetCashflowTrendParams(
              budgetId: budgetId,
              monthsCount: cashflowMonths,
            ),
          );
          trend = trendResult.fold((_) => null, (r) => r);
        }

        // Fetch enhanced dashboard data in parallel (failures are non-blocking)
        final results = await Future.wait([
          getEssentialBreakdownUseCase(
            GetEssentialBreakdownParams(budgetId: budgetId, yearMonth: yearMonth),
          ),
          getMemberSpendingUseCase(
            GetMemberSpendingParams(budgetId: budgetId, yearMonth: yearMonth),
          ),
          getExpenseForecastUseCase(
            GetExpenseForecastParams(budgetId: budgetId),
          ),
          getDashboardAlertsUseCase(
            GetDashboardAlertsParams(budgetId: budgetId),
          ),
          getIncomeByMemberUseCase(
            GetIncomeByMemberParams(budgetId: budgetId, yearMonth: yearMonth),
          ),
        ], eagerError: false);

        // Extract results (failures become null -- non-blocking)
        final essentialBreakdown = results[0].fold((_) => null, (r) => r) as EssentialBreakdown?;
        final memberSpending = results[1].fold((_) => null, (r) => r) as MemberSpendingReport?;
        final expenseForecast = results[2].fold((_) => null, (r) => r) as ExpenseForecast?;
        final alertsReport = results[3].fold((_) => null, (r) => r) as DashboardAlertsReport?;
        final incomeByMember = results[4].fold((_) => null, (r) => r) as IncomeByMemberReport?;

        state = DashboardLoaded(
          summary: summary,
          cashflowTrend: trend,
          essentialBreakdown: essentialBreakdown,
          memberSpending: memberSpending,
          expenseForecast: expenseForecast,
          alerts: alertsReport,
          incomeByMember: incomeByMember,
        );
      },
    );
  }

  /// Refresh dashboard data (with optimistic UI)
  ///
  /// Shows current data while fetching new data in background
  Future<void> refreshDashboard(
    String budgetId, {
    String? yearMonth,
    int cashflowMonths = 6,
  }) async {
    // If we have current data, show refreshing state
    final currentState = state;
    if (currentState is DashboardLoaded) {
      state = DashboardRefreshing(
        currentSummary: currentState.summary,
        currentCashflowTrend: currentState.cashflowTrend,
        currentEssentialBreakdown: currentState.essentialBreakdown,
        currentMemberSpending: currentState.memberSpending,
        currentExpenseForecast: currentState.expenseForecast,
        currentAlerts: currentState.alerts,
        currentIncomeByMember: currentState.incomeByMember,
      );
    } else {
      state = const DashboardLoading();
    }

    // Reload data
    await loadDashboard(
      budgetId,
      yearMonth: yearMonth,
      loadCashflow: true,
      cashflowMonths: cashflowMonths,
    );
  }

  /// Load only summary (skip cashflow trend)
  Future<void> loadSummaryOnly(
    String budgetId, {
    String? yearMonth,
  }) async {
    await loadDashboard(
      budgetId,
      yearMonth: yearMonth,
      loadCashflow: false,
    );
  }

  /// Load cashflow trend separately
  Future<void> loadCashflowTrend(
    String budgetId, {
    int monthsCount = 6,
  }) async {
    final currentState = state;
    if (currentState is! DashboardLoaded) {
      // Can't load trend without summary
      return;
    }

    final trendResult = await getCashflowTrendUseCase(
      GetCashflowTrendParams(
        budgetId: budgetId,
        monthsCount: monthsCount,
      ),
    );

    trendResult.fold(
      (failure) {
        // Keep current state, just log error
      },
      (trend) {
        state = currentState.copyWith(cashflowTrend: trend);
      },
    );
  }

  /// Reset to initial state
  void reset() {
    state = const DashboardInitial();
  }
}

/// Dashboard Provider
///
/// Global provider for dashboard state
final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>(
  (ref) {
    return DashboardNotifier(
      getDashboardSummaryUseCase: getIt<GetDashboardSummaryUseCase>(),
      getCashflowTrendUseCase: getIt<GetCashflowTrendUseCase>(),
      getEssentialBreakdownUseCase: getIt<GetEssentialBreakdownUseCase>(),
      getMemberSpendingUseCase: getIt<GetMemberSpendingUseCase>(),
      getExpenseForecastUseCase: getIt<GetExpenseForecastUseCase>(),
      getDashboardAlertsUseCase: getIt<GetDashboardAlertsUseCase>(),
      getIncomeByMemberUseCase: getIt<GetIncomeByMemberUseCase>(),
    );
  },
);
