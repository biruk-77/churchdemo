import 'dart:async';
import 'package:flutter/material.dart' show Color;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:church/core/logger/app_logger.dart';

final notificationServiceProvider = Provider<NotificationService>(
  (_) => NotificationService(),
);

class NotificationService {
  static const String _tag = 'NotificationService';
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

    log.i(_tag, '🚀 NotificationService initialized with local & FCM channels');

    // Listen to real-time broadcasts from Web Admin via Firestore
    startBroadcastListener();

    // Show FCM foreground messages as local notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final n = message.notification;
      if (n != null) {
        log.i(_tag, '📩 FCM Foreground Message: ${n.title}');
        showBroadcastNotification(
          title: n.title ?? 'EOTC Notification',
          body: n.body ?? '',
        );
      }
    });
  }

  String? _lastHandledDocId;
  StreamSubscription? _broadcastSub;

  /// Real-time Firestore sync that converts Admin Broadcasts to native Push Notifications
  void startBroadcastListener({String? userChurchId}) {
    log.d(_tag, '📡 Subscribing to broadcast listener (churchId: ${userChurchId ?? "all"})');
    _broadcastSub?.cancel();
    _broadcastSub = _firestore
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;

        // Skip notifying if this is the initial snapshot upon app startup
        if (_lastHandledDocId == null) {
          _lastHandledDocId = doc.id;
          log.d(_tag, '📌 Initial broadcast snapshot synced (docId: ${doc.id})');
          return;
        }

        if (doc.id == _lastHandledDocId) return;
        _lastHandledDocId = doc.id;

        final data = doc.data();
        final targetType = data['targetType'];
        final targetId = data['targetId'];
        final title = data['title'] ?? '📢 EOTC Announcement';
        final body = data['body'] ?? '';

        // Check target filtering
        if (targetType == 'all' || targetType == null || (targetType == 'church' && targetId == userChurchId)) {
          log.i(_tag, '🔔 New Broadcast Announcement received: "$title" — Dispatching push notification!');
          showBroadcastNotification(title: title, body: body);
        }
      }
    }, onError: (error) {
      log.w(_tag, '⚠️ Broadcast listener error caught gracefully: $error');
    });
  }

  Future<void> showBroadcastNotification({
    required String title,
    required String body,
  }) async {
    await _local.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _highChannel.id,
          _highChannel.name,
          channelDescription: _highChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFF006A4E), // EOTC Royal Emerald
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
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
