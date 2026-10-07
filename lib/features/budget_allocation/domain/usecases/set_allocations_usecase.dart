import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/budget_allocation.dart';
import '../repositories/budget_allocation_repository.dart';

/// Use Case: Set Budget Allocations
/// Validates inputs and delegates to repository to save allocations.
class SetAllocationsUseCase {
  final BudgetAllocationRepository repository;

  SetAllocationsUseCase(this.repository);

  Future<Either<Failure, BudgetAllocation>> call({
    required String budgetId,
    required String month,
    required List<CategoryAllocationInput> allocations,
  }) async {
    if (budgetId.trim().isEmpty) {
      return const Left(ValidationFailure('Budget ID cannot be empty'));
    }
    if (month.trim().isEmpty) {
      return const Left(ValidationFailure('Month cannot be empty'));
    }
    if (allocations.isEmpty) {
      return const Left(ValidationFailure('At least one allocation is required'));
    }
    for (final allocation in allocations) {
      if (allocation.allocatedAmount < 0) {
        return const Left(
          ValidationFailure('Allocation amount must be non-negative'),
        );
      }
    }
    return await repository.setAllocations(
      budgetId: budgetId,
      month: month,
      allocations: allocations,
    );
  }
}
