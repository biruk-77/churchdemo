import 'package:flutter/material.dart';
import 'package:church/app/theme.dart';
import 'package:church/l10n/app_localizations.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _stagger;
  late final List<Animation<double>> _fades;
  late final List<Animation<Offset>> _slides;

  static final _items = [
    _NotifyItem(
      title: 'Monthly Asrat Reminder (የወርሃዊ አስራት ማሳሰቢያ)',
      body: 'Blessed member, this is a reminder to pay your monthly Asrat (Tithe) contribution.',
      date: 'Today',
      icon: Icons.notifications_active_rounded,
      color: AppTheme.primaryGold,
      isUnread: true,
    ),
    _NotifyItem(
      title: 'Fasting Period Announcement (የአዋጅ ጾም ማስታወቂያ)',
      body: 'The Assumption Fast (Filseta) begins soon. Let us prepare our hearts for prayers.',
      date: '2 days ago',
      icon: Icons.church_rounded,
      color: AppTheme.primaryBlue,
      isUnread: false,
    ),
    _NotifyItem(
      title: 'Building Fund Campaign (የህንፃ መገንቢያ ማሰባሰቢያ)',
      body: 'Our church reconstruction project is underway. Your contribution is highly appreciated.',
      date: '1 week ago',
      icon: Icons.campaign_rounded,
      color: Colors.green,
      isUnread: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _stagger = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _fades = List.generate(_items.length, (i) {
      final s = i * 0.14;
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _stagger, curve: Interval(s, (s + 0.4).clamp(0, 1.0), curve: Curves.easeOut)),
      );
    });
    _slides = List.generate(_items.length, (i) {
      final s = i * 0.14;
      return Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero).animate(
        CurvedAnimation(parent: _stagger, curve: Interval(s, (s + 0.5).clamp(0, 1.0), curve: Curves.easeOutCubic)),
      );
    });
  }

  @override
  void dispose() {
    _stagger.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
      body: AnimatedBuilder(
        animation: _stagger,
        builder: (context, _) => ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: _items.length,
          itemBuilder: (context, i) => FadeTransition(
            opacity: _fades[i],
            child: SlideTransition(
              position: _slides[i],
              child: _NotificationCard(item: _items[i]),
            ),
          ),
        ),
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
  final String title, body, date;
  final IconData icon;
  final Color color;
  final bool isUnread;

  const _NotifyItem({
    required this.title,
    required this.body,
    required this.date,
    required this.icon,
    required this.color,
    required this.isUnread,
  });
}
