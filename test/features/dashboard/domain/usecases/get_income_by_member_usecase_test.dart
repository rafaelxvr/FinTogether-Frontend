import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:frontend/core/utils/failure.dart';
import 'package:frontend/features/dashboard/domain/entities/income_report.dart';
import 'package:frontend/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:frontend/features/dashboard/domain/usecases/get_income_by_member_usecase.dart';

class MockDashboardRepository extends Mock implements DashboardRepository {}

void main() {
  late GetIncomeByMemberUseCase useCase;
  late MockDashboardRepository mockRepository;

  setUp(() {
    mockRepository = MockDashboardRepository();
    useCase = GetIncomeByMemberUseCase(mockRepository);
  });

  group('GetIncomeByMemberUseCase', () {
    const testReport = IncomeByMemberReport(
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
          topSources: [
            IncomeSource(
              categoryId: 'cat-1',
              categoryName: 'Salary',
              amount: 4500.0,
              percentage: 90.0,
            ),
          ],
        ),
      ],
    );

    test('should return ValidationFailure when budgetId is empty', () async {
      final result = await useCase(
        GetIncomeByMemberParams(budgetId: ''),
      );

      expect(result, const Left(ValidationFailure('Budget ID cannot be empty')));
      verifyNever(() => mockRepository.getIncomeByMember(any()));
    });

    test('should return IncomeByMemberReport on success', () async {
      when(() => mockRepository.getIncomeByMember(
        any(),
        yearMonth: any(named: 'yearMonth'),
      )).thenAnswer((_) async => const Right(testReport));

      final result = await useCase(
        GetIncomeByMemberParams(budgetId: 'budget-1', yearMonth: '2026-03'),
      );

      expect(result, const Right(testReport));
      verify(() => mockRepository.getIncomeByMember(
        'budget-1',
        yearMonth: '2026-03',
      )).called(1);
    });

    test('should forward failure from repository', () async {
      const failure = NetworkFailure('No connection');
      when(() => mockRepository.getIncomeByMember(
        any(),
        yearMonth: any(named: 'yearMonth'),
      )).thenAnswer((_) async => const Left(failure));

      final result = await useCase(
        GetIncomeByMemberParams(budgetId: 'budget-1'),
      );

      expect(result, const Left(failure));
    });
  });
}
