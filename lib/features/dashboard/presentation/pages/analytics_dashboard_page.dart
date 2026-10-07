import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/dashboard_provider.dart';
import '../providers/dashboard_state.dart';
import '../widgets/summary_card.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/cashflow_line_chart.dart';
import '../widgets/recent_transactions_widget.dart';
import '../widgets/essential_breakdown_widget.dart';
import '../widgets/member_spending_widget.dart';
import '../widgets/expense_forecast_widget.dart';
import '../widgets/credit_card_alerts_widget.dart';
import '../widgets/income_by_member_widget.dart';
import '../widgets/income_sources_widget.dart';
import '../widgets/month_comparison_widget.dart';
import '../widgets/dashboard_alerts_widget.dart';
import '../widgets/widget_skeleton.dart';
import '../../../merchant/presentation/widgets/top_merchants_widget.dart';
import '../../../budget_allocation/presentation/providers/budget_allocation_provider.dart';
import '../../../budget_allocation/presentation/providers/budget_allocation_state.dart';
import '../../../budget_allocation/presentation/widgets/budget_health_widget.dart';

/// Analytics Dashboard Page
/// Displays comprehensive financial overview with charts and summaries
class AnalyticsDashboardPage extends ConsumerStatefulWidget {
  final String budgetId;

  const AnalyticsDashboardPage({
    super.key,
    required this.budgetId,
  });

  @override
  ConsumerState<AnalyticsDashboardPage> createState() =>
      _AnalyticsDashboardPageState();
}

