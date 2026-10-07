import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/budget_allocation.dart';
import '../repositories/budget_allocation_repository.dart';

/// Use Case: Get Budget Allocations
/// Loads allocations with actual spending for a budget and month.
class GetAllocationsUseCase {
  final BudgetAllocationRepository repository;

  GetAllocationsUseCase(this.repository);

  Future<Either<Failure, BudgetAllocation>> call(
    String budgetId,
    String month,
  ) async {
    if (budgetId.trim().isEmpty) {
      return const Left(ValidationFailure('Budget ID cannot be empty'));
    }
    if (month.trim().isEmpty) {
      return const Left(ValidationFailure('Month cannot be empty'));
    }
    final monthPattern = RegExp(r'^\d{4}-\d{2}$');
    if (!monthPattern.hasMatch(month)) {
      return const Left(
        ValidationFailure('Invalid month format. Expected: YYYY-MM'),
      );
    }
    return await repository.getAllocations(budgetId, month);
  }
}
