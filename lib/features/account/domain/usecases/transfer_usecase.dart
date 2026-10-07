import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../repositories/account_repository.dart';

class TransferUseCase {
  final AccountRepository repository;

  TransferUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    String? description,
  }) async {
    // Validate from account ID
    if (fromAccountId.trim().isEmpty) {
      return const Left(ValidationFailure('Source account is required'));
    }

    // Validate to account ID
    if (toAccountId.trim().isEmpty) {
      return const Left(ValidationFailure('Destination account is required'));
    }

    // Prevent self-transfer
    if (fromAccountId.trim() == toAccountId.trim()) {
      return const Left(
          ValidationFailure('Cannot transfer to the same account'));
    }

    // Validate amount
    if (amount <= 0) {
      return const Left(
          ValidationFailure('Transfer amount must be greater than zero'));
    }
    if (amount.isNaN || amount.isInfinite) {
      return const Left(ValidationFailure('Invalid transfer amount'));
    }

    return await repository.transfer(
      fromAccountId: fromAccountId.trim(),
      toAccountId: toAccountId.trim(),
      amount: amount,
      description: description?.trim(),
    );
  }
}
