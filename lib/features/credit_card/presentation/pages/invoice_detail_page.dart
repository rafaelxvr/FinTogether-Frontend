import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/credit_card_invoice.dart';
import '../providers/credit_card_invoice_provider.dart';
import '../providers/credit_card_invoice_state.dart';
import '../widgets/invoice_summary_card.dart';

/// Page displaying a credit card's monthly invoice detail.
/// Shows summary, credit utilization, and transactions grouped by date.
class InvoiceDetailPage extends ConsumerStatefulWidget {
  final String cardId;
  final String? month;

  const InvoiceDetailPage({
    super.key,
    required this.cardId,
    this.month,
  });

  @override
  ConsumerState<InvoiceDetailPage> createState() => _InvoiceDetailPageState();
}

class _InvoiceDetailPageState extends ConsumerState<InvoiceDetailPage> {
  late String _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = widget.month ?? _formatCurrentMonth();
    Future.microtask(
      () => ref
          .read(creditCardInvoiceProvider.notifier)
          .loadInvoice(widget.cardId, _currentMonth),
    );
  }

  String _formatCurrentMonth() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  String _formatMonthDisplay(String month) {
    try {
      final parts = month.split('-');
      final year = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final date = DateTime(year, m);
      return DateFormat('MMMM yyyy').format(date);
    } catch (_) {
      return month;
    }
  }

  String _previousMonth(String month) {
    final parts = month.split('-');
    var year = int.parse(parts[0]);
    var m = int.parse(parts[1]);
    m -= 1;
    if (m < 1) {
      m = 12;
      year -= 1;
    }
    return '$year-${m.toString().padLeft(2, '0')}';
  }

  String _nextMonth(String month) {
    final parts = month.split('-');
    var year = int.parse(parts[0]);
    var m = int.parse(parts[1]);
    m += 1;
    if (m > 12) {
      m = 1;
      year += 1;
    }
    return '$year-${m.toString().padLeft(2, '0')}';
  }

  void _navigateToPreviousMonth() {
    setState(() {
      _currentMonth = _previousMonth(_currentMonth);
    });
    ref
        .read(creditCardInvoiceProvider.notifier)
        .navigateToMonth(widget.cardId, _currentMonth);
  }

  void _navigateToNextMonth() {
    setState(() {
      _currentMonth = _nextMonth(_currentMonth);
    });
    ref
        .read(creditCardInvoiceProvider.notifier)
        .navigateToMonth(widget.cardId, _currentMonth);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(creditCardInvoiceProvider);

    String appBarTitle = l10n.invoiceDetail;
    if (state is InvoiceLoaded) {
      appBarTitle = state.invoice.cardName;
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(appBarTitle),
            Text(
              _formatMonthDisplay(_currentMonth),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            tooltip: l10n.invoiceHistory,
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/credit-cards/${widget.cardId}/invoices',
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Month navigation
          _buildMonthNavigation(),
          // Body content
          Expanded(child: _buildBody(state)),
        ],
      ),
    );
  }

  Widget _buildMonthNavigation() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _navigateToPreviousMonth,
            tooltip: l10n.previousMonth,
          ),
          Text(
            _formatMonthDisplay(_currentMonth),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _navigateToNextMonth,
            tooltip: l10n.nextMonth,
          ),
        ],
      ),
    );
  }

  Widget _buildBody(CreditCardInvoiceState state) {
    final l10n = AppLocalizations.of(context)!;
    if (state is InvoiceLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is InvoiceError) {
      return _buildErrorState(state.message);
    }

    if (state is InvoiceLoaded) {
      return _buildInvoiceContent(state.invoice);
    }

    return Center(child: Text(l10n.selectMonthToView));
  }

  Widget _buildInvoiceContent(CreditCardInvoice invoice) {
    final l10n = AppLocalizations.of(context)!;
    final currencyFormat = NumberFormat.currency(symbol: 'BRL ', decimalDigits: 2);

    if (invoice.transactions.isEmpty) {
      return _buildEmptyState();
    }

    // Group transactions by date
    final groupedTransactions = _groupTransactionsByDate(invoice.transactions);
    final dateFormat = DateFormat('EEEE, MMM dd, yyyy');

    return RefreshIndicator(
      onRefresh: () => ref
          .read(creditCardInvoiceProvider.notifier)
          .loadInvoice(widget.cardId, _currentMonth),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary Card
          InvoiceSummaryCard(
            totalAmount: invoice.totalAmount,
            dueDate: invoice.dueDate,
            periodStart: invoice.periodStart,
            periodEnd: invoice.periodEnd,
            status: invoice.status,
            creditLimit: invoice.creditLimit,
            availableCredit: invoice.availableCredit,
          ),
          const SizedBox(height: 24),

          // Transactions header
          Row(
            children: [
              Text(
                l10n.transactions,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  invoice.transactionCount.toString(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Grouped transaction list
          ...groupedTransactions.entries.expand((entry) => [
                // Date header
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 4),
                  child: Text(
                    dateFormat.format(entry.key),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                // Transactions for this date
                ...entry.value.map(
                  (transaction) => _buildTransactionTile(transaction, currencyFormat),
                ),
              ]),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Map<DateTime, List<InvoiceTransaction>> _groupTransactionsByDate(
    List<InvoiceTransaction> transactions,
  ) {
    final grouped = <DateTime, List<InvoiceTransaction>>{};
    for (final transaction in transactions) {
      final dateKey = DateTime(
        transaction.transactionDate.year,
        transaction.transactionDate.month,
        transaction.transactionDate.day,
      );
      grouped.putIfAbsent(dateKey, () => []).add(transaction);
    }
    // Sort by date descending
    final sortedEntries = grouped.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));
    return Map.fromEntries(sortedEntries);
  }

  Widget _buildTransactionTile(
    InvoiceTransaction transaction,
    NumberFormat currencyFormat,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        title: Text(
          transaction.description ?? 'Transaction',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Row(
          children: [
            if (transaction.categoryName != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  transaction.categoryName!,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.blue[800],
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            if (transaction.installmentInfo != null)
              Text(
                transaction.installmentInfo!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
        trailing: Text(
          currencyFormat.format(transaction.amount),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 24),
          Text(
            l10n.noTransactions,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.noTransactionsForPeriod,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            l10n.error,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => ref
                .read(creditCardInvoiceProvider.notifier)
                .loadInvoice(widget.cardId, _currentMonth),
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }
}
