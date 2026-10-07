import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/fixed_expense_summary.dart';
import '../../domain/entities/recurring_transaction_template.dart';
import '../providers/recurring_transaction_provider.dart';
import '../providers/recurring_transaction_state.dart';

/// Page listing all fixed monthly expense templates.
class FixedExpenseListPage extends ConsumerStatefulWidget {
  final String budgetId;

  const FixedExpenseListPage({super.key, required this.budgetId});

  @override
  ConsumerState<FixedExpenseListPage> createState() =>
      _FixedExpenseListPageState();
}

class _FixedExpenseListPageState extends ConsumerState<FixedExpenseListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(recurringTransactionProvider.notifier)
          .loadFixedExpenseSummary(widget.budgetId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(recurringTransactionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.fixedMonthlyCosts),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref
                .read(recurringTransactionProvider.notifier)
                .loadFixedExpenseSummary(widget.budgetId),
          ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(RecurringTransactionState state) {
    final l10n = AppLocalizations.of(context)!;
    if (state is RecurringLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is RecurringError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.message),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref
                  .read(recurringTransactionProvider.notifier)
                  .loadFixedExpenseSummary(widget.budgetId),
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    if (state is FixedExpenseSummaryLoaded) {
      return _buildContent(state.summary);
    }

    return Center(child: Text(l10n.loadingFixedExpenses));
  }

  Widget _buildContent(FixedExpenseSummary summary) {
    final l10n = AppLocalizations.of(context)!;
    final currencyFormat =
        NumberFormat.currency(symbol: 'R\$ ', decimalDigits: 2);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return RefreshIndicator(
      onRefresh: () => ref
          .read(recurringTransactionProvider.notifier)
          .loadFixedExpenseSummary(widget.budgetId),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header card with total
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.red[50],
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    l10n.totalMonthlyFixedCosts,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currencyFormat.format(summary.totalMonthlyAmount),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.nFixedExpenses(summary.expenseCount, summary.expenseCount != 1 ? "s" : ""),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // List of fixed expenses
          if (summary.expenses.isEmpty)
            _buildEmptyState()
          else
            ...summary.expenses.map((expense) {
              return _buildExpenseCard(expense, currencyFormat, dateFormat);
            }),
        ],
      ),
    );
  }

  Widget _buildExpenseCard(
    RecurringTransactionTemplate expense,
    NumberFormat currencyFormat,
    DateFormat dateFormat,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange.withOpacity(0.15),
          child: const Icon(Icons.lock, color: Colors.orange, size: 20),
        ),
        title: Text(
          expense.description,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: expense.nextDueDate != null
            ? Text('Next: ${dateFormat.format(expense.nextDueDate!)}')
            : Text(expense.recurrenceDescription),
        trailing: Text(
          currencyFormat.format(expense.amount),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.red[700],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.lock_open_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              l10n.noFixedExpenses,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.markRecurringAsFixed,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}
