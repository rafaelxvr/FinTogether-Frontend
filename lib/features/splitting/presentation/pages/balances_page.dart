import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/member_balance.dart';
import '../providers/split_provider.dart';
import '../providers/split_state.dart';
import '../widgets/balance_card.dart';

class BalancesPage extends ConsumerStatefulWidget {
  final String budgetId;

  const BalancesPage({
    super.key,
    required this.budgetId,
  });

  @override
  ConsumerState<BalancesPage> createState() => _BalancesPageState();
}

class _BalancesPageState extends ConsumerState<BalancesPage> {
  DateTime? _lastSynced;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(splitProvider.notifier).loadBalances(widget.budgetId);
      setState(() => _lastSynced = DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(splitProvider);
    final theme = Theme.of(context);

    ref.listen<SplitState>(splitProvider, (previous, next) {
      if (next is SplitSettled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.splitSettledSuccessfully)),
        );
      } else if (next is SplitError) {
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
        title: Text(l10n.balances),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Column(
          children: [
            // Last synced indicator
            if (_lastSynced != null)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: theme.colorScheme.surfaceContainerHighest,
                child: Text(
                  _formatLastSynced(_lastSynced!),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),

            // Content
            Expanded(
              child: _buildContent(state, theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(SplitState state, ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    if (state is SplitLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is SplitError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(state.message),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refresh,
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    if (state is BalancesLoaded) {
      if (state.balances.isEmpty) {
        return _buildEmptyState(theme);
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: state.balances.length,
        itemBuilder: (context, index) {
          final balance = state.balances[index];
          return BalanceCard(
            balance: balance,
            onSettle: () => _navigateToSettle(balance),
          );
        },
      );
    }

    return _buildEmptyState(theme);
  }

  Widget _buildEmptyState(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.allSettledUp,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.noOutstandingBalances,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToSettle(MemberBalance balance) {
    // Navigate to settle page passing balance info via extra
    context.pushNamed(
      'settle-split',
      pathParameters: {'splitId': '${balance.userId}_${balance.owesTo}'},
      extra: balance,
    );
  }

  Future<void> _refresh() async {
    ref.read(splitProvider.notifier).loadBalances(widget.budgetId);
    setState(() => _lastSynced = DateTime.now());
  }

  String _formatLastSynced(DateTime time) {
    final l10n = AppLocalizations.of(context)!;
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 60) return l10n.lastSynced(l10n.justNow);
    if (diff.inMinutes < 60) return l10n.lastSynced(l10n.nMinAgo(diff.inMinutes));
    return l10n.lastSynced(l10n.nHrAgo(diff.inHours));
  }
}
