import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/savings_goal.dart';
import '../repositories/savings_goal_repository.dart';

class GetSavingsGoalsUseCase {
  final SavingsGoalRepository repository;

  GetSavingsGoalsUseCase(this.repository);

  Future<Either<Failure, List<SavingsGoal>>> call(String budgetId) async {
    if (budgetId.trim().isEmpty) {
      return const Left(ValidationFailure('Budget ID is required'));
    }
    return await repository.getSavingsGoals(budgetId);
  }
}
