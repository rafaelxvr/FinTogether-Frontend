import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Widget showing credit card due date alerts
class CreditCardAlertsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> alerts;

  const CreditCardAlertsWidget({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (alerts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: alerts.map((alert) {
        final isOverdue = alert['isOverdue'] == true;
        final daysUntilDue = alert['daysUntilDue'] as int? ?? 0;
        final color = isOverdue
            ? Colors.red
            : daysUntilDue <= 3
                ? Colors.orange
                : Colors.amber;

        return Card(
          color: color.withOpacity(0.1),
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(
              isOverdue ? Icons.warning : Icons.credit_card,
              color: color[700],
            ),
            title: Text(
              alert['cardName'] as String? ?? 'Card',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              isOverdue
                  ? l10n.overdue
                  : l10n.dueIn(daysUntilDue),
            ),
            trailing: Text(
              'R\$ ${(alert['statementAmount'] as num? ?? 0).toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color[700],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
