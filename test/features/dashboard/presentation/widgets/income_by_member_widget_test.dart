import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/features/dashboard/domain/entities/income_report.dart';
import 'package:frontend/features/dashboard/presentation/widgets/income_by_member_widget.dart';

void main() {
  group('IncomeByMemberWidget', () {
    testWidgets('should display income data for shared budgets', (tester) async {
      const report = IncomeByMemberReport(
        budgetId: 'budget-1',
        period: '2026-03',
        totalBudgetIncome: 8000.0,
        members: [
          MemberIncome(
            userId: 'user-1',
            userName: 'Alice',
            totalIncome: 5000.0,
            percentage: 62.5,
            transactionCount: 3,
            topSources: [],
          ),
          MemberIncome(
            userId: 'user-2',
            userName: 'Bob',
            totalIncome: 3000.0,
            percentage: 37.5,
            transactionCount: 2,
            topSources: [],
          ),
        ],
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: IncomeByMemberWidget(report: report),
            ),
          ),
        ),
      );

      expect(find.text('Income Distribution'), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.textContaining('8000'), findsOneWidget);
    });

    testWidgets('should return SizedBox.shrink for personal budgets', (tester) async {
      const report = IncomeByMemberReport(
        budgetId: 'budget-1',
        period: '2026-03',
        totalBudgetIncome: 5000.0,
        members: [
          MemberIncome(
            userId: 'user-1',
            userName: 'Alice',
            totalIncome: 5000.0,
            percentage: 100.0,
            transactionCount: 3,
            topSources: [],
          ),
        ],
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: IncomeByMemberWidget(report: report),
          ),
        ),
      );

      // Should not render since isSharedBudget == false (only 1 member)
      expect(find.text('Income Distribution'), findsNothing);
    });

    testWidgets('should show no income message when totalBudgetIncome is 0', (tester) async {
      const report = IncomeByMemberReport(
        budgetId: 'budget-1',
        period: '2026-03',
        totalBudgetIncome: 0.0,
        members: [
          MemberIncome(
            userId: 'user-1',
            userName: 'Alice',
            totalIncome: 0.0,
            percentage: 0.0,
            transactionCount: 0,
            topSources: [],
          ),
          MemberIncome(
            userId: 'user-2',
            userName: 'Bob',
            totalIncome: 0.0,
            percentage: 0.0,
            transactionCount: 0,
            topSources: [],
          ),
        ],
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: IncomeByMemberWidget(report: report),
            ),
          ),
        ),
      );

      expect(find.text('No income data for this period'), findsOneWidget);
    });
  });
}
