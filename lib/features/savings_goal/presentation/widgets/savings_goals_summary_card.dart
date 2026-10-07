import 'package:flutter/material.dart';
import '../../domain/entities/savings_goal.dart';
import 'savings_goal_progress_bar.dart';

class SavingsGoalsSummaryCard extends StatelessWidget {
  final List<SavingsGoal> goals;
  final VoidCallback? onTap;

  const SavingsGoalsSummaryCard({
    super.key,
    required this.goals,
    this.onTap,
  });

  List<SavingsGoal> get _activeGoals =>
      goals.where((g) => g.active && !g.isCompleted).toList();

  double get _totalSaved =>
      goals.fold(0.0, (sum, g) => sum + g.currentAmount);

  double get _totalTarget =>
      goals.fold(0.0, (sum, g) => sum + g.targetAmount);

  List<SavingsGoal> get _topGoals {
    final sorted = List<SavingsGoal>.from(_activeGoals)
      ..sort((a, b) =>
          b.progressPercentage.compareTo(a.progressPercentage));
    return sorted.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (goals.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.savings, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Savings Goals',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_activeGoals.length} active',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Overall progress bar
              SavingsGoalProgressBar(
                currentAmount: _totalSaved,
                targetAmount: _totalTarget,
                height: 14,
              ),
              const SizedBox(height: 6),
              Text(
                '${_totalTarget > 0 ? ((_totalSaved / _totalTarget) * 100).toInt() : 0}% overall',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              const SizedBox(height: 12),

              // Top goals
              ..._topGoals.map((goal) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        if (goal.icon != null && goal.icon!.isNotEmpty)
                          Text(goal.icon!, style: const TextStyle(fontSize: 14))
                        else
                          const Icon(Icons.flag, size: 14),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            goal.name,
                            style: const TextStyle(fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${goal.progressPercent}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
