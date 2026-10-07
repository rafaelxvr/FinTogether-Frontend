enum RecurrenceFrequency {
  weekly,
  monthly,
  yearly;

  String get displayName {
    switch (this) {
      case RecurrenceFrequency.weekly:
        return 'Weekly';
      case RecurrenceFrequency.monthly:
        return 'Monthly';
      case RecurrenceFrequency.yearly:
        return 'Yearly';
    }
  }

  static RecurrenceFrequency fromString(String value) {
    switch (value.toLowerCase()) {
      case 'weekly':
        return RecurrenceFrequency.weekly;
      case 'monthly':
        return RecurrenceFrequency.monthly;
      case 'yearly':
        return RecurrenceFrequency.yearly;
      default:
        throw ArgumentError('Unknown recurrence frequency: $value');
    }
  }
}

class RecurrenceRule {
  final RecurrenceFrequency frequency;
  final int interval;
  final int? dayOfMonth;
  final int? dayOfWeek;
  final DateTime startDate;
  final DateTime? endDate;
  final int? occurrenceCount;

  const RecurrenceRule({
    required this.frequency,
    this.interval = 1,
    this.dayOfMonth,
    this.dayOfWeek,
    required this.startDate,
    this.endDate,
    this.occurrenceCount,
  });

  String get humanReadableDescription {
    final buffer = StringBuffer();

    if (interval == 1) {
      buffer.write('Every ${frequency.displayName.toLowerCase()}');
    } else {
      final unit = switch (frequency) {
        RecurrenceFrequency.weekly => 'weeks',
        RecurrenceFrequency.monthly => 'months',
        RecurrenceFrequency.yearly => 'years',
      };
      buffer.write('Every $interval $unit');
    }

    if (frequency == RecurrenceFrequency.monthly && dayOfMonth != null) {
      buffer.write(' on day $dayOfMonth');
    }

    if (frequency == RecurrenceFrequency.weekly && dayOfWeek != null) {
      buffer.write(' on ${_dayOfWeekName(dayOfWeek!)}');
    }

    if (occurrenceCount != null) {
      buffer.write(', $occurrenceCount times');
    }

    if (endDate != null) {
      buffer.write(
          ', until ${endDate!.year}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}');
    }

    return buffer.toString();
  }

  Map<String, dynamic> toMap() {
    return {
      'frequency': frequency.name,
      'interval': interval,
      if (dayOfMonth != null) 'day_of_month': dayOfMonth,
      if (dayOfWeek != null) 'day_of_week': dayOfWeek,
      'start_date': startDate.toIso8601String(),
      if (endDate != null) 'end_date': endDate!.toIso8601String(),
      if (occurrenceCount != null) 'occurrence_count': occurrenceCount,
    };
  }

  factory RecurrenceRule.fromMap(Map<String, dynamic> map) {
    return RecurrenceRule(
      frequency: RecurrenceFrequency.fromString(map['frequency'] as String),
      interval: (map['interval'] as num?)?.toInt() ?? 1,
      dayOfMonth: (map['day_of_month'] as num?)?.toInt(),
      dayOfWeek: (map['day_of_week'] as num?)?.toInt(),
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: map['end_date'] != null
          ? DateTime.parse(map['end_date'] as String)
          : null,
      occurrenceCount: (map['occurrence_count'] as num?)?.toInt(),
    );
  }

  static String _dayOfWeekName(int day) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    if (day >= 1 && day <= 7) {
      return days[day - 1];
    }
    return 'Day $day';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecurrenceRule &&
        other.frequency == frequency &&
        other.interval == interval &&
        other.dayOfMonth == dayOfMonth &&
        other.dayOfWeek == dayOfWeek &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.occurrenceCount == occurrenceCount;
  }

  @override
  int get hashCode => Object.hash(
        frequency,
        interval,
        dayOfMonth,
        dayOfWeek,
        startDate,
        endDate,
        occurrenceCount,
      );
}
