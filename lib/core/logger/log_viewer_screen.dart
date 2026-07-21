// lib/core/logger/log_viewer_screen.dart
//
// In-app debug log viewer — only reachable in DEBUG builds.
//
// Features:
//   • Real-time log stream from MemoryLogHandler via Riverpod
//   • Filter by level (chip row) and free-text search
//   • Color-coded rows per log level
//   • Tap a row to expand full error/stack-trace
//   • Copy a single record or export all as JSON
//   • Clear buffer button
//   • Live stats header (total / errors / warnings / fatals)

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_logger.dart';
import 'logger_provider.dart';

// ── Entry-point guard ─────────────────────────────────────────────────────────

/// Wrap calls to this route with a debug-mode guard so it is never
/// reachable in production builds.
///
/// ```dart
/// if (kDebugMode) context.push('/debug/logs');
/// ```
class LogViewerScreen extends ConsumerStatefulWidget {
  const LogViewerScreen({super.key});

  @override
  ConsumerState<LogViewerScreen> createState() => _LogViewerScreenState();
}

class _LogViewerScreenState extends ConsumerState<LogViewerScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _autoScroll  = true;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearchChanged);
    _scrollCtrl.addListener(_onScroll);
  }

  void _onSearchChanged() {
    ref.read(logFilterProvider.notifier).setSearch(_searchCtrl.text);
  }

  void _onScroll() {
    final pos = _scrollCtrl.position;
    setState(() => _autoScroll = pos.pixels >= pos.maxScrollExtent - 60);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients && _autoScroll) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // In production this screen should never appear
    assert(kDebugMode, 'LogViewerScreen must only be used in debug builds');

    final records = ref.watch(filteredLogsProvider);
    final stats   = ref.watch(logStatsProvider);
    final filter  = ref.watch(logFilterProvider);

    // Auto-scroll to bottom on new records
    ref.listen(filteredLogsProvider, (_, _) => _scrollToBottom());

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: _buildAppBar(context, stats, records),
      body: Column(
        children: [
          _buildStatsBar(stats),
          _buildFilterChips(filter),
          _buildSearchBar(),
          const Divider(height: 1, color: Color(0xFF2A2A2A)),
          Expanded(child: _buildLogList(records)),
        ],
      ),
      floatingActionButton: _autoScroll
          ? null
          : FloatingActionButton.small(
              backgroundColor: const Color(0xFF1E88E5),
              onPressed: _scrollToBottom,
              child: const Icon(Icons.arrow_downward, size: 18),
            ),
    );
  }

  // ── App bar ──────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(
      BuildContext context, LogStats stats, List<LogRecord> records) {
    return AppBar(
      backgroundColor: const Color(0xFF111111),
      foregroundColor: Colors.white,
      title: const Row(
        children: [
          Icon(Icons.bug_report_rounded, color: Color(0xFF69F0AE), size: 20),
          SizedBox(width: 8),
          Text(
            'Debug Logs',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
      actions: [
        // Copy all as JSON
        IconButton(
          tooltip: 'Copy all as JSON',
          icon: const Icon(Icons.copy_all_rounded, size: 20),
          onPressed: records.isEmpty
              ? null
              : () {
                  Clipboard.setData(
                    ClipboardData(text: AppLogger.memory.toJson()),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Logs copied to clipboard as JSON'),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
        ),
        // Clear
        IconButton(
          tooltip: 'Clear logs',
          icon: const Icon(Icons.delete_outline_rounded, size: 20),
          onPressed: records.isEmpty
              ? null
              : () => showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: const Color(0xFF1A1A1A),
                      title: const Text('Clear logs?',
                          style: TextStyle(color: Colors.white)),
                      content: const Text(
                        'This will clear the in-memory log buffer.',
                        style: TextStyle(color: Colors.white70),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            ref
                                .read(logRecordsNotifierProvider.notifier)
                                .clearAll();
                            Navigator.pop(context);
                          },
                          child: const Text('Clear',
                              style: TextStyle(color: Colors.redAccent)),
                        ),
                      ],
                    ),
                  ),
        ),
      ],
    );
  }

  // ── Stats bar ─────────────────────────────────────────────────────

  Widget _buildStatsBar(LogStats stats) {
    return Container(
      color: const Color(0xFF111111),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _statChip('Total', stats.total, Colors.white54),
          const SizedBox(width: 12),
          _statChip('Errors', stats.errors, Colors.redAccent),
          const SizedBox(width: 12),
          _statChip('Warns', stats.warnings, Colors.orange),
          const SizedBox(width: 12),
          _statChip('Fatal', stats.fatals, const Color(0xFFE040FB)),
          const Spacer(),
          Text(
            'buf ${AppLogger.memory.capacity}',
            style: const TextStyle(fontSize: 10, color: Colors.white24),
          ),
        ],
      ),
    );
  }

  Widget _statChip(String label, int count, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          '$label: $count',
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  // ── Filter chips ──────────────────────────────────────────────────

  Widget _buildFilterChips(LogFilter filter) {
    return Container(
      height: 40,
      color: const Color(0xFF111111),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        children: LogLevel.values.map((level) {
          final selected = filter.minLevel == level;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: FilterChip(
              label: Text(
                level.label,
                style: TextStyle(
                  fontSize: 10,
                  color: selected ? Colors.black : _levelColor(level),
                  fontWeight: FontWeight.w600,
                ),
              ),
              selected: selected,
              selectedColor: _levelColor(level),
              backgroundColor: const Color(0xFF1E1E1E),
              side: BorderSide(color: _levelColor(level), width: 0.8),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onSelected: (_) {
                ref.read(logFilterProvider.notifier).setLevel(level);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Search bar ────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      color: const Color(0xFF111111),
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: TextField(
        controller: _searchCtrl,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Search messages…',
          hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
          prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 18),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white38, size: 18),
                  onPressed: () {
                    _searchCtrl.clear();
                    _onSearchChanged();
                  },
                )
              : null,
          filled: true,
          fillColor: const Color(0xFF1A1A1A),
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ── Log list ──────────────────────────────────────────────────────

  Widget _buildLogList(List<LogRecord> records) {
    if (records.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined, color: Colors.white24, size: 48),
            SizedBox(height: 12),
            Text(
              'No logs match the current filter.',
              style: TextStyle(color: Colors.white38, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      controller: _scrollCtrl,
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: records.length,
      separatorBuilder: (_, _) =>
          const Divider(height: 1, color: Color(0xFF1A1A1A)),
      itemBuilder: (_, i) => _LogTile(record: records[i]),
    );
  }

  Color _levelColor(LogLevel level) {
    switch (level) {
      case LogLevel.verbose: return Colors.white38;
      case LogLevel.debug:   return const Color(0xFF69F0AE);
      case LogLevel.info:    return const Color(0xFF40C4FF);
      case LogLevel.warning: return Colors.orange;
      case LogLevel.error:   return Colors.redAccent;
      case LogLevel.fatal:   return const Color(0xFFE040FB);
    }
  }
}

// ── Individual log tile ───────────────────────────────────────────────────────

class _LogTile extends StatefulWidget {
  const _LogTile({required this.record});
  final LogRecord record;

  @override
  State<_LogTile> createState() => _LogTileState();
}

class _LogTileState extends State<_LogTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final r     = widget.record;
    final color = _levelColor(r.level);
    final hasDetail = r.error != null || r.stackTrace != null;

    return InkWell(
      onTap: hasDetail ? () => setState(() => _expanded = !_expanded) : null,
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: r.toString()));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Log record copied'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        color: _expanded ? const Color(0xFF1A1A1A) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Level indicator bar
                Container(
                  width: 3,
                  height: 14,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                // Timestamp
                Text(
                  _fmtTime(r.timestamp),
                  style: const TextStyle(
                    color: Colors.white24,
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(width: 6),
                // Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    r.tag,
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Message
                Expanded(
                  child: Text(
                    r.message,
                    style: TextStyle(
                      color: _expanded ? Colors.white : Colors.white70,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                    maxLines: _expanded ? null : 2,
                    overflow: _expanded ? null : TextOverflow.ellipsis,
                  ),
                ),
                if (hasDetail)
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white24,
                    size: 16,
                  ),
              ],
            ),
            // Expanded detail section
            if (_expanded && hasDetail) ...[
              const SizedBox(height: 6),
              if (r.error != null)
                _DetailBlock(label: 'Error', content: r.error.toString(), color: Colors.redAccent),
              if (r.stackTrace != null)
                _DetailBlock(
                  label: 'Stack',
                  content: r.stackTrace.toString(),
                  color: Colors.orange,
                  maxLines: 15,
                ),
            ],
          ],
        ),
      ),
    );
  }

  static Color _levelColor(LogLevel level) {
    switch (level) {
      case LogLevel.verbose: return Colors.white38;
      case LogLevel.debug:   return const Color(0xFF69F0AE);
      case LogLevel.info:    return const Color(0xFF40C4FF);
      case LogLevel.warning: return Colors.orange;
      case LogLevel.error:   return Colors.redAccent;
      case LogLevel.fatal:   return const Color(0xFFE040FB);
    }
  }

  static String _fmtTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}:'
      '${dt.second.toString().padLeft(2, '0')}.${dt.millisecond.toString().padLeft(3, '0')}';
}

class _DetailBlock extends StatelessWidget {
  const _DetailBlock({
    required this.label,
    required this.content,
    required this.color,
    this.maxLines,
  });

  final String label;
  final String content;
  final Color  color;
  final int?   maxLines;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 11, top: 4, bottom: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        border: Border(left: BorderSide(color: color, width: 2)),
        borderRadius: const BorderRadius.only(
          topRight:    Radius.circular(6),
          bottomRight: Radius.circular(6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 10,
              fontFamily: 'monospace',
            ),
            maxLines: maxLines,
            overflow: maxLines != null ? TextOverflow.ellipsis : null,
          ),
        ],
      ),
    );
  }
}
