import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/budget_allocation.dart';
import '../../domain/usecases/get_allocations_usecase.dart';
import '../../domain/usecases/set_allocations_usecase.dart';
import 'budget_allocation_state.dart';

/// Budget Allocation Notifier
/// Manages budget allocation state and delegates to use cases.
class BudgetAllocationNotifier extends StateNotifier<BudgetAllocationState> {
  final GetAllocationsUseCase getAllocationsUseCase;
  final SetAllocationsUseCase setAllocationsUseCase;

  BudgetAllocationNotifier({
    required this.getAllocationsUseCase,
    required this.setAllocationsUseCase,
  }) : super(const BudgetAllocationInitial());

  /// Load allocations for a budget and month.
  Future<void> loadAllocations(String budgetId, String month) async {
    state = const BudgetAllocationLoading();

    final result = await getAllocationsUseCase(budgetId, month);

    result.fold(
      (failure) => state = BudgetAllocationError(failure.message),
      (allocation) => state = BudgetAllocationLoaded(allocation),
    );
  }

  /// Save allocations for a budget and month.
  Future<void> saveAllocations(
    String budgetId,
    String month,
    List<CategoryAllocationInput> allocations,
  ) async {
    state = const BudgetAllocationSaving();

    final result = await setAllocationsUseCase(
      budgetId: budgetId,
      month: month,
      allocations: allocations,
    );

    result.fold(
      (failure) => state = BudgetAllocationError(failure.message),
      (allocation) => state = BudgetAllocationSaved(allocation),
    );
  }

  /// Reset to initial state.
  void reset() {
    state = const BudgetAllocationInitial();
  }
}

/// Budget Allocation Provider
final budgetAllocationProvider =
    StateNotifierProvider<BudgetAllocationNotifier, BudgetAllocationState>(
  (ref) {
    return BudgetAllocationNotifier(
      getAllocationsUseCase: getIt<GetAllocationsUseCase>(),
      setAllocationsUseCase: getIt<SetAllocationsUseCase>(),
    );
  },
);
