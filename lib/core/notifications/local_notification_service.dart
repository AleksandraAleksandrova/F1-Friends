import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter_local_notifications/flutter_local_notifications.dart";

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static const String _channelId = "prediction_reminders_v2";
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
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            "Prediction Reminders",
            description: "Reminders to submit race predictions",
            importance: Importance.high,
          ),
        );

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

    var enabled = await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.areNotificationsEnabled();
    if (enabled == false) {
      await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      enabled = await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.areNotificationsEnabled();
    }
    if (enabled == false) {
      return;
    }

    await _show(
      "F1 Friends",
      "Create a league and invite friends to predict next race!",
    );
  }

  static Future<void> _show(String title, String body) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
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
