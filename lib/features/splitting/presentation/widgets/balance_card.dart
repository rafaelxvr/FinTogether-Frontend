import 'package:flutter/material.dart';
import '../../domain/entities/member_balance.dart';

/// Displays a single balance entry: debtor avatar, amount, creditor avatar, settle action.
class BalanceCard extends StatelessWidget {
  final MemberBalance balance;
  final VoidCallback? onSettle;

  const BalanceCard({
    super.key,
    required this.balance,
    this.onSettle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Debtor avatar
            CircleAvatar(
              backgroundColor: theme.colorScheme.errorContainer,
              child: Text(
                balance.userName.isNotEmpty
                    ? balance.userName[0].toUpperCase()
                    : '?',
                style: TextStyle(color: theme.colorScheme.onErrorContainer),
              ),
            ),
            const SizedBox(width: 12),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    balance.userName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  RichText(
                    text: TextSpan(
                      style: theme.textTheme.bodySmall,
                      children: [
                        const TextSpan(text: 'owes '),
                        TextSpan(
                          text: balance.owesToName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  balance.formattedAmount,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                if (onSettle != null)
                  SizedBox(
                    height: 28,
                    child: FilledButton.tonal(
                      onPressed: onSettle,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                      child: const Text('Settle'),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 8),

            // Creditor avatar
            CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                balance.owesToName.isNotEmpty
                    ? balance.owesToName[0].toUpperCase()
                    : '?',
                style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
