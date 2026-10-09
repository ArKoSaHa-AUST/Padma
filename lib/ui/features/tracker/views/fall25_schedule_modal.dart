import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../admin/view_models/admin_view_model.dart';
import '../../auth/view_models/auth_view_model.dart';

class Fall25ScheduleModal extends StatelessWidget {
  const Fall25ScheduleModal({super.key});

  static const List<Map<String, String>> scheduleRows = [
    {
      'stopBn': 'মিরপুর ১২ (বিআরটি পাম্প)',
      'stopEn': 'Mirpur 12 (BRT Pump)',
      'time1Bn': '৬.৪৫',
      'time1En': '06:45 AM',
      'time2Bn': '৮.৩০',
      'time2En': '08:30 AM',
    },
    {
      'stopBn': 'মিরপুর ১১.৫ (রংধনু শপিং সেন্টার)',
      'stopEn': 'Mirpur 11.5 (Rongdhonu)',
      'time1Bn': '৬.৪৮',
      'time1En': '06:48 AM',
      'time2Bn': '৮.৩৩',
      'time2En': '08:33 AM',
    },
    {
      'stopBn': 'পুরবী (বনলতা)',
      'stopEn': 'Purobi (Bonolota)',
      'time1Bn': '৬.৫০',
      'time1En': '06:50 AM',
      'time2Bn': '৮.৩৬',
      'time2En': '08:36 AM',
    },
    {
      'stopBn': 'মিরপুর ১১ (ইস্টার্ন ব্যাংক)',
      'stopEn': 'Mirpur 11 (Eastern Bank)',
      'time1Bn': '৬.৫৩',
      'time1En': '06:53 AM',
      'time2Bn': '৮.৩৯',
      'time2En': '08:39 AM',
    },
    {
      'stopBn': 'মিরপুর বাংলা স্কুল',
      'stopEn': 'Mirpur Bangla School',
      'time1Bn': '৬.৫৫',
      'time1En': '06:55 AM',
      'time2Bn': '৮.৪২',
      'time2En': '08:42 AM',
    },
    {
      'stopBn': 'মিরপুর অরিজিনাল ১০ (পপুলারের বিপরীতে)',
      'stopEn': 'Mirpur Original 10 (Opp. Popular)',
      'time1Bn': '৬.৫৭',
      'time1En': '06:57 AM',
      'time2Bn': '৮.৪৪',
      'time2En': '08:44 AM',
    },
    {
      'stopBn': 'মিরপুর ১০ (ফলপট্টির বিপরীতে)',
      'stopEn': 'Mirpur 10 (Opp. Folpotti)',
      'time1Bn': '৭.০৫',
      'time1En': '07:05 AM',
      'time2Bn': '৮.৫৮',
      'time2En': '08:58 AM',
    },
    {
      'stopBn': 'সেনপাড়া (আল হেলাল হাসপাতালের সামনে)',
      'stopEn': 'Senpara (Al Helal Hospital)',
      'time1Bn': '৭.০৮',
      'time1En': '07:08 AM',
      'time2Bn': '৯.০১',
      'time2En': '09:01 AM',
    },
    {
      'stopBn': 'কাজীপাডা (স্বপ্নের সামনে)',
      'stopEn': 'Kazipara (Shwapno)',
      'time1Bn': '৭.১১',
      'time1En': '07:11 AM',
      'time2Bn': '৯.০৪',
      'time2En': '09:04 AM',
    },
    {
      'stopBn': 'মনিপুর স্কুল',
      'stopEn': 'Monipur School',
      'time1Bn': '৭.১৫',
      'time1En': '07:15 AM',
      'time2Bn': '৯.০৭',
      'time2En': '09:07 AM',
    },
    {
      'stopBn': 'শেওড়াপাড়া (ডি এস এস এর বিপরীতে)',
      'stopEn': 'Shewrapara (Opp. DSS)',
      'time1Bn': '৭.২৩',
      'time1En': '07:23 AM',
      'time2Bn': '৯.১৫',
      'time2En': '09:15 AM',
    },
    {
      'stopBn': 'তালতলা (ডাম্পিং স্টেশনের পাশে)',
      'stopEn': 'Taltola (Dumping Station)',
      'time1Bn': '৭.২৫',
      'time1En': '07:25 AM',
      'time2Bn': '৯.২০',
      'time2En': '09:20 AM',
    },
    {
      'stopBn': 'আগারগাঁও (আইডিবি ভবনের বিপরীত পাশে)',
      'stopEn': 'Agargaon (Opp. IDB Bhaban)',
      'time1Bn': '৭.২৮',
      'time1En': '07:28 AM',
      'time2Bn': '৯.২৪',
      'time2En': '09:24 AM',
    },
    {
      'stopBn': 'ভার্সিটি (আহছানউল্লা ক্যাম্পাস)',
      'stopEn': 'Varsity (AUST Campus)',
      'time1Bn': '৭.৪৫',
      'time1En': '07:45 AM',
      'time2Bn': '৯.৪৫',
      'time2En': '09:45 AM',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final adminVM = context.watch<AdminViewModel>();
    final authVM = context.watch<AuthViewModel>();
    final isAdmin = authVM.isAdmin || authVM.currentUser?.email.contains('admin') == true;

    final firstBusLabel = adminVM.firstBusId == 'bus_1' ? 'Padma 1 (পদ্মা ১)' : 'Padma 2 (পদ্মা ২)';
    final secondBusLabel = adminVM.firstBusId == 'bus_1' ? 'Padma 2 (পদ্মা ২)' : 'Padma 1 (পদ্মা ১)';

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: const BoxDecoration(
        color: PadmaTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: PadmaTheme.borderLine,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF991B1B).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.5)),
                  ),
                  child: const Icon(Icons.directions_bus_rounded, color: Color(0xFFEF4444), size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PADMA FALL 25 BUS SCHEDULE',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: PadmaTheme.textPrimary, letterSpacing: 0.3),
                      ),
                      Text(
                        'পদ্মা ফল ২৫ বাস সময়সূচী (মিরপুর ১২ ➔ ভার্সিটি)',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: PadmaTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: PadmaTheme.textMuted),
                ),
              ],
            ),
          ),
          const Divider(height: 16),

          // Scrollable Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              children: [
                // 1. Dynamic Admin 1st Bus Confirmation Banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        PadmaTheme.primaryTeal.withValues(alpha: 0.15),
                        PadmaTheme.busAmber.withValues(alpha: 0.12),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: PadmaTheme.primaryTeal.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: PadmaTheme.primaryTeal,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'ADMIN CONFIRMED',
                              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: PadmaTheme.onPrimary),
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.verified_rounded, size: 16, color: PadmaTheme.primaryTeal),
                        ],
                      ),
                      const SizedBox(height: 8),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 12.5, color: PadmaTheme.textPrimary, height: 1.4),
                          children: [
                            const TextSpan(text: 'Today\'s 1st Bus: ', style: TextStyle(fontWeight: FontWeight.w500)),
                            TextSpan(
                              text: '$firstBusLabel (Departure: 06:45 AM / ৬.৪৫)\n',
                              style: const TextStyle(fontWeight: FontWeight.w800, color: PadmaTheme.primaryTeal),
                            ),
                            const TextSpan(text: 'Today\'s 2nd Bus: ', style: TextStyle(fontWeight: FontWeight.w500)),
                            TextSpan(
                              text: '$secondBusLabel (Departure: 08:30 AM / ৮.৩০)',
                              style: const TextStyle(fontWeight: FontWeight.w800, color: PadmaTheme.busAmber),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. If Admin, show interactive Switcher Controls
                if (isAdmin) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: PadmaTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: PadmaTheme.borderLine),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.admin_panel_settings_rounded, size: 16, color: PadmaTheme.busAmber),
                            SizedBox(width: 6),
                            Text(
                              'Admin Control: Confirm Daily 1st Bus Assignment',
                              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: PadmaTheme.busAmber),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  adminVM.setFirstBus('bus_1');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('✅ Padma 1 confirmed as 1st Bus (06:45 AM) and broadcasted.'),
                                      backgroundColor: PadmaTheme.primaryTeal,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: adminVM.firstBusId == 'bus_1'
                                      ? PadmaTheme.primaryTeal.withValues(alpha: 0.2)
                                      : Colors.transparent,
                                  side: BorderSide(
                                    color: adminVM.firstBusId == 'bus_1' ? PadmaTheme.primaryTeal : PadmaTheme.borderLine,
                                    width: adminVM.firstBusId == 'bus_1' ? 1.5 : 1,
                                  ),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                ),
                                child: Text(
                                  'Padma 1 as 1st Bus',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: adminVM.firstBusId == 'bus_1' ? PadmaTheme.primaryTeal : PadmaTheme.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  adminVM.setFirstBus('bus_2');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('✅ Padma 2 confirmed as 1st Bus (06:45 AM) and broadcasted.'),
                                      backgroundColor: PadmaTheme.busAmber,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: adminVM.firstBusId == 'bus_2'
                                      ? PadmaTheme.busAmber.withValues(alpha: 0.2)
                                      : Colors.transparent,
                                  side: BorderSide(
                                    color: adminVM.firstBusId == 'bus_2' ? PadmaTheme.busAmber : PadmaTheme.borderLine,
                                    width: adminVM.firstBusId == 'bus_2' ? 1.5 : 1,
                                  ),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                ),
                                child: Text(
                                  'Padma 2 as 1st Bus',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: adminVM.firstBusId == 'bus_2' ? PadmaTheme.busAmber : PadmaTheme.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 14),

                // 3. Official Timetable Grid
                Container(
                  decoration: BoxDecoration(
                    color: PadmaTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF7F1D1D).withValues(alpha: 0.6)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      // Table Sub-header (Buses)
                      Container(
                        color: const Color(0xFF450A0A),
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                '(পদ্মা ১ম বাস)\n${adminVM.firstBusName}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFFECACA), height: 1.2),
                              ),
                            ),
                            const Expanded(
                              flex: 5,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.directions_bus, color: Colors.white, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    'FALL 25',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                '(পদ্মা ২য় বাস)\n${adminVM.secondBusName}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFFECACA), height: 1.2),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Column Headers (TIME | STOPPAGE | TIME)
                      Container(
                        color: const Color(0xFF991B1B),
                        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                        child: const Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                'TIME',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: Colors.white),
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Text(
                                'STOPPAGE (স্টপেজ)',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: Colors.white),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                'TIME',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Rows
                      ...scheduleRows.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final row = entry.value;
                        final isEven = idx % 2 == 0;
                        final isLast = idx == scheduleRows.length - 1;

                        return Container(
                          color: isEven ? PadmaTheme.surface : PadmaTheme.surfaceElevated,
                          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: isLast ? Colors.transparent : const Color(0xFF7F1D1D).withValues(alpha: 0.3),
                                width: 0.8,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              // 1st Bus Time
                              Expanded(
                                flex: 3,
                                child: Column(
                                  children: [
                                    Text(
                                      row['time1Bn']!,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: PadmaTheme.primaryTeal),
                                    ),
                                    Text(
                                      row['time1En']!,
                                      style: const TextStyle(fontSize: 9, color: PadmaTheme.textMuted),
                                    ),
                                  ],
                                ),
                              ),

                              // Stoppage Name
                              Expanded(
                                flex: 5,
                                child: Column(
                                  children: [
                                    Text(
                                      row['stopBn']!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary),
                                    ),
                                    Text(
                                      row['stopEn']!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 9, color: PadmaTheme.textSecondary),
                                    ),
                                  ],
                                ),
                              ),

                              // 2nd Bus Time
                              Expanded(
                                flex: 3,
                                child: Column(
                                  children: [
                                    Text(
                                      row['time2Bn']!,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: PadmaTheme.busAmber),
                                    ),
                                    Text(
                                      row['time2En']!,
                                      style: const TextStyle(fontSize: 9, color: PadmaTheme.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // 4. Return Trips Card (ফিরতি বাস)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7F1D1D).withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.5)),
                  ),
                  child: const Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.replay_rounded, size: 16, color: Color(0xFFFCA5A5)),
                          SizedBox(width: 6),
                          Text(
                            'ফিরতি বাস (Return Trips)',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFFFECACA)),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        'দুপুর ৩.৪৫ (03:45 PM) & সন্ধ্যা ৬.১৫ (06:15 PM)',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // 5. Stoppage arrival advisory notice
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: PadmaTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: PadmaTheme.borderLine),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded, size: 16, color: PadmaTheme.busAmber),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'বিঃদ্রঃ- স্টপেজে উল্লেখিত নির্ধারিত সময়ের ১০ মিনিট পূর্বে স্টপেজে দাঁড়ানোর জন্য অনুরোধ করা হলো।\n(Please arrive at the stoppage at least 10 minutes before the scheduled time.)',
                          style: TextStyle(fontSize: 11, color: PadmaTheme.textSecondary, height: 1.35),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
