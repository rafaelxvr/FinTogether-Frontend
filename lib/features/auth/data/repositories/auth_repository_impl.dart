import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/utils/failure.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/user_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final UserLocalDataSource userLocalDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.userLocalDataSource,
  });

  @override
  Future<Either<Failure, AuthResult>> register({
    required String name,
    required String email,
    required String password,
    String locale = 'pt-BR',
  }) async {
    try {
      final response = await remoteDataSource.register({
        'name': name,
        'email': email,
        'password': password,
        'locale': locale,
      });

      if (response.success && response.data != null) {
        final authResponse = response.data!;

        // Save tokens and user locally
        await localDataSource.saveTokens(
          accessToken: authResponse.accessToken,
          refreshToken: authResponse.refreshToken,
        );
        await localDataSource.saveUser(authResponse.user.toEntity());
        await userLocalDataSource.saveUser(authResponse.user);

        return Right(authResponse.toEntity());
      } else {
        return Left(ServerFailure(response.message ?? 'Registration failed'));
      }
    } on DioException catch (e) {
      AppLogger.error('Registration error', e);
      return Left(_handleDioError(e));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected registration error', e, stackTrace);
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResult>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await remoteDataSource.login({
        'email': email,
        'password': password,
      });

      if (response.success && response.data != null) {
        final authResponse = response.data!;

        // Save tokens and user locally
        await localDataSource.saveTokens(
          accessToken: authResponse.accessToken,
          refreshToken: authResponse.refreshToken,
        );
        await localDataSource.saveUser(authResponse.user.toEntity());
        await userLocalDataSource.saveUser(authResponse.user);

        return Right(authResponse.toEntity());
      } else {
        return Left(ServerFailure(response.message ?? 'Login failed'));
      }
    } on DioException catch (e) {
      AppLogger.error('Login error', e);
      return Left(_handleDioError(e));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected login error', e, stackTrace);
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResult>> refreshToken() async {
    try {
      final refreshToken = await localDataSource.getRefreshToken();
      if (refreshToken == null) {
        return const Left(UnauthorizedFailure('No refresh token available'));
      }

      final response = await remoteDataSource.refreshToken({
        'refreshToken': refreshToken,
      });

      if (response.success && response.data != null) {
        final authResponse = response.data!;

        // Update tokens
        await localDataSource.saveTokens(
          accessToken: authResponse.accessToken,
          refreshToken: authResponse.refreshToken,
        );

        return Right(authResponse.toEntity());
      } else {
        return Left(ServerFailure(response.message ?? 'Token refresh failed'));
      }
    } on DioException catch (e) {
      AppLogger.error('Token refresh error', e);
      return Left(_handleDioError(e));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected token refresh error', e, stackTrace);
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      // Try UserLocalDataSource (Drift DB) first
      final localUser = await userLocalDataSource.getUser();
      if (localUser != null) {
        return Right(localUser.toEntity());
      }

      // Fallback: try legacy cached user from AuthLocalDataSource
      final cachedUser = await localDataSource.getCachedUser();
      if (cachedUser != null) {
        return Right(cachedUser);
      }

      // Fetch from server
      final response = await remoteDataSource.getCurrentUser();

      if (response.success && response.data != null) {
        final userModel = response.data!;
        await localDataSource.saveUser(userModel.toEntity());
        await userLocalDataSource.saveUser(userModel);
        return Right(userModel.toEntity());
      } else {
        return Left(ServerFailure(response.message ?? 'Failed to get user'));
      }
    } on DioException catch (e) {
      AppLogger.error('Get current user error', e);
      return Left(_handleDioError(e));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected get user error', e, stackTrace);
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.clearAll();
      await userLocalDataSource.clearAll();
      return const Right(null);
    } catch (e, stackTrace) {
      AppLogger.error('Logout error', e, stackTrace);
      return const Left(CacheFailure('Failed to logout'));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword({required String email}) async {
    try {
      final response = await remoteDataSource.forgotPassword({'email': email});

      if (response.success) {
        return const Right(null);
      } else {
        return Left(ServerFailure(response.message ?? 'Failed to send reset email'));
      }
    } on DioException catch (e) {
      AppLogger.error('Forgot password error', e);
      return Left(_handleDioError(e));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected forgot password error', e, stackTrace);
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await remoteDataSource.resetPassword({
        'token': token,
        'newPassword': newPassword,
      });

      if (response.success) {
        return const Right(null);
      } else {
        return Left(ServerFailure(response.message ?? 'Failed to reset password'));
      }
    } on DioException catch (e) {
      AppLogger.error('Reset password error', e);
      return Left(_handleDioError(e));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected reset password error', e, stackTrace);
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    return await localDataSource.isLoggedIn();
  }

  @override
  Future<String?> getAccessToken() async {
    return await localDataSource.getAccessToken();
  }

  Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure('Connection timeout');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401) {
          return const UnauthorizedFailure('Invalid credentials');
        } else if (statusCode == 400) {
          final message = error.response?.data['message'] ?? 'Bad request';
          return ValidationFailure(message);
        } else {
          return ServerFailure(
            error.response?.data['message'] ?? 'Server error',
          );
        }

      case DioExceptionType.cancel:
        return const ServerFailure('Request cancelled');

      case DioExceptionType.connectionError:
        return const NetworkFailure('No internet connection');

      case DioExceptionType.badCertificate:
        return const ServerFailure('Invalid certificate');

      case DioExceptionType.unknown:
      default:
        return ServerFailure(error.message ?? 'Unknown error');
    }
  }
}
