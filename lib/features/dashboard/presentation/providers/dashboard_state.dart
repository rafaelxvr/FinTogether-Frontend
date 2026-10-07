import 'package:equatable/equatable.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/entities/cashflow_trend.dart';
import '../../domain/entities/essential_breakdown.dart';
import '../../domain/entities/member_spending.dart';
import '../../domain/entities/expense_forecast.dart';
import '../../domain/entities/dashboard_alerts.dart';
import '../../domain/entities/income_report.dart';

/// Dashboard State
/// Represents the current state of the dashboard feature
abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

/// Initial state - before any data is loaded
class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

/// Loading state - data is being fetched
class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

/// Loaded state - dashboard data successfully retrieved
class DashboardLoaded extends DashboardState {
  final DashboardSummary summary;
  final CashflowTrend? cashflowTrend;
  final EssentialBreakdown? essentialBreakdown;
  final MemberSpendingReport? memberSpending;
  final ExpenseForecast? expenseForecast;
  final DashboardAlertsReport? alerts;
  final IncomeByMemberReport? incomeByMember;

  const DashboardLoaded({
    required this.summary,
    this.cashflowTrend,
    this.essentialBreakdown,
    this.memberSpending,
    this.expenseForecast,
    this.alerts,
    this.incomeByMember,
  });

  @override
  List<Object?> get props => [
        summary, cashflowTrend, essentialBreakdown,
        memberSpending, expenseForecast, alerts, incomeByMember,
      ];

  /// Create a copy with updated fields
  DashboardLoaded copyWith({
    DashboardSummary? summary,
    CashflowTrend? cashflowTrend,
    EssentialBreakdown? essentialBreakdown,
    MemberSpendingReport? memberSpending,
    ExpenseForecast? expenseForecast,
    DashboardAlertsReport? alerts,
    IncomeByMemberReport? incomeByMember,
  }) {
    return DashboardLoaded(
      summary: summary ?? this.summary,
      cashflowTrend: cashflowTrend ?? this.cashflowTrend,
      essentialBreakdown: essentialBreakdown ?? this.essentialBreakdown,
      memberSpending: memberSpending ?? this.memberSpending,
      expenseForecast: expenseForecast ?? this.expenseForecast,
      alerts: alerts ?? this.alerts,
      incomeByMember: incomeByMember ?? this.incomeByMember,
    );
  }
}

/// Error state - failed to fetch data
class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Refreshing state - refreshing data while showing cached data
class DashboardRefreshing extends DashboardState {
  final DashboardSummary currentSummary;
  final CashflowTrend? currentCashflowTrend;
  final EssentialBreakdown? currentEssentialBreakdown;
  final MemberSpendingReport? currentMemberSpending;
  final ExpenseForecast? currentExpenseForecast;
  final DashboardAlertsReport? currentAlerts;
  final IncomeByMemberReport? currentIncomeByMember;

  const DashboardRefreshing({
    required this.currentSummary,
    this.currentCashflowTrend,
    this.currentEssentialBreakdown,
    this.currentMemberSpending,
    this.currentExpenseForecast,
    this.currentAlerts,
    this.currentIncomeByMember,
  });

  @override
  List<Object?> get props => [
        currentSummary, currentCashflowTrend, currentEssentialBreakdown,
        currentMemberSpending, currentExpenseForecast, currentAlerts,
        currentIncomeByMember,
      ];
}
