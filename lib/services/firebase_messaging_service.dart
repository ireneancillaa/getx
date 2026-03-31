import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FirebaseMessagingService {
  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._internal();

  factory FirebaseMessagingService() {
    return _instance;
  }

  FirebaseMessagingService._internal();

  Future<void> initializeFirebaseMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // request notification permission
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('User granted permission: ${settings.authorizationStatus}');

    // foreground message handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // show dialog for foreground notifications
      if (message.notification != null &&
          (message.notification!.title != null ||
              message.notification!.body != null)) {
        _showNotificationDialog(
          message.notification?.title ?? 'No title',
          message.notification?.body ?? 'No body',
        );
      }
    });

    // app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("Notification opened from background!");
      debugPrint("Title: ${message.notification?.title}");
      debugPrint("Body: ${message.notification?.body}");
    });

    // app is in terminated state
    RemoteMessage? initialMessage = await FirebaseMessaging.instance
        .getInitialMessage();
    if (initialMessage != null) {
      debugPrint("App opened from terminated state!");
      debugPrint("Title: ${initialMessage.notification?.title}");
      debugPrint("Body: ${initialMessage.notification?.body}");
    }
  }

  void _showNotificationDialog(String title, String body) {
    Get.snackbar(
      title,
      body,
      duration: const Duration(seconds: 3),
      animationDuration: const Duration(milliseconds: 500),
      borderRadius: 12,
      backgroundColor: Colors.transparent,
      colorText: Colors.black,
      icon: const Icon(Icons.notifications, color: Colors.black),
    );
  }
}
