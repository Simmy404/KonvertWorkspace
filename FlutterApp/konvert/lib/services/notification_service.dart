import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/notification.dart';
import '../managers/error_manager.dart';
import '../models/error_struct.dart';

class NotificationService {
  NotificationService._privateConstructor();
  static final NotificationService instance = NotificationService._privateConstructor();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
        macOS: initializationSettingsDarwin,
      );

      await _notificationsPlugin.initialize(initializationSettings);

      // Request notification permissions for Android 13+ (API 33+)
      final androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
      }

      _initialized = true;
    } catch (e, stack) {
      ErrorManager.instance.logErrorToConsole(
        'NOTIFICATION_SERVICE',
        ErrorStruct(
          code: 'NTF-INIT-001',
          technicalDetails: 'Failed to initialize notification service: $e',
        ),
        stack,
      );
    }
  }

  Future<void> showNotification(AppNotification notification) async {
    try {
      if (!_initialized) {
        await init();
      }

      // Generate a valid positive 32-bit integer ID for Android notification channel
      final int notifId = notification.id.hashCode.abs() % 2147483647;

      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'konvert_default_channel',
        'Konvert Notifications',
        channelDescription: 'Notifications for Konvert App updates and alerts',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      await _notificationsPlugin.show(
        notifId,
        notification.title,
        notification.body,
        notificationDetails,
      );
    } catch (e, stack) {
      ErrorManager.instance.logErrorToConsole(
        'NOTIFICATION_SERVICE',
        ErrorStruct(
          code: 'NTF-SHOW-001',
          technicalDetails: 'Failed to show notification: $e',
        ),
        stack,
      );
    }
  }
}
