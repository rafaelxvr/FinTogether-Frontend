import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../features/credit_card/data/datasources/credit_card_local_datasource.dart';
import '../../features/savings_goal/data/datasources/savings_goal_local_datasource.dart';
import '../../features/savings_goal/domain/entities/savings_goal.dart';
import '../../features/transaction/data/datasources/transaction_local_datasource.dart';
import 'notification_channels.dart';
import 'notification_preferences.dart';

/// Schedules and manages all local notifications based on cached data
/// and user preferences.
///
/// Uses deterministic IDs derived from entity + trigger type to prevent
/// duplicate notifications across reschedule cycles.
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin;
  final SharedPreferences _prefs;
  final CreditCardLocalDataSource _creditCardLocalDataSource;
  final TransactionLocalDataSource _transactionLocalDataSource;
  final SavingsGoalLocalDataSource _savingsGoalLocalDataSource;
  final Logger _logger = Logger();

  NotificationService({
    required FlutterLocalNotificationsPlugin plugin,
    required SharedPreferences prefs,
    required CreditCardLocalDataSource creditCardLocalDataSource,
    required TransactionLocalDataSource transactionLocalDataSource,
    required SavingsGoalLocalDataSource savingsGoalLocalDataSource,
  })  : _plugin = plugin,
        _prefs = prefs,
        _creditCardLocalDataSource = creditCardLocalDataSource,
        _transactionLocalDataSource = transactionLocalDataSource,
        _savingsGoalLocalDataSource = savingsGoalLocalDataSource;

  /// Cancel all existing notifications then reschedule based on current
  /// data and preferences.
  Future<void> rescheduleAll() async {
    final preferences = NotificationPreferences.load(_prefs);

    if (!preferences.anyEnabled) {
      await _plugin.cancelAll();
      _logger.d('All notification types disabled -- cancelled all');
      return;
    }

    await _plugin.cancelAll();

    if (preferences.creditCardDueEnabled) {
      await scheduleCreditCardDueNotifications();
    }
    if (preferences.savingsDeadlineEnabled) {
      await scheduleSavingsDeadlineNotifications();
    }
    if (preferences.weeklySummaryEnabled) {
      await scheduleWeeklySummary(preferences);
    }

    _logger.i('Notifications rescheduled');
  }

  // ---------------------------------------------------------------------------
  // Credit Card Due Date Notifications
  // ---------------------------------------------------------------------------

  /// Reads all active credit cards and schedules 3-day-before and day-of
  /// notifications for the current and next month.
  Future<void> scheduleCreditCardDueNotifications() async {
    try {
      final cards = await _creditCardLocalDataSource.getAllActiveCreditCards();
      final now = DateTime.now();

      for (final card in cards) {
        final dueDates = _computeDueDates(card.dueDay, now);

        for (final dueDate in dueDates) {
          final monthStr =
              '${dueDate.year}-${dueDate.month.toString().padLeft(2, '0')}';

          // 3-day-before notification
          final threeDaysBefore = dueDate.subtract(const Duration(days: 3));
          if (threeDaysBefore.isAfter(now)) {
            await _scheduleNotification(
              id: _generateId('credit_card_due_${card.id}_3day_$monthStr'),
              title: 'Credit Card Due Soon',
              body: '${card.name} is due in 3 days ($monthStr)',
              scheduledDate: _toTZDateTime(threeDaysBefore, hour: 9),
              channelId: NotificationChannels.creditCardDueId,
              channelName: NotificationChannels.creditCardDueName,
              payload: jsonEncode({
                'type': 'credit_card_due',
                'cardId': card.id,
                'month': monthStr,
              }),
            );
          }

          // Day-of notification
          if (dueDate.isAfter(now)) {
            await _scheduleNotification(
              id: _generateId('credit_card_due_${card.id}_dayof_$monthStr'),
              title: 'Credit Card Due Today',
              body: '${card.name} payment is due today',
              scheduledDate: _toTZDateTime(dueDate, hour: 9),
              channelId: NotificationChannels.creditCardDueId,
              channelName: NotificationChannels.creditCardDueName,
              payload: jsonEncode({
                'type': 'credit_card_due',
                'cardId': card.id,
                'month': monthStr,
              }),
            );
          }
        }
      }
      _logger.d('Credit card due notifications scheduled');
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to schedule credit card notifications',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Computes due dates for the current and next month given a [dueDay].
  List<DateTime> _computeDueDates(int dueDay, DateTime now) {
    final dates = <DateTime>[];

    // Current month
    final currentMonthDays = DateTime(now.year, now.month + 1, 0).day;
    final clampedCurrentDay =
        dueDay > currentMonthDays ? currentMonthDays : dueDay;
    dates.add(DateTime(now.year, now.month, clampedCurrentDay));

    // Next month
    final nextMonth = now.month == 12
        ? DateTime(now.year + 1, 1, 1)
        : DateTime(now.year, now.month + 1, 1);
    final nextMonthDays =
        DateTime(nextMonth.year, nextMonth.month + 1, 0).day;
    final clampedNextDay =
        dueDay > nextMonthDays ? nextMonthDays : dueDay;
    dates.add(DateTime(nextMonth.year, nextMonth.month, clampedNextDay));

    return dates;
  }

  // ---------------------------------------------------------------------------
  // Savings Goal Milestone Notifications
  // ---------------------------------------------------------------------------

  /// Checks whether a savings goal has crossed a milestone threshold
  /// (25%, 50%, 75%, 100%) and fires an immediate notification if so.
  Future<void> checkSavingsMilestones(
    SavingsGoal goal,
    double previousProgress,
  ) async {
    final preferences = NotificationPreferences.load(_prefs);
    if (!preferences.savingsMilestoneEnabled) return;

    final currentProgress = goal.progressPercentage;
    const milestones = [0.25, 0.50, 0.75, 1.0];

    for (final milestone in milestones) {
      if (previousProgress < milestone && currentProgress >= milestone) {
        final percent = (milestone * 100).toInt();
        await _showImmediateNotification(
          id: _generateId('savings_milestone_${goal.id}_$percent'),
          title: 'Savings Goal Milestone!',
          body: '${goal.name} has reached $percent% of its target!',
          channelId: NotificationChannels.savingsMilestoneId,
          channelName: NotificationChannels.savingsMilestoneName,
          payload: jsonEncode({
            'type': 'savings_milestone',
            'goalId': goal.id,
            'budgetId': goal.budgetId,
          }),
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Savings Goal Deadline Notifications
  // ---------------------------------------------------------------------------

  /// Reads active savings goals with deadlines and schedules 7-day and
  /// 1-day reminders before the deadline.
  Future<void> scheduleSavingsDeadlineNotifications() async {
    try {
      final goals = await _savingsGoalLocalDataSource.getAllActiveSavingsGoals();
      final now = DateTime.now();

      for (final goal in goals) {
        if (goal.deadline == null || goal.isCompleted) continue;

        final deadline = goal.deadline!;
        if (deadline.isBefore(now)) continue;

        // 7-day reminder
        final sevenDaysBefore = deadline.subtract(const Duration(days: 7));
        if (sevenDaysBefore.isAfter(now)) {
          await _scheduleNotification(
            id: _generateId('savings_deadline_${goal.id}_7day'),
            title: 'Savings Goal Deadline Approaching',
            body: '${goal.name} deadline is in 7 days. '
                '${goal.formattedRemainingAmount} remaining.',
            scheduledDate: _toTZDateTime(sevenDaysBefore, hour: 9),
            channelId: NotificationChannels.savingsDeadlineId,
            channelName: NotificationChannels.savingsDeadlineName,
            payload: jsonEncode({
              'type': 'savings_deadline',
              'goalId': goal.id,
              'budgetId': goal.budgetId,
            }),
          );
        }

        // 1-day reminder
        final oneDayBefore = deadline.subtract(const Duration(days: 1));
        if (oneDayBefore.isAfter(now)) {
          await _scheduleNotification(
            id: _generateId('savings_deadline_${goal.id}_1day'),
            title: 'Savings Goal Deadline Tomorrow',
            body: '${goal.name} deadline is tomorrow. '
                '${goal.formattedRemainingAmount} remaining.',
            scheduledDate: _toTZDateTime(oneDayBefore, hour: 9),
            channelId: NotificationChannels.savingsDeadlineId,
            channelName: NotificationChannels.savingsDeadlineName,
            payload: jsonEncode({
              'type': 'savings_deadline',
              'goalId': goal.id,
              'budgetId': goal.budgetId,
            }),
          );
        }
      }
      _logger.d('Savings deadline notifications scheduled');
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to schedule savings deadline notifications',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Weekly Spending Summary
  // ---------------------------------------------------------------------------

  /// Schedules a recurring weekly notification at the configured day and time.
  Future<void> scheduleWeeklySummary(NotificationPreferences preferences) async {
    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = _nextWeekday(
        now,
        preferences.weeklySummaryDay,
        preferences.weeklySummaryHour,
      );

      // If the computed time is in the past (same day but earlier hour),
      // move to next week.
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 7));
      }

      await _scheduleNotification(
        id: _generateId('weekly_summary'),
        title: 'Weekly Spending Summary',
        body: 'Tap to review your spending this week.',
        scheduledDate: scheduledDate,
        channelId: NotificationChannels.weeklySummaryId,
        channelName: NotificationChannels.weeklySummaryName,
        payload: jsonEncode({'type': 'weekly_summary'}),
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
      _logger.d('Weekly summary notification scheduled');
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to schedule weekly summary notification',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Computes the next occurrence of a given weekday and hour.
  tz.TZDateTime _nextWeekday(tz.TZDateTime from, int weekday, int hour) {
    var date = tz.TZDateTime(
      tz.local,
      from.year,
      from.month,
      from.day,
      hour,
    );

    // Dart DateTime.weekday: 1=Monday, 7=Sunday — matches our convention.
    while (date.weekday != weekday) {
      date = date.add(const Duration(days: 1));
    }

    return date;
  }

  // ---------------------------------------------------------------------------
  // Scheduling Helpers
  // ---------------------------------------------------------------------------

  /// Generates a deterministic notification ID from a string key.
  int _generateId(String key) => key.hashCode.abs() % 2147483647;

  /// Converts a [DateTime] to a [tz.TZDateTime] at the given [hour].
  tz.TZDateTime _toTZDateTime(DateTime date, {required int hour}) {
    return tz.TZDateTime(
      tz.local,
      date.year,
      date.month,
      date.day,
      hour,
    );
  }

  /// Schedules a notification at a specific date/time.
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required String channelId,
    required String channelName,
    required String payload,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      icon: 'ic_notification',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: matchDateTimeComponents,
    );
  }

  /// Shows an immediate notification (used for milestones).
  Future<void> _showImmediateNotification({
    required int id,
    required String title,
    required String body,
    required String channelId,
    required String channelName,
    required String payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      icon: 'ic_notification',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(id, title, body, details, payload: payload);
  }
}
