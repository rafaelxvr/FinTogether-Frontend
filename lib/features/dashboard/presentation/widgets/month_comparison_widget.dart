import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../domain/entities/cashflow_trend.dart';

/// Month-over-month comparison widget using cashflow trend data
class MonthComparisonWidget extends StatelessWidget {
  final CashflowTrend trend;

  const MonthComparisonWidget({super.key, required this.trend});

  @override
  Widget build(BuildContext context) {
    if (trend.months.length < 2) return const SizedBox.shrink();

    final currentMonth = trend.months.last;
    final previousMonth = trend.months[trend.months.length - 2];

    final incomeChange = currentMonth.income - previousMonth.income;
    final expenseChange = currentMonth.expense - previousMonth.expense;
    final netChange = currentMonth.net - previousMonth.net;

    final incomePct = previousMonth.income > 0
        ? (incomeChange / previousMonth.income * 100)
        : 0.0;
    final expensePct = previousMonth.expense > 0
        ? (expenseChange / previousMonth.expense * 100)
        : 0.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.monthComparison,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildColumn(
                    context,
                    previousMonth.shortMonthName,
                    previousMonth.income,
                    previousMonth.expense,
                    previousMonth.net,
                  ),
                ),
                Container(
                  width: 1,
                  height: 100,
                  color: Colors.grey[300],
                ),
                Expanded(
                  child: _buildColumn(
                    context,
                    currentMonth.shortMonthName,
                    currentMonth.income,
                    currentMonth.expense,
                    currentMonth.net,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildChangeBadge(AppLocalizations.of(context)!.income, incomePct, incomeChange >= 0),
                _buildChangeBadge(AppLocalizations.of(context)!.expense, expensePct, expenseChange <= 0),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColumn(BuildContext context, String month, double income,
      double expense, double net) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Text(
            month,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          _buildRow(AppLocalizations.of(context)!.income, income, Colors.green),
          const SizedBox(height: 4),
          _buildRow(AppLocalizations.of(context)!.expense, expense, Colors.red),
          const SizedBox(height: 4),
          _buildRow(AppLocalizations.of(context)!.netCashFlow, net, net >= 0 ? Colors.green : Colors.red),
        ],
      ),
    );
  }

  Widget _buildRow(String label, double value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 11)),
        Text(
          'R\$ ${value.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildChangeBadge(String label, double pct, bool isPositive) {
    final color = isPositive ? Colors.green : Colors.red;
    final sign = pct >= 0 ? '+' : '';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$label: $sign${pct.toStringAsFixed(1)}%',
        style: TextStyle(
          color: color[700],
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
