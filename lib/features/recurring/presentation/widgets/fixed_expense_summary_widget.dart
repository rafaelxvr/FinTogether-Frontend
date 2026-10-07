import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/fixed_expense_summary.dart';

/// Card widget showing a summary of fixed monthly costs.
class FixedExpenseSummaryWidget extends StatelessWidget {
  final FixedExpenseSummary summary;
  final VoidCallback? onSeeAll;

  const FixedExpenseSummaryWidget({
    super.key,
    required this.summary,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat =
        NumberFormat.currency(symbol: 'R\$ ', decimalDigits: 2);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.lock_clock,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Fixed Monthly Costs',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Total amount
            Text(
              currencyFormat.format(summary.totalMonthlyAmount),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 4),

            // Expense count
            Text(
              '${summary.expenseCount} fixed expense${summary.expenseCount != 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),

            // Mini list of top 3 expenses
            if (summary.expenses.isNotEmpty) ...[
              const Divider(),
              ...summary.expenses.take(3).map((expense) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          expense.description,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Text(
                        currencyFormat.format(expense.amount),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],

            // See all button
            if (summary.expenseCount > 3 && onSeeAll != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onSeeAll,
                  child: const Text('See all'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
