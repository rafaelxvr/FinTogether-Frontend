import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// "More" tab listing secondary features and settings.
class MorePage extends ConsumerWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.morePage),
      ),
      body: ListView(
        children: [
          _buildSectionHeader(context, l10n.manage),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet),
            title: Text(l10n.budgets),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/budgets'),
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: Text(l10n.categories),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/categories'),
          ),
          ListTile(
            leading: const Icon(Icons.pie_chart),
            title: Text(l10n.budgetPlan),
            subtitle: Text(l10n.allocateBudgetPerCategory),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Replace with actual budgetId from context/state
              context.push('/budgets/default/budget-plan');
            },
          ),
          ListTile(
            leading: const Icon(Icons.repeat),
            title: Text(l10n.recurringTemplates),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/recurring-templates'),
          ),
          const Divider(),
          _buildSectionHeader(context, l10n.app),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(l10n.settings),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/more/settings'),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.about),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showAboutDialog(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(
              l10n.logout,
              style: const TextStyle(color: Colors.red),
            ),
            onTap: () => _handleLogout(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showAboutDialog(
      context: context,
      applicationName: l10n.appTitle,
      applicationVersion: '1.0.0',
      applicationLegalese: l10n.sharedFinancialManagement,
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      ref.read(authProvider.notifier).logout();
      context.go('/login');
    }
  }
}
