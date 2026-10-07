import 'package:dartz/dartz.dart';

import '../../../../core/utils/failure.dart';
import '../repositories/auth_repository.dart';

class ForgotPasswordUseCase {
  final AuthRepository repository;

  ForgotPasswordUseCase(this.repository);

  Future<Either<Failure, void>> call({required String email}) async {
    // Validate input
    if (email.isEmpty) {
      return const Left(ValidationFailure('Email is required'));
    }
    if (!_isValidEmail(email)) {
      return const Left(ValidationFailure('Invalid email format'));
    }

    return await repository.forgotPassword(email: email);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
