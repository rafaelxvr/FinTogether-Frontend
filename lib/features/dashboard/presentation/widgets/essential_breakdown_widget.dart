import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../domain/entities/essential_breakdown.dart';

/// Essential vs non-essential spending breakdown widget
class EssentialBreakdownWidget extends StatelessWidget {
  final EssentialBreakdown breakdown;

  const EssentialBreakdownWidget({super.key, required this.breakdown});

  @override
  Widget build(BuildContext context) {
    if (breakdown.totalExpense == 0) return const SizedBox.shrink();

    final essentialTotal = breakdown.essentialTotal;
    final nonEssentialTotal = breakdown.nonEssentialTotal;
    final essentialPct = breakdown.essentialPercentage;
    final nonEssentialPct = breakdown.nonEssentialPercentage;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.essentialBreakdown,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            // Stacked bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 24,
                child: Row(
                  children: [
                    Expanded(
                      flex: essentialPct.round().clamp(1, 100),
                      child: Container(color: Colors.blue[400]),
                    ),
                    Expanded(
                      flex: nonEssentialPct.round().clamp(1, 100),
                      child: Container(color: Colors.orange[400]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem(
                  AppLocalizations.of(context)!.essential,
                  essentialTotal,
                  essentialPct,
                  Colors.blue[400]!,
                ),
                _buildLegendItem(
                  AppLocalizations.of(context)!.nonEssential,
                  nonEssentialTotal,
                  nonEssentialPct,
                  Colors.orange[400]!,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(
      String label, double amount, double pct, Color color) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'R\$ ${amount.toStringAsFixed(0)} (${pct.toStringAsFixed(0)}%)',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ],
    );
  }
}
