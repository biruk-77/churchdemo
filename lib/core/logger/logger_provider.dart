// lib/core/logger/logger_provider.dart
//
// Riverpod providers that expose the logger's in-memory ring-buffer
// to the rest of the UI tree.
//
// Usage:
//   final records = ref.watch(filteredLogsProvider);

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_logger.dart';

// ── Filter notifier ───────────────────────────────────────────────────────────

class LogFilterNotifier extends Notifier<LogFilter> {
  @override
  LogFilter build() => const LogFilter(minLevel: LogLevel.verbose);

  void setLevel(LogLevel level) =>
      state = state.copyWith(minLevel: level);

  void setSearch(String? text) =>
      state = state.copyWith(
        messageContains: (text == null || text.isEmpty) ? null : text,
      );

  void reset() => state = const LogFilter(minLevel: LogLevel.verbose);
}

final logFilterProvider =
    NotifierProvider<LogFilterNotifier, LogFilter>(LogFilterNotifier.new);

// ── Records notifier ──────────────────────────────────────────────────────────

/// Keeps a live snapshot of the in-memory buffer.
/// Re-builds the list every time a new record is appended.
class LogRecordsNotifier extends Notifier<List<LogRecord>> {
  @override
  List<LogRecord> build() {
    final initial = List<LogRecord>.from(AppLogger.memory.records);

    AppLogger.memory.onRecord = (_) {
      state = List<LogRecord>.from(AppLogger.memory.records);
    };

    ref.onDispose(() => AppLogger.memory.onRecord = null);

    return initial;
  }

  void clearAll() {
    AppLogger.memory.clear();
    state = [];
  }
}

final logRecordsNotifierProvider =
    NotifierProvider<LogRecordsNotifier, List<LogRecord>>(
  LogRecordsNotifier.new,
);

// ── Derived: filtered list ────────────────────────────────────────────────────

/// Filtered, reverse-chronological list of log records.
final filteredLogsProvider = Provider<List<LogRecord>>((ref) {
  final all    = ref.watch(logRecordsNotifierProvider);
  final filter = ref.watch(logFilterProvider);
  return all.reversed.where(filter.accepts).toList();
});

// ── Stats ─────────────────────────────────────────────────────────────────────

class LogStats {
  const LogStats({
    required this.total,
    required this.errors,
    required this.warnings,
    required this.fatals,
  });
  final int total;
  final int errors;
  final int warnings;
  final int fatals;
}

final logStatsProvider = Provider<LogStats>((ref) {
  final all = ref.watch(logRecordsNotifierProvider);
  return LogStats(
    total:    all.length,
    errors:   all.where((r) => r.level == LogLevel.error).length,
    warnings: all.where((r) => r.level == LogLevel.warning).length,
    fatals:   all.where((r) => r.level == LogLevel.fatal).length,
  );
});
