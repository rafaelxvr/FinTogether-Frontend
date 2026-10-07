import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/budget.dart';
import '../providers/budget_provider.dart';
import '../providers/budget_state.dart';

class BudgetDetailsPage extends ConsumerStatefulWidget {
  final String budgetId;

  const BudgetDetailsPage({
    super.key,
    required this.budgetId,
  });

  @override
  ConsumerState<BudgetDetailsPage> createState() => _BudgetDetailsPageState();
}

class _BudgetDetailsPageState extends ConsumerState<BudgetDetailsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(budgetProvider.notifier).loadBudgets(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final budgetState = ref.watch(budgetProvider);
    final budgetNotifier = ref.read(budgetProvider.notifier);
    final budgets = budgetState is BudgetsLoaded
        ? budgetState.budgets
        : budgetNotifier.budgets;

    final budget = budgets.where((b) => b.id == widget.budgetId).firstOrNull;

    if (budget == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.budgetDetails),
        ),
        body: Center(
          child: Text(l10n.budgetNotFound),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(budget.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.featureComingSoon('Edit'))),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _confirmDelete(context, budget);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(l10n.deleteBudget),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(budget),
            const SizedBox(height: 16),
            _buildMembersCard(context, budget),
            const SizedBox(height: 16),
            _buildQuickActionsCard(context, budget),
            const SizedBox(height: 16),
            _buildStatisticsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(Budget budget) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('dd MMM yyyy');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  budget.isPersonal ? Icons.person : Icons.group,
                  size: 32,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        budget.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        budget.isPersonal ? l10n.personalBudget : l10n.sharedBudget,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(l10n.owner, budget.ownerName),
            const SizedBox(height: 8),
            _buildInfoRow(l10n.members, '${budget.memberCount}'),
            const SizedBox(height: 8),
            _buildInfoRow(l10n.createdAt, dateFormat.format(budget.createdAt)),
            const SizedBox(height: 8),
            _buildInfoRow(l10n.lastUpdated, dateFormat.format(budget.updatedAt)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildMembersCard(BuildContext context, Budget budget) {
    final l10n = AppLocalizations.of(context)!;
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
                  l10n.members,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (budget.isShared)
                  TextButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.featureComingSoon('Manage')),
                        ),
                      );
                    },
                    icon: const Icon(Icons.person_add),
                    label: Text(l10n.manage),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: const Icon(Icons.person, color: Colors.white),
              ),
              title: Text(budget.ownerName),
              subtitle: Text(l10n.owner),
              trailing: const Icon(Icons.star, color: Colors.amber),
            ),
            if (budget.memberCount > 1)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '+${budget.memberCount - 1} ${l10n.members.toLowerCase()}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsCard(BuildContext context, Budget budget) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.quickActions,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _buildActionTile(
              context,
              icon: Icons.account_balance_wallet,
              title: l10n.accounts,
              subtitle: l10n.trackAccounts,
              onTap: () => context.push('/budgets/${budget.id}/accounts'),
            ),
            _buildActionTile(
              context,
              icon: Icons.category,
              title: l10n.categories,
              subtitle: l10n.organizeExpenses,
              onTap: () => context.push('/budgets/${budget.id}/categories'),
            ),
            _buildActionTile(
              context,
              icon: Icons.receipt_long,
              title: l10n.transactions,
              subtitle: l10n.viewActivity,
              onTap: () => context.push('/budgets/${budget.id}/transactions'),
            ),
            _buildActionTile(
              context,
              icon: Icons.dashboard,
              title: l10n.analytics,
              subtitle: l10n.detailedInsights,
              onTap: () => context.push('/budgets/${budget.id}/analytics'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
        child: Icon(icon, color: Theme.of(context).primaryColor),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildStatisticsCard() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.statistics,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: l10n.accounts,
                    value: '-',
                    icon: Icons.account_balance,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: l10n.categories,
                    value: '-',
                    icon: Icons.category,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: l10n.transactions,
                    value: '-',
                    icon: Icons.receipt,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: l10n.creditCards,
                    value: '-',
                    icon: Icons.credit_card,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Budget budget) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteBudget),
        content: Text(l10n.deleteBudgetConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await ref.read(budgetProvider.notifier).deleteBudget(budget.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.budgetDeleted),
                      backgroundColor: Colors.green,
                    ),
                  );
                  context.go('/budgets');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${l10n.error}: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
