import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:firebase_core/firebase_core.dart';
import '../constants/app_constants.dart';

// Background message handler must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Need to initialize Firebase for background handlers
  await Firebase.initializeApp();
  print('Handling background message: ${message.messageId}');
}

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  Future<void> initialize() async {
    try {
      // Request permission for notifications
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      
      print('User granted permission: ${settings.authorizationStatus}');

      // Get FCM token only on real devices
      if (!kIsWeb && !defaultTargetPlatform.toString().toLowerCase().contains('macos')) {
        try {
          String? token = await _messaging.getToken();
          if (token != null) {
            print('FCM Token: $token');
          } else {
            print('Unable to get FCM token');
          }
        } catch (e) {
          print('Error getting FCM token (this is normal in simulator): $e');
        }
      }

      // Set up background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Create notification channel for Android
      if (defaultTargetPlatform == TargetPlatform.android) {
        const AndroidNotificationChannel channel = AndroidNotificationChannel(
          'high_importance_channel',
          'High Importance Notifications',
          description: 'This channel is used for important notifications.',
          importance: Importance.high,
        );

        // Initialize local notifications plugin for Android
        await _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
      }

      // Initialize local notifications
      const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          print('Notification clicked: ${response.payload}');
        },
      );

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Received foreground message: ${message.messageId}');
        _handleForegroundMessage(message);
      });

      // Handle when the app is opened from a notification
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('App opened from notification: ${message.messageId}');
      });

      print('Notification service initialized successfully');

    } catch (e) {
      print('Error initializing notifications: $e');
      // Continue anyway as local notifications should still work
    }
  }

  Future<void> scheduleBedtimeNotification(TimeOfDay bedtime) async {
    try {
      final now = DateTime.now();
      var scheduledTime = DateTime(
        now.year,
        now.month,
        now.day,
        bedtime.hour,
        bedtime.minute,
      );

      // If the time has already passed today, schedule for tomorrow
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      final tzDateTime = tz.TZDateTime.from(scheduledTime, tz.local);

      await _localNotifications.zonedSchedule(
        1, // ID for bedtime notification
        'Bedtime Reminder',
        'Time to wind down and prepare for sleep 🌙',
        tzDateTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'bedtime_channel',
            'Bedtime Reminders',
            channelDescription: 'Notifications for bedtime reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      print('Scheduled bedtime notification for: ${tzDateTime.toString()}');
    } catch (e) {
      print('Error scheduling bedtime notification: $e');
    }
  }

  Future<void> scheduleDailyMeditationReminder() async {
    try {
      final now = DateTime.now();
      var scheduledTime = DateTime(
        now.year,
        now.month,
        now.day,
        12, // 12 PM (noon)
        0,
      );

      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      final tzDateTime = tz.TZDateTime.from(scheduledTime, tz.local);

      await _localNotifications.zonedSchedule(
        2, // ID for meditation reminder
        'Meditation Time 🧘‍♂️',
        'Take a peaceful break and find your inner calm',
        tzDateTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'meditation_channel',
            'Meditation Reminders',
            channelDescription: 'Daily meditation reminder notifications',
            importance: Importance.high,
            priority: Priority.high,
            enableLights: true,
            color: Colors.purple,
            largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
            styleInformation: BigTextStyleInformation(
              'Take a moment to meditate and find your inner peace. A few minutes of mindfulness can transform your entire day.',
              contentTitle: 'Meditation Time 🧘‍♂️',
              summaryText: 'Daily Meditation Reminder',
            ),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: 'meditation_bell.wav',
            subtitle: 'Daily Meditation Reminder',
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // This makes it repeat daily
      );
      print('Scheduled daily meditation reminder for: ${tzDateTime.toString()}');
    } catch (e) {
      print('Error scheduling meditation reminder: $e');
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Handling foreground message: ${message.messageId}');
    
    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'New Message',
      message.notification?.body ?? '',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'default_channel',
          'Default Notifications',
          channelDescription: 'Default notification channel',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }
} 