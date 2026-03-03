import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter_local_notifications/flutter_local_notifications.dart";

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    const androidSettings = AndroidInitializationSettings("@mipmap/ic_launcher");
    await _plugin.initialize(const InitializationSettings(android: androidSettings));

    await FirebaseMessaging.instance.requestPermission();
    await FirebaseMessaging.instance.setAutoInitEnabled(true);

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    FirebaseMessaging.onMessage.listen((message) async {
      final title = message.notification?.title ?? "F1 Friends";
      final body = message.notification?.body ?? "New update available.";
      await _show(title, body);
    });

    _initialized = true;
  }

  static Future<void> showPredictionReminder() async {
    if (!_initialized) {
      return;
    }

    await _show(
      "F1 Friends",
      "Share your race predictions with friends today to earn points!",
    );
  }

  static Future<void> _show(String title, String body) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        "prediction_reminders",
        "Prediction Reminders",
        channelDescription: "Reminders to submit race predictions",
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(1 << 20),
      title,
      body,
      details,
    );
  }
}
