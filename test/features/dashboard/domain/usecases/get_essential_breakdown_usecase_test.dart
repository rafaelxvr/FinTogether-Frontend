import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:frontend/core/utils/failure.dart';
import 'package:frontend/features/dashboard/domain/entities/essential_breakdown.dart';
import 'package:frontend/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:frontend/features/dashboard/domain/usecases/get_essential_breakdown_usecase.dart';

class MockDashboardRepository extends Mock implements DashboardRepository {}

void main() {
  late GetEssentialBreakdownUseCase useCase;
  late MockDashboardRepository mockRepository;

  setUp(() {
    mockRepository = MockDashboardRepository();
    useCase = GetEssentialBreakdownUseCase(mockRepository);
  });

  group('GetEssentialBreakdownUseCase', () {
    const testBreakdown = EssentialBreakdown(
      budgetId: 'budget-1',
      period: '2026-03',
      essentialTotal: 3000.0,
      nonEssentialTotal: 2000.0,
      essentialPercentage: 60.0,
      nonEssentialPercentage: 40.0,
      essentialCategories: [],
      nonEssentialCategories: [],
    );

    test('should return ValidationFailure when budgetId is empty', () async {
      final result = await useCase(
        GetEssentialBreakdownParams(budgetId: ''),
      );

      expect(result, const Left(ValidationFailure('Budget ID cannot be empty')));
      verifyNever(() => mockRepository.getEssentialBreakdown(any()));
    });

    test('should return ValidationFailure when budgetId is whitespace', () async {
      final result = await useCase(
        GetEssentialBreakdownParams(budgetId: '   '),
      );

      expect(result, const Left(ValidationFailure('Budget ID cannot be empty')));
    });

    test('should return EssentialBreakdown on success', () async {
      when(() => mockRepository.getEssentialBreakdown(
        any(),
        yearMonth: any(named: 'yearMonth'),
      )).thenAnswer((_) async => const Right(testBreakdown));

      final result = await useCase(
        GetEssentialBreakdownParams(budgetId: 'budget-1', yearMonth: '2026-03'),
      );

      expect(result, const Right(testBreakdown));
      verify(() => mockRepository.getEssentialBreakdown(
        'budget-1',
        yearMonth: '2026-03',
      )).called(1);
    });

    test('should forward failure from repository', () async {
      const failure = ServerFailure('Server error');
      when(() => mockRepository.getEssentialBreakdown(
        any(),
        yearMonth: any(named: 'yearMonth'),
      )).thenAnswer((_) async => const Left(failure));

      final result = await useCase(
        GetEssentialBreakdownParams(budgetId: 'budget-1'),
      );

      expect(result, const Left(failure));
    });
  });
}
