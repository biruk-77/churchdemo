import 'package:flutter/material.dart';
import 'package:church/app/theme.dart';
import 'package:church/l10n/app_localizations.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final mockNotifications = [
      _NotifyItem(
        title: 'Monthly Asrat Reminder (የወርሃዊ አስራት ማሳሰቢያ)',
        body: 'Blessed member, this is a reminder to pay your monthly Asrat (Tithe) contribution.',
        date: 'Today',
        icon: Icons.notifications_active,
        color: AppTheme.primaryGold,
      ),
      _NotifyItem(
        title: 'Fasting Period Announcement (የአዋጅ ጾም ማስታወቂያ)',
        body: 'The Assumption Fast (Filseta) begins soon. Let us prepare our hearts for prayers.',
        date: '2 days ago',
        icon: Icons.church,
        color: AppTheme.primaryBlue,
      ),
      _NotifyItem(
        title: 'Building Fund Campaign (የህንፃ መገንቢያ ማሰባሰቢያ)',
        body: 'Our church reconstruction project is underway. Your contribution is highly appreciated.',
        date: '1 week ago',
        icon: Icons.campaign,
        color: Colors.green,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notifications),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () {},
            tooltip: l10n.markAllRead,
          ),

        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: mockNotifications.length,
        itemBuilder: (context, index) {
          final item = mockNotifications[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item.icon, color: item.color, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Text(
                              item.date,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.body,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NotifyItem {
  final String title;
  final String body;
  final String date;
  final IconData icon;
  final Color color;

  _NotifyItem({
    required this.title,
    required this.body,
    required this.date,
    required this.icon,
    required this.color,
  });
}
