import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme.dart';
import '../../view_models/admin_view_model.dart';
import '../widgets/admin_3d_card.dart';

class AdminSchedulesTab extends StatelessWidget {
  const AdminSchedulesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final adminVM = context.watch<AdminViewModel>();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: [
        // 1. First Bus Dynamic Confirmation Card
        Admin3dCard(
          borderColor: PadmaTheme.busAmber.withValues(alpha: 0.5),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.directions_bus_rounded, color: PadmaTheme.busAmber, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Daily 1st Bus Confirmation',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: PadmaTheme.busAmberContainer,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: PadmaTheme.busAmber.withValues(alpha: 0.4)),
                    ),
                    child: const Text(
                      'ADMIN CONTROL',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: PadmaTheme.busAmber),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Confirm which bus operates as the 1st Bus (06:45 AM departure from Mirpur 12) vs 2nd Bus (08:30 AM departure). Students receive instant live alerts upon confirmation.',
                style: TextStyle(fontSize: 12, color: PadmaTheme.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 14),

              // Bus Selector Option Cards
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => adminVM.setFirstBus('bus_1'),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: adminVM.isBus1First ? PadmaTheme.primaryTeal.withValues(alpha: 0.15) : PadmaTheme.surfaceElevated,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: adminVM.isBus1First ? PadmaTheme.primaryTeal : PadmaTheme.borderLine.withValues(alpha: 0.5),
                            width: adminVM.isBus1First ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Padma 1', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: PadmaTheme.textPrimary)),
                                if (adminVM.isBus1First)
                                  const Icon(Icons.check_circle_rounded, color: PadmaTheme.primaryTeal, size: 16),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              adminVM.isBus1First ? '1st Bus • 06:45 AM' : '2nd Bus • 08:30 AM',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: adminVM.isBus1First ? PadmaTheme.primaryTeal : PadmaTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => adminVM.setFirstBus('bus_2'),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: !adminVM.isBus1First ? PadmaTheme.busAmber.withValues(alpha: 0.15) : PadmaTheme.surfaceElevated,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: !adminVM.isBus1First ? PadmaTheme.busAmber : PadmaTheme.borderLine.withValues(alpha: 0.5),
                            width: !adminVM.isBus1First ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Padma 2', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: PadmaTheme.textPrimary)),
                                if (!adminVM.isBus1First)
                                  const Icon(Icons.check_circle_rounded, color: PadmaTheme.busAmber, size: 16),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              !adminVM.isBus1First ? '1st Bus • 06:45 AM' : '2nd Bus • 08:30 AM',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: !adminVM.isBus1First ? PadmaTheme.busAmber : PadmaTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    adminVM.setFirstBus(adminVM.firstBusId, broadcast: true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Broadcasted to students: ${adminVM.firstBusName} is confirmed as 1st Bus!'),
                        backgroundColor: PadmaTheme.primaryTeal,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PadmaTheme.primaryTeal,
                    foregroundColor: PadmaTheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.campaign_rounded, size: 18),
                  label: const Text('Confirm & Broadcast Announcement', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 2. Official Fall 25 Bus Schedule Table
        Admin3dCard(
          borderColor: PadmaTheme.primaryTeal.withValues(alpha: 0.3),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PADMA FALL 25 BUS SCHEDULE',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: PadmaTheme.textPrimary, letterSpacing: 0.3),
                      ),
                      Text(
                        'Mirpur 12 ⇄ AUST Campus (14 Stoppages)',
                        style: TextStyle(fontSize: 11, color: PadmaTheme.textSecondary),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: PadmaTheme.primaryTealContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('OFFICIAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: PadmaTheme.primaryTeal)),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Timetable Table Header
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF8B1515), // Deep maroon header from schedule banner
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          const Text('(পদ্মা ১ম বাস)', style: TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.w700)),
                          Text(
                            adminVM.isBus1First ? 'Padma 1' : 'Padma 2',
                            style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                    const Expanded(
                      flex: 5,
                      child: Text(
                        'STOPPAGE (স্টপেজ)',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w800),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          const Text('(পদ্মা ২য় বাস)', style: TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.w700)),
                          Text(
                            !adminVM.isBus1First ? 'Padma 1' : 'Padma 2',
                            style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),

              // 14 Stoppage Rows
              ...List.generate(AdminViewModel.fall25FirstBusStoppages.length, (idx) {
                final stop1 = AdminViewModel.fall25FirstBusStoppages[idx];
                final stop2 = AdminViewModel.fall25SecondBusStoppages[idx];
                final isEven = idx % 2 == 0;

                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                  decoration: BoxDecoration(
                    color: isEven ? PadmaTheme.surfaceElevated : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          stop1.eta,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: adminVM.isBus1First ? PadmaTheme.primaryTeal : PadmaTheme.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Text(
                          stop1.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: PadmaTheme.textPrimary),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          stop2.eta,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: !adminVM.isBus1First ? PadmaTheme.busAmber : PadmaTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 12),

              // Return Trips & Notice Banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF7A1010),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.directions_bus_filled_rounded, color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'ফিরতি বাস: দুপুর ৩.৪৫ & সন্ধ্যা ৬.১৫',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      'বিঃদ্রঃ- স্টপেজে উল্লেখিত নির্ধারিত সময়ের ১০ মিনিট পূর্বে স্টপেজে দাঁড়ানোর জন্য অনুরোধ করা হলো।',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10.5, color: Colors.white70, height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
