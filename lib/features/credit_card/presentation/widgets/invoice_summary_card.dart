import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/credit_card_invoice.dart';
import 'invoice_status_badge.dart';

/// A Card widget displaying invoice summary information.
/// Shows total amount, due date, period, status badge, and optional credit limit progress bar.
class InvoiceSummaryCard extends StatelessWidget {
  final double totalAmount;
  final DateTime dueDate;
  final DateTime periodStart;
  final DateTime periodEnd;
  final InvoiceStatus status;
  final double? creditLimit;
  final double? availableCredit;
  final String currency;

  const InvoiceSummaryCard({
    super.key,
    required this.totalAmount,
    required this.dueDate,
    required this.periodStart,
    required this.periodEnd,
    required this.status,
    this.creditLimit,
    this.availableCredit,
    this.currency = 'BRL',
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '$currency ', decimalDigits: 2);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total amount and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormat.format(totalAmount),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                InvoiceStatusBadge(status: status),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            // Period and Due date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem(
                  label: 'Period',
                  value: '${dateFormat.format(periodStart)} - ${dateFormat.format(periodEnd)}',
                  icon: Icons.date_range,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
              label: 'Due Date',
              value: dateFormat.format(dueDate),
              icon: Icons.event,
            ),

            // Credit limit progress bar
            if (creditLimit != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              _buildCreditLimitSection(currencyFormat),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCreditLimitSection(NumberFormat currencyFormat) {
    final limit = creditLimit!;
    final utilization = limit > 0 ? (totalAmount / limit).clamp(0.0, 1.0) : 0.0;
    final utilizationPercent = (utilization * 100).toStringAsFixed(1);
    final progressColor = utilization > 0.9
        ? Colors.red
        : utilization > 0.7
            ? Colors.orange
            : Colors.green;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Credit Utilization',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            Text(
              '$utilizationPercent%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: progressColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: utilization,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Used: ${currencyFormat.format(totalAmount)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              'Limit: ${currencyFormat.format(limit)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }
}
