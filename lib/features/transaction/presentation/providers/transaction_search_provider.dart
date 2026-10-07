import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_search_params.dart';
import '../../domain/usecases/search_transactions_usecase.dart';
import 'transaction_search_state.dart';

class TransactionSearchNotifier
    extends StateNotifier<TransactionSearchState> {
  final SearchTransactionsUseCase searchTransactionsUseCase;

  Timer? _debounceTimer;
  TransactionSearchParams _currentParams = const TransactionSearchParams();
  List<Transaction> _currentResults = [];

  TransactionSearchNotifier({
    required this.searchTransactionsUseCase,
  }) : super(TransactionSearchInitial());

  TransactionSearchParams get currentParams => _currentParams;

  void search(String budgetId, TransactionSearchParams params) {
    _debounceTimer?.cancel();
    _currentParams = params.copyWith(page: 0);

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _executeSearch(budgetId);
    });
  }

  void searchImmediate(String budgetId, TransactionSearchParams params) {
    _debounceTimer?.cancel();
    _currentParams = params.copyWith(page: 0);
    _executeSearch(budgetId);
  }

  Future<void> loadMore(String budgetId) async {
    if (state is! TransactionSearchLoaded) return;
    final loadedState = state as TransactionSearchLoaded;
    if (!loadedState.hasMore) return;

    _currentParams = _currentParams.copyWith(
        page: _currentParams.page + 1);

    final result = await searchTransactionsUseCase(
      budgetId: budgetId,
      params: _currentParams,
    );

    result.fold(
      (failure) {
        state = TransactionSearchError(message: failure.message);
      },
      (transactions) {
        _currentResults = [..._currentResults, ...transactions];
        if (transactions.isEmpty) {
          state = TransactionSearchLoaded(
            results: _currentResults,
            params: _currentParams,
            hasMore: false,
          );
        } else {
          state = TransactionSearchLoaded(
            results: _currentResults,
            params: _currentParams,
            hasMore: transactions.length >= _currentParams.size,
          );
        }
      },
    );
  }

  void clearSearch() {
    _debounceTimer?.cancel();
    _currentParams = const TransactionSearchParams();
    _currentResults = [];
    state = TransactionSearchInitial();
  }

  void updateFilters(String budgetId, TransactionSearchParams params) {
    _currentParams = params.copyWith(page: 0);
    _executeSearch(budgetId);
  }

  Future<void> _executeSearch(String budgetId) async {
    state = TransactionSearchLoading();

    final result = await searchTransactionsUseCase(
      budgetId: budgetId,
      params: _currentParams,
    );

    result.fold(
      (failure) {
        state = TransactionSearchError(message: failure.message);
      },
      (transactions) {
        _currentResults = transactions;
        if (transactions.isEmpty) {
          state = TransactionSearchEmpty(params: _currentParams);
        } else {
          state = TransactionSearchLoaded(
            results: transactions,
            params: _currentParams,
            hasMore: transactions.length >= _currentParams.size,
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

final transactionSearchProvider = StateNotifierProvider<
    TransactionSearchNotifier, TransactionSearchState>(
  (ref) => TransactionSearchNotifier(
    searchTransactionsUseCase: getIt<SearchTransactionsUseCase>(),
  ),
);
