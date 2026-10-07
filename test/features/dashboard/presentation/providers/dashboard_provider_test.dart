import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:frontend/core/utils/failure.dart';
import 'package:frontend/features/dashboard/domain/entities/cashflow_trend.dart';
import 'package:frontend/features/dashboard/domain/entities/dashboard_alerts.dart';
import 'package:frontend/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:frontend/features/dashboard/domain/entities/essential_breakdown.dart';
import 'package:frontend/features/dashboard/domain/entities/expense_forecast.dart';
import 'package:frontend/features/dashboard/domain/entities/income_report.dart';
import 'package:frontend/features/dashboard/domain/entities/member_spending.dart';
import 'package:frontend/features/dashboard/domain/usecases/get_cashflow_trend_usecase.dart';
import 'package:frontend/features/dashboard/domain/usecases/get_dashboard_alerts_usecase.dart';
import 'package:frontend/features/dashboard/domain/usecases/get_dashboard_summary_usecase.dart';
import 'package:frontend/features/dashboard/domain/usecases/get_essential_breakdown_usecase.dart';
import 'package:frontend/features/dashboard/domain/usecases/get_expense_forecast_usecase.dart';
import 'package:frontend/features/dashboard/domain/usecases/get_income_by_member_usecase.dart';
import 'package:frontend/features/dashboard/domain/usecases/get_member_spending_usecase.dart';
import 'package:frontend/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:frontend/features/dashboard/presentation/providers/dashboard_state.dart';

class MockGetDashboardSummaryUseCase extends Mock
    implements GetDashboardSummaryUseCase {}

class MockGetCashflowTrendUseCase extends Mock
    implements GetCashflowTrendUseCase {}

class MockGetEssentialBreakdownUseCase extends Mock
    implements GetEssentialBreakdownUseCase {}

class MockGetMemberSpendingUseCase extends Mock
    implements GetMemberSpendingUseCase {}

class MockGetExpenseForecastUseCase extends Mock
    implements GetExpenseForecastUseCase {}

class MockGetDashboardAlertsUseCase extends Mock
    implements GetDashboardAlertsUseCase {}

class MockGetIncomeByMemberUseCase extends Mock
    implements GetIncomeByMemberUseCase {}

// Register fallback values for mocktail
class FakeGetDashboardSummaryParams extends Fake
    implements GetDashboardSummaryParams {}

class FakeGetCashflowTrendParams extends Fake
    implements GetCashflowTrendParams {}

class FakeGetEssentialBreakdownParams extends Fake
    implements GetEssentialBreakdownParams {}

class FakeGetMemberSpendingParams extends Fake
    implements GetMemberSpendingParams {}

class FakeGetExpenseForecastParams extends Fake
    implements GetExpenseForecastParams {}

class FakeGetDashboardAlertsParams extends Fake
    implements GetDashboardAlertsParams {}

class FakeGetIncomeByMemberParams extends Fake
    implements GetIncomeByMemberParams {}

