import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/notifications/notification_permission_handler.dart';
import '../../../../core/notifications/notification_preferences.dart';
import '../../../../core/notifications/notification_service.dart';

/// Provider that exposes [NotificationPreferences] with persistence.
final _notificationPrefsProvider =
    StateNotifierProvider<_NotificationPrefsNotifier, NotificationPreferences>(
  (ref) => _NotificationPrefsNotifier(prefs: getIt<SharedPreferences>()),
);

class _NotificationPrefsNotifier
    extends StateNotifier<NotificationPreferences> {
  final SharedPreferences _prefs;

  _NotificationPrefsNotifier({required SharedPreferences prefs})
      : _prefs = prefs,
        super(NotificationPreferences.load(prefs));

  Future<void> _persist() async {
    await state.save(_prefs);
    await getIt<NotificationService>().rescheduleAll();
  }

  Future<bool> _ensurePermission(BuildContext context) async {
    final handler = getIt<NotificationPermissionHandler>();
    final granted = await handler.requestPermissionIfNeeded();
    if (!granted && context.mounted) {
      await handler.openSettingsIfDenied(context);
    }
    return granted;
  }

  Future<void> toggleCreditCardDue(BuildContext context) async {
    final newVal = !state.creditCardDueEnabled;
    if (newVal && !await _ensurePermission(context)) return;
    state = state.copyWith(creditCardDueEnabled: newVal);
    await _persist();
  }

  Future<void> toggleRecurringDue(BuildContext context) async {
    final newVal = !state.recurringDueEnabled;
    if (newVal && !await _ensurePermission(context)) return;
    state = state.copyWith(recurringDueEnabled: newVal);
    await _persist();
  }

  Future<void> toggleSavingsMilestone(BuildContext context) async {
    final newVal = !state.savingsMilestoneEnabled;
    if (newVal && !await _ensurePermission(context)) return;
    state = state.copyWith(savingsMilestoneEnabled: newVal);
    await _persist();
  }

  Future<void> toggleSavingsDeadline(BuildContext context) async {
    final newVal = !state.savingsDeadlineEnabled;
    if (newVal && !await _ensurePermission(context)) return;
    state = state.copyWith(savingsDeadlineEnabled: newVal);
    await _persist();
  }

  Future<void> toggleWeeklySummary(BuildContext context) async {
    final newVal = !state.weeklySummaryEnabled;
    if (newVal && !await _ensurePermission(context)) return;
    state = state.copyWith(weeklySummaryEnabled: newVal);
    await _persist();
  }

  Future<void> setWeeklySummaryDay(int day) async {
    state = state.copyWith(weeklySummaryDay: day);
    await _persist();
  }

  Future<void> setWeeklySummaryHour(int hour) async {
    state = state.copyWith(weeklySummaryHour: hour);
    await _persist();
  }
}

/// Settings UI section that exposes toggle switches for each notification type
/// plus a day/time picker for the weekly spending summary.
class NotificationSettingsSection extends ConsumerWidget {
  const NotificationSettingsSection({super.key});

  static const _dayNames = {
    1: 'Monday',
    2: 'Tuesday',
    3: 'Wednesday',
    4: 'Thursday',
    5: 'Friday',
    6: 'Saturday',
    7: 'Sunday',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(_notificationPrefsProvider);
    final notifier = ref.read(_notificationPrefsProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.credit_card),
          title: const Text('Credit Card Due Dates'),
          subtitle: const Text('3 days before and day of'),
          value: prefs.creditCardDueEnabled,
          onChanged: (_) => notifier.toggleCreditCardDue(context),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.repeat),
          title: const Text('Recurring Expenses'),
          subtitle: const Text('1 day before'),
          value: prefs.recurringDueEnabled,
          onChanged: (_) => notifier.toggleRecurringDue(context),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.emoji_events),
          title: const Text('Savings Milestones'),
          subtitle: const Text('At 25%, 50%, 75%, 100%'),
          value: prefs.savingsMilestoneEnabled,
          onChanged: (_) => notifier.toggleSavingsMilestone(context),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.calendar_today),
          title: const Text('Savings Deadlines'),
          subtitle: const Text('7 days and 1 day before'),
          value: prefs.savingsDeadlineEnabled,
          onChanged: (_) => notifier.toggleSavingsDeadline(context),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.bar_chart),
          title: const Text('Weekly Spending Summary'),
          subtitle: Text(
            prefs.weeklySummaryEnabled
                ? '${_dayNames[prefs.weeklySummaryDay]} at '
                    '${prefs.weeklySummaryHour.toString().padLeft(2, '0')}:00'
                : 'Disabled',
          ),
          value: prefs.weeklySummaryEnabled,
          onChanged: (_) => notifier.toggleWeeklySummary(context),
        ),
        if (prefs.weeklySummaryEnabled)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const SizedBox(width: 40),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Day',
                      isDense: true,
                    ),
                    value: prefs.weeklySummaryDay,
                    items: _dayNames.entries
                        .map((e) => DropdownMenuItem(
                              value: e.key,
                              child: Text(e.value),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) notifier.setWeeklySummaryDay(val);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Hour',
                      isDense: true,
                    ),
                    value: prefs.weeklySummaryHour,
                    items: List.generate(
                      24,
                      (i) => DropdownMenuItem(
                        value: i,
                        child: Text('${i.toString().padLeft(2, '0')}:00'),
                      ),
                    ),
                    onChanged: (val) {
                      if (val != null) notifier.setWeeklySummaryHour(val);
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
