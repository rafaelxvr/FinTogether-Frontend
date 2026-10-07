import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:frontend/core/utils/failure.dart';
import 'package:frontend/features/dashboard/domain/entities/dashboard_alerts.dart';
import 'package:frontend/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:frontend/features/dashboard/domain/usecases/get_dashboard_alerts_usecase.dart';

class MockDashboardRepository extends Mock implements DashboardRepository {}

void main() {
  late GetDashboardAlertsUseCase useCase;
  late MockDashboardRepository mockRepository;

  setUp(() {
    mockRepository = MockDashboardRepository();
    useCase = GetDashboardAlertsUseCase(mockRepository);
  });

  group('GetDashboardAlertsUseCase', () {
    const testAlerts = DashboardAlertsReport(
      lowBalanceAlerts: [
        DashboardAlert(
          type: 'low_balance',
          title: 'Low balance: Checking',
          severity: 'warning',
        ),
      ],
      categoryLimitAlerts: [],
      creditCardDueAlerts: [
        DashboardAlert(
          type: 'credit_card_due',
          title: 'Card Due: Visa',
          severity: 'critical',
          metadata: {'daysUntilDue': 2, 'amount': 1500.0},
        ),
      ],
    );

    test('should return ValidationFailure when budgetId is empty', () async {
      final result = await useCase(
        GetDashboardAlertsParams(budgetId: ''),
      );

      expect(result, const Left(ValidationFailure('Budget ID cannot be empty')));
      verifyNever(() => mockRepository.getDashboardAlerts(any()));
    });

    test('should return DashboardAlertsReport on success', () async {
      when(() => mockRepository.getDashboardAlerts(any()))
          .thenAnswer((_) async => const Right(testAlerts));

      final result = await useCase(
        GetDashboardAlertsParams(budgetId: 'budget-1'),
      );

      expect(result, const Right(testAlerts));
      verify(() => mockRepository.getDashboardAlerts('budget-1')).called(1);
    });

    test('should forward failure from repository', () async {
      const failure = ServerFailure('Server error');
      when(() => mockRepository.getDashboardAlerts(any()))
          .thenAnswer((_) async => const Left(failure));

      final result = await useCase(
        GetDashboardAlertsParams(budgetId: 'budget-1'),
      );

      expect(result, const Left(failure));
    });
  });
}
