import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/savings_goal.dart';
import '../repositories/savings_goal_repository.dart';

class ContributeToSavingsGoalUseCase {
  final SavingsGoalRepository repository;

  ContributeToSavingsGoalUseCase(this.repository);

  Future<Either<Failure, SavingsGoal>> call({
    required String id,
    required double amount,
    String? note,
  }) async {
    if (id.trim().isEmpty) {
      return const Left(ValidationFailure('Savings goal ID is required'));
    }

    if (amount <= 0) {
      return const Left(
          ValidationFailure('Contribution amount must be greater than zero'));
    }
    if (amount.isNaN || amount.isInfinite) {
      return const Left(ValidationFailure('Invalid amount'));
    }

    return await repository.contribute(
      id: id.trim(),
      amount: amount,
      note: note?.trim(),
    );
  }
}
