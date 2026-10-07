import 'package:flutter/material.dart';
import '../../domain/entities/card_monthly_cost.dart';

/// Widget displaying per-card cost summary
class CardMonthlyCostWidget extends StatelessWidget {
  final List<CardMonthlyCost> costs;
  final double grandTotal;
  final void Function(String cardId)? onCardTap;

  const CardMonthlyCostWidget({
    super.key,
    required this.costs,
    required this.grandTotal,
    this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.credit_card, color: Colors.deepOrange[600]),
                const SizedBox(width: 8),
                Text(
                  'Credit Card Costs',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (costs.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('No credit card expenses this period'),
              )
            else ...[
              ...costs.map((cost) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: Colors.deepOrange.withOpacity(0.1),
                      child: const Icon(Icons.credit_card, color: Colors.deepOrange),
                    ),
                    title: Text(
                      cost.cardName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text('${cost.transactionCount} transactions'),
                    trailing: Text(
                      cost.formattedCost,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                    onTap: onCardTap != null ? () => onCardTap!(cost.cardId) : null,
                  )),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Grand Total',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      'R\$ ${grandTotal.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.red[700],
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
