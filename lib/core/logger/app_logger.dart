// lib/core/logger/app_logger.dart
//
// ╔══════════════════════════════════════════════════════════════════╗
// ║          EOTC Church App — Centralized Logger System            ║
// ╠══════════════════════════════════════════════════════════════════╣
// ║  Handlers available:                                            ║
// ║    • ConsoleLogHandler   — dart:developer (IDE / logcat)        ║
// ║    • FileLogHandler      — rolling file in app documents dir     ║
// ║    • AnalyticsLogHandler — Firebase Analytics (release only)    ║
// ║    • MemoryLogHandler    — ring-buffer (last N records)         ║
// ║                                                                  ║
// ║  Extras:                                                         ║
// ║    • DioLogInterceptor   — auto-log every HTTP request/response ║
// ║    • LogFilter           — filter by level / tag / text         ║
// ║    • JSON export helper                                         ║
// ╚══════════════════════════════════════════════════════════════════╝

import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:path_provider/path_provider.dart';

// ── Log level ─────────────────────────────────────────────────────────────────

enum LogLevel { verbose, debug, info, warning, error, fatal }

extension LogLevelX on LogLevel {
  String get label {
    switch (this) {
      case LogLevel.verbose: return 'VERBOSE';
      case LogLevel.debug:   return 'DEBUG';
      case LogLevel.info:    return 'INFO';
      case LogLevel.warning: return 'WARN';
      case LogLevel.error:   return 'ERROR';
      case LogLevel.fatal:   return 'FATAL';
    }
  }

  /// Prominent emoji — each level gets a unique, immediately recognisable icon.
  String get emoji {
    switch (this) {
      case LogLevel.verbose: return '🔎'; // magnifying glass — searching
      case LogLevel.debug:   return '🐛'; // bug — dev detail
      case LogLevel.info:    return '✅'; // green check — all good
      case LogLevel.warning: return '⚠️'; // classic warning triangle
      case LogLevel.error:   return '🔴'; // red circle — something broke
      case LogLevel.fatal:   return '💥'; // explosion — app is on fire
    }
  }

  /// Short badge shown after the emoji in terminal output.
  String get badge {
    switch (this) {
      case LogLevel.verbose: return '[VERBOSE]';
      case LogLevel.debug:   return '[DEBUG]  ';
      case LogLevel.info:    return '[INFO]   ';
      case LogLevel.warning: return '[WARN]   ';
      case LogLevel.error:   return '[ERROR]  ';
      case LogLevel.fatal:   return '[FATAL]  ';
    }
  }

  String get paddedLabel => '[${label.padRight(7)}]';

  /// Whether this level warrants a visual separator in the terminal.
  bool get isSevere => index >= LogLevel.error.index;

  int get dartLogLevel {
    switch (this) {
      case LogLevel.verbose: return 300;
      case LogLevel.debug:   return 500;
      case LogLevel.info:    return 800;
      case LogLevel.warning: return 900;
      case LogLevel.error:   return 1000;
      case LogLevel.fatal:   return 1200;
    }
  }
}

// ── Log record ────────────────────────────────────────────────────────────────

class LogRecord {
  const LogRecord({
    required this.level,
    required this.tag,
    required this.message,
    this.error,
    this.stackTrace,
    required this.timestamp,
  });

  final LogLevel    level;
  final String      tag;
  final String      message;
  final Object?     error;
  final StackTrace? stackTrace;
  final DateTime    timestamp;

  // ── Formatters ──────────────────────────────────────────────────

  /// Full terminal line — emoji + badge + tag + message + optional error/stack.
  @override
  String toString() {
    final time = _fmtTime(timestamp);
    final buf  = StringBuffer();

    // Severe levels (error / fatal) get a visual banner so they jump out
    if (level.isSevere) {
      buf.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    }

    buf.write('$time  ${level.emoji}  ${level.badge}  🏷️ $tag  ›  $message');

    if (error != null)      buf.write('\n         🔺 error   : $error');
    if (stackTrace != null) buf.write('\n         📄 stack   :\n$stackTrace');

    if (level.isSevere) {
      buf.write('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    }

    return buf.toString();
  }

  /// Compact single-line — used in the in-app log viewer list tiles.
  String toCompactString() =>
      '${_fmtTime(timestamp)}  ${level.emoji}  [$tag]  $message'
      '${error != null ? "  🔺 $error" : ""}';

  /// Machine-readable JSON — used for file export / crash dumps.
  Map<String, dynamic> toJson() => {
    'ts':      timestamp.toIso8601String(),
    'level':   level.label,
    'tag':     tag,
    'message': message,
    if (error != null)      'error': error.toString(),
    if (stackTrace != null) 'stack': stackTrace.toString(),
  };

  static String _fmtTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}:'
      '${dt.second.toString().padLeft(2, '0')}.'
      '${dt.millisecond.toString().padLeft(3, '0')}';
}

// ── Log filter ────────────────────────────────────────────────────────────────

class LogFilter {
  const LogFilter({
    this.minLevel = LogLevel.verbose,
    this.tag,
    this.messageContains,
  });

