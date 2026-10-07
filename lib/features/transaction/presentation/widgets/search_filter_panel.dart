import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/transaction_search_params.dart';

class SearchFilterPanel extends StatefulWidget {
  final TransactionSearchParams currentParams;
  final ValueChanged<TransactionSearchParams> onApply;

  const SearchFilterPanel({
    super.key,
    required this.currentParams,
    required this.onApply,
  });

  @override
  State<SearchFilterPanel> createState() => _SearchFilterPanelState();
}

class _SearchFilterPanelState extends State<SearchFilterPanel> {
  late String? _selectedType;
  late String? _categoryId;
  late String? _merchantId;
  late TextEditingController _minAmountController;
  late TextEditingController _maxAmountController;
  late DateTime? _startDate;
  late DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.currentParams.type;
    _categoryId = widget.currentParams.categoryId;
    _merchantId = widget.currentParams.merchantId;
    _minAmountController = TextEditingController(
      text: widget.currentParams.minAmount?.toString() ?? '',
    );
    _maxAmountController = TextEditingController(
      text: widget.currentParams.maxAmount?.toString() ?? '',
    );
    _startDate = widget.currentParams.startDate;
    _endDate = widget.currentParams.endDate;
  }

  @override
  void dispose() {
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _selectedType = null;
      _categoryId = null;
      _merchantId = null;
      _minAmountController.clear();
      _maxAmountController.clear();
      _startDate = null;
      _endDate = null;
    });
  }

  void _applyFilters() {
    final minAmount = _minAmountController.text.isNotEmpty
        ? double.tryParse(_minAmountController.text)
        : null;
    final maxAmount = _maxAmountController.text.isNotEmpty
        ? double.tryParse(_maxAmountController.text)
        : null;

    final params = TransactionSearchParams(
      query: widget.currentParams.query,
      type: _selectedType,
      categoryId: _categoryId,
      merchantId: _merchantId,
      minAmount: minAmount,
      maxAmount: maxAmount,
      startDate: _startDate,
      endDate: _endDate,
      page: 0,
      size: widget.currentParams.size,
    );

    widget.onApply(params);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filters', style: theme.textTheme.titleLarge),
                TextButton(
                  onPressed: _clearFilters,
                  child: const Text('Clear all'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Type filter
            Text('Transaction Type', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<String?>(
              segments: const [
                ButtonSegment(value: null, label: Text('All')),
                ButtonSegment(value: 'INCOME', label: Text('Income')),
                ButtonSegment(value: 'EXPENSE', label: Text('Expense')),
              ],
              selected: {_selectedType},
              onSelectionChanged: (values) {
                setState(() => _selectedType = values.first);
              },
            ),
            const SizedBox(height: 16),

            // Amount range
            Text('Amount Range', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _minAmountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Min',
                      prefixText: 'R\$ ',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _maxAmountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Max',
                      prefixText: 'R\$ ',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Date range
            Text('Date Range', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _DatePickerButton(
                    label: 'Start Date',
                    date: _startDate,
                    onChanged: (date) => setState(() => _startDate = date),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DatePickerButton(
                    label: 'End Date',
                    date: _endDate,
                    onChanged: (date) => setState(() => _endDate = date),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Apply button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _applyFilters,
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DatePickerButton extends StatelessWidget {
  final String label;
  final DateTime? date;
  final ValueChanged<DateTime?> onChanged;

  const _DatePickerButton({
    required this.label,
    required this.date,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) {
          onChanged(picked);
        }
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today, size: 16),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              date != null ? DateFormat('MMM dd, yyyy').format(date!) : label,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (date != null) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => onChanged(null),
              child: const Icon(Icons.close, size: 16),
            ),
          ],
        ],
      ),
    );
  }
}
