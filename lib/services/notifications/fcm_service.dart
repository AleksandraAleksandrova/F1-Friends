import "package:firebase_messaging/firebase_messaging.dart";

class PushNotificationService {
  final FirebaseMessaging _messaging;

  PushNotificationService(this._messaging);

  Future<String?> requestAndGetToken() async {
    await _messaging.requestPermission();
    return _messaging.getToken();
  }

  Stream<RemoteMessage> onMessage() => FirebaseMessaging.onMessage;
}
