import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/credit_card_invoice.dart';
import '../providers/credit_card_invoice_provider.dart';
import '../providers/credit_card_invoice_state.dart';
import '../widgets/invoice_status_badge.dart';
import 'invoice_detail_page.dart';

/// Page showing the history of invoices for a credit card.
class InvoiceListPage extends ConsumerStatefulWidget {
  final String cardId;
  final String? cardName;

  const InvoiceListPage({
    super.key,
    required this.cardId,
    this.cardName,
  });

  @override
  ConsumerState<InvoiceListPage> createState() => _InvoiceListPageState();
}

class _InvoiceListPageState extends ConsumerState<InvoiceListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(creditCardInvoiceProvider.notifier)
          .loadSummaries(widget.cardId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(creditCardInvoiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.cardName ?? l10n.creditCards),
            Text(
              l10n.invoiceHistory,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref
                .read(creditCardInvoiceProvider.notifier)
                .loadSummaries(widget.cardId),
          ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(CreditCardInvoiceState state) {
    if (state is InvoiceLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is InvoiceError) {
      return _buildErrorState(state.message);
    }

    if (state is InvoiceSummariesLoaded) {
      if (state.summaries.isEmpty) {
        return _buildEmptyState();
      }
      return _buildSummaryList(state.summaries);
    }

    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildSummaryList(List<InvoiceSummary> summaries) {
    final currencyFormat = NumberFormat.currency(symbol: 'BRL ', decimalDigits: 2);

    return RefreshIndicator(
      onRefresh: () => ref
          .read(creditCardInvoiceProvider.notifier)
          .loadSummaries(widget.cardId),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: summaries.length,
        itemBuilder: (context, index) {
          final summary = summaries[index];
          return _buildSummaryCard(summary, currencyFormat);
        },
      ),
    );
  }

  Widget _buildSummaryCard(InvoiceSummary summary, NumberFormat currencyFormat) {
    final l10n = AppLocalizations.of(context)!;
    final monthDisplay = _formatReferenceMonth(summary.referenceMonth);
    final dateFormat = DateFormat('MMM dd');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToInvoiceDetail(summary.referenceMonth),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: month and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    monthDisplay,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  InvoiceStatusBadge(status: summary.status),
                ],
              ),
              const SizedBox(height: 12),

              // Amount
              Text(
                currencyFormat.format(summary.totalAmount),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Period and transaction count
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.date_range, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${dateFormat.format(summary.periodStart)} - ${dateFormat.format(summary.periodEnd)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.receipt, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        l10n.nTransactionsSuffix(summary.transactionCount, summary.transactionCount != 1 ? 's' : ''),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Due date
              Row(
                children: [
                  Icon(Icons.event, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    l10n.due(DateFormat('MMM dd, yyyy').format(summary.dueDate)),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatReferenceMonth(String referenceMonth) {
    try {
      final parts = referenceMonth.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final date = DateTime(year, month);
      return DateFormat('MMMM yyyy').format(date);
    } catch (_) {
      return referenceMonth;
    }
  }

  void _navigateToInvoiceDetail(String month) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InvoiceDetailPage(
          cardId: widget.cardId,
          month: month,
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
            l10n.noInvoicesYet,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.invoiceHistoryDescription,
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
                .loadSummaries(widget.cardId),
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }
}
