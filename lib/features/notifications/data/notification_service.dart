import 'package:flutter/material.dart' show Color;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationServiceProvider = Provider<NotificationService>(
  (_) => NotificationService(),
);

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();

  static const _highChannel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'Important church notifications.',
    importance: Importance.high,
  );

  static const _otpChannel = AndroidNotificationChannel(
    'otp_channel',
    'Verification Codes',
    description: 'One-time password codes for sign-in.',
    importance: Importance.max,
    playSound: true,
  );

  Future<void> init() async {
    // iOS / FCM permission
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // Android 13+ notification permission + channel setup
    final androidPlugin = _local
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
      await androidPlugin.createNotificationChannel(_highChannel);
      await androidPlugin.createNotificationChannel(_otpChannel);
    }

    // v22 named-params initialize
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _local.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (_) {},
    );

    // Show FCM foreground messages as local notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final n = message.notification;
      if (n != null) {
        _local.show(
          id: n.hashCode,
          title: n.title,
          body: n.body,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              _highChannel.id,
              _highChannel.name,
              channelDescription: _highChannel.description,
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
            iOS: const DarwinNotificationDetails(),
          ),
        );
      }
    });
  }

  /// Fires in RELEASE mode after Firebase successfully sends the SMS.
  /// Does NOT reveal the code — just tells the user to check their messages.
  Future<void> showCodeSentConfirmation({required String phone}) async {
    await _local.show(
      id: 9001,
      title: '📱 Verification Code Sent',
      body: 'A 6-digit code was sent to $phone via SMS.',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _otpChannel.id,
          _otpChannel.name,
          channelDescription: _otpChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          styleInformation: BigTextStyleInformation(
            'Open your SMS messages to find the 6-digit code sent to $phone.\n\nThe code expires in a few minutes.',
          ),
          autoCancel: true,
          color: const Color(0xFF1A237E), // Orthodox blue
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: false,
        ),
      ),
    );
  }

  /// Sends a local push notification showing the OTP code.
  /// Used in debug / development to simulate a real SMS.
  Future<void> showOtpNotification({
    required String phone,
    required String code,
  }) async {
    await _local.show(
      id: 9000, // fixed ID — replaces any previous OTP notification
      title: '🔐 EOTC Verification Code',
      body: 'Code for $phone: $code',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _otpChannel.id,
          _otpChannel.name,
          channelDescription: _otpChannel.description,
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/ic_launcher',
          styleInformation: BigTextStyleInformation(
            'Your EOTC sign-in code is:\n\n$code\n\nValid for 5 minutes. Do not share.',
            summaryText: 'Tap to view code',
          ),
          autoCancel: false,
          color: const Color(0xFFC9A227), // Ethiopian gold accent
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: true,
          subtitle: 'EOTC sign-in',
        ),
      ),
    );
  }

  /// Dismiss the OTP notification after the user enters the code.
  Future<void> dismissOtpNotification() async {
    await _local.cancel(id: 9000);
  }

  Future<void> subscribeToChurchTopic(String churchId) async {
    try {
      await _fcm.subscribeToTopic('church_$churchId');
    } catch (_) {}
  }

  Future<void> unsubscribeFromChurchTopic(String churchId) async {
    try {
      await _fcm.unsubscribeFromTopic('church_$churchId');
    } catch (_) {}
  }
}
