import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/savings_goal.dart';
import '../entities/savings_goal_contribution.dart';

abstract class SavingsGoalRepository {
  Future<Either<Failure, List<SavingsGoal>>> getSavingsGoals(String budgetId);

  Future<Either<Failure, SavingsGoal>> getSavingsGoalById(String id);

  Future<Either<Failure, SavingsGoal>> createSavingsGoal({
    required String budgetId,
    required String name,
    String? description,
    required double targetAmount,
    String currency = 'BRL',
    DateTime? deadline,
    String? accountId,
    String? icon,
    String? color,
  });

  Future<Either<Failure, SavingsGoal>> updateSavingsGoal({
    required String id,
    required String name,
    String? description,
    double? targetAmount,
    DateTime? deadline,
    String? icon,
    String? color,
  });

  Future<Either<Failure, void>> deleteSavingsGoal(String id);

  Future<Either<Failure, SavingsGoal>> contribute({
    required String id,
    required double amount,
    String? note,
  });

  Future<Either<Failure, SavingsGoal>> withdraw({
    required String id,
    required double amount,
    String? note,
  });

  Future<Either<Failure, List<SavingsGoalContribution>>> getContributions(
      String savingsGoalId);
}
