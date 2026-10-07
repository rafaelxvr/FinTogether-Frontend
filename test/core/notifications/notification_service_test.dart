import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:fintogether/core/notifications/notification_service.dart';
import 'package:fintogether/core/notifications/notification_preferences.dart';
import 'package:fintogether/features/credit_card/data/datasources/credit_card_local_datasource.dart';
import 'package:fintogether/features/credit_card/data/models/credit_card_model.dart';
import 'package:fintogether/features/savings_goal/data/datasources/savings_goal_local_datasource.dart';
import 'package:fintogether/features/savings_goal/data/models/savings_goal_model.dart';
import 'package:fintogether/features/savings_goal/domain/entities/savings_goal.dart';
import 'package:fintogether/features/transaction/data/datasources/transaction_local_datasource.dart';

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

class MockCreditCardLocalDataSource extends Mock
    implements CreditCardLocalDataSource {}

class MockTransactionLocalDataSource extends Mock
    implements TransactionLocalDataSource {}

class MockSavingsGoalLocalDataSource extends Mock
    implements SavingsGoalLocalDataSource {}

// Register fallback values for argument matchers
class FakeNotificationDetails extends Fake implements NotificationDetails {}

class FakeTZDateTime extends Fake implements tz.TZDateTime {}

void main() {
  late MockFlutterLocalNotificationsPlugin mockPlugin;
  late SharedPreferences prefs;
  late MockCreditCardLocalDataSource mockCreditCardDs;
  late MockTransactionLocalDataSource mockTransactionDs;
  late MockSavingsGoalLocalDataSource mockSavingsGoalDs;
  late NotificationService service;

  setUpAll(() {
    tz.initializeTimeZones();
    registerFallbackValue(FakeNotificationDetails());
    registerFallbackValue(FakeTZDateTime());
    registerFallbackValue(AndroidScheduleMode.inexactAllowWhileIdle);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();

    mockPlugin = MockFlutterLocalNotificationsPlugin();
    mockCreditCardDs = MockCreditCardLocalDataSource();
    mockTransactionDs = MockTransactionLocalDataSource();
    mockSavingsGoalDs = MockSavingsGoalLocalDataSource();

    service = NotificationService(
      plugin: mockPlugin,
      prefs: prefs,
      creditCardLocalDataSource: mockCreditCardDs,
      transactionLocalDataSource: mockTransactionDs,
      savingsGoalLocalDataSource: mockSavingsGoalDs,
    );

    // Default stubs
    when(() => mockPlugin.cancelAll()).thenAnswer((_) async {});
    when(() => mockPlugin.zonedSchedule(
          any(),
          any(),
          any(),
          any(),
          any(),
          payload: any(named: 'payload'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
          matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
        )).thenAnswer((_) async {});
    when(() => mockPlugin.show(
          any(),
          any(),
          any(),
          any(),
          payload: any(named: 'payload'),
        )).thenAnswer((_) async {});
  });

  group('rescheduleAll', () {
    test('cancels all notifications when all toggles are disabled', () async {
      await service.rescheduleAll();

      verify(() => mockPlugin.cancelAll()).called(1);
      verifyNever(() => mockPlugin.zonedSchedule(
            any(),
            any(),
            any(),
            any(),
            any(),
            payload: any(named: 'payload'),
            androidScheduleMode: any(named: 'androidScheduleMode'),
            matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
          ));
    });

    test('schedules credit card notifications when enabled', () async {
      // Enable credit card due notifications
      final notifPrefs = NotificationPreferences(creditCardDueEnabled: true);
      await notifPrefs.save(prefs);

      final now = DateTime.now();
      final dueDay = now.day + 5 > 28 ? 15 : now.day + 5;

      when(() => mockCreditCardDs.getAllActiveCreditCards()).thenAnswer(
        (_) async => [
          CreditCardModel(
            id: 'card-1',
            budgetId: 'budget-1',
            name: 'Test Card',
            currency: 'BRL',
            statementCloseDay: 1,
            dueDay: dueDay,
            active: true,
            createdAt: now.toIso8601String(),
          ),
        ],
      );

      await service.rescheduleAll();

      verify(() => mockPlugin.cancelAll()).called(1);
      // Should schedule at least one notification (3-day-before or day-of)
      verify(() => mockPlugin.zonedSchedule(
            any(),
            any(),
            any(),
            any(),
            any(),
            payload: any(named: 'payload'),
            androidScheduleMode: any(named: 'androidScheduleMode'),
            matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
          )).called(greaterThanOrEqualTo(1));
    });
  });

  group('scheduleCreditCardDueNotifications', () {
    test('does not schedule for past due dates', () async {
      final yesterday = DateTime.now().subtract(const Duration(days: 2));
      final dueDay = yesterday.day;

      when(() => mockCreditCardDs.getAllActiveCreditCards()).thenAnswer(
        (_) async => [
          CreditCardModel(
            id: 'card-past',
            budgetId: 'budget-1',
            name: 'Past Card',
            currency: 'BRL',
            statementCloseDay: 1,
            dueDay: dueDay,
            active: true,
            createdAt: DateTime.now()
                .subtract(const Duration(days: 30))
                .toIso8601String(),
          ),
        ],
      );

      await service.scheduleCreditCardDueNotifications();

      // Next month's due date should still be scheduled
      verify(() => mockPlugin.zonedSchedule(
            any(),
            any(),
            any(),
            any(),
            any(),
            payload: any(named: 'payload'),
            androidScheduleMode: any(named: 'androidScheduleMode'),
            matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
          )).called(greaterThanOrEqualTo(1));
    });
  });

  group('checkSavingsMilestones', () {
    test('fires notification when goal crosses 50% threshold', () async {
      // Enable savings milestones
      final notifPrefs =
          NotificationPreferences(savingsMilestoneEnabled: true);
      await notifPrefs.save(prefs);

      final goal = SavingsGoal(
        id: 'goal-1',
        budgetId: 'budget-1',
        name: 'Vacation',
        targetAmount: 1000,
        currentAmount: 550,
        currency: 'BRL',
        active: true,
        createdAt: DateTime.now(),
      );

      await service.checkSavingsMilestones(goal, 0.45);

      verify(() => mockPlugin.show(
            any(),
            'Savings Goal Milestone!',
            'Vacation has reached 50% of its target!',
            any(),
            payload: any(named: 'payload'),
          )).called(1);
    });

    test('does not fire when milestones are disabled', () async {
      final goal = SavingsGoal(
        id: 'goal-1',
        budgetId: 'budget-1',
        name: 'Vacation',
        targetAmount: 1000,
        currentAmount: 550,
        currency: 'BRL',
        active: true,
        createdAt: DateTime.now(),
      );

      await service.checkSavingsMilestones(goal, 0.45);

      verifyNever(() => mockPlugin.show(
            any(),
            any(),
            any(),
            any(),
            payload: any(named: 'payload'),
          ));
    });

    test('fires 100% notification when goal is completed', () async {
      final notifPrefs =
          NotificationPreferences(savingsMilestoneEnabled: true);
      await notifPrefs.save(prefs);

      final goal = SavingsGoal(
        id: 'goal-2',
        budgetId: 'budget-1',
        name: 'Emergency Fund',
        targetAmount: 5000,
        currentAmount: 5000,
        currency: 'BRL',
        active: true,
        createdAt: DateTime.now(),
      );

      await service.checkSavingsMilestones(goal, 0.90);

      verify(() => mockPlugin.show(
            any(),
            'Savings Goal Milestone!',
            'Emergency Fund has reached 100% of its target!',
            any(),
            payload: any(named: 'payload'),
          )).called(1);
    });
  });

  group('scheduleSavingsDeadlineNotifications', () {
    test('schedules 7-day and 1-day reminders for goals with deadlines',
        () async {
      final deadline = DateTime.now().add(const Duration(days: 10));

      when(() => mockSavingsGoalDs.getAllActiveSavingsGoals()).thenAnswer(
        (_) async => [
          SavingsGoalModel(
            id: 'goal-dl',
            budgetId: 'budget-1',
            name: 'Car',
            targetAmount: 20000,
            currentAmount: 5000,
            currency: 'BRL',
            deadline: deadline,
            active: true,
            createdAt: DateTime.now(),
          ),
        ],
      );

      await service.scheduleSavingsDeadlineNotifications();

      // Should schedule both 7-day and 1-day notifications
      verify(() => mockPlugin.zonedSchedule(
            any(),
            any(),
            any(),
            any(),
            any(),
            payload: any(named: 'payload'),
            androidScheduleMode: any(named: 'androidScheduleMode'),
            matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
          )).called(2);
    });

    test('does not schedule for completed goals', () async {
      final deadline = DateTime.now().add(const Duration(days: 10));

      when(() => mockSavingsGoalDs.getAllActiveSavingsGoals()).thenAnswer(
        (_) async => [
          SavingsGoalModel(
            id: 'goal-complete',
            budgetId: 'budget-1',
            name: 'Done Goal',
            targetAmount: 1000,
            currentAmount: 1000,
            currency: 'BRL',
            deadline: deadline,
            active: true,
            completedAt: DateTime.now(),
            createdAt: DateTime.now(),
          ),
        ],
      );

      await service.scheduleSavingsDeadlineNotifications();

      verifyNever(() => mockPlugin.zonedSchedule(
            any(),
            any(),
            any(),
            any(),
            any(),
            payload: any(named: 'payload'),
            androidScheduleMode: any(named: 'androidScheduleMode'),
            matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
          ));
    });
  });

  group('scheduleWeeklySummary', () {
    test('schedules weekly notification with matching day/time components',
        () async {
      const preferences = NotificationPreferences(
        weeklySummaryEnabled: true,
        weeklySummaryDay: 7,
        weeklySummaryHour: 9,
      );

      await service.scheduleWeeklySummary(preferences);

      verify(() => mockPlugin.zonedSchedule(
            any(),
            'Weekly Spending Summary',
            any(),
            any(),
            any(),
            payload: any(named: 'payload'),
            androidScheduleMode: any(named: 'androidScheduleMode'),
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          )).called(1);
    });
  });
}
