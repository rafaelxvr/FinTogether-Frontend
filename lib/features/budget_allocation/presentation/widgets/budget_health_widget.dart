import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/budget_allocation.dart';

/// Compact dashboard widget showing budget health as a circular progress indicator.
/// Tap navigates to BudgetPlanPage.
class BudgetHealthWidget extends StatelessWidget {
  final BudgetAllocation allocation;
  final VoidCallback? onTap;

  const BudgetHealthWidget({
    super.key,
    required this.allocation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
        NumberFormat.currency(symbol: 'R\$ ', decimalDigits: 2);
    final percentage = allocation.overallPercentageUsed.clamp(0.0, 200.0);
    final healthColor = _healthColor(allocation.healthStatus);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Circular progress indicator
              SizedBox(
                width: 64,
                height: 64,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: (percentage / 100).clamp(0.0, 1.0),
                      strokeWidth: 6,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(healthColor),
                    ),
                    Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: healthColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Text info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Budget Health',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${currencyFormat.format(allocation.totalSpent)} of ${currencyFormat.format(allocation.totalAllocated)} spent',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: healthColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _healthLabel(allocation.healthStatus),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: healthColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
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

  String _healthLabel(BudgetHealthStatus status) {
    switch (status) {
      case BudgetHealthStatus.healthy:
        return 'HEALTHY';
      case BudgetHealthStatus.warning:
        return 'WARNING';
      case BudgetHealthStatus.overBudget:
        return 'OVER BUDGET';
    }
  }
}
