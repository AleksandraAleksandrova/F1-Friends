import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter_local_notifications/flutter_local_notifications.dart";

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static const String _channelId = "prediction_reminders_v2";
  static bool _initialized = false;
  static String _channelName = "Prediction Reminders";
  static String _channelDescription = "Reminders to submit race predictions";

  static Future<void> initialize({
    required String channelName,
    required String channelDescription,
  }) async {
    if (_initialized) {
      return;
    }

    _channelName = channelName;
    _channelDescription = channelDescription;

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
          AndroidNotificationChannel(
            _channelId,
            channelName,
            description: channelDescription,
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

  static Future<void> showPredictionReminder({
    required String title,
    required String body,
  }) async {
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

    await _show(title, body);
  }

  static Future<void> _show(String title, String body) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
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
