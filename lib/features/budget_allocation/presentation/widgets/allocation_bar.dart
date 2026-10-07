import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/budget_allocation.dart';

/// Reusable widget showing a single category's allocation progress.
/// Displays category name, horizontal progress bar (color-coded), and amounts.
class AllocationBar extends StatelessWidget {
  final CategoryAllocation allocation;

  const AllocationBar({super.key, required this.allocation});

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
        NumberFormat.currency(symbol: 'R\$ ', decimalDigits: 2);
    final progress =
        allocation.allocatedAmount > 0
            ? (allocation.spentAmount / allocation.allocatedAmount).clamp(0.0, 1.5)
            : 0.0;
    final barColor = _resolveBarColor(allocation.barColor);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category name and percentage
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      if (allocation.categoryIcon != null) ...[
                        Icon(
                          Icons.category,
                          size: 18,
                          color: _parseCategoryColor(allocation.categoryColor),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Text(
                          allocation.categoryName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: barColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${allocation.percentageUsed.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: barColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Progress bar
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(barColor),
                  minHeight: 8,
                ),
              ),
            ),
            const SizedBox(height: 6),

            // Amounts
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${currencyFormat.format(allocation.spentAmount)} / ${currencyFormat.format(allocation.allocatedAmount)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                if (allocation.isOverBudget)
                  Text(
                    'Over by ${currencyFormat.format(allocation.spentAmount - allocation.allocatedAmount)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else
                  Text(
                    '${currencyFormat.format(allocation.remainingAmount)} left',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _resolveBarColor(AllocationBarColor color) {
    switch (color) {
      case AllocationBarColor.green:
        return Colors.green;
      case AllocationBarColor.yellow:
        return Colors.orange;
      case AllocationBarColor.red:
        return Colors.red;
    }
  }

  Color? _parseCategoryColor(String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) return null;
    try {
      final hex = colorHex.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return null;
    }
  }
}
