import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/merchant.dart';
import '../providers/merchant_provider.dart';
import '../providers/merchant_state.dart';
import '../widgets/merchant_card.dart';
import 'create_merchant_page.dart';

class MerchantListPage extends ConsumerStatefulWidget {
  final String budgetId;

  const MerchantListPage({
    super.key,
    required this.budgetId,
  });

  @override
  ConsumerState<MerchantListPage> createState() => _MerchantListPageState();
}

class _MerchantListPageState extends ConsumerState<MerchantListPage> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(merchantProvider.notifier).loadMerchants(
            budgetId: widget.budgetId,
          ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(merchantProvider);
    final notifier = ref.read(merchantProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.searchMerchants,
                  border: InputBorder.none,
                ),
                onChanged: (query) {
                  if (query.isNotEmpty) {
                    notifier.searchMerchants(
                      budgetId: widget.budgetId,
                      query: query,
                    );
                  } else {
                    notifier.loadMerchants(budgetId: widget.budgetId);
                  }
                },
              )
            : Text(l10n.merchants),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  notifier.loadMerchants(budgetId: widget.budgetId);
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => notifier.loadMerchants(
              budgetId: widget.budgetId,
            ),
          ),
        ],
      ),
      body: _buildBody(state, notifier),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateMerchantDialog(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.addMerchant),
      ),
    );
  }

  Widget _buildBody(MerchantState state, MerchantNotifier notifier) {
    if (state is MerchantLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is MerchantError) {
      return _buildErrorState(state.message);
    }

    final activeMerchants = notifier.activeMerchants;
    final archivedMerchants = notifier.archivedMerchants;

    if (activeMerchants.isEmpty && archivedMerchants.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () => notifier.loadMerchants(budgetId: widget.budgetId),
      child: _buildMerchantList(activeMerchants, archivedMerchants, notifier),
    );
  }

  Widget _buildMerchantList(
    List<Merchant> activeMerchants,
    List<Merchant> archivedMerchants,
    MerchantNotifier notifier,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary Card
        _buildSummaryCard(activeMerchants.length, archivedMerchants.length),
        const SizedBox(height: 24),

        // Active Merchants
        if (activeMerchants.isNotEmpty) ...[
          _buildSectionHeader(l10n.activeMerchants, activeMerchants.length),
          const SizedBox(height: 12),
          ...activeMerchants.map((merchant) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: MerchantCard(
                  merchant: merchant,
                  onTap: () => _showMerchantDetails(context, merchant),
                  onEdit: () => _showEditMerchantDialog(context, merchant),
                  onDelete: () =>
                      _confirmDelete(context, merchant, notifier),
                  onArchive: () =>
                      _archiveMerchant(context, merchant, notifier),
                ),
              )),
        ],

        // Archived Merchants
        if (archivedMerchants.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildSectionHeader(
              l10n.archivedMerchants, archivedMerchants.length),
          const SizedBox(height: 12),
          ...archivedMerchants.map((merchant) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: MerchantCard(
                  merchant: merchant,
                  onTap: () => _showMerchantDetails(context, merchant),
                  onEdit: () => _showEditMerchantDialog(context, merchant),
                  onDelete: () =>
                      _confirmDelete(context, merchant, notifier),
                  onUnarchive: () =>
                      _unarchiveMerchant(context, merchant, notifier),
                ),
              )),
        ],
        const SizedBox(height: 80), // Space for FAB
      ],
    );
  }

  Widget _buildSummaryCard(int activeCount, int archivedCount) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSummaryItem(
              icon: Icons.store,
              label: l10n.active,
              value: activeCount.toString(),
              valueColor: Theme.of(context).primaryColor,
            ),
            Container(
              height: 40,
              width: 1,
              color: Colors.grey[300],
            ),
            _buildSummaryItem(
              icon: Icons.archive,
              label: l10n.archived,
              value: archivedCount.toString(),
              valueColor: Colors.orange,
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
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
          Icon(Icons.store, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 24),
          Text(
            l10n.noMerchantsYet,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.addMerchantsDescription,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _showCreateMerchantDialog(context),
            icon: const Icon(Icons.add),
            label: Text(l10n.addMerchant),
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
            onPressed: () =>
                ref.read(merchantProvider.notifier).loadMerchants(
                      budgetId: widget.budgetId,
                    ),
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  void _showCreateMerchantDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CreateMerchantPage(
        budgetId: widget.budgetId,
      ),
    );
  }

  void _showEditMerchantDialog(BuildContext context, Merchant merchant) {
    showDialog(
      context: context,
      builder: (context) => CreateMerchantPage(
        budgetId: widget.budgetId,
        merchant: merchant,
      ),
    );
  }

  void _showMerchantDetails(BuildContext context, Merchant merchant) {
    // Navigate to merchant details (could use go_router)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Merchant: ${merchant.effectiveDisplayName}')),
    );
  }

  void _confirmDelete(
    BuildContext context,
    Merchant merchant,
    MerchantNotifier notifier,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteMerchant),
        content: Text(
          '${l10n.deleteConfirmWithName(merchant.effectiveDisplayName)}\n\n${l10n.actionCannotBeUndone}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              notifier.deleteMerchant(
                budgetId: widget.budgetId,
                id: merchant.id,
              );
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

  void _archiveMerchant(
    BuildContext context,
    Merchant merchant,
    MerchantNotifier notifier,
  ) {
    notifier.archiveMerchant(
      budgetId: widget.budgetId,
      id: merchant.id,
    );
  }

  void _unarchiveMerchant(
    BuildContext context,
    Merchant merchant,
    MerchantNotifier notifier,
  ) {
    notifier.unarchiveMerchant(
      budgetId: widget.budgetId,
      id: merchant.id,
    );
  }
}
