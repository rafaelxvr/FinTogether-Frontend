import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Dashboard Alerts Widget
/// Displays warnings and notifications about account balances, budgets, etc.
class DashboardAlertsWidget extends StatelessWidget {
  final List<AlertItem> alerts;

  const DashboardAlertsWidget({
    super.key,
    required this.alerts,
  });

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) {
      return const SizedBox.shrink();
    }

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
            // Title
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange[600],
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Alertas',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Alerts list
            ...alerts.map((alert) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _AlertCard(alert: alert),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// Alert Card
/// Individual alert card with icon, message, and severity
class _AlertCard extends StatelessWidget {
  final AlertItem alert;

  const _AlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    final config = _getAlertConfig(alert.type, alert.severity);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: config.borderColor,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Icon(
            config.icon,
            color: config.iconColor,
            size: 20,
          ),
          const SizedBox(width: 12),

          // Message
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: config.textColor,
                      ),
                ),
                if (alert.message != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    alert.message!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: config.textColor.withOpacity(0.8),
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  _AlertConfig _getAlertConfig(AlertType type, AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return _AlertConfig(
          icon: Icons.error,
          iconColor: Colors.red[700]!,
          backgroundColor: Colors.red[50]!,
          borderColor: Colors.red[200]!,
          textColor: Colors.red[900]!,
        );

      case AlertSeverity.warning:
        return _AlertConfig(
          icon: Icons.warning_amber,
          iconColor: Colors.orange[700]!,
          backgroundColor: Colors.orange[50]!,
          borderColor: Colors.orange[200]!,
          textColor: Colors.orange[900]!,
        );

      case AlertSeverity.info:
        return _AlertConfig(
          icon: Icons.info,
          iconColor: Colors.blue[700]!,
          backgroundColor: Colors.blue[50]!,
          borderColor: Colors.blue[200]!,
          textColor: Colors.blue[900]!,
        );
    }
  }
}

/// Alert Configuration
/// Visual configuration for different alert severities
class _AlertConfig {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;

  _AlertConfig({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
  });
}

/// Alert Item
/// Represents a single alert with type, severity, and message
class AlertItem {
  final AlertType type;
  final AlertSeverity severity;
  final String title;
  final String? message;

  const AlertItem({
    required this.type,
    required this.severity,
    required this.title,
    this.message,
  });

  /// Factory: Low balance alert
  factory AlertItem.lowBalance({
    required String accountName,
    required double balance,
  }) {
    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );

    return AlertItem(
      type: AlertType.lowBalance,
      severity: balance < 0 ? AlertSeverity.critical : AlertSeverity.warning,
      title: 'Saldo baixo: $accountName',
      message: 'Saldo atual: ${currencyFormat.format(balance)}',
    );
  }

  /// Factory: Category limit exceeded
  factory AlertItem.categoryLimitExceeded({
    required String categoryName,
    required double spent,
    required double limit,
    required double percentage,
  }) {
    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );

    return AlertItem(
      type: AlertType.categoryLimit,
      severity: percentage > 120 ? AlertSeverity.critical : AlertSeverity.warning,
      title: 'Orçamento excedido: $categoryName',
      message:
          'Gasto: ${currencyFormat.format(spent)} de ${currencyFormat.format(limit)} (${percentage.toStringAsFixed(0)}%)',
    );
  }

  /// Factory: Credit card due soon
  factory AlertItem.creditCardDue({
    required String cardName,
    required DateTime dueDate,
    required double amount,
  }) {
    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    final dateFormat = DateFormat('dd/MM/yyyy', 'pt_BR');

    final daysUntilDue = dueDate.difference(DateTime.now()).inDays;
    final severity = daysUntilDue <= 3
        ? AlertSeverity.critical
        : daysUntilDue <= 7
            ? AlertSeverity.warning
            : AlertSeverity.info;

    return AlertItem(
      type: AlertType.creditCardDue,
      severity: severity,
      title: 'Fatura próxima: $cardName',
      message:
          'Vencimento: ${dateFormat.format(dueDate)} - ${currencyFormat.format(amount)}',
    );
  }

  /// Factory: Budget milestone reached
  factory AlertItem.budgetMilestone({
    required String categoryName,
    required double percentage,
  }) {
    return AlertItem(
      type: AlertType.budgetMilestone,
      severity: AlertSeverity.info,
      title: 'Meta atingida: $categoryName',
      message: 'Você atingiu ${percentage.toStringAsFixed(0)}% do orçamento',
    );
  }
}

/// Alert Type
/// Different types of alerts that can be displayed
enum AlertType {
  lowBalance,
  categoryLimit,
  creditCardDue,
  budgetMilestone,
}

/// Alert Severity
/// Severity levels for alerts
enum AlertSeverity {
  info,
  warning,
  critical,
}
