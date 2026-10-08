import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final alerts = [
      {
        'title': 'Mirpur Bus 1 Approaching Agargaon',
        'desc': 'ETA to AUST Tejgaon is approximately 14 minutes. 12 seats remaining.',
        'time': '3 mins ago',
        'type': 'transit',
        'icon': Icons.directions_bus_rounded,
        'color': PadmaTheme.busAmber,
      },
      {
        'title': 'Emergency B+ Blood Donor Requested',
        'desc': 'Urgent patient at National Heart Foundation Mirpur. Tap to respond.',
        'time': '42 mins ago',
        'type': 'blood',
        'icon': Icons.bloodtype_rounded,
        'color': PadmaTheme.urgentRed,
      },
      {
        'title': 'Campus Transit Schedule Update',
        'desc': 'Extra evening bus service deployed on Uttara route for mid-term exams week.',
        'time': '2 hours ago',
        'type': 'info',
        'icon': Icons.campaign_rounded,
        'color': PadmaTheme.primaryTeal,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications & Alerts'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        itemCount: alerts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = alerts[index];
          final color = item['color'] as Color;

          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: PadmaTheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: PadmaTheme.borderLine),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item['icon'] as IconData, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'] as String,
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item['desc'] as String,
                        style: const TextStyle(fontSize: 12.5, color: PadmaTheme.textSecondary, height: 1.3),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item['time'] as String,
                        style: const TextStyle(fontSize: 10.5, color: PadmaTheme.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
