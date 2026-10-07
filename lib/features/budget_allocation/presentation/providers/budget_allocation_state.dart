import 'package:equatable/equatable.dart';
import '../../domain/entities/budget_allocation.dart';

/// Budget Allocation State
abstract class BudgetAllocationState extends Equatable {
  const BudgetAllocationState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class BudgetAllocationInitial extends BudgetAllocationState {
  const BudgetAllocationInitial();
}

/// Loading state
class BudgetAllocationLoading extends BudgetAllocationState {
  const BudgetAllocationLoading();
}

/// Loaded state with allocation data
class BudgetAllocationLoaded extends BudgetAllocationState {
  final BudgetAllocation allocation;

  const BudgetAllocationLoaded(this.allocation);

  @override
  List<Object?> get props => [allocation];
}

/// Saving state while submitting allocations
class BudgetAllocationSaving extends BudgetAllocationState {
  const BudgetAllocationSaving();
}

/// Saved state after successful submission
class BudgetAllocationSaved extends BudgetAllocationState {
  final BudgetAllocation allocation;

  const BudgetAllocationSaved(this.allocation);

  @override
  List<Object?> get props => [allocation];
}

/// Error state
class BudgetAllocationError extends BudgetAllocationState {
  final String message;

  const BudgetAllocationError(this.message);

  @override
  List<Object?> get props => [message];
}
