import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:timezone/data/latest_all.dart' as tz;

import '../router/app_router.dart';
import 'notification_channels.dart';

/// Handles one-time initialization of the local notifications plugin,
/// creation of Android notification channels, and tap-to-navigate routing.
class NotificationInitializer {
  final FlutterLocalNotificationsPlugin _plugin;
  final Logger _logger = Logger();

  NotificationInitializer(this._plugin);

  /// Initialize the plugin with platform-specific settings and create channels.
  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('ic_notification');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    await _createChannels();
    _logger.i('NotificationInitializer: initialization complete');
  }

  /// Creates all Android notification channels.
  Future<void> _createChannels() async {
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return;

    final channels = [
      AndroidNotificationChannel(
        NotificationChannels.creditCardDueId,
        NotificationChannels.creditCardDueName,
        description: NotificationChannels.creditCardDueDescription,
        importance: Importance.high,
      ),
      AndroidNotificationChannel(
        NotificationChannels.recurringDueId,
        NotificationChannels.recurringDueName,
        description: NotificationChannels.recurringDueDescription,
        importance: Importance.high,
      ),
      AndroidNotificationChannel(
        NotificationChannels.savingsMilestoneId,
        NotificationChannels.savingsMilestoneName,
        description: NotificationChannels.savingsMilestoneDescription,
        importance: Importance.defaultImportance,
      ),
      AndroidNotificationChannel(
        NotificationChannels.savingsDeadlineId,
        NotificationChannels.savingsDeadlineName,
        description: NotificationChannels.savingsDeadlineDescription,
        importance: Importance.high,
      ),
      AndroidNotificationChannel(
        NotificationChannels.weeklySummaryId,
        NotificationChannels.weeklySummaryName,
        description: NotificationChannels.weeklySummaryDescription,
        importance: Importance.defaultImportance,
      ),
    ];

    for (final channel in channels) {
      await androidPlugin.createNotificationChannel(channel);
    }
  }

  /// Handles notification tap by parsing the JSON payload and navigating
  /// to the relevant page via the global [appRouter].
  void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;

    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final type = data['type'] as String?;

      switch (type) {
        case 'credit_card_due':
          final cardId = data['cardId'] as String?;
          final month = data['month'] as String?;
          if (cardId != null) {
            final uri = month != null
                ? '/credit-cards/$cardId/invoice?month=$month'
                : '/credit-cards/$cardId/invoice';
            appRouter.go(uri);
          }
          break;

        case 'recurring_due':
          final budgetId = data['budgetId'] as String? ?? '';
          appRouter.go('/budgets/$budgetId/recurring-templates');
          break;

        case 'savings_milestone':
        case 'savings_deadline':
          final goalId = data['goalId'] as String?;
          final budgetId = data['budgetId'] as String? ?? '';
          if (goalId != null) {
            appRouter.go('/savings-goals/$goalId?budgetId=$budgetId');
          }
          break;

        case 'weekly_summary':
          appRouter.go('/dashboard');
          break;

        default:
          _logger.w('Unknown notification type: $type');
      }
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to handle notification tap',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}
