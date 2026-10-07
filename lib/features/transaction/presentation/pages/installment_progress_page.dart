import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/installment_progress.dart';
import '../../domain/entities/transaction.dart';
import '../providers/installment_group_provider.dart';
import '../providers/installment_group_state.dart';
import '../widgets/installment_progress_indicator.dart';

/// Page displaying the progress of a specific installment group.
class InstallmentProgressPage extends ConsumerStatefulWidget {
  final String groupId;

  const InstallmentProgressPage({super.key, required this.groupId});

  @override
  ConsumerState<InstallmentProgressPage> createState() =>
      _InstallmentProgressPageState();
}

class _InstallmentProgressPageState
    extends ConsumerState<InstallmentProgressPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(installmentGroupProvider.notifier)
          .loadProgress(widget.groupId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(installmentGroupProvider);

    ref.listen<InstallmentGroupState>(installmentGroupProvider,
        (previous, next) {
      if (next is InstallmentGroupDeleted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.installmentGroupDeleted),
            backgroundColor: Colors.green,
          ),
        );
      } else if (next is InstallmentGroupError) {
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
        title: Text(l10n.installmentProgress),
        actions: [
          if (state is InstallmentProgressLoaded)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              tooltip: l10n.deleteInstallmentGroup,
              onPressed: () =>
                  _confirmDelete(context, state.progress),
            ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(InstallmentGroupState state) {
    final l10n = AppLocalizations.of(context)!;
    if (state is InstallmentGroupLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is InstallmentGroupError) {
      return _buildErrorState(state.message);
    }

    if (state is InstallmentProgressLoaded) {
      return _buildProgressContent(state.progress);
    }

    return Center(child: Text(l10n.loadingInstallmentProgress));
  }

  Widget _buildProgressContent(InstallmentProgress progress) {
    final l10n = AppLocalizations.of(context)!;
    final currencyFormat =
        NumberFormat.currency(symbol: 'R\$ ', decimalDigits: 2);
    final dateFormat = DateFormat('MMM dd, yyyy');
    final group = progress.group;

    return RefreshIndicator(
      onRefresh: () => ref
          .read(installmentGroupProvider.notifier)
          .loadProgress(widget.groupId),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Card
          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    group.description ?? l10n.installments,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${l10n.total}: ${currencyFormat.format(group.totalWithInterest)}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 20),
                  InstallmentProgressIndicator(
                    paidCount: progress.paidCount,
                    totalCount: group.installmentCount,
                    size: 100,
                    strokeWidth: 8,
                  ),
                  const SizedBox(height: 20),
                  // Amounts row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildAmountColumn(
                        l10n.paid,
                        currencyFormat.format(progress.paidAmount),
                        Colors.green,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey[300],
                      ),
                      _buildAmountColumn(
                        l10n.remaining,
                        currencyFormat.format(progress.remainingAmount),
                        Colors.orange,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Transactions header
          Row(
            children: [
              Text(
                l10n.installments,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${progress.paidCount}/${group.installmentCount}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Transaction list
          ...progress.transactions
              .map((t) => _buildTransactionTile(t, currencyFormat, dateFormat)),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildAmountColumn(String label, String amount, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionTile(
    Transaction transaction,
    NumberFormat currencyFormat,
    DateFormat dateFormat,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final isPaid = transaction.transactionDate.isBefore(now) ||
        transaction.transactionDate.isAtSameMomentAs(now);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              isPaid ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
          child: Icon(
            isPaid ? Icons.check_circle : Icons.schedule,
            color: isPaid ? Colors.green : Colors.grey,
          ),
        ),
        title: Text(
          l10n.installmentN(transaction.installmentNumber?.toString() ?? "-"),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          dateFormat.format(transaction.transactionDate),
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 13,
          ),
        ),
        trailing: Text(
          currencyFormat.format(transaction.amount),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isPaid ? Colors.green[700] : Colors.grey[700],
          ),
        ),
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
                .read(installmentGroupProvider.notifier)
                .loadProgress(widget.groupId),
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, InstallmentProgress progress) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteInstallmentGroup),
        content: Text(
          l10n.deleteInstallmentGroupConfirm(
            progress.group.description ?? l10n.installments,
            progress.group.installmentCount,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(installmentGroupProvider.notifier)
                  .deleteGroup(widget.groupId,
                      budgetId: progress.group.budgetId);
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
}
