/// Defines Android notification channel identifiers and display metadata.
///
/// Each notification type has its own channel so users can control
/// individual notification categories from system settings.
class NotificationChannels {
  NotificationChannels._();

  // Credit Card Due Dates
  static const String creditCardDueId = 'credit_card_due';
  static const String creditCardDueName = 'Credit Card Due Dates';
  static const String creditCardDueDescription =
      'Reminders for upcoming credit card due dates';

  // Recurring Expenses
  static const String recurringDueId = 'recurring_due';
  static const String recurringDueName = 'Recurring Expenses';
  static const String recurringDueDescription =
      'Reminders for upcoming recurring expenses';

  // Savings Milestones
  static const String savingsMilestoneId = 'savings_milestone';
  static const String savingsMilestoneName = 'Savings Milestones';
  static const String savingsMilestoneDescription =
      'Notifications when savings goals reach milestones';

  // Savings Deadlines
  static const String savingsDeadlineId = 'savings_deadline';
  static const String savingsDeadlineName = 'Savings Deadlines';
  static const String savingsDeadlineDescription =
      'Reminders for approaching savings goal deadlines';

  // Weekly Summary
  static const String weeklySummaryId = 'weekly_summary';
  static const String weeklySummaryName = 'Weekly Summary';
  static const String weeklySummaryDescription =
      'Weekly spending summary notifications';
}
