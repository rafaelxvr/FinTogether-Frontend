import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/savings_goal_contribution.dart';
import '../repositories/savings_goal_repository.dart';

class GetContributionsUseCase {
  final SavingsGoalRepository repository;

  GetContributionsUseCase(this.repository);

  Future<Either<Failure, List<SavingsGoalContribution>>> call(
      String savingsGoalId) async {
    if (savingsGoalId.trim().isEmpty) {
      return const Left(ValidationFailure('Savings goal ID is required'));
    }
    return await repository.getContributions(savingsGoalId);
  }
}
