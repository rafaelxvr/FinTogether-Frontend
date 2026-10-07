import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/account.dart';
import '../providers/account_provider.dart';
import '../providers/account_state.dart';
import '../widgets/account_card.dart';
import 'create_account_page.dart';
import 'transfer_page.dart';

class AccountListPage extends ConsumerStatefulWidget {
  final String budgetId;

  const AccountListPage({
    super.key,
    required this.budgetId,
  });

  @override
  ConsumerState<AccountListPage> createState() => _AccountListPageState();
}

class _AccountListPageState extends ConsumerState<AccountListPage> {
  @override
  void initState() {
    super.initState();
    // Load accounts when page opens
    Future.microtask(
      () => ref.read(accountProvider.notifier).loadAccounts(widget.budgetId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(accountProvider);
    final notifier = ref.read(accountProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.accounts),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: () => _showTransferDialog(context),
            tooltip: l10n.transfer,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => notifier.loadAccounts(widget.budgetId),
          ),
        ],
      ),
      body: _buildBody(state, notifier),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateAccountDialog(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.addAccount),
      ),
    );
  }

  Widget _buildBody(AccountState state, AccountNotifier notifier) {
    if (state is AccountLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is AccountError) {
      return _buildErrorState(state.message);
    }

    final accounts = notifier.accounts;

    if (accounts.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () => notifier.loadAccounts(widget.budgetId),
      child: _buildAccountList(accounts, notifier),
    );
  }

  Widget _buildAccountList(List<Account> accounts, AccountNotifier notifier) {
    final l10n = AppLocalizations.of(context)!;
    // Separate active and inactive accounts
    final activeAccounts = accounts.where((a) => a.active).toList();
    final inactiveAccounts = accounts.where((a) => !a.active).toList();

    // Calculate totals
    final totalBalance = activeAccounts.fold<double>(
      0,
      (sum, account) => sum + account.currentBalance,
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary Card
        _buildSummaryCard(activeAccounts.length, totalBalance),
        const SizedBox(height: 24),

        // Active Accounts
        if (activeAccounts.isNotEmpty) ...[
          _buildSectionHeader(l10n.activeAccounts, activeAccounts.length),
          const SizedBox(height: 12),
          ...activeAccounts.map((account) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AccountCard(
                  account: account,
                  onTap: () => _showAccountDetails(context, account),
                  onEdit: () => _showEditAccountDialog(context, account),
                  onDelete: () => _confirmDelete(context, account, notifier),
                  onToggleStatus: () => _toggleStatus(context, account, notifier),
                ),
              )),
        ],

        // Inactive Accounts
        if (inactiveAccounts.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildSectionHeader(l10n.inactiveAccounts, inactiveAccounts.length),
          const SizedBox(height: 12),
          ...inactiveAccounts.map((account) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AccountCard(
                  account: account,
                  onTap: () => _showAccountDetails(context, account),
                  onEdit: () => _showEditAccountDialog(context, account),
                  onDelete: () => _confirmDelete(context, account, notifier),
                  onToggleStatus: () => _toggleStatus(context, account, notifier),
                ),
              )),
        ],
        const SizedBox(height: 80), // Space for FAB
      ],
    );
  }

  Widget _buildSummaryCard(int accountCount, double totalBalance) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSummaryItem(
              icon: Icons.account_balance_wallet,
              label: l10n.totalBalance,
              value: 'BRL ${totalBalance.toStringAsFixed(2)}',
              valueColor: totalBalance >= 0 ? Colors.green : Colors.red,
            ),
            Container(
              height: 40,
              width: 1,
              color: Colors.grey[300],
            ),
            _buildSummaryItem(
              icon: Icons.account_balance,
              label: l10n.activeAccounts,
              value: accountCount.toString(),
              valueColor: Theme.of(context).primaryColor,
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
            Icons.account_balance_wallet_outlined,
            size: 120,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 24),
          Text(
            l10n.noAccountsYet,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.createFirstAccountDescription,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _showCreateAccountDialog(context),
            icon: const Icon(Icons.add),
            label: Text(l10n.createAccount),
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
                ref.read(accountProvider.notifier).loadAccounts(widget.budgetId),
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  void _showCreateAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CreateAccountPage(budgetId: widget.budgetId),
    );
  }

  void _showEditAccountDialog(BuildContext context, Account account) {
    showDialog(
      context: context,
      builder: (context) => CreateAccountPage(
        budgetId: widget.budgetId,
        account: account,
      ),
    );
  }

  void _showTransferDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(accountProvider.notifier);
    final activeAccounts = notifier.activeAccounts;

    if (activeAccounts.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.inactive2ActiveAccounts),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => TransferPage(
        budgetId: widget.budgetId,
      ),
    );
  }

  void _showAccountDetails(BuildContext context, Account account) {
    context.go('/budgets/${widget.budgetId}/accounts/${account.id}/details');
  }

  void _confirmDelete(
    BuildContext context,
    Account account,
    AccountNotifier notifier,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAccount),
        content: Text(
          '${l10n.deleteConfirmWithName(account.name)}\n${l10n.actionCannotBeUndone}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              notifier.deleteAccount(
                budgetId: widget.budgetId,
                id: account.id,
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

  void _toggleStatus(
    BuildContext context,
    Account account,
    AccountNotifier notifier,
  ) {
    notifier.toggleAccountStatus(
      budgetId: widget.budgetId,
      id: account.id,
      active: !account.active,
    );
  }
}
