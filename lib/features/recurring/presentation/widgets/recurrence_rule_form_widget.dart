import 'package:flutter/material.dart';

import '../../domain/entities/recurring_transaction_template.dart';

/// Reusable form section for configuring recurrence rules.
class RecurrenceRuleFormWidget extends StatelessWidget {
  final RecurrenceFrequency frequency;
  final int interval;
  final int? dayOfMonth;
  final ValueChanged<RecurrenceFrequency> onFrequencyChanged;
  final ValueChanged<int> onIntervalChanged;
  final ValueChanged<int?> onDayOfMonthChanged;

  const RecurrenceRuleFormWidget({
    super.key,
    required this.frequency,
    required this.interval,
    this.dayOfMonth,
    required this.onFrequencyChanged,
    required this.onIntervalChanged,
    required this.onDayOfMonthChanged,
  });

  /// Build human-readable preview text for the recurrence rule.
  String get previewText {
    final frequencyLabel = switch (frequency) {
      RecurrenceFrequency.monthly => 'month',
      RecurrenceFrequency.weekly => 'week',
      RecurrenceFrequency.yearly => 'year',
    };

    if (interval == 1) {
      if (frequency == RecurrenceFrequency.monthly && dayOfMonth != null) {
        return 'Every month on day $dayOfMonth';
      }
      return 'Every $frequencyLabel';
    }

    final suffix = '${frequencyLabel}s';
    if (frequency == RecurrenceFrequency.monthly && dayOfMonth != null) {
      return 'Every $interval $suffix on day $dayOfMonth';
    }
    return 'Every $interval $suffix';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Frequency dropdown
        DropdownButtonFormField<RecurrenceFrequency>(
          value: frequency,
          decoration: const InputDecoration(
            labelText: 'Frequency',
            prefixIcon: Icon(Icons.repeat),
            border: OutlineInputBorder(),
          ),
          items: RecurrenceFrequency.values.map((freq) {
            final label = switch (freq) {
              RecurrenceFrequency.monthly => 'Monthly',
              RecurrenceFrequency.weekly => 'Weekly',
              RecurrenceFrequency.yearly => 'Yearly',
            };
            return DropdownMenuItem(value: freq, child: Text(label));
          }).toList(),
          onChanged: (val) {
            if (val != null) onFrequencyChanged(val);
          },
        ),
        const SizedBox(height: 16),

        // Interval input
        DropdownButtonFormField<int>(
          value: interval,
          decoration: const InputDecoration(
            labelText: 'Repeat every',
            prefixIcon: Icon(Icons.loop),
            border: OutlineInputBorder(),
          ),
          items: List.generate(12, (i) => i + 1)
              .map((val) => DropdownMenuItem(
                    value: val,
                    child: Text('$val'),
                  ))
              .toList(),
          onChanged: (val) {
            if (val != null) onIntervalChanged(val);
          },
        ),
        const SizedBox(height: 16),

        // Day of month (shown only for Monthly frequency)
        if (frequency == RecurrenceFrequency.monthly) ...[
          DropdownButtonFormField<int>(
            value: dayOfMonth,
            decoration: const InputDecoration(
              labelText: 'Day of month',
              prefixIcon: Icon(Icons.calendar_today),
              border: OutlineInputBorder(),
            ),
            items: List.generate(31, (i) => i + 1)
                .map((day) => DropdownMenuItem(
                      value: day,
                      child: Text('Day $day'),
                    ))
                .toList(),
            onChanged: (val) => onDayOfMonthChanged(val),
            validator: (val) {
              if (frequency == RecurrenceFrequency.monthly && val == null) {
                return 'Please select a day';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
        ],

        // Preview text
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  previewText,
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
