import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Widget that shows a live preview of installment breakdown.
class InstallmentPreviewCard extends StatelessWidget {
  final double totalAmount;
  final int installmentCount;
  final double interestRate;
  final DateTime startDate;

  const InstallmentPreviewCard({
    super.key,
    required this.totalAmount,
    required this.installmentCount,
    required this.interestRate,
    required this.startDate,
  });

  @override
  Widget build(BuildContext context) {
    if (totalAmount <= 0 || installmentCount < 2) {
      return const SizedBox.shrink();
    }

    final currencyFormat =
        NumberFormat.currency(symbol: 'R\$ ', decimalDigits: 2);
    final dateFormat = DateFormat('MMM yyyy');

    final hasInterest = interestRate > 0;
    final totalWithInterest = hasInterest
        ? totalAmount * pow(1 + interestRate / 100, installmentCount)
        : totalAmount;
    final installmentAmount = totalWithInterest / installmentCount;

    final endDate = DateTime(
      startDate.year,
      startDate.month + installmentCount - 1,
      startDate.day,
    );

    return Card(
      elevation: 2,
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                const Text(
                  'Installment Preview',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            Text(
              '${installmentCount}x of ${currencyFormat.format(installmentAmount)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (hasInterest) ...[
              Text(
                'Total with interest: ${currencyFormat.format(totalWithInterest)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.orange[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Original amount: ${currencyFormat.format(totalAmount)}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
            ] else ...[
              Text(
                'Total: ${currencyFormat.format(totalAmount)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              '${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
