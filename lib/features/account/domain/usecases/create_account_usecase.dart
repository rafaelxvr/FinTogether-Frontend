import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/account.dart';
import '../repositories/account_repository.dart';

class CreateAccountUseCase {
  final AccountRepository repository;

  CreateAccountUseCase(this.repository);

  Future<Either<Failure, Account>> call({
    required String budgetId,
    required String name,
    required AccountType type,
    String currency = 'BRL',
    double openingBalance = 0.0,
  }) async {
    // Validate budget ID
    if (budgetId.trim().isEmpty) {
      return const Left(ValidationFailure('Budget ID is required'));
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

    // Validate opening balance
    if (openingBalance.isNaN || openingBalance.isInfinite) {
      return const Left(ValidationFailure('Invalid opening balance'));
    }

    return await repository.createAccount(
      budgetId: budgetId.trim(),
      name: name.trim(),
      type: type,
      currency: currency.trim().toUpperCase(),
      openingBalance: openingBalance,
    );
  }
}
