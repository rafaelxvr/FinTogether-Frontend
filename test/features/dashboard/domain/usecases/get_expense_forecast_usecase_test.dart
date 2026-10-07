import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:frontend/core/utils/failure.dart';
import 'package:frontend/features/dashboard/domain/entities/expense_forecast.dart';
import 'package:frontend/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:frontend/features/dashboard/domain/usecases/get_expense_forecast_usecase.dart';

class MockDashboardRepository extends Mock implements DashboardRepository {}

void main() {
  late GetExpenseForecastUseCase useCase;
  late MockDashboardRepository mockRepository;

  setUp(() {
    mockRepository = MockDashboardRepository();
    useCase = GetExpenseForecastUseCase(mockRepository);
  });

  group('GetExpenseForecastUseCase', () {
    const testForecast = ExpenseForecast(
      currentMonthExpense: 2000.0,
      projectedMonthEndExpense: 4000.0,
      dailyAverage: 133.0,
      daysElapsed: 15,
      daysRemaining: 16,
      lastMonthTotal: 3500.0,
      projectedVsLastMonth: 14.3,
    );

    test('should return ValidationFailure when budgetId is empty', () async {
      final result = await useCase(
        GetExpenseForecastParams(budgetId: ''),
      );

      expect(result, const Left(ValidationFailure('Budget ID cannot be empty')));
      verifyNever(() => mockRepository.getExpenseForecast(any()));
    });

    test('should return ExpenseForecast on success', () async {
      when(() => mockRepository.getExpenseForecast(any()))
          .thenAnswer((_) async => const Right(testForecast));

      final result = await useCase(
        GetExpenseForecastParams(budgetId: 'budget-1'),
      );

      expect(result, const Right(testForecast));
      verify(() => mockRepository.getExpenseForecast('budget-1')).called(1);
    });

    test('should forward failure from repository', () async {
      const failure = ServerFailure('Server error');
      when(() => mockRepository.getExpenseForecast(any()))
          .thenAnswer((_) async => const Left(failure));

      final result = await useCase(
        GetExpenseForecastParams(budgetId: 'budget-1'),
      );

      expect(result, const Left(failure));
    });
  });
}
