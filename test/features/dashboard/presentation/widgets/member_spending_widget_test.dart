import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/features/dashboard/domain/entities/member_spending.dart';
import 'package:frontend/features/dashboard/presentation/widgets/member_spending_widget.dart';

void main() {
  group('MemberSpendingWidget', () {
    testWidgets('should display member spending data for shared budgets', (tester) async {
      const report = MemberSpendingReport(
        budgetId: 'budget-1',
        period: '2026-03',
        members: [
          MemberSpending(
            userId: 'user-1',
            userName: 'Alice',
            totalExpense: 1500.0,
            totalIncome: 3000.0,
            transactionCount: 10,
            percentage: 60.0,
          ),
          MemberSpending(
            userId: 'user-2',
            userName: 'Bob',
            totalExpense: 1000.0,
            totalIncome: 2000.0,
            transactionCount: 8,
            percentage: 40.0,
          ),
        ],
        totalBudgetExpense: 2500.0,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MemberSpendingWidget(report: report),
            ),
          ),
        ),
      );

      expect(find.text('Member Spending'), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
    });

    testWidgets('should return SizedBox.shrink for personal budgets', (tester) async {
      const report = MemberSpendingReport(
        budgetId: 'budget-1',
        period: '2026-03',
        members: [
          MemberSpending(
            userId: 'user-1',
            userName: 'Alice',
            totalExpense: 1500.0,
            totalIncome: 3000.0,
            transactionCount: 10,
            percentage: 100.0,
          ),
        ],
        totalBudgetExpense: 1500.0,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MemberSpendingWidget(report: report),
          ),
        ),
      );

      // Should not render since isSharedBudget == false (only 1 member)
      expect(find.text('Member Spending'), findsNothing);
    });
  });
}
