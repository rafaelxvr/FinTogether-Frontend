import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/savings_goal.dart';
import '../repositories/savings_goal_repository.dart';

class GetSavingsGoalByIdUseCase {
  final SavingsGoalRepository repository;

  GetSavingsGoalByIdUseCase(this.repository);

  Future<Either<Failure, SavingsGoal>> call(String id) async {
    if (id.trim().isEmpty) {
      return const Left(ValidationFailure('Savings goal ID is required'));
    }
    return await repository.getSavingsGoalById(id);
  }
}
