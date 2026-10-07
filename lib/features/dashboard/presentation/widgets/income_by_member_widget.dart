import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../domain/entities/income_report.dart';

/// Donut chart showing income distribution per member
class IncomeByMemberWidget extends StatelessWidget {
  final IncomeByMemberReport report;
  final void Function(MemberIncome member)? onMemberTap;

  const IncomeByMemberWidget({
    super.key,
    required this.report,
    this.onMemberTap,
  });

  static const _colors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
  ];

  @override
  Widget build(BuildContext context) {
    if (!report.isSharedBudget) return const SizedBox.shrink();
    if (report.totalBudgetIncome == 0) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(Icons.money_off, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text(AppLocalizations.of(context)!.noIncomeData),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.incomeDistribution,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: report.members.asMap().entries.map((entry) {
                    final member = entry.value;
                    final color = _colors[entry.key % _colors.length];
                    return PieChartSectionData(
                      value: member.totalIncome,
                      title: '${member.percentage.toStringAsFixed(0)}%',
                      color: color,
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                '${AppLocalizations.of(context)!.total}: R\$ ${report.totalBudgetIncome.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const Divider(height: 24),
            ...report.members.asMap().entries.map((entry) {
              final member = entry.value;
              final color = _colors[entry.key % _colors.length];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text(member.userName),
                subtitle: Text(AppLocalizations.of(context)!.nTransactions(member.transactionCount)),
                trailing: Text(
                  'R\$ ${member.totalIncome.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: onMemberTap != null
                    ? () => onMemberTap!(member)
                    : null,
              );
            }),
          ],
        ),
      ),
    );
  }
}
