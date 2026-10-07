import 'package:flutter/material.dart';
import '../../domain/entities/income_report.dart';

/// Shows income sources for a specific member (bottom sheet)
class IncomeSourcesWidget extends StatelessWidget {
  final MemberIncome member;

  const IncomeSourcesWidget({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${member.userName} - Income Sources',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Total: R\$ ${member.totalIncome.toStringAsFixed(2)}',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          if (member.topSources.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No categorized income sources'),
            )
          else
            ...member.topSources.map((source) {
              final barWidth = source.percentage / 100;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          source.categoryName,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          'R\$ ${source.amount.toStringAsFixed(0)} (${source.percentage.toStringAsFixed(0)}%)',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: barWidth.clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: Colors.grey[200],
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
