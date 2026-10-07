import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/account.dart';
import '../providers/account_provider.dart';
import '../providers/account_state.dart';

class AccountDetailsPage extends ConsumerStatefulWidget {
  final String budgetId;
  final String accountId;

  const AccountDetailsPage({
    super.key,
    required this.budgetId,
    required this.accountId,
  });

  @override
  ConsumerState<AccountDetailsPage> createState() => _AccountDetailsPageState();
}

class _AccountDetailsPageState extends ConsumerState<AccountDetailsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(accountProvider.notifier).loadAccounts(widget.budgetId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accountState = ref.watch(accountProvider);
    final notifier = ref.read(accountProvider.notifier);
    final accounts = accountState is AccountsLoaded
        ? accountState.accounts
        : notifier.accounts;

    final account = accounts.where((a) => a.id == widget.accountId).firstOrNull;

    if (account == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.accountDetails),
        ),
        body: Center(
          child: Text(l10n.accountNotFound),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(account.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit account page
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.featureComingSoon(l10n.editAccount))),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'activate') {
                _toggleAccountStatus(account);
              } else if (value == 'delete') {
                _confirmDelete(context, account);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'activate',
                child: Row(
                  children: [
                    Icon(
                      account.isActive ? Icons.block : Icons.check_circle,
                      color: account.isActive ? Colors.orange : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Text(account.isActive ? l10n.deactivate : l10n.activate),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(l10n.deleteAccount),
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
            _buildBalanceCard(account),
            const SizedBox(height: 16),
            _buildInfoCard(account),
            const SizedBox(height: 16),
            _buildQuickActionsCard(context, account),
            const SizedBox(height: 16),
            _buildRecentTransactionsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(Account account) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      color: Theme.of(context).primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  account.type.icon,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        account.type.displayName,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!account.isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      l10n.inactive.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              l10n.currentBalance,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              account.formattedBalance,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: account.hasGained
                    ? Colors.green.withOpacity(0.2)
                    : account.hasLost
                        ? Colors.red.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    account.hasGained
                        ? Icons.trending_up
                        : account.hasLost
                            ? Icons.trending_down
                            : Icons.trending_flat,
                    color: account.hasGained
                        ? Colors.green
                        : account.hasLost
                            ? Colors.red
                            : Colors.grey,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    account.formattedBalanceChange,
                    style: TextStyle(
                      color: account.hasGained
                          ? Colors.green
                          : account.hasLost
                              ? Colors.red
                              : Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    l10n.fromOpening,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(Account account) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.accountInformation,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(height: 24),
            _buildInfoRow(l10n.accountType, account.type.displayName),
            const SizedBox(height: 12),
            _buildInfoRow(l10n.currency, account.currency),
            const SizedBox(height: 12),
            _buildInfoRow(l10n.openingBalance, account.formattedOpeningBalance),
            const SizedBox(height: 12),
            _buildInfoRow(l10n.currentBalance, account.formattedBalance),
            const SizedBox(height: 12),
            _buildInfoRow(l10n.balanceChange, account.formattedBalanceChange),
            const SizedBox(height: 12),
            _buildInfoRow(l10n.status, account.isActive ? l10n.active : l10n.inactive),
            const SizedBox(height: 12),
            _buildInfoRow(l10n.created, dateFormat.format(account.createdAt)),
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
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsCard(BuildContext context, Account account) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.quickActions,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _buildActionTile(
              context,
              icon: Icons.add_circle,
              title: l10n.addTransaction,
              subtitle: l10n.recordNewTransaction,
              color: Colors.green,
              onTap: () {
                context.go('/budgets/${widget.budgetId}/transactions/create');
              },
            ),
            _buildActionTile(
              context,
              icon: Icons.swap_horiz,
              title: l10n.transfer,
              subtitle: l10n.transferToAnotherAccount,
              color: Colors.blue,
              onTap: () {
                context.go('/budgets/${widget.budgetId}/accounts/transfer');
              },
            ),
            _buildActionTile(
              context,
              icon: Icons.history,
              title: l10n.transactionHistory,
              subtitle: l10n.viewAllTransactions,
              color: Colors.purple,
              onTap: () {
                context.go('/budgets/${widget.budgetId}/transactions?accountId=${widget.accountId}');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildRecentTransactionsCard() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.recentTransactions,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: () {
                    context.go('/budgets/${widget.budgetId}/transactions');
                  },
                  child: Text(l10n.viewAll),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: Column(
                children: [
                  Icon(Icons.receipt_long, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    l10n.noRecentTransactions,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleAccountStatus(Account account) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref.read(accountProvider.notifier).toggleAccountStatus(
        budgetId: widget.budgetId,
        id: account.id,
        active: !account.isActive,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(account.isActive ? l10n.accountDeactivated : l10n.accountActivated),
            backgroundColor: account.isActive ? Colors.orange : Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorWithMessage(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _confirmDelete(BuildContext context, Account account) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAccount),
        content: Text(
          '${l10n.deleteConfirmWithName(account.name)} ${l10n.actionCannotBeUndone}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(accountProvider.notifier).deleteAccount(budgetId: widget.budgetId, id: account.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.accountDeletedSuccessfully),
                      backgroundColor: Colors.green,
                    ),
                  );
                  context.go('/budgets/${widget.budgetId}/accounts');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.errorWithMessage(e.toString())),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
