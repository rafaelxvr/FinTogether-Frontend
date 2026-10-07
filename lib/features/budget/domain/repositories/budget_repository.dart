import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/budget.dart';
import '../entities/budget_member.dart';

abstract class BudgetRepository {
  /// Get all budgets for the current user
  Future<Either<Failure, List<Budget>>> getBudgets();

  /// Get a budget by ID
  Future<Either<Failure, Budget>> getBudgetById(String id);

  /// Create a new budget
  Future<Either<Failure, Budget>> createBudget({
    required String name,
    required BudgetType type,
  });

  /// Update an existing budget
  Future<Either<Failure, Budget>> updateBudget({
    required String id,
    required String name,
    required BudgetType type,
  });

  /// Delete a budget
  Future<Either<Failure, void>> deleteBudget(String id);

  /// Get all members of a budget
  Future<Either<Failure, List<BudgetMember>>> getBudgetMembers(String budgetId);

  /// Add a member to a budget
  Future<Either<Failure, BudgetMember>> addBudgetMember({
    required String budgetId,
    required String email,
    required BudgetMemberRole role,
  });

  /// Remove a member from a budget
  Future<Either<Failure, void>> removeBudgetMember({
    required String budgetId,
    required String memberId,
  });
}
