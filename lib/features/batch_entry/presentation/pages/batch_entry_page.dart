import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../category/domain/entities/category.dart';
import '../../../category/presentation/providers/category_provider.dart';
import '../../../transaction/domain/entities/transaction.dart';
import '../../domain/entities/batch_entry_item.dart';
import '../../domain/entities/batch_session.dart';
import '../providers/batch_entry_provider.dart';
import '../providers/batch_entry_state.dart';
import '../widgets/amount_keypad.dart';
import '../widgets/batch_session_summary.dart';
import '../widgets/category_icon_grid.dart';

class BatchEntryPage extends ConsumerStatefulWidget {
  final String budgetId;

  const BatchEntryPage({super.key, required this.budgetId});

  @override
  ConsumerState<BatchEntryPage> createState() => _BatchEntryPageState();
}

class _BatchEntryPageState extends ConsumerState<BatchEntryPage> {
  final _descriptionController = TextEditingController();
  final _keypadKey = GlobalKey<AmountKeypadState>();

  double _currentAmount = 0.0;
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategoryId;
  String? _selectedCategoryName;
  bool _showConfirmation = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(batchEntryProvider.notifier).startSession(widget.budgetId);
      ref.read(categoryProvider.notifier).loadCategories(
            budgetId: widget.budgetId,
          );
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _onAmountChanged(double amount) {
    setState(() {
      _currentAmount = amount;
    });
  }

  void _onCategorySelected(Category category) {
    setState(() {
      _selectedCategoryId = category.id;
      _selectedCategoryName = category.name;
    });

    // Auto-add when amount is set and category is tapped
    if (_currentAmount > 0) {
      _addEntryToSession();
    }
  }

