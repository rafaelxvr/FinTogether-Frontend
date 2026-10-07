import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/budget_allocation.dart';
import '../providers/budget_allocation_provider.dart';
import '../providers/budget_allocation_state.dart';
import '../widgets/allocation_bar.dart';

/// Budget Plan Page
/// Shows allocations with actual spending for a budget and month.
/// Includes month navigation, summary header, and per-category allocation bars.
class BudgetPlanPage extends ConsumerStatefulWidget {
  final String budgetId;

  const BudgetPlanPage({super.key, required this.budgetId});

  @override
  ConsumerState<BudgetPlanPage> createState() => _BudgetPlanPageState();
}

class _BudgetPlanPageState extends ConsumerState<BudgetPlanPage> {
  late String _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = _formatCurrentMonth();
    Future.microtask(
      () => ref
          .read(budgetAllocationProvider.notifier)
          .loadAllocations(widget.budgetId, _currentMonth),
    );
  }

  String _formatCurrentMonth() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  String _formatMonthDisplay(String month) {
    try {
      final parts = month.split('-');
      final year = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final date = DateTime(year, m);
      return DateFormat('MMMM yyyy').format(date);
    } catch (_) {
      return month;
    }
  }

  String _previousMonth(String month) {
    final parts = month.split('-');
    var year = int.parse(parts[0]);
    var m = int.parse(parts[1]);
    m -= 1;
    if (m < 1) {
      m = 12;
      year -= 1;
    }
    return '$year-${m.toString().padLeft(2, '0')}';
  }

  String _nextMonth(String month) {
    final parts = month.split('-');
    var year = int.parse(parts[0]);
    var m = int.parse(parts[1]);
    m += 1;
    if (m > 12) {
      m = 1;
      year += 1;
    }
    return '$year-${m.toString().padLeft(2, '0')}';
  }

  void _navigateToPreviousMonth() {
    setState(() {
      _currentMonth = _previousMonth(_currentMonth);
    });
    ref
        .read(budgetAllocationProvider.notifier)
        .loadAllocations(widget.budgetId, _currentMonth);
  }

  void _navigateToNextMonth() {
    setState(() {
      _currentMonth = _nextMonth(_currentMonth);
    });
    ref
        .read(budgetAllocationProvider.notifier)
        .loadAllocations(widget.budgetId, _currentMonth);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(budgetAllocationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.budgetPlan),
      ),
      body: Column(
        children: [
          _buildMonthNavigation(),
          Expanded(child: _buildBody(state)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push(
            '/budgets/${widget.budgetId}/budget-plan/edit?month=$_currentMonth',
          );
        },
        icon: const Icon(Icons.edit),
        label: Text(l10n.editAllocations),
      ),
    );
  }

  Widget _buildMonthNavigation() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withOpacity(0.3),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _navigateToPreviousMonth,
            tooltip: l10n.previousMonth,
          ),
          Text(
            _formatMonthDisplay(_currentMonth),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _navigateToNextMonth,
            tooltip: l10n.nextMonth,
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BudgetAllocationState state) {
    final l10n = AppLocalizations.of(context)!;
    if (state is BudgetAllocationLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is BudgetAllocationError) {
      return _buildErrorState(state.message);
    }

    if (state is BudgetAllocationLoaded) {
      return _buildAllocationContent(state.allocation);
    }

    if (state is BudgetAllocationSaved) {
      return _buildAllocationContent(state.allocation);
    }

    return Center(
      child: Text(l10n.selectMonthToViewBudgetPlan),
    );
  }

  Widget _buildAllocationContent(BudgetAllocation allocation) {
    final currencyFormat =
        NumberFormat.currency(symbol: 'R\$ ', decimalDigits: 2);

    if (allocation.categories.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => ref
          .read(budgetAllocationProvider.notifier)
          .loadAllocations(widget.budgetId, _currentMonth),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary header
          _buildSummaryHeader(allocation, currencyFormat),
          const SizedBox(height: 16),

          // Allocation bars
          ...allocation.categories.map(
            (cat) => AllocationBar(allocation: cat),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader(
    BudgetAllocation allocation,
    NumberFormat currencyFormat,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final healthColor = _healthColor(allocation.healthStatus);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.totalAllocated,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      currencyFormat.format(allocation.totalAllocated),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: healthColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    l10n.percentUsed(allocation.overallPercentageUsed.toStringAsFixed(0)),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: healthColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoColumn(
                  l10n.spent,
                  currencyFormat.format(allocation.totalSpent),
                ),
                _buildInfoColumn(
                  l10n.remaining,
                  currencyFormat.format(allocation.totalRemaining),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Color _healthColor(BudgetHealthStatus status) {
    switch (status) {
      case BudgetHealthStatus.healthy:
        return Colors.green;
      case BudgetHealthStatus.warning:
        return Colors.orange;
      case BudgetHealthStatus.overBudget:
        return Colors.red;
    }
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 24),
          Text(
            l10n.noAllocations,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.noAllocationsDescription,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            l10n.error,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => ref
                .read(budgetAllocationProvider.notifier)
                .loadAllocations(widget.budgetId, _currentMonth),
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }
}
