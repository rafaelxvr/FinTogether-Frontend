import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_search_params.dart';
import '../providers/transaction_provider.dart';
import '../providers/transaction_search_provider.dart';
import '../providers/transaction_search_state.dart';
import '../providers/transaction_state.dart';
import '../widgets/search_filter_panel.dart';
import '../widgets/search_result_item.dart';
import '../../../../shared/providers/active_budget_provider.dart';

class TransactionListPage extends ConsumerStatefulWidget {
  final String budgetId;

  const TransactionListPage({super.key, required this.budgetId});

  @override
  ConsumerState<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends ConsumerState<TransactionListPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSearchActive = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  String get _effectiveBudgetId {
    if (widget.budgetId.isNotEmpty) return widget.budgetId;
    return ref.read(activeBudgetProvider) ?? '';
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final budgetId = _effectiveBudgetId;
      if (budgetId.isNotEmpty) {
        ref.read(transactionProvider.notifier).loadTransactions(budgetId: budgetId);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchActive = !_isSearchActive;
      if (!_isSearchActive) {
        _searchController.clear();
        ref.read(transactionSearchProvider.notifier).clearSearch();
      } else {
        _searchFocusNode.requestFocus();
      }
    });
  }

  void _onSearchTextChanged(String text) {
    final budgetId = _effectiveBudgetId;
    if (budgetId.isEmpty) return;

    final searchNotifier = ref.read(transactionSearchProvider.notifier);
    if (text.isEmpty && !searchNotifier.currentParams.hasActiveFilters) {
      searchNotifier.clearSearch();
      return;
    }

    final params = searchNotifier.currentParams.copyWith(
      query: text.isNotEmpty ? text : null,
      clearQuery: text.isEmpty,
      page: 0,
    );
    searchNotifier.search(budgetId, params);
  }

  void _showFilterPanel() {
    final searchNotifier = ref.read(transactionSearchProvider.notifier);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SearchFilterPanel(
        currentParams: searchNotifier.currentParams,
        onApply: (params) {
          final budgetId = _effectiveBudgetId;
          if (budgetId.isEmpty) return;
          // Keep the current search text
          final updatedParams = params.copyWith(
            query: _searchController.text.isNotEmpty
                ? _searchController.text
                : null,
          );
          searchNotifier.updateFilters(budgetId, updatedParams);
          if (!_isSearchActive) {
            setState(() => _isSearchActive = true);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(transactionProvider);
    final notifier = ref.read(transactionProvider.notifier);
    final searchState = ref.watch(transactionSearchProvider);
    final searchNotifier = ref.read(transactionSearchProvider.notifier);
    final budgetId = _effectiveBudgetId;

    if (budgetId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.transactions)),
        body: Center(
          child: Text(l10n.selectBudgetFirst),
        ),
      );
    }

    final activeFilterCount = searchNotifier.currentParams.activeFilterCount;

    return Scaffold(
      appBar: AppBar(
        title: _isSearchActive
            ? TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: l10n.searchTransactions,
                  border: InputBorder.none,
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchTextChanged('');
                          },
                        )
                      : null,
                ),
                onChanged: _onSearchTextChanged,
              )
            : Text(l10n.transactions),
        actions: [
          IconButton(
            icon: Icon(_isSearchActive ? Icons.close : Icons.search),
            tooltip: _isSearchActive ? l10n.closeSearch : l10n.search,
            onPressed: _toggleSearch,
          ),
          if (_isSearchActive)
            Badge(
              isLabelVisible: activeFilterCount > 0,
              label: Text('$activeFilterCount'),
              child: IconButton(
                icon: const Icon(Icons.tune),
                tooltip: l10n.filters,
                onPressed: _showFilterPanel,
              ),
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.bolt),
              tooltip: l10n.quickEntry,
              onPressed: () => context.push('/budgets/$budgetId/batch-entry'),
            ),
            IconButton(
              icon: const Icon(Icons.receipt_long),
              tooltip: l10n.installments,
              onPressed: () => context.push('/budgets/$budgetId/installments'),
            ),
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => _showDateFilter(context),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => notifier.loadTransactions(budgetId: budgetId, startDate: _startDate, endDate: _endDate),
            ),
          ],
        ],
      ),
      body: _isSearchActive && searchState is! TransactionSearchInitial
          ? _buildSearchResults(searchState, searchNotifier, budgetId)
          : _buildBody(state, notifier, budgetId),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/transactions/create', extra: budgetId),
        icon: const Icon(Icons.add),
        label: Text(l10n.addTransaction),
      ),
    );
  }

  Widget _buildSearchResults(
    TransactionSearchState searchState,
    TransactionSearchNotifier searchNotifier,
    String budgetId,
  ) {
    final l10n = AppLocalizations.of(context)!;

    if (searchState is TransactionSearchLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (searchState is TransactionSearchError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(searchState.message),
          ],
        ),
      );
    }

    if (searchState is TransactionSearchEmpty) {
      final queryText = searchState.params.query;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              queryText != null && queryText.isNotEmpty
                  ? l10n.noResultsFor(queryText)
                  : l10n.noResultsMatchFilters,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (searchState is TransactionSearchLoaded) {
      final results = searchState.results;
      final query = searchState.params.query;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              l10n.nResultsFound(results.length, searchState.hasMore ? '+' : ''),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollEndNotification &&
                    notification.metrics.extentAfter < 200 &&
                    searchState.hasMore) {
                  searchNotifier.loadMore(budgetId);
                }
                return false;
              },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final transaction = results[index];
                  return SearchResultItem(
                    transaction: transaction,
                    highlightQuery: query,
                    onTap: () => context.push(
                        '/transactions/${transaction.id}/edit',
                        extra: transaction),
                  );
                },
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildBody(TransactionState state, TransactionNotifier notifier, String budgetId) {
    final l10n = AppLocalizations.of(context)!;

    if (state is TransactionLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is TransactionError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.message),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => notifier.loadTransactions(budgetId: budgetId),
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    final transactions = notifier.transactions;
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long, size: 100, color: Colors.grey),
            const SizedBox(height: 16),
            Text(l10n.noTransactionsYet),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.push('/transactions/create', extra: budgetId),
              icon: const Icon(Icons.add),
              label: Text(l10n.createTransaction),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return Dismissible(
          key: ValueKey(transaction.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: Colors.red,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (_) async {
            _undoDelete(transaction);
            return false; // We handle deletion ourselves
          },
          child: _buildTransactionCard(transaction, budgetId),
        );
      },
    );
  }

  Widget _buildTransactionCard(Transaction transaction, String budgetId) {
    final color = transaction.isIncome ? Colors.green : (transaction.isExpense ? Colors.red : Colors.blue);

    return Semantics(
      label: '${transaction.displayType} of ${transaction.formattedAmount} ${transaction.description ?? ""}',
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Text(transaction.displayIcon, style: const TextStyle(fontSize: 20)),
          ),
          title: Text(
            transaction.description ?? transaction.displayType,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(DateFormat('MMM dd, yyyy').format(transaction.transactionDate)),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                transaction.amountWithSign,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          onTap: () => context.push('/transactions/${transaction.id}/edit', extra: transaction),
          onLongPress: () => _undoDelete(transaction),
        ),
      ),
    );
  }

  void _undoDelete(Transaction transaction) {
    final l10n = AppLocalizations.of(context)!;
    // Optimistic removal from UI
    final notifier = ref.read(transactionProvider.notifier);
    final budgetId = _effectiveBudgetId;

    HapticFeedback.heavyImpact();

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.transactionDeleted),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: l10n.undoDelete,
          onPressed: () {
            // Re-load to restore
            notifier.loadTransactions(budgetId: budgetId);
          },
        ),
      ),
    ).closed.then((reason) {
      if (reason != SnackBarClosedReason.action) {
        // User did not undo, actually delete
        notifier.deleteTransaction(budgetId: budgetId, id: transaction.id);
      }
    });
  }

  void _showDateFilter(BuildContext context) {
    showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    ).then((range) {
      if (range != null) {
        setState(() {
          _startDate = range.start;
          _endDate = range.end;
        });
        ref.read(transactionProvider.notifier).loadTransactions(
          budgetId: _effectiveBudgetId,
          startDate: _startDate,
          endDate: _endDate,
        );
      }
    });
  }
}
