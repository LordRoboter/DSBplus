import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: android);

    await notifications.initialize(settings: settings);
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
