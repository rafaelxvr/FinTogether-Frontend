import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/member_balance.dart';
import '../providers/split_provider.dart';
import '../providers/split_state.dart';

class SettlePage extends ConsumerWidget {
  final String splitId;

  const SettlePage({
    super.key,
    required this.splitId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final balance = GoRouterState.of(context).extra as MemberBalance?;

    ref.listen<SplitState>(splitProvider, (previous, next) {
      if (next is SplitSettled) {
        HapticFeedback.mediumImpact();
        context.pop();
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

    final state = ref.watch(splitProvider);
    final isLoading = state is SplitLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settleUp),
      ),
      body: balance == null
          ? Center(child: Text(l10n.balanceDataNotAvailable))
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // From member
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: theme.colorScheme.errorContainer,
                    child: Text(
                      balance.userName.isNotEmpty
                          ? balance.userName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 24,
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    balance.userName,
                    style: theme.textTheme.titleMedium,
                  ),

                  const SizedBox(height: 24),

                  // Arrow and amount
                  Icon(
                    Icons.arrow_downward,
                    size: 32,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    balance.formattedAmount,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // To member
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      balance.owesToName.isNotEmpty
                          ? balance.owesToName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 24,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    balance.owesToName,
                    style: theme.textTheme.titleMedium,
                  ),

                  const SizedBox(height: 48),

                  // Settle button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: isLoading
                          ? null
                          : () {
                              ref.read(splitProvider.notifier).settleSplit(
                                    splitId: splitId,
                                    budgetId: '', // Budget ID is derived from the split
                                  );
                            },
                      icon: isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check),
                      label: Text(
                          isLoading ? l10n.settling : l10n.markAsSettled),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    l10n.settlePaymentNote,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
