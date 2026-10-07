import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/features/dashboard/domain/entities/essential_breakdown.dart';
import 'package:frontend/features/dashboard/presentation/widgets/essential_breakdown_widget.dart';

void main() {
  group('EssentialBreakdownWidget', () {
    testWidgets('should display breakdown data correctly', (tester) async {
      const breakdown = EssentialBreakdown(
        budgetId: 'budget-1',
        period: '2026-03',
        essentialTotal: 3000.0,
        nonEssentialTotal: 2000.0,
        essentialPercentage: 60.0,
        nonEssentialPercentage: 40.0,
        essentialCategories: [],
        nonEssentialCategories: [],
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: EssentialBreakdownWidget(breakdown: breakdown),
            ),
          ),
        ),
      );

      expect(find.text('Essential vs Non-Essential'), findsOneWidget);
      expect(find.textContaining('3000'), findsOneWidget);
      expect(find.textContaining('2000'), findsOneWidget);
      expect(find.textContaining('60%'), findsOneWidget);
      expect(find.textContaining('40%'), findsOneWidget);
    });

    testWidgets('should return SizedBox.shrink when totalExpense is 0', (tester) async {
      const breakdown = EssentialBreakdown(
        budgetId: 'budget-1',
        period: '2026-03',
        essentialTotal: 0.0,
        nonEssentialTotal: 0.0,
        essentialPercentage: 0.0,
        nonEssentialPercentage: 0.0,
        essentialCategories: [],
        nonEssentialCategories: [],
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EssentialBreakdownWidget(breakdown: breakdown),
          ),
        ),
      );

      expect(find.text('Essential vs Non-Essential'), findsNothing);
    });
  });
}
