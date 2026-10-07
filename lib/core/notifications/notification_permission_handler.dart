import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

/// Handles requesting and checking notification permissions on both
/// Android 13+ and iOS.
class NotificationPermissionHandler {
  final FlutterLocalNotificationsPlugin _plugin;

  NotificationPermissionHandler(this._plugin);

  /// Returns `true` if notification permission is currently granted.
  Future<bool> isPermissionGranted() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      return status.isGranted;
    }

    if (Platform.isIOS) {
      final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      // On iOS <10 this always returns true; on iOS 10+ it checks UNAuthorizationStatus.
      // If plugin returns null we assume not granted.
      final result = await iosPlugin?.checkPermissions();
      return result?.isEnabled ?? false;
    }

    return false;
  }

  /// Requests notification permission if not yet determined.
  ///
  /// Returns `true` if permission is granted after the request.
  Future<bool> requestPermissionIfNeeded() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      if (status.isGranted) return true;
      if (status.isPermanentlyDenied) return false;

      final result = await Permission.notification.request();
      return result.isGranted;
    }

    if (Platform.isIOS) {
      final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final granted = await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return false;
  }

  /// Shows a dialog explaining why notifications are useful, with a
  /// button to open the system app settings.
  Future<void> openSettingsIfDenied(BuildContext context) async {
    final granted = await isPermissionGranted();
    if (granted) return;

    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Notifications Disabled'),
        content: const Text(
          'Notifications help you stay on top of due dates, savings '
          'milestones, and spending summaries. Please enable them in '
          'your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}
