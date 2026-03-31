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
    print('User granted permission: ${settings.authorizationStatus}');

    String? token;

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
      print("Notification opened from background!");
      print("Title: ${message.notification?.title}");
      print("Body: ${message.notification?.body}");
    });

    // app is in terminated state
    RemoteMessage? initialMessage = await FirebaseMessaging.instance
        .getInitialMessage();
    if (initialMessage != null) {
      print("App opened from terminated state!");
      print("Title: ${initialMessage.notification?.title}");
      print("Body: ${initialMessage.notification?.body}");
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
