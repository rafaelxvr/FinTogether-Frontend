import 'package:flutter/material.dart';
import '../../domain/entities/batch_session.dart';
import '../../domain/entities/batch_entry_item.dart';

class BatchSessionSummary extends StatefulWidget {
  final BatchSession session;
  final VoidCallback onSubmit;
  final ValueChanged<String> onRemoveItem;

  const BatchSessionSummary({
    super.key,
    required this.session,
    required this.onSubmit,
    required this.onRemoveItem,
  });

  @override
  State<BatchSessionSummary> createState() => _BatchSessionSummaryState();
}

class _BatchSessionSummaryState extends State<BatchSessionSummary> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = widget.session;

    if (session.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Summary bar
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Entry count
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${session.entryCount} ${session.entryCount == 1 ? 'item' : 'items'}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Total amount
                  Expanded(
                    child: Semantics(
                      label:
                          '${session.entryCount} entries totaling ${session.totalAmount.toStringAsFixed(2)} reais',
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          session.formattedTotal,
                          key: ValueKey(session.totalAmount),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Submit button
                  FilledButton.tonal(
                    onPressed: widget.onSubmit,
                    child: const Text('Submit'),
                  ),
                  const SizedBox(width: 8),
                  // Expand/collapse icon
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.expand_more,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Expanded item list
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildItemList(context, session),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildItemList(BuildContext context, BatchSession session) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 200),
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: 8),
        itemCount: session.items.length,
        itemBuilder: (context, index) {
          final item = session.items[index];
          return Dismissible(
            key: ValueKey(item.localId),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => widget.onRemoveItem(item.localId),
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16),
              color: theme.colorScheme.error,
              child: Icon(Icons.delete, color: theme.colorScheme.onError),
            ),
            child: _buildItemTile(context, item),
          );
        },
      ),
    );
  }

  Widget _buildItemTile(BuildContext context, BatchEntryItem item) {
    final theme = Theme.of(context);
    final color = item.isExpense ? Colors.red : Colors.green;

    return ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: color.withOpacity(0.1),
        child: Icon(
          item.isExpense ? Icons.arrow_downward : Icons.arrow_upward,
          size: 16,
          color: color,
        ),
      ),
      title: Text(
        item.categoryName ?? 'Uncategorized',
        style: theme.textTheme.bodyMedium,
      ),
      subtitle: item.description != null && item.description!.isNotEmpty
          ? Text(
              item.description!,
              style: theme.textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: Text(
        item.formattedAmount,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