  final LogLevel minLevel;

  /// If set, only records whose tag contains this string (case-insensitive).
  final String? tag;

  /// If set, only records whose message contains this string (case-insensitive).
  final String? messageContains;

  bool accepts(LogRecord r) {
    if (r.level.index < minLevel.index) return false;
    if (tag != null && !r.tag.toLowerCase().contains(tag!.toLowerCase())) {
      return false;
    }
    if (messageContains != null &&
        !r.message.toLowerCase().contains(messageContains!.toLowerCase())) {
      return false;
    }
    return true;
  }

  LogFilter copyWith({
    LogLevel? minLevel,
    String? tag,
    String? messageContains,
  }) =>
      LogFilter(
        minLevel:        minLevel ?? this.minLevel,
        tag:             tag ?? this.tag,
        messageContains: messageContains ?? this.messageContains,
      );
}

// ── Log handler interface ─────────────────────────────────────────────────────

abstract class LogHandler {
  void handle(LogRecord record);
  Future<void> dispose() async {}
}

// ── Console handler ───────────────────────────────────────────────────────────
//
// Uses TWO outputs:
//   1. debugPrint  → shows in `flutter run` terminal WITH emojis
//   2. developer.log → feeds the IDE DevTools log tab (structured)

class ConsoleLogHandler implements LogHandler {
  const ConsoleLogHandler({this.minLevel = LogLevel.verbose});
  final LogLevel minLevel;

  @override
  void handle(LogRecord record) {
    if (record.level.index < minLevel.index) return;

    // ── 1. Emoji-rich print → visible in `flutter run` terminal ──────
    //    debugPrint is throttle-safe and supports Unicode / emojis.
    debugPrint(record.toString());

    // ── 2. Structured entry → IDE DevTools / Observatory log tab ─────
    developer.log(
      '${record.level.emoji} ${record.message}',
      time:       record.timestamp,
      level:      record.level.dartLogLevel,
      name:       '${record.level.badge} ${record.tag}',
      error:      record.error,
      stackTrace: record.stackTrace,
    );
  }

  @override
  Future<void> dispose() async {}
}

// ── File log handler (rolling, daily rotation) ───────────────────────────────

class FileLogHandler implements LogHandler {
  FileLogHandler({
    this.minLevel  = LogLevel.debug,
    this.maxSizeKB = 512,            // rotate when file exceeds 512 KB
    this.keepFiles = 5,              // keep up to 5 rotated log files
  });

  final LogLevel minLevel;
  final int maxSizeKB;
  final int keepFiles;

  IOSink?  _sink;
  File?    _currentFile;
  String?  _currentDay;  // 'yyyy-MM-dd' of the currently open file
  bool     _ready = false;

  /// Call once before the first write (needs path_provider).
  Future<void> init() async {
    if (kIsWeb) return; // No file system on web
    try {
      final dir  = await getApplicationDocumentsDirectory();
      final logs = Directory('${dir.path}/logs');
      if (!await logs.exists()) await logs.create(recursive: true);
      _logsDir = logs;
      _ready   = true;
      await _openFile();
    } catch (e) {
      debugPrint('[FileLogHandler] init failed: $e');
    }
  }

  Directory? _logsDir;

  Future<void> _openFile() async {
    final today = _today();
    if (_currentDay == today && _sink != null) return;

    await _sink?.close();
    _currentDay = today;
    _currentFile = File('${_logsDir!.path}/church_$today.log');
    _sink = _currentFile!.openWrite(mode: FileMode.append);
  }

