import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fintogether/core/notifications/notification_preferences.dart';

void main() {
  group('NotificationPreferences', () {
    test('returns defaults when no prefs are saved', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final notifPrefs = NotificationPreferences.load(prefs);

      expect(notifPrefs.creditCardDueEnabled, false);
      expect(notifPrefs.recurringDueEnabled, false);
      expect(notifPrefs.savingsMilestoneEnabled, false);
      expect(notifPrefs.savingsDeadlineEnabled, false);
      expect(notifPrefs.weeklySummaryEnabled, false);
      expect(notifPrefs.weeklySummaryDay, 7);
      expect(notifPrefs.weeklySummaryHour, 9);
      expect(notifPrefs.anyEnabled, false);
    });

    test('save and load round-trip preserves all values', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      const original = NotificationPreferences(
        creditCardDueEnabled: true,
        recurringDueEnabled: false,
        savingsMilestoneEnabled: true,
        savingsDeadlineEnabled: true,
        weeklySummaryEnabled: false,
        weeklySummaryDay: 3,
        weeklySummaryHour: 18,
      );

      await original.save(prefs);
      final loaded = NotificationPreferences.load(prefs);

      expect(loaded.creditCardDueEnabled, true);
      expect(loaded.recurringDueEnabled, false);
      expect(loaded.savingsMilestoneEnabled, true);
      expect(loaded.savingsDeadlineEnabled, true);
      expect(loaded.weeklySummaryEnabled, false);
      expect(loaded.weeklySummaryDay, 3);
      expect(loaded.weeklySummaryHour, 18);
    });

    test('individual toggle persistence works', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      const original = NotificationPreferences();
      final toggled = original.copyWith(recurringDueEnabled: true);
      await toggled.save(prefs);

      final loaded = NotificationPreferences.load(prefs);
      expect(loaded.recurringDueEnabled, true);
      expect(loaded.creditCardDueEnabled, false);
    });

    test('anyEnabled returns true when at least one type is enabled', () {
      const prefs = NotificationPreferences(savingsMilestoneEnabled: true);
      expect(prefs.anyEnabled, true);
    });

    test('anyEnabled returns false when all types are disabled', () {
      const prefs = NotificationPreferences();
      expect(prefs.anyEnabled, false);
    });

    test('copyWith creates a new instance with overridden values', () {
      const original = NotificationPreferences(
        creditCardDueEnabled: true,
        weeklySummaryDay: 1,
      );

      final copy = original.copyWith(weeklySummaryDay: 5);

      expect(copy.creditCardDueEnabled, true);
      expect(copy.weeklySummaryDay, 5);
      expect(original.weeklySummaryDay, 1);
    });

    test('equatable compares correctly', () {
      const a = NotificationPreferences(creditCardDueEnabled: true);
      const b = NotificationPreferences(creditCardDueEnabled: true);
      const c = NotificationPreferences(creditCardDueEnabled: false);

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });
}
