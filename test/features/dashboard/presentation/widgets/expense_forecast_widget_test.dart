import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/features/dashboard/domain/entities/expense_forecast.dart';
import 'package:frontend/features/dashboard/presentation/widgets/expense_forecast_widget.dart';

void main() {
  group('ExpenseForecastWidget', () {
    testWidgets('should display forecast data correctly', (tester) async {
      const forecast = ExpenseForecast(
        currentMonthExpense: 2000.0,
        projectedMonthEndExpense: 4000.0,
        dailyAverage: 133.0,
        daysElapsed: 15,
        daysRemaining: 16,
        lastMonthTotal: 3500.0,
        projectedVsLastMonth: 14.3,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ExpenseForecastWidget(forecast: forecast),
            ),
          ),
        ),
      );

      expect(find.text('Expense Forecast'), findsOneWidget);
      expect(find.textContaining('2000'), findsOneWidget);
      expect(find.textContaining('4000'), findsOneWidget);
      expect(find.textContaining('133'), findsOneWidget);
      expect(find.text('16'), findsOneWidget);
      expect(find.textContaining('14.3%'), findsOneWidget);
    });

    testWidgets('should show correct color for higher projection', (tester) async {
      const forecast = ExpenseForecast(
        currentMonthExpense: 2000.0,
        projectedMonthEndExpense: 4000.0,
        dailyAverage: 133.0,
        daysElapsed: 15,
        daysRemaining: 16,
        lastMonthTotal: 3500.0,
        projectedVsLastMonth: 14.3,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ExpenseForecastWidget(forecast: forecast),
            ),
          ),
        ),
      );

      // "more" indicates spending more than last month
      expect(find.textContaining('more'), findsOneWidget);
    });
  });
}
