import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const settings = InitializationSettings(android: android, iOS: ios);

    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      await notifications.initialize(settings: settings);
    }
  }

  static Future<bool> requestPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidImplementation = notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      final granted = await androidImplementation
          ?.requestNotificationsPermission();

      return granted ?? false;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosImplementation = notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();

      final granted = await iosImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

      return granted ?? false;
    }

    return false;
  }

  static Future<bool> areNotificationsEnabled() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidImplementation = notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      return await androidImplementation?.areNotificationsEnabled() ?? false;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosImplementation = notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();

      final settings = await iosImplementation?.checkPermissions();

      return settings?.isEnabled ?? false;
    }

    return false;
  }

  static Future<void> showUpdateNotification() async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'updates',
        'Timetable Updates',
        channelDescription: 'Notifications when the timetable changes',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    await notifications.show(
      id: 0,
      title: 'Veränderter Vertretungsplan',
      body: 'Der Vertretungsplan wurde verändert',
      payload: 'Your timetable has changed.',
      notificationDetails: details,
    );
  }

  static Future<void> makeUpdateNotification(
    int id,
    String title,
    String body,
  ) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'updates',
        'Timetable Updates',
        channelDescription: 'Notifications when the timetable changes',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    await notifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }
}
