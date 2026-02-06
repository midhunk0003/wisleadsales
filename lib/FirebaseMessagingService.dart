import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final NotificationService _notificationService = NotificationService();

  // Future<void> regenerateAndSaveFcmTokenWhenLogin() async {
  //   final token = await FirebaseMessaging.instance.getToken();
  //   if (token != null) {
  //     final prefs = await SharedPreferences.getInstance();
  //     await prefs.setString('fcm_token', token);
  //     print('FCM Token Regenerated: $token');
  //   } else {
  //     print('Failed to regenerate FCM token');
  //   }
  // }

  Future<void> initialize() async {
    await _requestPermission();
    await _getToken();
    _setupMessageHandlers();
    await _notificationService.initialize();
  }

  Future<void> _requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');
  }

  Future<void> _getToken() async {
    // STEP 1: Check if token already exists locally
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? storedToken = pref.getString("fcm_token");

    if (storedToken == null) {
      // STEP 2: Generate token ONLY if not saved earlier
      String? newToken = await _firebaseMessaging.getToken();
      print("Generated New FCM Token: $newToken");

      if (newToken != null) {
        await pref.setString("fcm_token", newToken);
      }
    } else {
      print("Existing FCM Token Found: $storedToken");
    }

    // String? token = await _firebaseMessaging.getToken();
    // print('FCM Token XXXXXXXXXXXX: $token');

    // if (token != null) {
    //   await _saveTokenToPrefs(token);
    // }
  }

  // Save FCM token to SharedPreferences
  Future<void> _saveTokenToPrefs(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);
    print('Token saved to SharedPreferences 000000000000000 : ${token}');
    getTokenFromPrefs();
  }

  // Retrieve FCM token from SharedPreferences
  Future<String?> getTokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(
      'Token retrieved from SharedPreferencespppppppppppppppppp : ${prefs.getString('fcm_token')}',
    );
    return prefs.getString('fcm_token');
  }

  void _setupMessageHandlers() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        _showLocalNotification(message.notification!);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      _showLocalNotification(message.notification!);
    });
  }

  void _showLocalNotification(RemoteNotification notification) {
    _notificationService.showNotification(
      0, // Notification ID
      notification.title ?? 'No Title',
      notification.body ?? 'No Body',
      null, // Optional payload
    );
  }
}
