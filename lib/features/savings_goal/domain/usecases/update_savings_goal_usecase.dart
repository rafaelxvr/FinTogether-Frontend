import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/savings_goal.dart';
import '../repositories/savings_goal_repository.dart';

class UpdateSavingsGoalUseCase {
  final SavingsGoalRepository repository;

  UpdateSavingsGoalUseCase(this.repository);

  Future<Either<Failure, SavingsGoal>> call({
    required String id,
    required String name,
    String? description,
    double? targetAmount,
    DateTime? deadline,
    String? icon,
    String? color,
  }) async {
    if (id.trim().isEmpty) {
      return const Left(ValidationFailure('Savings goal ID is required'));
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

    if (targetAmount != null && targetAmount <= 0) {
      return const Left(
          ValidationFailure('Target amount must be greater than zero'));
    }

    return await repository.updateSavingsGoal(
      id: id.trim(),
      name: name.trim(),
      description: description?.trim(),
      targetAmount: targetAmount,
      deadline: deadline,
      icon: icon,
      color: color,
    );
  }
}
