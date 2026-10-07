import 'package:flutter/material.dart';
import '../../domain/entities/savings_goal.dart';
import 'savings_goal_progress_bar.dart';

class SavingsGoalCard extends StatelessWidget {
  final SavingsGoal goal;
  final VoidCallback? onTap;
  final VoidCallback? onContribute;
  final VoidCallback? onWithdraw;

  const SavingsGoalCard({
    super.key,
    required this.goal,
    this.onTap,
    this.onContribute,
    this.onWithdraw,
  });

  Color? get _cardColor {
    if (goal.color != null && goal.color!.isNotEmpty) {
      try {
        final hex = goal.color!.replaceFirst('#', '');
        return Color(int.parse('FF$hex', radix: 16));
      } catch (_) {}
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
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
              _buildHeader(context),
              const SizedBox(height: 12),
              SavingsGoalProgressBar(
                currentAmount: goal.currentAmount,
                targetAmount: goal.targetAmount,
                color: _cardColor,
              ),
              const SizedBox(height: 8),
              _buildAmounts(context),
              if (goal.daysRemaining != null || goal.isCompleted || goal.isExpired)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _buildStatusChips(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        if (goal.icon != null && goal.icon!.isNotEmpty) ...[
          Text(goal.icon!, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
        ] else ...[
          Icon(Icons.savings, size: 24, color: _cardColor ?? Colors.blue),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
            goal.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          '${goal.progressPercent}%',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _cardColor ?? Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildAmounts(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          goal.formattedCurrentAmount,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        Text(
          'of ${goal.formattedTargetAmount}',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChips() {
    return Wrap(
      spacing: 8,
      children: [
        if (goal.isCompleted)
          _buildChip('Completed', Colors.green),
        if (goal.isExpired)
          _buildChip('Expired', Colors.red),
        if (goal.daysRemaining != null && !goal.isCompleted && !goal.isExpired)
          _buildChip(
            '${goal.daysRemaining} days left',
            goal.daysRemaining! <= 7 ? Colors.orange : Colors.blue,
          ),
      ],
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
