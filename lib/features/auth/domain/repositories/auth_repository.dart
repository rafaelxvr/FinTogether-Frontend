import 'package:dartz/dartz.dart';

import '../../../../core/utils/failure.dart';
import '../entities/auth_result.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthResult>> register({
    required String name,
    required String email,
    required String password,
    String locale = 'pt-BR',
  });

  Future<Either<Failure, AuthResult>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, AuthResult>> refreshToken();

  Future<Either<Failure, User>> getCurrentUser();

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, void>> forgotPassword({required String email});

  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
  });

  Future<bool> isLoggedIn();

  Future<String?> getAccessToken();
}
