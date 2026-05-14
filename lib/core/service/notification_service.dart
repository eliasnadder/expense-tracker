import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static const _channelId = 'budget_alerts';
  static const _channelName = 'Budget Alerts';

  Future<void> initialize() async {
    // ── Local Notifications Setup ──
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _localNotifications.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
    );

    // Android Channel
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      importance: Importance.high,
    );

    final androidImpl = await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidImpl?.createNotificationChannel(channel);

    // ── FCM Setup ──
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    // Foreground FCM messages
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification != null) {
        showLocalNotification(
          title: notification.title ?? '',
          body: notification.body ?? '',
        );
      }
    });
  }

  Future<String?> getFCMToken() async {
    return await _messaging.getToken();
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
    int id = 0,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
      payload: null,
    );
  }

  Future<void> showBudgetWarning({required bool isAr}) async {
    await showLocalNotification(
      id: 1,
      title: isAr ? '⚠️ تحذير الميزانية' : '⚠️ Budget Warning',
      body: isAr
          ? 'لقد تجاوزت 80% من ميزانيتك الشهرية!'
          : 'You have used over 80% of your monthly budget!',
    );
  }

  Future<void> showBudgetExceeded({required bool isAr}) async {
    await showLocalNotification(
      id: 2,
      title: isAr ? '🚨 تجاوزت الميزانية!' : '🚨 Budget Exceeded!',
      body: isAr
          ? 'لقد تجاوزت ميزانيتك الشهرية. حاول التحكم في مصاريفك.'
          : 'You have exceeded your monthly budget. Try to control your spending.',
    );
  }
}