  Future<void> _rotateIfNeeded() async {
    final f = _currentFile;
    if (f == null || !await f.exists()) return;
    final sizeKB = (await f.length()) / 1024;
    if (sizeKB < maxSizeKB) return;

    // Close current sink
    await _sink?.close();
    _sink = null;

    // Rename to timestamped archive
    final ts      = DateTime.now().millisecondsSinceEpoch;
    final archive = '${_logsDir!.path}/church_${_currentDay}_$ts.log';
    await f.rename(archive);

    // Prune old files
    final all = _logsDir!
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.log'))
        .toList()
      ..sort((a, b) => a.statSync().modified.compareTo(b.statSync().modified));
    while (all.length > keepFiles) {
      try { await all.removeAt(0).delete(); } catch (_) {}
    }

    await _openFile();
  }

  @override
  void handle(LogRecord record) {
    if (!_ready || kIsWeb) return;
    if (record.level.index < minLevel.index) return;
    _write(record);
  }

  void _write(LogRecord record) async {
    try {
      await _rotateIfNeeded();
      if (_currentDay != _today()) await _openFile();
      _sink?.writeln(record.toString());
    } catch (e) {
      debugPrint('[FileLogHandler] write error: $e');
    }
  }

  @override
  Future<void> dispose() async {
    await _sink?.flush();
    await _sink?.close();
    _sink = null;
  }

  /// Returns a list of all log files (newest first).
  Future<List<File>> getLogFiles() async {
    if (!_ready || _logsDir == null) return [];
    final files = _logsDir!
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.log'))
        .toList()
      ..sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
    return files;
  }

  /// Reads the entire content of today's log file (or empty string).
  Future<String> readToday() async {
    try {
      final f = File('${_logsDir!.path}/church_${_today()}.log');
      if (await f.exists()) return await f.readAsString();
    } catch (_) {}
    return '';
  }

  static String _today() {
    final n = DateTime.now();
    return '${n.year}-'
        '${n.month.toString().padLeft(2, '0')}-'
        '${n.day.toString().padLeft(2, '0')}';
  }
}

// ── Analytics handler (WARNING+ → Firebase Analytics) ────────────────────────

class AnalyticsLogHandler implements LogHandler {
  const AnalyticsLogHandler({this.minLevel = LogLevel.warning});
  final LogLevel minLevel;

  @override
  void handle(LogRecord record) {
    if (record.level.index < minLevel.index) return;
    try {
      FirebaseAnalytics.instance.logEvent(
        name: 'app_log',
        parameters: {
          'level':   record.level.label,
          'tag':     _truncate(record.tag, 40),
          'message': _truncate(record.message, 100),
        },
      );
    } catch (_) {
      // Never let the logger crash the app
    }
  }

  @override
  Future<void> dispose() async {}

  static String _truncate(String s, int max) =>
      s.length > max ? s.substring(0, max) : s;
}

// ── In-memory ring-buffer handler (last N records for crash reports / UI) ─────

class MemoryLogHandler implements LogHandler {
  MemoryLogHandler({this.capacity = 500});
  final int capacity;

  final List<LogRecord> _buffer = [];

  /// Unmodifiable snapshot — safe to iterate from any isolate.
  List<LogRecord> get records => List.unmodifiable(_buffer);

  /// Callback fired after every new record is added.
  void Function(LogRecord)? onRecord;

  @override
  void handle(LogRecord record) {
    if (_buffer.length >= capacity) _buffer.removeAt(0);
    _buffer.add(record);
    onRecord?.call(record);
  }

  /// Filtered view.
  List<LogRecord> where(LogFilter filter) =>
      _buffer.where(filter.accepts).toList();

  /// Export full buffer as a JSON string.
  String toJson() => jsonEncode(_buffer.map((r) => r.toJson()).toList());

  /// Human-readable dump of the full buffer.
  String dump() => _buffer.map((r) => r.toString()).join('\n');

  void clear() => _buffer.clear();

  @override
  Future<void> dispose() async => clear();
}

// ── Dio HTTP interceptor ─────────────────────────────────────────────────────

/// Attach to any [Dio] instance to get automatic request/response/error logs.
///
/// ```dart
/// _dio.interceptors.add(DioLogInterceptor());
/// ```
class DioLogInterceptor extends Interceptor {
  DioLogInterceptor({
    this.tag              = 'HTTP',
    this.logHeaders       = false,   // flip to true for deep debugging
    this.logResponseBody  = false,   // flip to true (can be verbose)
    this.logger,
  });

