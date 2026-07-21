import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:church/firebase_options.dart';
import 'package:church/app/app.dart';
import 'package:church/core/logger/app_logger.dart';
import 'package:church/features/notifications/data/notification_service.dart';

void main() {
  // Catch all unhandled Flutter + async errors through the logger
  runZonedGuarded(_bootstrap, (error, stack) {
    log.fatal('main', 'Unhandled zone error', error: error, stack: stack);
  });
}

Future<void> _bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise file-based logging (writes to app documents/logs/)
  await AppLogger.initFileLogging();

  // Catch synchronous Flutter framework errors
  FlutterError.onError = (details) {
    log.fatal('FlutterError', details.exceptionAsString(),
        error: details.exception, stack: details.stack);
    FlutterError.presentError(details);
  };

  log.i('main', 'App starting — initializing Firebase...');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  log.i('main', 'Firebase initialized');

  await NotificationService().init();
  log.i('main', 'Notifications ready');

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  log.i('main', 'Launching app UI');
  runApp(const ProviderScope(child: MyApp()));
}
