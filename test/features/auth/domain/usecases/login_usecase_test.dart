import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:frontend/core/utils/failure.dart';
import 'package:frontend/features/auth/domain/entities/auth_result.dart';
import 'package:frontend/features/auth/domain/entities/user.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:frontend/features/auth/domain/usecases/login_usecase.dart';

// Mock class for AuthRepository
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUseCase(mockRepository);
  });

  group('LoginUseCase', () {
    const testEmail = 'test@example.com';
    const testPassword = 'password123';

    final testUser = User(
      id: 'user-123',
      email: testEmail,
      name: 'Test User',
      locale: 'en-US',
    );

    final testAuthResult = AuthResult(
      user: testUser,
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
    );

    test('should return AuthResult when login is successful', () async {
      // Arrange
      when(() => mockRepository.login(testEmail, testPassword))
          .thenAnswer((_) async => Right(testAuthResult));

      // Act
      final result = await useCase(testEmail, testPassword);

      // Assert
      expect(result, Right(testAuthResult));
      verify(() => mockRepository.login(testEmail, testPassword)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when login fails with server error',
        () async {
      // Arrange
      final failure = ServerFailure('Invalid credentials');
      when(() => mockRepository.login(testEmail, testPassword))
          .thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase(testEmail, testPassword);

      // Assert
      expect(result, Left(failure));
      verify(() => mockRepository.login(testEmail, testPassword)).called(1);
    });

    test('should return NetworkFailure when login fails with network error',
        () async {
      // Arrange
      final failure = NetworkFailure('No internet connection');
      when(() => mockRepository.login(testEmail, testPassword))
          .thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase(testEmail, testPassword);

      // Assert
      expect(result, Left(failure));
      verify(() => mockRepository.login(testEmail, testPassword)).called(1);
    });

    test('should return ValidationFailure for empty email', () async {
      // Act
      final result = await useCase('', testPassword);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect((failure as ValidationFailure).message, 'Email cannot be empty');
        },
        (_) => fail('Should not return success'),
      );
      verifyZeroInteractions(mockRepository);
    });

    test('should return ValidationFailure for invalid email format', () async {
      // Act
      final result = await useCase('invalid-email', testPassword);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect((failure as ValidationFailure).message, 'Invalid email format');
        },
        (_) => fail('Should not return success'),
      );
      verifyZeroInteractions(mockRepository);
    });

    test('should return ValidationFailure for empty password', () async {
      // Act
      final result = await useCase(testEmail, '');

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(
              (failure as ValidationFailure).message, 'Password cannot be empty');
        },
        (_) => fail('Should not return success'),
      );
      verifyZeroInteractions(mockRepository);
    });

    test('should return ValidationFailure for password less than 6 characters',
        () async {
      // Act
      final result = await useCase(testEmail, '12345');

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect((failure as ValidationFailure).message,
              'Password must be at least 6 characters');
        },
        (_) => fail('Should not return success'),
      );
      verifyZeroInteractions(mockRepository);
    });

    test('should call repository exactly once for valid credentials', () async {
      // Arrange
      when(() => mockRepository.login(testEmail, testPassword))
          .thenAnswer((_) async => Right(testAuthResult));

      // Act
      await useCase(testEmail, testPassword);

      // Assert
      verify(() => mockRepository.login(testEmail, testPassword)).called(1);
    });

    test('should not call repository for invalid email', () async {
      // Act
      await useCase('invalid-email', testPassword);

      // Assert
      verifyZeroInteractions(mockRepository);
    });

    test('should not call repository for invalid password', () async {
      // Act
      await useCase(testEmail, '123');

      // Assert
      verifyZeroInteractions(mockRepository);
    });

    test('should handle repository throwing exception', () async {
      // Arrange
      when(() => mockRepository.login(testEmail, testPassword))
          .thenThrow(Exception('Unexpected error'));

      // Act & Assert
      expect(
        () => useCase(testEmail, testPassword),
        throwsA(isA<Exception>()),
      );
    });
  });
}
