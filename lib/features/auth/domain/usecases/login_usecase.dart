import 'package:dartz/dartz.dart';

import '../../../../core/utils/failure.dart';
import '../entities/auth_result.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, AuthResult>> call({
    required String email,
    required String password,
  }) async {
    // Validate input
    if (email.isEmpty) {
      return const Left(ValidationFailure('Email is required'));
    }
    if (password.isEmpty) {
      return const Left(ValidationFailure('Password is required'));
    }
    if (!_isValidEmail(email)) {
      return const Left(ValidationFailure('Invalid email format'));
    }

    return await repository.login(email: email, password: password);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
