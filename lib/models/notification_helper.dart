import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> showNotification({
  required String title,
  required String body,
  FlutterLocalNotificationsPlugin? plugin,
}) async {
  final flutterLocalNotificationsPlugin = plugin ?? FlutterLocalNotificationsPlugin();

  const androidDetails = AndroidNotificationDetails(
    'channel_id_01',
    'App Notifications',
    channelDescription: 'This channel is used for app notifications',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
  );

  const notifDetails = NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    notifDetails,
  );
}