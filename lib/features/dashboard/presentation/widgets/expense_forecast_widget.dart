import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../domain/entities/expense_forecast.dart';

/// Expense forecast widget showing current pace projection
class ExpenseForecastWidget extends StatelessWidget {
  final ExpenseForecast forecast;

  const ExpenseForecastWidget({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isHigher = forecast.isProjectedHigher;
    final statusColor = isHigher ? Colors.red : Colors.green;
    final comparisonText = isHigher ? l10n.more : l10n.less;
    final pctText = forecast.projectedVsLastMonth.abs().toStringAsFixed(1);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: statusColor),
                const SizedBox(width: 8),
                Text(
                  l10n.expenseForecast,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: forecast.progressPercentage,
                minHeight: 12,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'R\$ ${forecast.currentMonthExpense.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'R\$ ${forecast.projectedMonthEndExpense.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.current, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                Text(l10n.projectedExpense, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              ],
            ),
            const SizedBox(height: 12),
            // Daily average badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBadge(
                  l10n.dailyAverage,
                  'R\$ ${forecast.dailyAverage.toStringAsFixed(0)}',
                  Colors.blue,
                ),
                _buildBadge(
                  l10n.daysRemaining,
                  '${forecast.daysRemaining}',
                  Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Comparison text
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                l10n.onTrackToSpend(pctText, comparisonText),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: statusColor[700],
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label, String value, MaterialColor color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color[700],
            ),
          ),
        ),
      ],
    );
  }
}
