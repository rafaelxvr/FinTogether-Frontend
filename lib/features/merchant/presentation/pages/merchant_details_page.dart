import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/merchant.dart';
import '../providers/merchant_provider.dart';
import '../providers/merchant_state.dart';

class MerchantDetailsPage extends ConsumerStatefulWidget {
  final String budgetId;
  final String merchantId;

  const MerchantDetailsPage({
    super.key,
    required this.budgetId,
    required this.merchantId,
  });

  @override
  ConsumerState<MerchantDetailsPage> createState() =>
      _MerchantDetailsPageState();
}

class _MerchantDetailsPageState extends ConsumerState<MerchantDetailsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(merchantProvider.notifier)
          .loadMerchants(budgetId: widget.budgetId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final merchantState = ref.watch(merchantProvider);
    final notifier = ref.read(merchantProvider.notifier);
    final merchants = merchantState is MerchantsLoaded
        ? merchantState.merchants
        : notifier.merchants;

    final merchant =
        merchants.where((m) => m.id == widget.merchantId).firstOrNull;

    if (merchant == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.merchantDetails)),
        body: Center(child: Text(l10n.merchantNotFound)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(merchant.effectiveDisplayName),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'archive') {
                _toggleArchiveStatus(merchant);
              } else if (value == 'delete') {
                _confirmDelete(context, merchant);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'archive',
                child: Row(
                  children: [
                    Icon(
                      merchant.isArchived ? Icons.unarchive : Icons.archive,
                      color:
                          merchant.isArchived ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Text(merchant.isArchived ? l10n.unarchive : l10n.archive),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(l10n.deleteMerchant),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(merchant),
            const SizedBox(height: 16),
            _buildInfoCard(merchant),
            const SizedBox(height: 16),
            _buildTransactionsSummaryCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(Merchant merchant) {
    final l10n = AppLocalizations.of(context)!;
    final color = merchant.color != null && merchant.color!.isNotEmpty
        ? _parseColor(merchant.color!)
        : Colors.teal;

    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            const Icon(Icons.store, size: 48, color: Colors.white),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    merchant.effectiveDisplayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (merchant.displayName != null &&
                      merchant.displayName != merchant.name) ...[
                    const SizedBox(height: 4),
                    Text(
                      merchant.name,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (merchant.isArchived)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  l10n.archived,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(Merchant merchant) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.merchantInformation,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(height: 24),
            _buildInfoRow(l10n.status, merchant.isActive ? l10n.active : l10n.archived),
            const SizedBox(height: 12),
            _buildInfoRow(l10n.defaultCategory,
                merchant.hasDefaultCategory ? l10n.set : l10n.notSet),
            const SizedBox(height: 12),
            _buildInfoRow(l10n.created, dateFormat.format(merchant.createdAt)),
            if (merchant.updatedAt != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(l10n.lastUpdated, dateFormat.format(merchant.updatedAt!)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsSummaryCard() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.transactionSummary,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: l10n.thisMonth,
                    value: 'BRL 0.00',
                    icon: Icons.calendar_today,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: l10n.total,
                    value: 'BRL 0.00',
                    icon: Icons.trending_up,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Color _parseColor(String colorString) {
    try {
      final hex = colorString.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return Colors.teal;
    }
  }

  void _toggleArchiveStatus(Merchant merchant) async {
    if (merchant.isArchived) {
      ref.read(merchantProvider.notifier).unarchiveMerchant(
            budgetId: widget.budgetId,
            id: merchant.id,
          );
    } else {
      ref.read(merchantProvider.notifier).archiveMerchant(
            budgetId: widget.budgetId,
            id: merchant.id,
          );
    }
  }

  void _confirmDelete(BuildContext context, Merchant merchant) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteMerchant),
        content: Text(
          '${l10n.deleteConfirmWithName(merchant.effectiveDisplayName)} ${l10n.actionCannotBeUndone}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(merchantProvider.notifier).deleteMerchant(
                    budgetId: widget.budgetId,
                    id: merchant.id,
                  );
              Navigator.pop(context); // Go back from details page
            },
            child:
                Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(title, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