class _AnalyticsDashboardPageState
    extends ConsumerState<AnalyticsDashboardPage> {
  @override
  void initState() {
    super.initState();
    // Load dashboard data on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboard();
    });
  }

  void _loadDashboard() {
    ref.read(dashboardProvider.notifier).loadDashboard(
          widget.budgetId,
          loadCashflow: true,
          cashflowMonths: 6,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dashboardState = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dashboardAnalytics),
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(dashboardProvider.notifier).refreshDashboard(
                    widget.budgetId,
                    cashflowMonths: 6,
                  );
            },
          ),
        ],
      ),
      body: _buildBody(dashboardState),
    );
  }

  Widget _buildBody(DashboardState state) {
    if (state is DashboardLoading) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            WidgetSkeleton(height: 120, label: 'Summary'),
            SizedBox(height: 16),
            WidgetSkeleton(height: 200, label: 'Cashflow'),
            SizedBox(height: 16),
            WidgetSkeleton(height: 200, label: 'Expense Forecast'),
            SizedBox(height: 16),
            WidgetSkeleton(height: 160, label: 'Essential Breakdown'),
            SizedBox(height: 16),
            WidgetSkeleton(height: 180, label: 'Categories'),
            SizedBox(height: 16),
            WidgetSkeleton(height: 120, label: 'Recent Transactions'),
          ],
        ),
      );
    }

    if (state is DashboardError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.failedToLoadDashboard,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadDashboard,
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context)!.retry),
            ),
          ],
        ),
      );
    }

    if (state is DashboardLoaded || state is DashboardRefreshing) {
      final summary = state is DashboardLoaded
          ? state.summary
          : (state as DashboardRefreshing).currentSummary;

      final cashflowTrend = state is DashboardLoaded
          ? state.cashflowTrend
          : (state as DashboardRefreshing).currentCashflowTrend;

      final essentialBreakdown = state is DashboardLoaded
          ? state.essentialBreakdown
          : (state as DashboardRefreshing).currentEssentialBreakdown;

      final memberSpending = state is DashboardLoaded
          ? state.memberSpending
          : (state as DashboardRefreshing).currentMemberSpending;

      final expenseForecast = state is DashboardLoaded
          ? state.expenseForecast
          : (state as DashboardRefreshing).currentExpenseForecast;

      final alerts = state is DashboardLoaded
          ? state.alerts
          : (state as DashboardRefreshing).currentAlerts;

      final incomeByMember = state is DashboardLoaded
          ? state.incomeByMember
          : (state as DashboardRefreshing).currentIncomeByMember;

      final isRefreshing = state is DashboardRefreshing;

      return RefreshIndicator(
        onRefresh: () async {
          await ref.read(dashboardProvider.notifier).refreshDashboard(
                widget.budgetId,
                cashflowMonths: 6,
              );
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Period indicator
              _buildPeriodHeader(summary.period, isRefreshing),
              const SizedBox(height: 16),

              // Summary cards grid (4 cards: income, expense, net, balance)
              SummaryCardsGrid(
                totalIncome: summary.totalIncome,
                totalExpense: summary.totalExpense,
                netCashFlow: summary.netCashFlow,
                accountsBalance: summary.accountsBalance,
              ),
              const SizedBox(height: 24),

              // Cashflow line chart
              if (cashflowTrend != null) ...[
                CashflowLineChart(
                  trend: cashflowTrend,
                  title: AppLocalizations.of(context)!.cashflowTrendTitle,
                ),
                const SizedBox(height: 24),
              ],

              // Month comparison (uses existing cashflow data)
              if (cashflowTrend != null && cashflowTrend.months.length >= 2) ...[
                MonthComparisonWidget(trend: cashflowTrend),
                const SizedBox(height: 24),
              ],

              // Expense forecast
              if (expenseForecast != null) ...[
                ExpenseForecastWidget(forecast: expenseForecast),
                const SizedBox(height: 24),
              ] else if (isRefreshing) ...[
                const WidgetSkeleton(height: 200, label: 'Expense Forecast'),
                const SizedBox(height: 24),
              ],

              // Essential vs Non-Essential breakdown
              if (essentialBreakdown != null) ...[
                EssentialBreakdownWidget(breakdown: essentialBreakdown),
                const SizedBox(height: 24),
              ] else if (isRefreshing) ...[
                const WidgetSkeleton(height: 160, label: 'Essential Breakdown'),
                const SizedBox(height: 24),
              ],

              // Category pie chart (expenses breakdown)
              if (summary.categoryBreakdown.isNotEmpty) ...[
                CategoryPieChart(
                  categories: summary.categoryBreakdown
                      .where((cat) => cat.isExpense)
                      .toList(),
                  title: AppLocalizations.of(context)!.expensesByCategory,
                ),
                const SizedBox(height: 24),
              ],

              // Member spending (shared budgets only)
              if (memberSpending != null) ...[
                MemberSpendingWidget(report: memberSpending),
                const SizedBox(height: 24),
              ],

              // Income by member (shared budgets only)
              if (incomeByMember != null) ...[
                IncomeByMemberWidget(
                  report: incomeByMember,
                  onMemberTap: (member) {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) => IncomeSourcesWidget(member: member),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],

              // Dashboard alerts
              if (alerts != null && alerts.hasAlerts) ...[
                DashboardAlertsWidget(
                  alerts: alerts.allAlerts.map((a) {
                    return AlertItem(
                      type: _mapAlertType(a.type),
                      severity: _mapAlertSeverity(a.severity),
                      title: a.title,
                      message: a.message,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
              ],

              // Credit card alerts (from dashboard alerts)
              if (alerts != null && alerts.creditCardDueAlerts.isNotEmpty) ...[
                CreditCardAlertsWidget(
                  alerts: alerts.creditCardDueAlerts.map((a) {
                    return {
                      'cardName': a.title,
                      'isOverdue': a.severity == 'critical',
                      'daysUntilDue': a.metadata?['daysUntilDue'] ?? 0,
                      'statementAmount': a.metadata?['amount'] ?? 0,
                    };
                  }).toList(),
                ),
                const SizedBox(height: 24),
              ],

              // Budget Health
              _buildBudgetHealthSection(),
              const SizedBox(height: 24),

              // Top Merchants
              TopMerchantsWidget(budgetId: widget.budgetId),
              const SizedBox(height: 24),

              // Recent transactions
              RecentTransactionsWidget(
                transactions: summary.recentTransactions,
                onViewAll: () {
                  // Navigate to transactions page
                  context.pushNamed(
                    'transactions',
                    pathParameters: {'budgetId': widget.budgetId},
                  );
                },
              ),
              const SizedBox(height: 16),

              // Additional insights
              _buildInsightsCard(summary),
            ],
          ),
        ),
      );
    }

    // Initial state
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.dashboard_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.dashboardAnalytics,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.loadDataToView,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadDashboard,
            child: Text(AppLocalizations.of(context)!.loadDashboard),
          ),
        ],
      ),
    );
  }

  /// Build budget health section from allocation provider
  Widget _buildBudgetHealthSection() {
    final allocationState = ref.watch(budgetAllocationProvider);
    if (allocationState is BudgetAllocationLoaded) {
      return BudgetHealthWidget(
        allocation: allocationState.allocation,
        onTap: () => context.push('/budgets/${widget.budgetId}/budget-plan'),
      );
    }
    // Trigger load if not yet loaded
    if (allocationState is BudgetAllocationInitial) {
      final now = DateTime.now();
      final month = '${now.year}-${now.month.toString().padLeft(2, '0')}';
      Future.microtask(
        () => ref
            .read(budgetAllocationProvider.notifier)
            .loadAllocations(widget.budgetId, month),
      );
    }
    return const SizedBox.shrink();
  }

  /// Build period header with refresh indicator
  Widget _buildPeriodHeader(String period, bool isRefreshing) {
    return Row(
      children: [
        Icon(
          Icons.calendar_today,
          size: 20,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Text(
          AppLocalizations.of(context)!.periodLabel(period),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
        ),
        if (isRefreshing) ...[
          const SizedBox(width: 12),
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Build insights card with financial metrics
  Widget _buildInsightsCard(summary) {
    final savingsRate = summary.savingsRate;
    final expenseRatio = summary.expenseRatio;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.amber[700],
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.financialInsights,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Savings rate
            _buildInsightRow(
              context,
              AppLocalizations.of(context)!.savingsRate,
              '${savingsRate.toStringAsFixed(1)}%',
              savingsRate >= 20
                  ? Colors.green[600]!
                  : savingsRate >= 10
                      ? Colors.orange[600]!
                      : Colors.red[600]!,
            ),
            const Divider(height: 24),

            // Expense ratio
            _buildInsightRow(
              context,
              AppLocalizations.of(context)!.expenseRate,
              '${expenseRatio.toStringAsFixed(1)}%',
              expenseRatio <= 80
                  ? Colors.green[600]!
                  : expenseRatio <= 100
                      ? Colors.orange[600]!
                      : Colors.red[600]!,
            ),
            const Divider(height: 24),

            // Cash flow status
            _buildInsightRow(
              context,
              AppLocalizations.of(context)!.cashFlowStatus,
              summary.isPositiveCashFlow ? AppLocalizations.of(context)!.positive : AppLocalizations.of(context)!.negative,
              summary.isPositiveCashFlow
                  ? Colors.green[600]!
                  : Colors.red[600]!,
            ),
          ],
        ),
      ),
    );
  }

  /// Build individual insight row
  Widget _buildInsightRow(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ),
      ],
    );
  }

  AlertType _mapAlertType(String type) {
    switch (type) {
      case 'low_balance':
        return AlertType.lowBalance;
      case 'category_limit':
        return AlertType.categoryLimit;
      case 'credit_card_due':
        return AlertType.creditCardDue;
      default:
        return AlertType.budgetMilestone;
    }
  }

  AlertSeverity _mapAlertSeverity(String severity) {
    switch (severity) {
      case 'critical':
        return AlertSeverity.critical;
      case 'warning':
        return AlertSeverity.warning;
      default:
        return AlertSeverity.info;
    }
  }
}
