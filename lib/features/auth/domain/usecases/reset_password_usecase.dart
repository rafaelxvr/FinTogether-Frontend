import 'package:dartz/dartz.dart';

import '../../../../core/utils/failure.dart';
import '../repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String token,
    required String newPassword,
  }) async {
    // Validate input
    if (token.isEmpty) {
      return const Left(ValidationFailure('Reset token is required'));
    }
    if (newPassword.isEmpty) {
      return const Left(ValidationFailure('New password is required'));
    }
    if (newPassword.length < 6) {
      return const Left(ValidationFailure('Password must be at least 6 characters'));
    }

    return await repository.resetPassword(
      token: token,
      newPassword: newPassword,
    );
  }
}
