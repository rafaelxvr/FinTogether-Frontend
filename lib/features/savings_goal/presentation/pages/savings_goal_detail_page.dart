import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/savings_goal.dart';
import '../../domain/entities/savings_goal_contribution.dart';
import '../providers/savings_goal_provider.dart';
import '../providers/savings_goal_state.dart';
import '../widgets/savings_goal_progress_bar.dart';
import '../widgets/contribute_bottom_sheet.dart';

class SavingsGoalDetailPage extends ConsumerStatefulWidget {
  final String goalId;
  final String budgetId;

  const SavingsGoalDetailPage({
    super.key,
    required this.goalId,
    required this.budgetId,
  });

  @override
  ConsumerState<SavingsGoalDetailPage> createState() =>
      _SavingsGoalDetailPageState();
}

class _SavingsGoalDetailPageState
    extends ConsumerState<SavingsGoalDetailPage> {
  SavingsGoal? _goal;
  List<SavingsGoalContribution> _contributions = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(savingsGoalProvider.notifier)
          .getSavingsGoalById(widget.goalId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(savingsGoalProvider);

    ref.listen<SavingsGoalState>(savingsGoalProvider, (previous, next) {
      if (next is SavingsGoalLoaded) {
        setState(() => _goal = next.goal);
        // Load contributions after goal is loaded
        ref
            .read(savingsGoalProvider.notifier)
            .loadContributions(widget.goalId);
      } else if (next is ContributionSuccess ||
          next is WithdrawalSuccess) {
        // Refresh goal and contributions
        ref
            .read(savingsGoalProvider.notifier)
            .getSavingsGoalById(widget.goalId);
      } else if (next is ContributionsLoaded) {
        setState(() => _contributions = next.contributions);
      } else if (next is SavingsGoalDeleted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.savingsGoalDeleted)),
        );
      }
    });

    if (_goal == null && state is SavingsGoalLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_goal == null && state is SavingsGoalError) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(state.message)),
      );
    }

    final goal = _goal;
    if (goal == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.goalNotFound)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(goal.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.go(
                '/savings-goals/${goal.id}/edit?budgetId=${widget.budgetId}'),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _confirmDelete(context, goal);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'delete',
                child: Text(l10n.delete,
                    style: const TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProgressSection(goal),
            const SizedBox(height: 16),
            _buildActionButtons(goal),
            const SizedBox(height: 16),
            _buildDetailsCard(goal),
            const SizedBox(height: 16),
            _buildContributionHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(SavingsGoal goal) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Large progress indicator
            SizedBox(
              width: 150,
              height: 150,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: CircularProgressIndicator(
                      value: goal.progressPercentage,
                      strokeWidth: 12,
                      backgroundColor: Colors.grey[200],
                      color: goal.isCompleted
                          ? const Color(0xFFFFD700)
                          : Colors.blue,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${goal.progressPercent}%',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (goal.isCompleted)
                        Text(
                          l10n.completedExclamation,
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Amounts
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.current,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey[500])),
                    Text(
                      goal.formattedCurrentAmount,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(l10n.target,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey[500])),
                    Text(
                      goal.formattedTargetAmount,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            SavingsGoalProgressBar(
              currentAmount: goal.currentAmount,
              targetAmount: goal.targetAmount,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.remainingAmount(goal.formattedRemainingAmount),
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(SavingsGoal goal) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => showContributeBottomSheet(
              context,
              goal: goal,
              budgetId: widget.budgetId,
            ),
            icon: const Icon(Icons.add),
            label: Text(l10n.contribute),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: goal.currentAmount > 0
                ? () => showContributeBottomSheet(
                      context,
                      goal: goal,
                      budgetId: widget.budgetId,
                      isWithdrawal: true,
                    )
                : null,
            icon: const Icon(Icons.remove),
            label: Text(l10n.withdraw),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsCard(SavingsGoal goal) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.details,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            if (goal.description != null && goal.description!.isNotEmpty)
              _detailRow(l10n.description, goal.description!),
            _detailRow(l10n.currency, goal.currency),
            if (goal.deadline != null)
              _detailRow(
                l10n.deadline,
                '${goal.deadline!.day}/${goal.deadline!.month}/${goal.deadline!.year}'
                '${goal.daysRemaining != null ? " (${l10n.daysLeft(goal.daysRemaining!)})" : ""}',
              ),
            _detailRow(l10n.status, goal.status.displayName),
            if (goal.accountId != null)
              _detailRow(l10n.linkedAccount, goal.accountId!),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContributionHistory() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.contributionHistory,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            if (_contributions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    l10n.noContributionsYet,
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ),
              )
            else
              ..._contributions.map((c) => _buildContributionTile(c)),
          ],
        ),
      ),
    );
  }

  Widget _buildContributionTile(SavingsGoalContribution contribution) {
    final isWithdrawal = contribution.isWithdrawal;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor:
            isWithdrawal ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
        child: Icon(
          isWithdrawal ? Icons.remove : Icons.add,
          color: isWithdrawal ? Colors.red : Colors.green,
          size: 20,
        ),
      ),
      title: Text(
        contribution.formattedAmount,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isWithdrawal ? Colors.red : Colors.green,
        ),
      ),
      subtitle: contribution.note != null && contribution.note!.isNotEmpty
          ? Text(contribution.note!)
          : null,
      trailing: Text(
        '${contribution.contributedAt.day}/${contribution.contributedAt.month}/${contribution.contributedAt.year}',
        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
      ),
    );
  }

  void _confirmDelete(BuildContext context, SavingsGoal goal) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteSavingsGoal),
        content: Text(
          '${l10n.deleteConfirmWithName(goal.name)}\n${l10n.actionCannotBeUndone}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(savingsGoalProvider.notifier).deleteSavingsGoal(
                    budgetId: widget.budgetId,
                    id: goal.id,
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}
