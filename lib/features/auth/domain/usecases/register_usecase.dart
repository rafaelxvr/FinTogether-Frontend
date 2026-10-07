import 'package:dartz/dartz.dart';

import '../../../../core/utils/failure.dart';
import '../entities/auth_result.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, AuthResult>> call({
    required String name,
    required String email,
    required String password,
    String locale = 'pt-BR',
  }) async {
    // Validate input
    if (name.isEmpty) {
      return const Left(ValidationFailure('Name is required'));
    }
    if (name.length < 2) {
      return const Left(ValidationFailure('Name must be at least 2 characters'));
    }
    if (email.isEmpty) {
      return const Left(ValidationFailure('Email is required'));
    }
    if (!_isValidEmail(email)) {
      return const Left(ValidationFailure('Invalid email format'));
    }
    if (password.isEmpty) {
      return const Left(ValidationFailure('Password is required'));
    }
    if (password.length < 6) {
      return const Left(ValidationFailure('Password must be at least 6 characters'));
    }

    return await repository.register(
      name: name,
      email: email,
      password: password,
      locale: locale,
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
