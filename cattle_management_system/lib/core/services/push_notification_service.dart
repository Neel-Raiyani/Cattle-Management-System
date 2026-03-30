import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../di/injection_container.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';

// Top level function for background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  debugPrint("Handling a background message: ${message.messageId}");
}

class PushNotificationService {
  static const String _pendingFcmTokenKey = 'pending_fcm_token';
  static const String _syncedFcmTokenKey = 'synced_fcm_token';
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final PushNotificationService _instance = PushNotificationService._internal();

  factory PushNotificationService() {
    return _instance;
  }

  PushNotificationService._internal();

  Future<void> initialize() async {
    // Request permission for iOS/Web
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('User granted permission: ${settings.authorizationStatus}');

    // Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Initialize local notifications for foreground display
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await _flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
    );

    // Set up foreground message handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint(
          'Message also contained a notification: ${message.notification}',
        );
        _showLocalNotification(message);
      }
    });

    // Get FCM token
    try {
      final token = await _firebaseMessaging.getToken();
      debugPrint("FCM Token: $token");
      await _handleTokenUpdate(token);
    } catch (e) {
      debugPrint("Failed to get FCM token: $e");
    }

    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      debugPrint("FCM Token refreshed: $newToken");
      await _handleTokenUpdate(newToken);
    });
  }

  Future<void> syncTokenToBackendIfPossible() async {
    try {
      final prefs = sl<SharedPreferences>();
      final pendingToken = prefs.getString(_pendingFcmTokenKey);
      await _handleTokenUpdate(
        pendingToken?.trim().isNotEmpty == true
            ? pendingToken
            : await _firebaseMessaging.getToken(),
      );
    } catch (e) {
      debugPrint('Failed to sync FCM token: $e');
    }
  }

  Future<void> clearSyncedTokenMarker() async {
    try {
      final prefs = sl<SharedPreferences>();
      await prefs.remove(_syncedFcmTokenKey);
    } catch (e) {
      debugPrint('Failed to clear synced FCM marker: $e');
    }
  }

  Future<void> _handleTokenUpdate(String? token) async {
    final normalized = token?.trim();
    if (normalized == null || normalized.isEmpty) return;

    try {
      final prefs = sl<SharedPreferences>();
      await prefs.setString(_pendingFcmTokenKey, normalized);

      final authToken = prefs.getString('auth_token');
      if (authToken == null || authToken.isEmpty) {
        debugPrint('FCM token cached locally until login completes');
        return;
      }

      final syncedToken = prefs.getString(_syncedFcmTokenKey);
      if (syncedToken == normalized) {
        return;
      }

      await sl<AuthRemoteDataSource>().registerFcmToken(normalized);
      await prefs.setString(_syncedFcmTokenKey, normalized);
      debugPrint('FCM token registered with backend');
    } catch (e) {
      debugPrint('Failed to register FCM token with backend: $e');
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;

    if (notification != null && notification.android != null) {
      await _flutterLocalNotificationsPlugin.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    }
  }
}
