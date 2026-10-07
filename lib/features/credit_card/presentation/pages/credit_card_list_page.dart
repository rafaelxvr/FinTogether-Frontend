import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/credit_card.dart';
import '../providers/credit_card_provider.dart';
import '../providers/credit_card_state.dart';
import '../widgets/credit_card_widget.dart';
import 'create_credit_card_page.dart';
import 'invoice_detail_page.dart';

class CreditCardListPage extends ConsumerStatefulWidget {
  final String budgetId;

  const CreditCardListPage({
    super.key,
    required this.budgetId,
  });

  @override
  ConsumerState<CreditCardListPage> createState() =>
      _CreditCardListPageState();
}

class _CreditCardListPageState extends ConsumerState<CreditCardListPage> {
  bool _showInactive = true;

  @override
  void initState() {
    super.initState();
    // Load credit cards when page opens
    Future.microtask(
      () => ref
          .read(creditCardProvider.notifier)
          .loadCreditCards(widget.budgetId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(creditCardProvider);
    final notifier = ref.read(creditCardProvider.notifier);

    // Listen for success/error messages
    ref.listen<CreditCardState>(creditCardProvider, (previous, next) {
      if (next is CreditCardOperationSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: Colors.green,
          ),
        );
        // Clear success state
        Future.delayed(const Duration(milliseconds: 500), () {
          notifier.clearSuccess();
        });
      } else if (next is CreditCardError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.creditCards),
        actions: [
          IconButton(
            icon: Icon(_showInactive
                ? Icons.visibility
                : Icons.visibility_off),
            onPressed: () {
              setState(() {
                _showInactive = !_showInactive;
              });
            },
            tooltip: _showInactive ? l10n.hideInactive : l10n.showInactive,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => notifier.loadCreditCards(widget.budgetId),
          ),
        ],
      ),
      body: _buildBody(state, notifier),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateCreditCardDialog(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.addCard),
      ),
    );
  }

  Widget _buildBody(CreditCardState state, CreditCardNotifier notifier) {
    if (state is CreditCardLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is CreditCardError) {
      return _buildErrorState(state.message);
    }

    List<CreditCard> creditCards = [];
    if (state is CreditCardLoaded) {
      creditCards = state.creditCards;
    } else if (state is CreditCardOperationSuccess) {
      creditCards = state.creditCards;
    }

    if (creditCards.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () => notifier.loadCreditCards(widget.budgetId),
      child: _buildCreditCardList(creditCards, notifier),
    );
  }

  Widget _buildCreditCardList(
      List<CreditCard> creditCards, CreditCardNotifier notifier) {
    final l10n = AppLocalizations.of(context)!;
    // Separate active and inactive credit cards
    final activeCards = creditCards.where((c) => c.active).toList();
    final inactiveCards = creditCards.where((c) => !c.active).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary Card
        _buildSummaryCard(activeCards.length, creditCards.length),
        const SizedBox(height: 24),

        // Active Credit Cards
        if (activeCards.isNotEmpty) ...[
          _buildSectionHeader(l10n.activeCards, activeCards.length),
          const SizedBox(height: 12),
          ...activeCards.map((card) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CreditCardWidget(
                  creditCard: card,
                  onTap: () => _showCreditCardDetails(context, card),
                  onEdit: () => _showEditCreditCardDialog(context, card),
                  onDelete: () => _confirmDelete(context, card, notifier),
                  onToggleStatus: () =>
                      _toggleStatus(context, card, notifier),
                  onViewInvoice: () => _navigateToInvoice(context, card),
                ),
              )),
        ],

        // Inactive Credit Cards
        if (_showInactive && inactiveCards.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildSectionHeader(l10n.inactiveCards, inactiveCards.length),
          const SizedBox(height: 12),
          ...inactiveCards.map((card) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CreditCardWidget(
                  creditCard: card,
                  onTap: () => _showCreditCardDetails(context, card),
                  onEdit: () => _showEditCreditCardDialog(context, card),
                  onDelete: () => _confirmDelete(context, card, notifier),
                  onToggleStatus: () =>
                      _toggleStatus(context, card, notifier),
                  onViewInvoice: () => _navigateToInvoice(context, card),
                ),
              )),
        ],
        const SizedBox(height: 80), // Space for FAB
      ],
    );
  }

  Widget _buildSummaryCard(int activeCount, int totalCount) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSummaryItem(
              icon: Icons.credit_card,
              label: l10n.activeCards,
              value: activeCount.toString(),
              valueColor: Theme.of(context).primaryColor,
            ),
            Container(
              height: 40,
              width: 1,
              color: Colors.grey[300],
            ),
            _buildSummaryItem(
              icon: Icons.credit_score,
              label: l10n.totalCards,
              value: totalCount.toString(),
              valueColor: Colors.grey[700]!,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.grey[600]),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
        Text(
          title,
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
            count.toString(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.credit_card_outlined,
            size: 120,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 24),
          Text(
            l10n.noCreditCardsYet,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.addFirstCreditCardDescription,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _showCreateCreditCardDialog(context),
            icon: const Icon(Icons.add),
            label: Text(l10n.addCreditCard),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
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
                .read(creditCardProvider.notifier)
                .loadCreditCards(widget.budgetId),
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  void _showCreateCreditCardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CreateCreditCardPage(budgetId: widget.budgetId),
    );
  }

  void _showEditCreditCardDialog(BuildContext context, CreditCard card) {
    showDialog(
      context: context,
      builder: (context) => CreateCreditCardPage(
        budgetId: widget.budgetId,
        creditCard: card,
      ),
    );
  }

  void _showCreditCardDetails(BuildContext context, CreditCard card) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(card.displayName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(l10n.issuer, card.issuer ?? 'N/A'),
            _buildDetailRow(l10n.lastFour, card.lastFour ?? 'N/A'),
            _buildDetailRow(l10n.currency, card.currency),
            _buildDetailRow(
                l10n.statementClose, l10n.dayN(card.statementCloseDay)),
            _buildDetailRow(l10n.dueDate, l10n.dayN(card.dueDay)),
            _buildDetailRow(l10n.status, card.statusText),
            if (card.hasLinkedAccount)
              _buildDetailRow(l10n.linkedAccount,
                  card.linkedAccountName ?? 'Unknown'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    CreditCard card,
    CreditCardNotifier notifier,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteCreditCard),
        content: Text(
          '${l10n.deleteConfirmWithName(card.displayName)}\n${l10n.actionCannotBeUndone}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              notifier.deleteCreditCard(card.id, widget.budgetId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  void _toggleStatus(
    BuildContext context,
    CreditCard card,
    CreditCardNotifier notifier,
  ) {
    notifier.toggleStatus(card.id, !card.active, widget.budgetId);
  }

  void _navigateToInvoice(BuildContext context, CreditCard card) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InvoiceDetailPage(cardId: card.id),
      ),
    );
  }
}
