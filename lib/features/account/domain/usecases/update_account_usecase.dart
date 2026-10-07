import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/account.dart';
import '../repositories/account_repository.dart';

class UpdateAccountUseCase {
  final AccountRepository repository;

  UpdateAccountUseCase(this.repository);

  Future<Either<Failure, Account>> call({
    required String id,
    required String name,
    required String currency,
  }) async {
    // Validate account ID
    if (id.trim().isEmpty) {
      return const Left(ValidationFailure('Account ID is required'));
    }

    // Validate name
    if (name.trim().isEmpty) {
      return const Left(ValidationFailure('Account name is required'));
    }
    if (name.trim().length < 2) {
      return const Left(
          ValidationFailure('Account name must be at least 2 characters'));
    }
    if (name.length > 255) {
      return const Left(
          ValidationFailure('Account name must not exceed 255 characters'));
    }

    // Validate currency
    if (currency.trim().isEmpty) {
      return const Left(ValidationFailure('Currency is required'));
    }
    if (currency.trim().length != 3) {
      return const Left(
          ValidationFailure('Currency must be a 3-letter code (e.g., BRL)'));
    }

    return await repository.updateAccount(
      id: id.trim(),
      name: name.trim(),
      currency: currency.trim().toUpperCase(),
    );
  }
}
