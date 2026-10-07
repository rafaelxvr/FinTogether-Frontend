import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/recurring_transaction_template.dart';
import '../providers/recurring_transaction_provider.dart';
import '../providers/recurring_transaction_state.dart';

/// Page listing all recurring transaction templates for a budget.
class RecurringTemplateListPage extends ConsumerStatefulWidget {
  final String budgetId;

  const RecurringTemplateListPage({super.key, required this.budgetId});

  @override
  ConsumerState<RecurringTemplateListPage> createState() =>
      _RecurringTemplateListPageState();
}

class _RecurringTemplateListPageState
    extends ConsumerState<RecurringTemplateListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(recurringTransactionProvider.notifier)
          .loadTemplates(widget.budgetId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(recurringTransactionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.recurringExpenses),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref
                .read(recurringTransactionProvider.notifier)
                .loadTemplates(widget.budgetId),
          ),
        ],
      ),
      body: _buildBody(state),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(
          '/budgets/${widget.budgetId}/recurring-templates/new',
        ),
        icon: const Icon(Icons.add),
        label: Text(l10n.newTemplate),
      ),
    );
  }

  Widget _buildBody(RecurringTransactionState state) {
    final l10n = AppLocalizations.of(context)!;
    if (state is RecurringLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is RecurringError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.message),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref
                  .read(recurringTransactionProvider.notifier)
                  .loadTemplates(widget.budgetId),
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    if (state is TemplatesLoaded) {
      if (state.templates.isEmpty) {
        return _buildEmptyState();
      }
      return _buildTemplateList(state.templates);
    }

    return Center(child: Text(l10n.loadingRecurringExpenses));
  }

  Widget _buildTemplateList(List<RecurringTransactionTemplate> templates) {
    return RefreshIndicator(
      onRefresh: () => ref
          .read(recurringTransactionProvider.notifier)
          .loadTemplates(widget.budgetId),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: templates.length,
        itemBuilder: (context, index) {
          final template = templates[index];
          return _buildTemplateCard(template);
        },
      ),
    );
  }

  Widget _buildTemplateCard(RecurringTransactionTemplate template) {
    final l10n = AppLocalizations.of(context)!;
    final currencyFormat =
        NumberFormat.currency(symbol: 'R\$ ', decimalDigits: 2);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push(
          '/budgets/${widget.budgetId}/recurring-templates/${template.id}/edit',
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row with chips
              Row(
                children: [
                  Expanded(
                    child: Text(
                      template.description,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (template.isFixedExpense)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      child: Chip(
                        label: Text(
                          l10n.fixed,
                          style: const TextStyle(fontSize: 11, color: Colors.white),
                        ),
                        backgroundColor: Colors.orange,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: EdgeInsets.zero,
                        labelPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    child: Chip(
                      label: Text(
                        template.frequencyLabel,
                        style:
                            const TextStyle(fontSize: 11, color: Colors.white),
                      ),
                      backgroundColor: Colors.blueGrey,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: EdgeInsets.zero,
                      labelPadding:
                          const EdgeInsets.symmetric(horizontal: 8),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Amount
              Text(
                currencyFormat.format(template.amount),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: template.type == RecurringTransactionType.expense
                      ? Colors.red[700]
                      : Colors.green[700],
                ),
              ),
              const SizedBox(height: 8),

              // Details row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (template.nextDueDate != null)
                    Text(
                      'Next: ${dateFormat.format(template.nextDueDate!)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    )
                  else
                    Text(
                      template.recurrenceDescription,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: template.isActive
                          ? Colors.green.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      template.isActive ? l10n.active : l10n.inactive,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color:
                            template.isActive ? Colors.green[700] : Colors.grey,
                      ),
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
            Icons.repeat_outlined,
            size: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 24),
          Text(
            l10n.noRecurringExpensesYet,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.createFirstRecurringDescription,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push(
              '/budgets/${widget.budgetId}/recurring-templates/new',
            ),
            icon: const Icon(Icons.add),
            label: Text(l10n.createTemplate),
          ),
        ],
      ),
    );
  }
}
