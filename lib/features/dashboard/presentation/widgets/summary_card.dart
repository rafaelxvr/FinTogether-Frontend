import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Summary Card Widget
/// Displays a financial metric with icon, title, amount, and optional trend indicator
class SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;
  final Color? backgroundColor;
  final bool showPositiveIndicator;
  final bool isPositive;

  const SummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    this.backgroundColor,
    this.showPositiveIndicator = false,
    this.isPositive = true,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );

    return Card(
      elevation: 2,
      color: backgroundColor ?? Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon and trend indicator row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                if (showPositiveIndicator)
                  Icon(
                    isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                    color: isPositive ? Colors.green : Colors.red,
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 4),

            // Amount
            Text(
              currencyFormat.format(amount),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: showPositiveIndicator
                        ? (isPositive ? Colors.green[700] : Colors.red[700])
                        : color,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Summary Cards Grid
/// Displays a 2x2 grid of financial summary cards
class SummaryCardsGrid extends StatelessWidget {
  final double totalIncome;
  final double totalExpense;
  final double netCashFlow;
  final double accountsBalance;

  const SummaryCardsGrid({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
    required this.netCashFlow,
    required this.accountsBalance,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        // Income Card
        SummaryCard(
          title: 'Receitas',
          amount: totalIncome,
          icon: Icons.trending_up,
          color: Colors.green[600]!,
          showPositiveIndicator: false,
        ),

        // Expense Card
        SummaryCard(
          title: 'Despesas',
          amount: totalExpense,
          icon: Icons.trending_down,
          color: Colors.red[600]!,
          showPositiveIndicator: false,
        ),

        // Net Cash Flow Card
        SummaryCard(
          title: 'Saldo do Mês',
          amount: netCashFlow,
          icon: netCashFlow >= 0 ? Icons.attach_money : Icons.money_off,
          color: netCashFlow >= 0 ? Colors.blue[600]! : Colors.orange[600]!,
          showPositiveIndicator: true,
          isPositive: netCashFlow >= 0,
        ),

        // Total Balance Card
        SummaryCard(
          title: 'Saldo Total',
          amount: accountsBalance,
          icon: Icons.account_balance_wallet,
          color: Colors.purple[600]!,
          showPositiveIndicator: false,
        ),
      ],
    );
  }
}
