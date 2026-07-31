import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:church/app/theme.dart';
import 'package:church/features/auth/presentation/providers/auth_provider.dart';
import 'package:church/l10n/app_localizations.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final userChurchId = ref.watch(authStateProvider).user?.churchId;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notifications),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded),
            onPressed: () {},
            tooltip: l10n.markAllRead,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_clock_rounded, size: 64, color: Colors.orange),
                    SizedBox(height: 16),
                    Text(
                      'ስርጭት በመጀመር ላይ',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'ቀጥታ ማሳወቂያዎች በሀገረ ስብከትዎ ወይም በደብር አስተዳዳሪዎ ሲረጋገጡ ይገናኛሉ።',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          List<_NotifyItem> items = [];

          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            for (final doc in snapshot.data!.docs) {
              final data = doc.data();
              final targetType = data['targetType'];
              final targetId = data['targetId'];

              // Filter notifications for all or matching church
              if (targetType == 'all' || (targetType == 'church' && targetId == userChurchId)) {
                final ts = (data['createdAt'] as Timestamp?)?.toDate();
                final timeStr = ts != null
                    ? '${ts.day}/${ts.month} ${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}'
                    : 'አሁን';

                items.add(_NotifyItem(
                  id: doc.id,
                  title: data['title'] ?? '📢 ማስታወቂያ',
                  body: data['body'] ?? '',
                  date: timeStr,
                  icon: Icons.campaign_rounded,
                  color: AppTheme.royalEmerald,
                  isUnread: true,
                ));
              }
            }
          }

          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_none_rounded, size: 64, color: AppTheme.imperialGold),
                    SizedBox(height: 16),
                    Text(
                      'ምንም የስርጭት ማስታወቂያ የለም',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'ከሀገረ ስብከትዎ ወይም ከደብር አስተዳዳሪዎ የተላኩ የስርጭት ማሳወቂያዎች እዚህ ወዲያውኑ ይታያሉ።',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: items.length,
            itemBuilder: (context, i) => _NotificationCard(item: items[i]),
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatefulWidget {
  final _NotifyItem item;
  const _NotificationCard({required this.item});

  @override
  State<_NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<_NotificationCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _dotScale;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _dotScale = Tween<double>(begin: 0.7, end: 1.3).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: item.isUnread
              ? item.color.withValues(alpha: 0.35)
              : Colors.black.withValues(alpha: 0.06),
          width: item.isUnread ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: item.isUnread
                ? item.color.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Animated icon container
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.icon, color: item.color, size: 22),
                ),
                // Unread pulsing dot
                if (item.isUnread)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: ScaleTransition(
                      scale: _dotScale,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: item.color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: item.color.withValues(alpha: 0.5),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontWeight: item.isUnread ? FontWeight.bold : FontWeight.w600,
                            fontSize: 14,
                            color: item.isUnread ? Colors.black87 : Colors.black54,
                          ),
                        ),
                      ),
                      Text(
                        item.date,
                        style: TextStyle(
                          fontSize: 11,
                          color: item.isUnread ? item.color : Colors.black38,
                          fontWeight: item.isUnread ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.body,
                    style: const TextStyle(fontSize: 13, color: Colors.black54, height: 1.45),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotifyItem {
  final String? id;
  final String title, body, date;
  final IconData icon;
  final Color color;
  final bool isUnread;

  const _NotifyItem({
    this.id,
    required this.title,
    required this.body,
    required this.date,
    required this.icon,
    required this.color,
    required this.isUnread,
  });
}
