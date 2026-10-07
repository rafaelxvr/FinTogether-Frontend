import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fintogether/core/notifications/notification_permission_handler.dart';
import 'package:fintogether/core/notifications/notification_service.dart';
import 'package:fintogether/features/settings/presentation/widgets/notification_settings_section.dart';
import 'package:fintogether/features/credit_card/data/datasources/credit_card_local_datasource.dart';
import 'package:fintogether/features/savings_goal/data/datasources/savings_goal_local_datasource.dart';
import 'package:fintogether/features/transaction/data/datasources/transaction_local_datasource.dart';

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

class MockNotificationPermissionHandler extends Mock
    implements NotificationPermissionHandler {}

class MockCreditCardLocalDataSource extends Mock
    implements CreditCardLocalDataSource {}

class MockTransactionLocalDataSource extends Mock
    implements TransactionLocalDataSource {}

class MockSavingsGoalLocalDataSource extends Mock
    implements SavingsGoalLocalDataSource {}

void main() {
  final getIt = GetIt.instance;
  late SharedPreferences prefs;

  setUp(() async {
    await getIt.reset();
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();

    getIt.registerSingleton<SharedPreferences>(prefs);

    final mockPlugin = MockFlutterLocalNotificationsPlugin();
    when(() => mockPlugin.cancelAll()).thenAnswer((_) async {});

    getIt.registerLazySingleton<FlutterLocalNotificationsPlugin>(
        () => mockPlugin);

    final mockPermHandler = MockNotificationPermissionHandler();
    when(() => mockPermHandler.requestPermissionIfNeeded())
        .thenAnswer((_) async => true);
    getIt.registerLazySingleton<NotificationPermissionHandler>(
        () => mockPermHandler);

    final mockCreditCardDs = MockCreditCardLocalDataSource();
    when(() => mockCreditCardDs.getAllActiveCreditCards())
        .thenAnswer((_) async => []);

    final mockSavingsGoalDs = MockSavingsGoalLocalDataSource();
    when(() => mockSavingsGoalDs.getAllActiveSavingsGoals())
        .thenAnswer((_) async => []);

    getIt.registerLazySingleton<NotificationService>(() => NotificationService(
          plugin: mockPlugin,
          prefs: prefs,
          creditCardLocalDataSource: mockCreditCardDs,
          transactionLocalDataSource: MockTransactionLocalDataSource(),
          savingsGoalLocalDataSource: mockSavingsGoalDs,
        ));
  });

  tearDown(() async {
    await getIt.reset();
  });

  Widget buildTestWidget() {
    return const ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: NotificationSettingsSection(),
          ),
        ),
      ),
    );
  }

  testWidgets('renders all toggle switches', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Credit Card Due Dates'), findsOneWidget);
    expect(find.text('Recurring Expenses'), findsOneWidget);
    expect(find.text('Savings Milestones'), findsOneWidget);
    expect(find.text('Savings Deadlines'), findsOneWidget);
    expect(find.text('Weekly Spending Summary'), findsOneWidget);
  });

  testWidgets('all toggles start as off', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // All SwitchListTile switches should be off
    final switches = tester.widgetList<Switch>(find.byType(Switch));
    for (final s in switches) {
      expect(s.value, false);
    }
  });

  testWidgets('toggling a switch updates the state', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Tap the Credit Card Due Dates switch
    final switchFinder = find.byType(Switch).first;
    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    // Verify the switch is now on
    final updatedSwitch = tester.widget<Switch>(find.byType(Switch).first);
    expect(updatedSwitch.value, true);
  });

  testWidgets('weekly summary shows day/time picker when enabled',
      (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Day/hour dropdowns should not be visible initially
    expect(find.text('Monday'), findsNothing);

    // Enable weekly summary (it's the last switch)
    final switches = find.byType(Switch);
    await tester.tap(switches.last);
    await tester.pumpAndSettle();

    // Day dropdown should now be visible
    expect(find.text('Sunday'), findsOneWidget);
  });
}
