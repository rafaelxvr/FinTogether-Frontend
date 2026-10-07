import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:frontend/core/utils/failure.dart';
import 'package:frontend/features/auth/domain/entities/auth_result.dart';
import 'package:frontend/features/auth/domain/entities/user.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:frontend/features/auth/domain/usecases/register_usecase.dart';

// Mock class for AuthRepository
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late RegisterUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = RegisterUseCase(mockRepository);
  });

  group('RegisterUseCase', () {
    const testEmail = 'test@example.com';
    const testPassword = 'password123';
    const testName = 'Test User';
    const testLocale = 'en-US';

    final testUser = User(
      id: 'user-123',
      email: testEmail,
      name: testName,
      locale: testLocale,
    );

    final testAuthResult = AuthResult(
      user: testUser,
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
    );

    test('should return AuthResult when registration is successful', () async {
      // Arrange
      when(() => mockRepository.register(
            email: testEmail,
            password: testPassword,
            name: testName,
            locale: testLocale,
          )).thenAnswer((_) async => Right(testAuthResult));

      // Act
      final result = await useCase(
        email: testEmail,
        password: testPassword,
        name: testName,
        locale: testLocale,
      );

      // Assert
      expect(result, Right(testAuthResult));
      verify(() => mockRepository.register(
            email: testEmail,
            password: testPassword,
            name: testName,
            locale: testLocale,
          )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when email already exists', () async {
      // Arrange
      final failure = ServerFailure('Email already in use');
      when(() => mockRepository.register(
            email: testEmail,
            password: testPassword,
            name: testName,
            locale: testLocale,
          )).thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase(
        email: testEmail,
        password: testPassword,
        name: testName,
        locale: testLocale,
      );

      // Assert
      expect(result, Left(failure));
      verify(() => mockRepository.register(
            email: testEmail,
            password: testPassword,
            name: testName,
            locale: testLocale,
          )).called(1);
    });

    test('should return NetworkFailure when network error occurs', () async {
      // Arrange
      final failure = NetworkFailure('No internet connection');
      when(() => mockRepository.register(
            email: testEmail,
            password: testPassword,
            name: testName,
            locale: testLocale,
          )).thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase(
        email: testEmail,
        password: testPassword,
        name: testName,
        locale: testLocale,
      );

      // Assert
      expect(result, Left(failure));
    });

    test('should return ValidationFailure for empty email', () async {
      // Act
      final result = await useCase(
        email: '',
        password: testPassword,
        name: testName,
        locale: testLocale,
      );

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
      final result = await useCase(
        email: 'invalid-email',
        password: testPassword,
        name: testName,
        locale: testLocale,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect((failure as ValidationFailure).message, 'Invalid email format');
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should return ValidationFailure for empty password', () async {
      // Act
      final result = await useCase(
        email: testEmail,
        password: '',
        name: testName,
        locale: testLocale,
      );

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
    });

    test('should return ValidationFailure for password less than 6 characters',
        () async {
      // Act
      final result = await useCase(
        email: testEmail,
        password: '12345',
        name: testName,
        locale: testLocale,
      );

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
    });

    test('should return ValidationFailure for empty name', () async {
      // Act
      final result = await useCase(
        email: testEmail,
        password: testPassword,
        name: '',
        locale: testLocale,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect((failure as ValidationFailure).message, 'Name cannot be empty');
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should return ValidationFailure for name less than 2 characters',
        () async {
      // Act
      final result = await useCase(
        email: testEmail,
        password: testPassword,
        name: 'A',
        locale: testLocale,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect((failure as ValidationFailure).message,
              'Name must be at least 2 characters');
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should use default locale when not provided', () async {
      // Arrange
      when(() => mockRepository.register(
            email: testEmail,
            password: testPassword,
            name: testName,
            locale: 'en-US', // Default locale
          )).thenAnswer((_) async => Right(testAuthResult));

      // Act
      final result = await useCase(
        email: testEmail,
        password: testPassword,
        name: testName,
        locale: null, // Not provided
      );

      // Assert
      expect(result.isRight(), true);
      verify(() => mockRepository.register(
            email: testEmail,
            password: testPassword,
            name: testName,
            locale: 'en-US',
          )).called(1);
    });

    test('should call repository exactly once for valid inputs', () async {
      // Arrange
      when(() => mockRepository.register(
            email: testEmail,
            password: testPassword,
            name: testName,
            locale: testLocale,
          )).thenAnswer((_) async => Right(testAuthResult));

      // Act
      await useCase(
        email: testEmail,
        password: testPassword,
        name: testName,
        locale: testLocale,
      );

      // Assert
      verify(() => mockRepository.register(
            email: testEmail,
            password: testPassword,
            name: testName,
            locale: testLocale,
          )).called(1);
    });

    test('should not call repository for invalid email', () async {
      // Act
      await useCase(
        email: 'invalid-email',
        password: testPassword,
        name: testName,
        locale: testLocale,
      );

      // Assert
      verifyZeroInteractions(mockRepository);
    });

    test('should not call repository for invalid password', () async {
      // Act
      await useCase(
        email: testEmail,
        password: '123',
        name: testName,
        locale: testLocale,
      );

      // Assert
      verifyZeroInteractions(mockRepository);
    });

    test('should not call repository for invalid name', () async {
      // Act
      await useCase(
        email: testEmail,
        password: testPassword,
        name: '',
        locale: testLocale,
      );

      // Assert
      verifyZeroInteractions(mockRepository);
    });

    test('should handle repository throwing exception', () async {
      // Arrange
      when(() => mockRepository.register(
            email: testEmail,
            password: testPassword,
            name: testName,
            locale: testLocale,
          )).thenThrow(Exception('Unexpected error'));

      // Act & Assert
      expect(
        () => useCase(
          email: testEmail,
          password: testPassword,
          name: testName,
          locale: testLocale,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
