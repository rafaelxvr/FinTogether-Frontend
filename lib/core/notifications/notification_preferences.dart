import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User preferences for each notification type, persisted via SharedPreferences.
///
/// All toggles default to `false` (opt-in). The weekly summary defaults to
/// Sunday at 9:00 AM.
class NotificationPreferences extends Equatable {
  static const String _keyCreditCardDue = 'notif_credit_card_due';
  static const String _keyRecurringDue = 'notif_recurring_due';
  static const String _keySavingsMilestone = 'notif_savings_milestone';
  static const String _keySavingsDeadline = 'notif_savings_deadline';
  static const String _keyWeeklySummary = 'notif_weekly_summary';
  static const String _keyWeeklySummaryDay = 'notif_weekly_summary_day';
  static const String _keyWeeklySummaryHour = 'notif_weekly_summary_hour';

  final bool creditCardDueEnabled;
  final bool recurringDueEnabled;
  final bool savingsMilestoneEnabled;
  final bool savingsDeadlineEnabled;
  final bool weeklySummaryEnabled;

  /// Day of week for the weekly summary (1 = Monday, 7 = Sunday).
  final int weeklySummaryDay;

  /// Hour of day for the weekly summary (0-23).
  final int weeklySummaryHour;

  const NotificationPreferences({
    this.creditCardDueEnabled = false,
    this.recurringDueEnabled = false,
    this.savingsMilestoneEnabled = false,
    this.savingsDeadlineEnabled = false,
    this.weeklySummaryEnabled = false,
    this.weeklySummaryDay = 7,
    this.weeklySummaryHour = 9,
  });

  /// Load preferences from SharedPreferences.
  static NotificationPreferences load(SharedPreferences prefs) {
    return NotificationPreferences(
      creditCardDueEnabled: prefs.getBool(_keyCreditCardDue) ?? false,
      recurringDueEnabled: prefs.getBool(_keyRecurringDue) ?? false,
      savingsMilestoneEnabled: prefs.getBool(_keySavingsMilestone) ?? false,
      savingsDeadlineEnabled: prefs.getBool(_keySavingsDeadline) ?? false,
      weeklySummaryEnabled: prefs.getBool(_keyWeeklySummary) ?? false,
      weeklySummaryDay: prefs.getInt(_keyWeeklySummaryDay) ?? 7,
      weeklySummaryHour: prefs.getInt(_keyWeeklySummaryHour) ?? 9,
    );
  }

  /// Persist current preferences to SharedPreferences.
  Future<void> save(SharedPreferences prefs) async {
    await prefs.setBool(_keyCreditCardDue, creditCardDueEnabled);
    await prefs.setBool(_keyRecurringDue, recurringDueEnabled);
    await prefs.setBool(_keySavingsMilestone, savingsMilestoneEnabled);
    await prefs.setBool(_keySavingsDeadline, savingsDeadlineEnabled);
    await prefs.setBool(_keyWeeklySummary, weeklySummaryEnabled);
    await prefs.setInt(_keyWeeklySummaryDay, weeklySummaryDay);
    await prefs.setInt(_keyWeeklySummaryHour, weeklySummaryHour);
  }

  /// Whether any notification type is enabled.
  bool get anyEnabled =>
      creditCardDueEnabled ||
      recurringDueEnabled ||
      savingsMilestoneEnabled ||
      savingsDeadlineEnabled ||
      weeklySummaryEnabled;

  NotificationPreferences copyWith({
    bool? creditCardDueEnabled,
    bool? recurringDueEnabled,
    bool? savingsMilestoneEnabled,
    bool? savingsDeadlineEnabled,
    bool? weeklySummaryEnabled,
    int? weeklySummaryDay,
    int? weeklySummaryHour,
  }) {
    return NotificationPreferences(
      creditCardDueEnabled:
          creditCardDueEnabled ?? this.creditCardDueEnabled,
      recurringDueEnabled:
          recurringDueEnabled ?? this.recurringDueEnabled,
      savingsMilestoneEnabled:
          savingsMilestoneEnabled ?? this.savingsMilestoneEnabled,
      savingsDeadlineEnabled:
          savingsDeadlineEnabled ?? this.savingsDeadlineEnabled,
      weeklySummaryEnabled:
          weeklySummaryEnabled ?? this.weeklySummaryEnabled,
      weeklySummaryDay: weeklySummaryDay ?? this.weeklySummaryDay,
      weeklySummaryHour: weeklySummaryHour ?? this.weeklySummaryHour,
    );
  }

  @override
  List<Object?> get props => [
        creditCardDueEnabled,
        recurringDueEnabled,
        savingsMilestoneEnabled,
        savingsDeadlineEnabled,
        weeklySummaryEnabled,
        weeklySummaryDay,
        weeklySummaryHour,
      ];
}
