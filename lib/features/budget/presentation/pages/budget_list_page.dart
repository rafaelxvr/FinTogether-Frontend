import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/budget.dart';
import '../providers/budget_provider.dart';
import '../providers/budget_state.dart';
import '../widgets/budget_card.dart';
import 'create_budget_page.dart';

class BudgetListPage extends ConsumerStatefulWidget {
  const BudgetListPage({super.key});

  @override
  ConsumerState<BudgetListPage> createState() => _BudgetListPageState();
}

class _BudgetListPageState extends ConsumerState<BudgetListPage> {
  @override
  void initState() {
    super.initState();
    // Load budgets when page is first opened
    Future.microtask(() => ref.read(budgetProvider.notifier).loadBudgets());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final budgetState = ref.watch(budgetProvider);
    final budgetNotifier = ref.read(budgetProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myBudgets),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => budgetNotifier.loadBudgets(),
            tooltip: l10n.refresh,
          ),
        ],
      ),
      body: _buildBody(budgetState, budgetNotifier),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateBudgetDialog(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.newBudget),
      ),
    );
  }

  Widget _buildBody(BudgetState state, budgetNotifier) {
    if (state is BudgetLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is BudgetError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              state.message,
              style: TextStyle(color: Colors.red[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => budgetNotifier.loadBudgets(),
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context)!.retry),
            ),
          ],
        ),
      );
    }

    final budgets = budgetNotifier.budgets;

    if (budgets.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () => budgetNotifier.loadBudgets(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: budgets.length,
        itemBuilder: (context, index) {
          final budget = budgets[index];
          return BudgetCard(
            budget: budget,
            onTap: () => _onBudgetTapped(budget),
            onEdit: () => _showEditBudgetDialog(context, budget),
            onDelete: () => _showDeleteConfirmation(context, budget),
            onManageMembers: () => _navigateToMemberManagement(budget),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 120,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.noBudgetsEmptyTitle,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.createFirstBudgetDescription,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _showCreateBudgetDialog(context),
            icon: const Icon(Icons.add),
            label: Text(AppLocalizations.of(context)!.createBudget),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateBudgetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreateBudgetDialog(),
    );
  }

  void _showEditBudgetDialog(BuildContext context, Budget budget) {
    showDialog(
      context: context,
      builder: (context) => CreateBudgetDialog(budget: budget),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Budget budget) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteBudget),
        content: Text(
          AppLocalizations.of(context)!.deleteConfirmWithName(budget.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(budgetProvider.notifier).deleteBudget(budget.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context)!.budgetDeleted)),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
  }

  void _onBudgetTapped(Budget budget) {
    context.go('/budgets/${budget.id}/details');
  }

  void _navigateToMemberManagement(Budget budget) {
    context.go('/budgets/${budget.id}/members');
  }
}