  final String     tag;
  final bool       logHeaders;
  final bool       logResponseBody;
  final AppLogger? logger;

  AppLogger get _log => logger ?? AppLogger.instance;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final headers = logHeaders ? '\n         📎 headers : ${options.headers}' : '';
    _log.d(tag, '📤  ${options.method.padRight(6)} › ${options.uri}$headers');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final status = response.statusCode ?? 0;
    final uri    = response.requestOptions.uri;
    final body   = logResponseBody ? '\n         📜 body    : ${response.data}' : '';
    if (status >= 400) {
      _log.w(tag, '⚠️  $status › $uri$body');
    } else {
      _log.i(tag, '📥  $status › $uri$body');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _log.e(
      tag,
      '💥  ${err.requestOptions.method} › ${err.requestOptions.uri}'
      '  —  ${err.type.name}: ${err.message}',
      error: err,
      stack: err.stackTrace,
    );
    handler.next(err);
  }
}

// ── Central AppLogger (singleton) ────────────────────────────────────────────

class AppLogger {
  AppLogger._();

  static AppLogger? _instance;
  static AppLogger get instance => _instance ??= _build();

  final List<LogHandler> _handlers = [];

  /// Shared in-memory ring-buffer.  Attach to crash reports, or observe via
  /// [LoggerProvider] in Riverpod.
  static final MemoryLogHandler memory = MemoryLogHandler();

  /// The singleton [FileLogHandler] — call [initFileLogging] once at startup.
  static final FileLogHandler file = FileLogHandler();

  static AppLogger _build() {
    final logger = AppLogger._();
    // Console: full detail in debug, warnings only in release
    logger._handlers.add(
      ConsoleLogHandler(
        minLevel: kDebugMode ? LogLevel.verbose : LogLevel.warning,
      ),
    );
    // File: written to disk (init separately — needs async path_provider)
    logger._handlers.add(file);
    // Firebase Analytics: warnings+ in release only
    if (!kDebugMode) {
      logger._handlers.add(const AnalyticsLogHandler());
    }
    // In-memory ring buffer: always on
    logger._handlers.add(memory);
    return logger;
  }

  /// Call this once during app bootstrap (after WidgetsFlutterBinding).
  static Future<void> initFileLogging() async {
    await file.init();
    instance.i('AppLogger', 'File logging initialized → ${file._logsDir?.path}');
  }

  // ── Public API ──────────────────────────────────────────────────

  void v(String tag, String message) =>
      _log(LogLevel.verbose, tag, message);

  void d(String tag, String message) =>
      _log(LogLevel.debug, tag, message);

  void i(String tag, String message) =>
      _log(LogLevel.info, tag, message);

  void w(String tag, String message, {Object? error, StackTrace? stack}) =>
      _log(LogLevel.warning, tag, message, error: error, stack: stack);

  void e(String tag, String message, {required Object error, StackTrace? stack}) =>
      _log(LogLevel.error, tag, message, error: error, stack: stack);

  void fatal(String tag, String message, {required Object error, StackTrace? stack}) =>
      _log(LogLevel.fatal, tag, message, error: error, stack: stack);

  // ── Internal ────────────────────────────────────────────────────

  void _log(LogLevel level, String tag, String message,
      {Object? error, StackTrace? stack}) {
    final record = LogRecord(
      level:      level,
      tag:        tag,
      message:    message,
      error:      error,
      stackTrace: stack,
      timestamp:  DateTime.now(),
    );
    for (final h in _handlers) {
      try { h.handle(record); } catch (_) { /* guard — handler must never crash app */ }
    }
  }

  /// Add a custom handler (e.g., remote Sentry / Crashlytics adapter).
  void addHandler(LogHandler handler) => _handlers.add(handler);

  /// Remove all handlers of a given type.
  void removeHandler<T extends LogHandler>() =>
      _handlers.removeWhere((h) => h is T);

  /// Flush & release all handlers (call on app teardown).
  Future<void> dispose() async {
    for (final h in _handlers) {
      await h.dispose();
    }
  }
}

// ── Convenience top-level shorthand ──────────────────────────────────────────

/// Global logger — use as `log.i('Tag', 'message')` from anywhere.
final AppLogger log = AppLogger.instance;
