import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/installment_group.dart';
import '../providers/installment_group_provider.dart';
import '../providers/installment_group_state.dart';

/// Page listing all installment groups for a budget.
class InstallmentGroupsPage extends ConsumerStatefulWidget {
  final String budgetId;

  const InstallmentGroupsPage({super.key, required this.budgetId});

  @override
  ConsumerState<InstallmentGroupsPage> createState() =>
      _InstallmentGroupsPageState();
}

class _InstallmentGroupsPageState
    extends ConsumerState<InstallmentGroupsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(installmentGroupProvider.notifier)
          .loadGroups(widget.budgetId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(installmentGroupProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.installments),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref
                .read(installmentGroupProvider.notifier)
                .loadGroups(widget.budgetId),
          ),
        ],
      ),
      body: _buildBody(state),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            context.push('/budgets/${widget.budgetId}/installments/create'),
        icon: const Icon(Icons.add),
        label: Text(l10n.newInstallment),
      ),
    );
  }

  Widget _buildBody(InstallmentGroupState state) {
    final l10n = AppLocalizations.of(context)!;
    if (state is InstallmentGroupLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is InstallmentGroupError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.message),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref
                  .read(installmentGroupProvider.notifier)
                  .loadGroups(widget.budgetId),
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    if (state is InstallmentGroupsLoaded) {
      if (state.groups.isEmpty) {
        return _buildEmptyState();
      }
      return _buildGroupList(state.groups);
    }

    return Center(child: Text(l10n.loadingInstallments));
  }

  Widget _buildGroupList(List<InstallmentGroup> groups) {
    return RefreshIndicator(
      onRefresh: () => ref
          .read(installmentGroupProvider.notifier)
          .loadGroups(widget.budgetId),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final group = groups[index];
          return _buildGroupCard(group);
        },
      ),
    );
  }

  Widget _buildGroupCard(InstallmentGroup group) {
    final l10n = AppLocalizations.of(context)!;
    final currencyFormat =
        NumberFormat.currency(symbol: 'R\$ ', decimalDigits: 2);

    // Approximate progress: installments that have passed based on start date
    final now = DateTime.now();
    final monthsSinceStart =
        (now.year - group.startDate.year) * 12 +
            (now.month - group.startDate.month);
    final paidEstimate =
        monthsSinceStart.clamp(0, group.installmentCount);
    final progress = group.installmentCount > 0
        ? paidEstimate / group.installmentCount
        : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/installments/${group.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      group.description ?? l10n.installments,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (group.hasCard)
                    Icon(Icons.credit_card,
                        size: 18, color: Colors.grey[600]),
                ],
              ),
              const SizedBox(height: 8),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 8),

              // Details row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$paidEstimate/${group.installmentCount} ${l10n.installments.toLowerCase()}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    l10n.perMonth(currencyFormat.format(group.installmentAmount)),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (group.hasInterest)
                    Text(
                      l10n.interestLabel(group.interestRate.toString()),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange[700],
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  Text(
                    '${l10n.total}: ${currencyFormat.format(group.totalWithInterest)}',
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
            l10n.noInstallmentsYet,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.createFirstInstallmentDescription,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context
                .push('/budgets/${widget.budgetId}/installments/create'),
            icon: const Icon(Icons.add),
            label: Text(l10n.createInstallment),
          ),
        ],
      ),
    );
  }
}
