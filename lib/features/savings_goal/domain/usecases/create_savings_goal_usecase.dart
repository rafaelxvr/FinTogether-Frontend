import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/savings_goal.dart';
import '../repositories/savings_goal_repository.dart';

class CreateSavingsGoalUseCase {
  final SavingsGoalRepository repository;

  CreateSavingsGoalUseCase(this.repository);

  Future<Either<Failure, SavingsGoal>> call({
    required String budgetId,
    required String name,
    String? description,
    required double targetAmount,
    String currency = 'BRL',
    DateTime? deadline,
    String? accountId,
    String? icon,
    String? color,
  }) async {
    if (budgetId.trim().isEmpty) {
      return const Left(ValidationFailure('Budget ID is required'));
    }

    if (name.trim().isEmpty) {
      return const Left(ValidationFailure('Savings goal name is required'));
    }
    if (name.trim().length < 2) {
      return const Left(
          ValidationFailure('Name must be at least 2 characters'));
    }
    if (name.length > 255) {
      return const Left(
          ValidationFailure('Name must not exceed 255 characters'));
    }

    if (targetAmount <= 0) {
      return const Left(
          ValidationFailure('Target amount must be greater than zero'));
    }
    if (targetAmount.isNaN || targetAmount.isInfinite) {
      return const Left(ValidationFailure('Invalid target amount'));
    }

    if (currency.trim().isEmpty || currency.trim().length != 3) {
      return const Left(
          ValidationFailure('Currency must be a 3-letter code (e.g., BRL)'));
    }

    return await repository.createSavingsGoal(
      budgetId: budgetId.trim(),
      name: name.trim(),
      description: description?.trim(),
      targetAmount: targetAmount,
      currency: currency.trim().toUpperCase(),
      deadline: deadline,
      accountId: accountId,
      icon: icon,
      color: color,
    );
  }
}
