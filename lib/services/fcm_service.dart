import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Handle background messages
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
}

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    try {
      // Request permission for iOS
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted permission');
      }

      // Initialize local notifications
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          // Handle notification tap
          print('Notification tapped: ${response.payload}');
        },
      );

      // Create notification channel for Android
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'pickup_reminders', // id
        'Pickup Reminders', // name
        description: 'Notifications for garbage pickup schedules',
        importance: Importance.high,
        playSound: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');

        if (message.notification != null) {
          _showLocalNotification(
            message.notification!.title ?? 'BinSync',
            message.notification!.body ?? '',
            message.data,
          );
        }
      });

      // Handle background message handler
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      // Get FCM token and save to Firestore (don't await, do it in background)
      _fcm.getToken().then((token) {
        if (token != null) {
          _saveFCMToken(token);
        }
      }).catchError((error) {
        print('Error getting FCM token: $error');
      });

      // Listen for token refresh
      _fcm.onTokenRefresh.listen(_saveFCMToken);
    } catch (e) {
      print('Error initializing FCM: $e');
      // Don't throw - allow app to continue even if FCM fails
    }
  }

  Future<void> _showLocalNotification(
    String title,
    String body,
    Map<String, dynamic> data,
  ) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'pickup_reminders',
      'Pickup Reminders',
      channelDescription: 'Notifications for garbage pickup schedules',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: data.toString(),
    );
  }

  Future<void> _saveFCMToken(String token) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'fcmToken': token,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        print('FCM token saved successfully');
      } else {
        print('User not logged in, FCM token not saved');
      }
    } catch (e) {
      print('Error saving FCM token: $e');
      // Don't throw - token can be saved later when user logs in
    }
  }

  // Public method to save FCM token for current user (called after login)
  Future<void> saveFCMTokenForCurrentUser() async {
    try {
      String? token = await _fcm.getToken();
      if (token != null) {
        await _saveFCMToken(token);
      }
    } catch (e) {
      print('Error saving FCM token for current user: $e');
    }
  }

  Future<void> scheduleLocalNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    // For local scheduled notifications (requires timezone package)
    // This is a placeholder - you'll need to implement with timezone
    print('Schedule notification for: $scheduledTime');
  }

  Future<void> showImmediateNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    await _showLocalNotification(title, body, data ?? {});

    // Also create in Firestore for in-app notifications
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': user.uid,
        'title': title,
        'message': body,
        'type': data?['type'] ?? 'general',
        'read': false,
        'timestamp': FieldValue.serverTimestamp(),
        'data': data,
      });
    }
  }
}
