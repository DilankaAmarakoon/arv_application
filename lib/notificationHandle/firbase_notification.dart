import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:staff_mangement/providers/notification_state_provider.dart';

class NotificationServices {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future<void> initializing(
    NotificationStateProvider notificationProvider,
  ) async {
    NotificationSettings settings = await messaging.requestPermission();
    FirebaseAnalytics analytics = FirebaseAnalytics.instance;

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await messaging.getToken();
      if (token != null) debugPrint("FCM Token: $token");

      FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        analytics.logEvent(name: 'notification_received');
        // print("onMessage: ${message.notification?.title}");
        notificationProvider.incrementNotificationCount();
      });

      FirebaseMessaging.onMessageOpenedApp.listen((
        RemoteMessage message,
      ) async {
        analytics.logEvent(name: 'notification_opened');
        // print("onbbbbbbbbb: ${message.notification?.title}");
        notificationProvider.incrementNotificationCount();
      });
      // FirebaseMessaging.onBackgroundMessage((RemoteMessage message) async {
      //   analytics.logEvent(name: 'notification_opened');
      //   // print("oncccccccc: ${message.notification?.title}");
      //   await incrementCount(context);
      // });

      RemoteMessage? initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        // print("onvvvvvvvvvvvvv: ${initialMessage.notification?.title}");
        analytics.logEvent(name: 'notification_opened_from_terminated');
        notificationProvider.incrementNotificationCount();
      }
    }
  }
}
