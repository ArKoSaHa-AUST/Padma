import 'package:flutter/material.dart';
import '../../../../core/theme.dart';
import '../widgets/admin_3d_card.dart';

class AdminSchedulesTab extends StatelessWidget {
  const AdminSchedulesTab({super.key});

  final List<Map<String, dynamic>> _schedules = const [
    {
      'route': 'Mirpur Route (Padma 1)',
      'morningDeparture': '07:15 AM (Mirpur 12)',
      'afternoonDeparture': '01:45 PM (AUST Campus)',
      'eveningDeparture': '04:30 PM (AUST Campus)',
      'assignedDriver': 'Md. Rafiqul Islam',
      'busPlate': 'Dhaka Metro-Cha 11-4589',
      'stopsCount': 8,
    },
    {
      'route': 'Uttara Route (Padma 2)',
      'morningDeparture': '07:00 AM (House Building)',
      'afternoonDeparture': '01:45 PM (AUST Campus)',
      'eveningDeparture': '04:45 PM (AUST Campus)',
      'assignedDriver': 'Al-Amin Hossain',
      'busPlate': 'Dhaka Metro-Cha 11-8920',
      'stopsCount': 9,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: _schedules.length,
      itemBuilder: (context, index) {
        final sch = _schedules[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          child: Admin3dCard(
            borderColor: PadmaTheme.primaryTeal.withValues(alpha: 0.3),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(sch['route'], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: PadmaTheme.primaryTealContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${sch['stopsCount']} STOPS',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: PadmaTheme.primaryTeal),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: PadmaTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.wb_sunny_outlined, size: 14, color: PadmaTheme.busAmber),
                              SizedBox(width: 6),
                              Text('Morning Trip', style: TextStyle(fontSize: 12, color: PadmaTheme.textSecondary)),
                            ],
                          ),
                          Text(sch['morningDeparture'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: PadmaTheme.textPrimary)),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.schedule_rounded, size: 14, color: PadmaTheme.primaryTeal),
                              SizedBox(width: 6),
                              Text('Afternoon Trip', style: TextStyle(fontSize: 12, color: PadmaTheme.textSecondary)),
                            ],
                          ),
                          Text(sch['afternoonDeparture'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: PadmaTheme.textPrimary)),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.nights_stay_outlined, size: 14, color: Color(0xFF8B5CF6)),
                              SizedBox(width: 6),
                              Text('Evening Trip', style: TextStyle(fontSize: 12, color: PadmaTheme.textSecondary)),
                            ],
                          ),
                          Text(sch['eveningDeparture'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: PadmaTheme.textPrimary)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Assigned: ${sch['assignedDriver']}', style: const TextStyle(fontSize: 11, color: PadmaTheme.textMuted)),
                    TextButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Timetable editor opened for ${sch['route']}')),
                        );
                      },
                      icon: const Icon(Icons.edit_calendar_rounded, size: 14, color: PadmaTheme.primaryTeal),
                      label: const Text('Edit Timetable', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: PadmaTheme.primaryTeal)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
