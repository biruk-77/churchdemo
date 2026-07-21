import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:church/core/logger/app_logger.dart';

class SecurityService {
  static const MethodChannel _channel = MethodChannel(
    'com.abyssiniasoftware.church/security',
  );

  /// Enables FLAG_SECURE on Android to prevent screenshots and screen recording.
  /// On iOS this is handled natively via AppDelegate (UIScreen observation).
  static Future<void> enableSecureMode() async {
    if (kIsWeb) return;
    if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod<void>('enableSecureMode');
      } on PlatformException catch (e) {
        log.w('SecurityService', 'enableSecureMode failed', error: e);
      }
    }
  }

  static Future<void> disableSecureMode() async {
    if (kIsWeb) return;
    if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod<void>('disableSecureMode');
      } on PlatformException catch (e) {
        log.w('SecurityService', 'disableSecureMode failed', error: e);
      }
    }
  }

  /// Basic root/jailbreak indicator check via known binary paths.
  /// A full implementation requires native C/C++ checks via JNI/FFI.
  static Future<bool> isDeviceCompromised() async {
    if (kIsWeb || kDebugMode) return false;
    if (Platform.isAndroid) {
      return _checkAndroidRoot();
    } else if (Platform.isIOS) {
      return _checkiOSJailbreak();
    }
    return false;
  }

  static bool _checkAndroidRoot() {
    const rootPaths = [
      '/system/app/Superuser.apk',
      '/system/xbin/su',
      '/sbin/su',
      '/su/bin/su',
      '/system/bin/su',
      '/data/local/xbin/su',
      '/data/local/su',
      '/system/sd/xbin/su',
    ];
    for (final path in rootPaths) {
      if (File(path).existsSync()) return true;
    }
    return false;
  }

  static bool _checkiOSJailbreak() {
    const jailbreakPaths = [
      '/Applications/Cydia.app',
      '/Library/MobileSubstrate/MobileSubstrate.dylib',
      '/bin/bash',
      '/usr/sbin/sshd',
      '/etc/apt',
      '/private/var/lib/apt/',
    ];
    for (final path in jailbreakPaths) {
      if (File(path).existsSync()) return true;
    }
    return false;
  }
}
