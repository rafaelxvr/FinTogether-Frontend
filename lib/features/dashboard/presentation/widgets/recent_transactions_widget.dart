import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/dashboard_summary.dart';

/// Recent Transactions Widget
/// Displays a list of recent transactions with compact view
class RecentTransactionsWidget extends StatelessWidget {
  final List<TransactionSummary> transactions;
  final VoidCallback? onViewAll;

  const RecentTransactionsWidget({
    super.key,
    required this.transactions,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and "View All" button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transações Recentes',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (onViewAll != null)
                  TextButton(
                    onPressed: onViewAll,
                    child: const Text('Ver Todas'),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Transactions list
            if (transactions.isEmpty)
              _buildEmptyState(context)
            else
              ...transactions.map((transaction) {
                return _TransactionTile(transaction: transaction);
              }),
          ],
        ),
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32.0),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              'Nenhuma transação recente',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Adicione transações para vê-las aqui',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Transaction Tile
/// Compact view of a single transaction
class _TransactionTile extends StatelessWidget {
  final TransactionSummary transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );

    final dateFormat = DateFormat('dd/MM', 'pt_BR');

    // Determine icon and color based on transaction type
    IconData icon;
    Color iconColor;

    if (transaction.isIncome) {
      icon = Icons.arrow_upward;
      iconColor = Colors.green[600]!;
    } else if (transaction.isExpense) {
      icon = Icons.arrow_downward;
      iconColor = Colors.red[600]!;
    } else {
      // Transfer
      icon = Icons.swap_horiz;
      iconColor = Colors.blue[600]!;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // Icon circle
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Description and category
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    // Date
                    Text(
                      dateFormat.format(transaction.date),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    if (transaction.categoryName != null) ...[
                      Text(
                        ' • ',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      // Category
                      Flexible(
                        child: Text(
                          transaction.categoryName!,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Amount
          Text(
            currencyFormat.format(transaction.amount),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: transaction.isIncome
                      ? Colors.green[700]
                      : transaction.isExpense
                          ? Colors.red[700]
                          : Colors.blue[700],
                ),
          ),
        ],
      ),
    );
  }
}