void main() {
  late DashboardNotifier notifier;
  late MockGetDashboardSummaryUseCase mockSummary;
  late MockGetCashflowTrendUseCase mockCashflow;
  late MockGetEssentialBreakdownUseCase mockEssential;
  late MockGetMemberSpendingUseCase mockMemberSpending;
  late MockGetExpenseForecastUseCase mockForecast;
  late MockGetDashboardAlertsUseCase mockAlerts;
  late MockGetIncomeByMemberUseCase mockIncome;

  setUpAll(() {
    registerFallbackValue(FakeGetDashboardSummaryParams());
    registerFallbackValue(FakeGetCashflowTrendParams());
    registerFallbackValue(FakeGetEssentialBreakdownParams());
    registerFallbackValue(FakeGetMemberSpendingParams());
    registerFallbackValue(FakeGetExpenseForecastParams());
    registerFallbackValue(FakeGetDashboardAlertsParams());
    registerFallbackValue(FakeGetIncomeByMemberParams());
  });

  setUp(() {
    mockSummary = MockGetDashboardSummaryUseCase();
    mockCashflow = MockGetCashflowTrendUseCase();
    mockEssential = MockGetEssentialBreakdownUseCase();
    mockMemberSpending = MockGetMemberSpendingUseCase();
    mockForecast = MockGetExpenseForecastUseCase();
    mockAlerts = MockGetDashboardAlertsUseCase();
    mockIncome = MockGetIncomeByMemberUseCase();

    notifier = DashboardNotifier(
      getDashboardSummaryUseCase: mockSummary,
      getCashflowTrendUseCase: mockCashflow,
      getEssentialBreakdownUseCase: mockEssential,
      getMemberSpendingUseCase: mockMemberSpending,
      getExpenseForecastUseCase: mockForecast,
      getDashboardAlertsUseCase: mockAlerts,
      getIncomeByMemberUseCase: mockIncome,
    );
  });

  group('DashboardNotifier', () {
    final testSummary = DashboardSummary(
      budgetId: 'budget-1',
      period: '2026-03',
      totalIncome: 5000.0,
      totalExpense: 3000.0,
      netCashFlow: 2000.0,
      accountsBalance: 10000.0,
      categoryBreakdown: [],
      recentTransactions: [],
    );

    const testForecast = ExpenseForecast(
      currentMonthExpense: 2000.0,
      projectedMonthEndExpense: 4000.0,
      dailyAverage: 133.0,
      daysElapsed: 15,
      daysRemaining: 16,
      lastMonthTotal: 3500.0,
      projectedVsLastMonth: 14.3,
    );

    const testAlerts = DashboardAlertsReport(
      lowBalanceAlerts: [],
      categoryLimitAlerts: [],
      creditCardDueAlerts: [],
    );

    test('initial state should be DashboardInitial', () {
      expect(notifier.state, const DashboardInitial());
    });

    test('loadDashboard should transition to DashboardLoaded with all data', () async {
      when(() => mockSummary(any()))
          .thenAnswer((_) async => Right(testSummary));
      when(() => mockCashflow(any()))
          .thenAnswer((_) async => const Left(ServerFailure('Not available')));
      when(() => mockEssential(any()))
          .thenAnswer((_) async => const Left(ServerFailure('Not available')));
      when(() => mockMemberSpending(any()))
          .thenAnswer((_) async => const Left(ServerFailure('Not available')));
      when(() => mockForecast(any()))
          .thenAnswer((_) async => const Right(testForecast));
      when(() => mockAlerts(any()))
          .thenAnswer((_) async => const Right(testAlerts));
      when(() => mockIncome(any()))
          .thenAnswer((_) async => const Left(ServerFailure('Not available')));

      await notifier.loadDashboard('budget-1');

      expect(notifier.state, isA<DashboardLoaded>());
      final loaded = notifier.state as DashboardLoaded;
      expect(loaded.summary, testSummary);
      expect(loaded.cashflowTrend, isNull); // failed
      expect(loaded.essentialBreakdown, isNull); // failed
      expect(loaded.memberSpending, isNull); // failed
      expect(loaded.expenseForecast, testForecast);
      expect(loaded.alerts, testAlerts);
      expect(loaded.incomeByMember, isNull); // failed
    });

    test('loadDashboard should show error when summary fails', () async {
      when(() => mockSummary(any()))
          .thenAnswer((_) async => const Left(ServerFailure('Server down')));

      await notifier.loadDashboard('budget-1');

      expect(notifier.state, isA<DashboardError>());
      expect((notifier.state as DashboardError).message, 'Server down');
    });

    test('enhanced endpoint failure should not block dashboard loading', () async {
      when(() => mockSummary(any()))
          .thenAnswer((_) async => Right(testSummary));
      when(() => mockCashflow(any()))
          .thenAnswer((_) async => const Left(ServerFailure('fail')));
      when(() => mockEssential(any()))
          .thenAnswer((_) async => const Left(ServerFailure('fail')));
      when(() => mockMemberSpending(any()))
          .thenAnswer((_) async => const Left(ServerFailure('fail')));
      when(() => mockForecast(any()))
          .thenAnswer((_) async => const Left(ServerFailure('fail')));
      when(() => mockAlerts(any()))
          .thenAnswer((_) async => const Left(ServerFailure('fail')));
      when(() => mockIncome(any()))
          .thenAnswer((_) async => const Left(ServerFailure('fail')));

      await notifier.loadDashboard('budget-1');

      expect(notifier.state, isA<DashboardLoaded>());
      final loaded = notifier.state as DashboardLoaded;
      expect(loaded.summary, testSummary);
      // All enhanced data is null but dashboard still loaded
      expect(loaded.essentialBreakdown, isNull);
      expect(loaded.memberSpending, isNull);
      expect(loaded.expenseForecast, isNull);
      expect(loaded.alerts, isNull);
      expect(loaded.incomeByMember, isNull);
    });

    test('reset should return to initial state', () {
      notifier.reset();
      expect(notifier.state, const DashboardInitial());
    });
  });
}
