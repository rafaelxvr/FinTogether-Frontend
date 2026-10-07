import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../repositories/savings_goal_repository.dart';

class DeleteSavingsGoalUseCase {
  final SavingsGoalRepository repository;

  DeleteSavingsGoalUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    if (id.trim().isEmpty) {
      return const Left(ValidationFailure('Savings goal ID is required'));
    }
    return await repository.deleteSavingsGoal(id);
  }
}
