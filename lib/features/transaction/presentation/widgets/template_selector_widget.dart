import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/transaction_template.dart';
import '../providers/transaction_template_provider.dart';

/// Bottom sheet for selecting a transaction template
class TemplateSelectorWidget extends ConsumerWidget {
  final void Function(TransactionTemplate template) onSelect;

  const TemplateSelectorWidget({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templates = ref.watch(transactionTemplateProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Transaction Templates',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          if (templates.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text('No templates saved yet'),
              ),
            )
          else
            ...templates.map((template) => ListTile(
                  leading: Icon(
                    template.type.icon == '💰'
                        ? Icons.trending_up
                        : template.type.icon == '💸'
                            ? Icons.trending_down
                            : Icons.swap_horiz,
                    color: template.type.icon == '💰'
                        ? Colors.green
                        : template.type.icon == '💸'
                            ? Colors.red
                            : Colors.blue,
                  ),
                  title: Text(template.name),
                  subtitle: template.amount != null
                      ? Text(
                          'R\$ ${template.amount!.toStringAsFixed(2)} - ${template.type.displayName}')
                      : Text(template.type.displayName),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    onSelect(template);
                    Navigator.pop(context);
                  },
                  onLongPress: () => _confirmDelete(context, ref, template),
                )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref,
      TransactionTemplate template) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Template'),
        content: Text('Delete "${template.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(transactionTemplateProvider.notifier)
                  .deleteTemplate(template.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
