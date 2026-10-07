import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/budget_allocation.dart';
import '../providers/budget_allocation_provider.dart';
import '../providers/budget_allocation_state.dart';

/// Allocation Form Page
/// Lists all expense categories for the budget with amount input fields.
/// Supports editing existing allocations and copying from previous month.
class AllocationFormPage extends ConsumerStatefulWidget {
  final String budgetId;
  final String? month;

  const AllocationFormPage({
    super.key,
    required this.budgetId,
    this.month,
  });

  @override
  ConsumerState<AllocationFormPage> createState() => _AllocationFormPageState();
}

class _AllocationFormPageState extends ConsumerState<AllocationFormPage> {
  final Map<String, TextEditingController> _controllers = {};
  bool _isInitialized = false;
  late String _month;

  @override
  void initState() {
    super.initState();
    _month = widget.month ?? _formatCurrentMonth();
    Future.microtask(
      () => ref
          .read(budgetAllocationProvider.notifier)
          .loadAllocations(widget.budgetId, _month),
    );
  }

  String _formatCurrentMonth() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  String _formatMonthDisplay(String month) {
    try {
      final parts = month.split('-');
      final year = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final date = DateTime(year, m);
      return DateFormat('MMMM yyyy').format(date);
    } catch (_) {
      return month;
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeControllers(BudgetAllocation allocation) {
    if (_isInitialized) return;
    _isInitialized = true;
    for (final cat in allocation.categories) {
      _controllers[cat.categoryId] = TextEditingController(
        text: cat.allocatedAmount > 0
            ? cat.allocatedAmount.toStringAsFixed(2)
            : '',
      );
    }
  }

  double _calculateTotal() {
    double total = 0;
    for (final controller in _controllers.values) {
      final value = double.tryParse(controller.text) ?? 0;
      total += value;
    }
    return total;
  }

  void _copyFromPreviousMonth() {
    final parts = _month.split('-');
    var year = int.parse(parts[0]);
    var m = int.parse(parts[1]);
    m -= 1;
    if (m < 1) {
      m = 12;
      year -= 1;
    }
    final previousMonth = '$year-${m.toString().padLeft(2, '0')}';

    // Load previous month allocations
    ref
        .read(budgetAllocationProvider.notifier)
        .loadAllocations(widget.budgetId, previousMonth)
        .then((_) {
      final state = ref.read(budgetAllocationProvider);
      if (state is BudgetAllocationLoaded) {
        for (final cat in state.allocation.categories) {
          if (_controllers.containsKey(cat.categoryId)) {
            _controllers[cat.categoryId]!.text =
                cat.allocatedAmount.toStringAsFixed(2);
          }
        }
        setState(() {});
        // Reload current month in the background
        ref
            .read(budgetAllocationProvider.notifier)
            .loadAllocations(widget.budgetId, _month);
      }
    });
  }

  void _saveAllocations() {
    final l10n = AppLocalizations.of(context)!;
    final allocations = <CategoryAllocationInput>[];

    for (final entry in _controllers.entries) {
      final amount = double.tryParse(entry.value.text) ?? 0;
      if (amount > 0) {
        allocations.add(CategoryAllocationInput(
          categoryId: entry.key,
          allocatedAmount: amount,
        ));
      }
    }

    if (allocations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.addAtLeastOneAllocation)),
      );
      return;
    }

    ref.read(budgetAllocationProvider.notifier).saveAllocations(
          widget.budgetId,
          _month,
          allocations,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(budgetAllocationProvider);
    final currencyFormat =
        NumberFormat.currency(symbol: 'R\$ ', decimalDigits: 2);

    // Listen for save success
    ref.listen<BudgetAllocationState>(budgetAllocationProvider, (previous, next) {
      if (next is BudgetAllocationSaved) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.allocationsSavedSuccessfully)),
        );
        context.pop();
      }
      if (next is BudgetAllocationError && previous is BudgetAllocationSaving) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message)),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.editAllocations),
            Text(
              _formatMonthDisplay(_month),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _copyFromPreviousMonth,
            child: Text(l10n.copyLastMonth),
          ),
        ],
      ),
      body: _buildBody(state),
      bottomNavigationBar: _buildBottomBar(state, currencyFormat),
    );
  }

  Widget _buildBody(BudgetAllocationState state) {
    if (state is BudgetAllocationLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is BudgetAllocationError && !_isInitialized) {
      return Center(child: Text(state.message));
    }

    if (state is BudgetAllocationLoaded) {
      _initializeControllers(state.allocation);
      return _buildForm(state.allocation);
    }

    if (_isInitialized) {
      return _buildFormFromControllers();
    }

    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildForm(BudgetAllocation allocation) {
    final l10n = AppLocalizations.of(context)!;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allocation.categories.length,
      itemBuilder: (context, index) {
        final cat = allocation.categories[index];
        final controller = _controllers[cat.categoryId]!;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cat.categoryName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (cat.limitAmount != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    l10n.categoryLimit(cat.limitAmount!.toStringAsFixed(2)),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                TextField(
                  controller: controller,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    prefixText: 'R\$ ',
                    hintText: '0.00',
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    suffixText: cat.limitAmount != null
                        ? 'max ${cat.limitAmount!.toStringAsFixed(0)}'
                        : null,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormFromControllers() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _controllers.length,
      itemBuilder: (context, index) {
        final entry = _controllers.entries.elementAt(index);
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: entry.value,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                prefixText: 'R\$ ',
                hintText: '0.00',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar(
    BudgetAllocationState state,
    NumberFormat currencyFormat,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final total = _calculateTotal();
    final isSaving = state is BudgetAllocationSaving;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.total,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                currencyFormat.format(total),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: isSaving ? null : _saveAllocations,
            child: isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.saveAllocations),
          ),
        ],
      ),
    );
  }
}
