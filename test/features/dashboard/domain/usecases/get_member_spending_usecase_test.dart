import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:frontend/core/utils/failure.dart';
import 'package:frontend/features/dashboard/domain/entities/member_spending.dart';
import 'package:frontend/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:frontend/features/dashboard/domain/usecases/get_member_spending_usecase.dart';

class MockDashboardRepository extends Mock implements DashboardRepository {}

void main() {
  late GetMemberSpendingUseCase useCase;
  late MockDashboardRepository mockRepository;

  setUp(() {
    mockRepository = MockDashboardRepository();
    useCase = GetMemberSpendingUseCase(mockRepository);
  });

  group('GetMemberSpendingUseCase', () {
    const testReport = MemberSpendingReport(
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

    test('should return ValidationFailure when budgetId is empty', () async {
      final result = await useCase(
        GetMemberSpendingParams(budgetId: ''),
      );

      expect(result, const Left(ValidationFailure('Budget ID cannot be empty')));
      verifyNever(() => mockRepository.getMemberSpending(any()));
    });

    test('should return MemberSpendingReport on success', () async {
      when(() => mockRepository.getMemberSpending(
        any(),
        yearMonth: any(named: 'yearMonth'),
      )).thenAnswer((_) async => const Right(testReport));

      final result = await useCase(
        GetMemberSpendingParams(budgetId: 'budget-1'),
      );

      expect(result, const Right(testReport));
      verify(() => mockRepository.getMemberSpending('budget-1')).called(1);
    });

    test('should forward failure from repository', () async {
      const failure = NetworkFailure('No connection');
      when(() => mockRepository.getMemberSpending(
        any(),
        yearMonth: any(named: 'yearMonth'),
      )).thenAnswer((_) async => const Left(failure));

      final result = await useCase(
        GetMemberSpendingParams(budgetId: 'budget-1'),
      );

      expect(result, const Left(failure));
    });
  });
}
