import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/savings_goal.dart';
import '../providers/savings_goal_provider.dart';
import '../providers/savings_goal_state.dart';
import '../widgets/savings_goal_card.dart';

class SavingsGoalListPage extends ConsumerStatefulWidget {
  final String budgetId;

  const SavingsGoalListPage({
    super.key,
    required this.budgetId,
  });

  @override
  ConsumerState<SavingsGoalListPage> createState() =>
      _SavingsGoalListPageState();
}

class _SavingsGoalListPageState extends ConsumerState<SavingsGoalListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(
      () => ref
          .read(savingsGoalProvider.notifier)
          .loadSavingsGoals(widget.budgetId),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(savingsGoalProvider);
    final notifier = ref.read(savingsGoalProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.savingsGoals),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => notifier.loadSavingsGoals(widget.budgetId),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.active),
            Tab(text: l10n.completed),
          ],
        ),
      ),
      body: _buildBody(state, notifier),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(
            '/budgets/${widget.budgetId}/savings-goals/create'),
        icon: const Icon(Icons.add),
        label: Text(l10n.newGoal),
      ),
    );
  }

  Widget _buildBody(SavingsGoalState state, SavingsGoalNotifier notifier) {
    if (state is SavingsGoalLoading && notifier.goals.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is SavingsGoalError && notifier.goals.isEmpty) {
      return _buildErrorState(state.message);
    }

    final goals = notifier.goals;

    if (goals.isEmpty) {
      return _buildEmptyState();
    }

    final activeGoals =
        goals.where((g) => g.active && !g.isCompleted).toList();
    final completedGoals = goals.where((g) => g.isCompleted).toList();

    return TabBarView(
      controller: _tabController,
      children: [
        _buildGoalList(activeGoals, notifier, isActive: true),
        _buildGoalList(completedGoals, notifier, isActive: false),
      ],
    );
  }

  Widget _buildGoalList(
    List<SavingsGoal> goals,
    SavingsGoalNotifier notifier, {
    required bool isActive,
  }) {
    final l10n = AppLocalizations.of(context)!;
    if (goals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? Icons.savings_outlined : Icons.check_circle_outline,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              isActive ? l10n.noActiveGoals : l10n.noCompletedGoalsYet,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    // Calculate summary for active tab
    final totalSaved = goals.fold<double>(0, (s, g) => s + g.currentAmount);
    final totalTarget = goals.fold<double>(0, (s, g) => s + g.targetAmount);

    return RefreshIndicator(
      onRefresh: () => notifier.loadSavingsGoals(widget.budgetId),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (isActive) ...[
            _buildSummaryCard(goals.length, totalSaved, totalTarget),
            const SizedBox(height: 16),
          ],
          ...goals.map((goal) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SavingsGoalCard(
                  goal: goal,
                  onTap: () => context
                      .go('/savings-goals/${goal.id}?budgetId=${widget.budgetId}'),
                ),
              )),
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      int count, double totalSaved, double totalTarget) {
    final l10n = AppLocalizations.of(context)!;
    final percent = totalTarget > 0
        ? ((totalSaved / totalTarget) * 100).toInt()
        : 0;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSummaryItem(
              icon: Icons.savings,
              label: l10n.totalSaved,
              value: 'BRL ${totalSaved.toStringAsFixed(2)}',
              valueColor: Colors.green,
            ),
            Container(height: 40, width: 1, color: Colors.grey[300]),
            _buildSummaryItem(
              icon: Icons.trending_up,
              label: l10n.progress,
              value: '$percent%',
              valueColor: Theme.of(context).primaryColor,
            ),
            Container(height: 40, width: 1, color: Colors.grey[300]),
            _buildSummaryItem(
              icon: Icons.flag,
              label: l10n.goals,
              value: count.toString(),
              valueColor: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Colors.grey[600]),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.savings_outlined, size: 120, color: Colors.grey[300]),
          const SizedBox(height: 24),
          Text(
            l10n.noSavingsGoalsYet,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.createFirstSavingsDescription,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.go(
                '/budgets/${widget.budgetId}/savings-goals/create'),
            icon: const Icon(Icons.add),
            label: Text(l10n.createGoal),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
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
                .read(savingsGoalProvider.notifier)
                .loadSavingsGoals(widget.budgetId),
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }
}
