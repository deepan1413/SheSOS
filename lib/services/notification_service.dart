import 'package:firebase_messaging/firebase_messaging.dart';


class NotificationService {
static final _fm = FirebaseMessaging.instance;


static Future<void> initialize() async {
await _fm.requestPermission();
await _fm.subscribeToTopic('volunteers');
FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}


static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
// Handle background notifications
}


Future<void> sendTopic(String topic, Map<String, dynamic> payload) async {
// Placeholder: send FCM via backend (Cloud Function / server)
throw UnimplementedError('sendTopic requires a backend function');
}
}