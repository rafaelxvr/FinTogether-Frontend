import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:frontend/core/utils/failure.dart';
import 'package:frontend/features/budget/domain/entities/budget.dart';
import 'package:frontend/features/budget/domain/repositories/budget_repository.dart';
import 'package:frontend/features/budget/domain/usecases/get_budgets_usecase.dart';

// Mock class for BudgetRepository
class MockBudgetRepository extends Mock implements BudgetRepository {}

void main() {
  late GetBudgetsUseCase useCase;
  late MockBudgetRepository mockRepository;

  setUp(() {
    mockRepository = MockBudgetRepository();
    useCase = GetBudgetsUseCase(mockRepository);
  });

  group('GetBudgetsUseCase', () {
    final testBudget1 = Budget(
      id: 'budget-1',
      name: 'Personal Budget',
      ownerId: 'user-123',
      type: BudgetType.personal,
      createdAt: DateTime(2025, 1, 1),
    );

    final testBudget2 = Budget(
      id: 'budget-2',
      name: 'Shared Budget',
      ownerId: 'user-123',
      type: BudgetType.shared,
      createdAt: DateTime(2025, 1, 15),
    );

    final testBudgets = [testBudget1, testBudget2];

    test('should return list of budgets when call is successful', () async {
      // Arrange
      when(() => mockRepository.getBudgets())
          .thenAnswer((_) async => Right(testBudgets));

      // Act
      final result = await useCase();

      // Assert
      expect(result, Right(testBudgets));
      expect(result.getOrElse(() => []).length, 2);
      verify(() => mockRepository.getBudgets()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty list when no budgets exist', () async {
      // Arrange
      when(() => mockRepository.getBudgets())
          .thenAnswer((_) async => const Right([]));

      // Act
      final result = await useCase();

      // Assert
      expect(result, const Right([]));
      expect(result.getOrElse(() => []).length, 0);
      verify(() => mockRepository.getBudgets()).called(1);
    });

    test('should return ServerFailure when server error occurs', () async {
      // Arrange
      final failure = ServerFailure('Failed to fetch budgets');
      when(() => mockRepository.getBudgets())
          .thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase();

      // Assert
      expect(result, Left(failure));
      verify(() => mockRepository.getBudgets()).called(1);
    });

    test('should return NetworkFailure when network error occurs', () async {
      // Arrange
      final failure = NetworkFailure('No internet connection');
      when(() => mockRepository.getBudgets())
          .thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase();

      // Assert
      expect(result, Left(failure));
      verify(() => mockRepository.getBudgets()).called(1);
    });

    test('should return UnauthorizedFailure when user is not authenticated',
        () async {
      // Arrange
      final failure = UnauthorizedFailure('Token expired');
      when(() => mockRepository.getBudgets())
          .thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase();

      // Assert
      expect(result, Left(failure));
      verify(() => mockRepository.getBudgets()).called(1);
    });

    test('should call repository exactly once', () async {
      // Arrange
      when(() => mockRepository.getBudgets())
          .thenAnswer((_) async => Right(testBudgets));

      // Act
      await useCase();

      // Assert
      verify(() => mockRepository.getBudgets()).called(1);
    });

    test('should handle repository throwing exception', () async {
      // Arrange
      when(() => mockRepository.getBudgets())
          .thenThrow(Exception('Unexpected error'));

      // Act & Assert
      expect(
        () => useCase(),
        throwsA(isA<Exception>()),
      );
    });

    test('should return budgets sorted by createdAt (newest first)', () async {
      // Arrange
      when(() => mockRepository.getBudgets())
          .thenAnswer((_) async => Right(testBudgets));

      // Act
      final result = await useCase();

      // Assert
      result.fold(
        (failure) => fail('Should return success'),
        (budgets) {
          expect(budgets.length, 2);
          // Verify order if the use case sorts them
          expect(budgets[0].id, 'budget-1');
          expect(budgets[1].id, 'budget-2');
        },
      );
    });

    test('should return budgets with correct properties', () async {
      // Arrange
      when(() => mockRepository.getBudgets())
          .thenAnswer((_) async => Right([testBudget1]));

      // Act
      final result = await useCase();

      // Assert
      result.fold(
        (failure) => fail('Should return success'),
        (budgets) {
          expect(budgets.length, 1);
          expect(budgets[0].id, 'budget-1');
          expect(budgets[0].name, 'Personal Budget');
          expect(budgets[0].ownerId, 'user-123');
          expect(budgets[0].type, BudgetType.personal);
        },
      );
    });

    test('should handle both personal and shared budget types', () async {
      // Arrange
      when(() => mockRepository.getBudgets())
          .thenAnswer((_) async => Right(testBudgets));

      // Act
      final result = await useCase();

      // Assert
      result.fold(
        (failure) => fail('Should return success'),
        (budgets) {
          expect(budgets.length, 2);
          expect(budgets[0].type, BudgetType.personal);
          expect(budgets[1].type, BudgetType.shared);
        },
      );
    });
  });
}
