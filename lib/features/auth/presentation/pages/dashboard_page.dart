import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../budget/presentation/providers/budget_provider.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../../dashboard/presentation/providers/dashboard_state.dart' as dashboard_state;
import '../../../dashboard/presentation/widgets/cashflow_line_chart.dart';
import '../../../dashboard/presentation/widgets/category_pie_chart.dart';
import '../../../dashboard/presentation/widgets/recent_transactions_widget.dart';
import '../../../dashboard/presentation/widgets/summary_card.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  String? _selectedBudgetId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(budgetProvider.notifier).loadBudgets();
      final budgets = ref.read(budgetProvider.notifier).budgets;
      if (budgets.isNotEmpty) {
        final budgetId = budgets[0].id;
        setState(() {
          _selectedBudgetId = budgetId;
        });
        _loadDashboardData(budgetId);
      }
    });
  }

  void _loadDashboardData(String budgetId) {
    ref.read(dashboardProvider.notifier).loadDashboard(
          budgetId,
          loadCashflow: true,
          cashflowMonths: 6,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);

    String userName = 'User';
    if (authState is AuthAuthenticated) {
      userName = authState.user.name;
    }

    final budgets = ref.read(budgetProvider.notifier).budgets;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(budgetProvider.notifier).loadBudgets(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(context, userName),
              const SizedBox(height: 24),
              _buildBudgetSelector(context, budgets),

              // Dashboard Analytics Section
              if (_selectedBudgetId != null) ...[
                const SizedBox(height: 24),
                _buildDashboardAnalytics(context),
              ],

              const SizedBox(height: 24),
              Text(
                l10n.manageFinances,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              _buildFeatureGrid(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, String userName) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                userName[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.welcomeBack,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    userName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetSelector(BuildContext context, List budgets) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.activeBudget,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton.icon(
                  onPressed: () => context.push('/budgets'),
                  icon: const Icon(Icons.settings, size: 18),
                  label: Text(AppLocalizations.of(context)!.manage),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (budgets.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.noBudgetsYet,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              DropdownButtonFormField<String>(
                value: _selectedBudgetId ?? (budgets.isNotEmpty ? budgets[0].id : null),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.account_balance_wallet),
                  border: OutlineInputBorder(),
                ),
                items: budgets.map<DropdownMenuItem<String>>((budget) {
                  return DropdownMenuItem<String>(
                    value: budget.id,
                    child: Text(budget.name),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedBudgetId = value;
                    });
                    _loadDashboardData(value);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final budgets = ref.read(budgetProvider.notifier).budgets;
    final hasBudget = budgets.isNotEmpty;
    final selectedId = _selectedBudgetId ?? (budgets.isNotEmpty ? budgets[0].id : null);

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildFeatureCard(
          context: context,
          icon: Icons.account_balance_wallet,
          title: l10n.budgets,
          subtitle: l10n.manageBudgets,
          color: Colors.blue,
          onTap: () => context.push('/budgets'),
        ),
        _buildFeatureCard(
          context: context,
          icon: Icons.account_balance,
          title: l10n.accounts,
          subtitle: l10n.trackAccounts,
          color: Colors.green,
          onTap: hasBudget
              ? () => context.push('/budgets/$selectedId/accounts')
              : () => _showNoBudgetDialog(context),
        ),
        _buildFeatureCard(
          context: context,
          icon: Icons.category,
          title: l10n.categories,
          subtitle: l10n.organizeExpenses,
          color: Colors.orange,
          onTap: hasBudget
              ? () => context.push('/budgets/$selectedId/categories')
              : () => _showNoBudgetDialog(context),
        ),
        _buildFeatureCard(
          context: context,
          icon: Icons.receipt_long,
          title: l10n.transactions,
          subtitle: l10n.viewActivity,
          color: Colors.purple,
          onTap: hasBudget
              ? () => context.push('/budgets/$selectedId/transactions')
              : () => _showNoBudgetDialog(context),
        ),
        _buildFeatureCard(
          context: context,
          icon: Icons.credit_card,
          title: l10n.creditCards,
          subtitle: l10n.manageCards,
          color: Colors.deepOrange,
          onTap: hasBudget
              ? () => context.push('/budgets/$selectedId/credit-cards')
              : () => _showNoBudgetDialog(context),
        ),
        _buildFeatureCard(
          context: context,
          icon: Icons.analytics,
          title: l10n.analytics,
          subtitle: l10n.detailedInsights,
          color: Colors.teal,
          onTap: hasBudget
              ? () => context.push('/budgets/$selectedId/analytics')
              : () => _showNoBudgetDialog(context),
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardAnalytics(BuildContext context) {
    final dashboardState = ref.watch(dashboardProvider);

    if (dashboardState is dashboard_state.DashboardInitial) {
      return const SizedBox.shrink();
    }

    if (dashboardState is dashboard_state.DashboardLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (dashboardState is dashboard_state.DashboardLoaded) {
      final summary = dashboardState.summary;
      final cashflowTrend = dashboardState.cashflowTrend;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards Grid
          SummaryCardsGrid(
            totalIncome: summary.totalIncome,
            totalExpense: summary.totalExpense,
            netCashFlow: summary.netCashFlow,
            accountsBalance: summary.accountsBalance,
          ),
          const SizedBox(height: 16),

          // Category Pie Chart
          if (summary.categoryBreakdown.isNotEmpty)
            CategoryPieChart(
              categories: summary.categoryBreakdown,
            ),
          if (summary.categoryBreakdown.isNotEmpty) const SizedBox(height: 16),

          // Cashflow Line Chart
          if (cashflowTrend != null)
            CashflowLineChart(
              trend: cashflowTrend,
            ),
          if (cashflowTrend != null) const SizedBox(height: 16),

          // Recent Transactions
          if (summary.recentTransactions.isNotEmpty)
            RecentTransactionsWidget(
              transactions: summary.recentTransactions,
              onViewAll: () {
                if (_selectedBudgetId != null) {
                  context.push('/budgets/$_selectedBudgetId/transactions');
                }
              },
            ),
        ],
      );
    }

    if (dashboardState is dashboard_state.DashboardError) {
      final message = dashboardState.message;
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context)!.failedToLoadDashboard,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  if (_selectedBudgetId != null) {
                    _loadDashboardData(_selectedBudgetId!);
                  }
                },
                icon: const Icon(Icons.refresh),
                label: Text(AppLocalizations.of(context)!.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (dashboardState is dashboard_state.DashboardRefreshing) {
      final currentSummary = dashboardState.currentSummary;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Show current data with opacity while refreshing
          Opacity(
            opacity: 0.6,
            child: Column(
              children: [
                SummaryCardsGrid(
                  totalIncome: currentSummary.totalIncome,
                  totalExpense: currentSummary.totalExpense,
                  netCashFlow: currentSummary.netCashFlow,
                  accountsBalance: currentSummary.accountsBalance,
                ),
                const SizedBox(height: 16),
                if (currentSummary.categoryBreakdown.isNotEmpty)
                  CategoryPieChart(
                    categories: currentSummary.categoryBreakdown,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ],
      );
    }

    // Default case - should never happen
    return const SizedBox.shrink();
  }

  void _showNoBudgetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.noBudgetSelected),
        content: Text(AppLocalizations.of(context)!.pleaseCreateOrSelectBudget),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/budgets');
            },
            child: Text(AppLocalizations.of(context)!.goToBudgets),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.logout),
        content: Text(AppLocalizations.of(context)!.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)!.logout),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      ref.read(authProvider.notifier).logout();
      context.go('/login');
    }
  }
}
