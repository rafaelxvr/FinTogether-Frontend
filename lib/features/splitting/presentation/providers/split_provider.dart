import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import '../../domain/usecases/get_balances_usecase.dart';
import '../../domain/usecases/get_splits_for_transaction_usecase.dart';
import '../../domain/usecases/settle_split_usecase.dart';
import 'split_state.dart';

class SplitNotifier extends StateNotifier<SplitState> {
  final GetBalancesUseCase getBalancesUseCase;
  final GetSplitsForTransactionUseCase getSplitsForTransactionUseCase;
  final SettleSplitUseCase settleSplitUseCase;

  SplitNotifier({
    required this.getBalancesUseCase,
    required this.getSplitsForTransactionUseCase,
    required this.settleSplitUseCase,
  }) : super(SplitInitial());

  Future<void> loadBalances(String budgetId) async {
    state = SplitLoading();
    final result = await getBalancesUseCase(budgetId);
    result.fold(
      (failure) => state = SplitError(failure.message),
      (balances) => state = BalancesLoaded(balances),
    );
  }

  Future<void> loadSplitsForTransaction(String transactionId) async {
    state = SplitLoading();
    final result = await getSplitsForTransactionUseCase(transactionId);
    result.fold(
      (failure) => state = SplitError(failure.message),
      (splits) => state = SplitsLoaded(splits),
    );
  }

  Future<void> settleSplit({
    required String splitId,
    required String budgetId,
  }) async {
    state = SplitLoading();
    final result = await settleSplitUseCase(splitId);
    result.fold(
      (failure) => state = SplitError(failure.message),
      (split) {
        state = SplitSettled(split);
        // Refresh balances after settling
        loadBalances(budgetId);
      },
    );
  }
}

final splitProvider = StateNotifierProvider<SplitNotifier, SplitState>(
  (ref) => SplitNotifier(
    getBalancesUseCase: getIt<GetBalancesUseCase>(),
    getSplitsForTransactionUseCase: getIt<GetSplitsForTransactionUseCase>(),
    settleSplitUseCase: getIt<SettleSplitUseCase>(),
  ),
);
