import 'package:dartz/dartz.dart';

import '../../../../core/utils/failure.dart';
import '../entities/installment_group.dart';
import '../repositories/installment_group_repository.dart';

class CreateInstallmentGroupUseCase {
  final InstallmentGroupRepository repository;

  CreateInstallmentGroupUseCase(this.repository);

  Future<Either<Failure, InstallmentGroup>> call({
    required String budgetId,
    required double totalAmount,
    required int installmentCount,
    double interestRate = 0,
    required DateTime startDate,
    String? description,
    String? categoryId,
    String? accountId,
    String? cardId,
  }) async {
    if (budgetId.trim().isEmpty) {
      return const Left(ValidationFailure('Budget ID is required'));
    }

    if (totalAmount <= 0) {
      return const Left(
          ValidationFailure('Total amount must be greater than zero'));
    }

    if (totalAmount.isNaN || totalAmount.isInfinite) {
      return const Left(ValidationFailure('Invalid amount'));
    }

    if (installmentCount < 2 || installmentCount > 48) {
      return const Left(
          ValidationFailure('Number of installments must be between 2 and 48'));
    }

    if (interestRate < 0 || interestRate > 100) {
      return const Left(
          ValidationFailure('Interest rate must be between 0 and 100'));
    }

    if (description != null && description.length > 500) {
      return const Left(
          ValidationFailure('Description must not exceed 500 characters'));
    }

    return await repository.createInstallmentGroup(
      budgetId: budgetId.trim(),
      totalAmount: totalAmount,
      installmentCount: installmentCount,
      interestRate: interestRate,
      startDate: startDate,
      description: description?.trim(),
      categoryId: categoryId?.trim(),
      accountId: accountId?.trim(),
      cardId: cardId?.trim(),
    );
  }
}