  void _addEntryToSession() {
    final l10n = AppLocalizations.of(context)!;
    if (_currentAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.enterAmountFirst),
          duration: const Duration(seconds: 1),
        ),
      );
      return;
    }

    final item = BatchEntryItem(
      localId: const Uuid().v4(),
      amount: _currentAmount,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      categoryId: _selectedCategoryId,
      categoryName: _selectedCategoryName,
      date: _selectedDate,
      transactionType: TransactionType.expense,
    );

    ref.read(batchEntryProvider.notifier).addItem(item);

    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}

    // Show confirmation overlay
    setState(() {
      _showConfirmation = true;
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          _showConfirmation = false;
        });
      }
    });

    // Reset form
    _keypadKey.currentState?.clear();
    _descriptionController.clear();
    setState(() {
      _currentAmount = 0.0;
      _selectedCategoryId = null;
      _selectedCategoryName = null;
    });
  }

  void _onSubmitBatch() {
    final l10n = AppLocalizations.of(context)!;
    final batchState = ref.read(batchEntryProvider);
    final BatchSession session;

    if (batchState is BatchEntryIdle) {
      session = batchState.session;
    } else if (batchState is BatchEntryError) {
      session = batchState.session;
    } else {
      return;
    }

    if (session.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.submitBatch),
        content: Text(
          l10n.submitBatchConfirm(session.entryCount, session.formattedTotal),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(batchEntryProvider.notifier).submitBatch();
            },
            child: Text(l10n.submit),
          ),
        ],
      ),
    );
  }

  void _onRemoveItem(String localId) {
    final l10n = AppLocalizations.of(context)!;
    ref.read(batchEntryProvider.notifier).removeItem(localId);

    try {
      HapticFeedback.lightImpact();
    } catch (_) {}

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.itemRemoved),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  BatchSession _getSessionFromState(BatchEntryState state) {
    if (state is BatchEntryIdle) return state.session;
    if (state is BatchEntrySubmitting) return state.session;
    if (state is BatchEntryCompleted) return state.session;
    if (state is BatchEntryError) return state.session;
    return BatchSession.empty(widget.budgetId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final batchState = ref.watch(batchEntryProvider);
    final categoryState = ref.watch(categoryProvider);
    final session = _getSessionFromState(batchState);

    // Listen for state changes
    ref.listen<BatchEntryState>(batchEntryProvider, (previous, next) {
      if (next is BatchEntryCompleted) {
        try {
          HapticFeedback.heavyImpact();
        } catch (_) {}

        _showSubmissionResult(next);
      } else if (next is BatchEntryError) {
        try {
          HapticFeedback.vibrate();
        } catch (_) {}

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.quickEntry),
        actions: [
          if (session.isNotEmpty)
            Badge(
              label: Text('${session.entryCount}'),
              child: IconButton(
                icon: const Icon(Icons.send),
                tooltip: l10n.submitAll,
                onPressed: _onSubmitBatch,
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          // Main content
          _buildMainContent(theme, session, categoryState),
          // Loading overlay
          if (batchState is BatchEntrySubmitting)
            _buildLoadingOverlay(theme, session),
          // Green check confirmation overlay
          if (_showConfirmation) _buildConfirmationOverlay(theme),
        ],
      ),
    );
  }

  Widget _buildMainContent(
    ThemeData theme,
    BatchSession session,
    dynamic categoryState,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final categoryNotifier = ref.read(categoryProvider.notifier);
    final categories = categoryNotifier.activeCategories;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Session summary bar
          BatchSessionSummary(
            session: session,
            onSubmit: _onSubmitBatch,
            onRemoveItem: _onRemoveItem,
          ),

          const SizedBox(height: 8),

          // Date selector chip
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                ActionChip(
                  avatar: const Icon(Icons.calendar_today, size: 16),
                  label: Text(
                    _isToday(_selectedDate)
                        ? l10n.today
                        : DateFormat('MMM dd').format(_selectedDate),
                  ),
                  onPressed: _selectDate,
                ),
                const SizedBox(width: 8),
                // Optional description field
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        hintText: l10n.descriptionOptional,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        isDense: true,
                      ),
                      style: theme.textTheme.bodySmall,
                      textInputAction: TextInputAction.done,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Amount keypad
          AmountKeypad(
            key: _keypadKey,
            onAmountChanged: _onAmountChanged,
          ),

          const SizedBox(height: 12),

          // Category grid header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  l10n.tapCategoryToAdd,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: _currentAmount > 0
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withOpacity(0.5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (_currentAmount > 0 && _selectedCategoryId == null)
                  Text(
                    'R\$ ${_currentAmount.toStringAsFixed(2)}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // Category icon grid
          CategoryIconGrid(
            categories: categories,
            selectedCategoryId: _selectedCategoryId,
            onSelected: _onCategorySelected,
          ),

          // Manual add button (when category not used)
          if (_currentAmount > 0)
            Padding(
              padding: const EdgeInsets.all(16),
              child: OutlinedButton.icon(
                onPressed: _addEntryToSession,
                icon: const Icon(Icons.add),
                label: Text(l10n.addWithoutCategory),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ),

          // Bottom padding for safe area
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay(ThemeData theme, BatchSession session) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  l10n.submittingTransactions(session.entryCount),
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmationOverlay(ThemeData theme) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: AnimatedOpacity(
            opacity: _showConfirmation ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 48,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSubmissionResult(BatchEntryCompleted state) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              state.result.allSucceeded
                  ? Icons.check_circle
                  : Icons.warning_amber_rounded,
              size: 56,
              color: state.result.allSucceeded
                  ? Colors.green
                  : Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.nTransactionsCreated(state.successCount),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (state.result.hasFailures) ...[
              const SizedBox(height: 8),
              Text(
                l10n.nTransactionsFailed(state.failCount),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.red,
                    ),
              ),
              const SizedBox(height: 8),
              ...state.result.failed.map(
                (error) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    'Item ${error.index + 1}: ${error.error}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                if (state.result.allSucceeded) {
                  ref.read(batchEntryProvider.notifier).clearSession();
                }
              },
              child: Text(
                state.result.allSucceeded ? l10n.done : l10n.close,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
