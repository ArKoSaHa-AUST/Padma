import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme.dart';
import '../../view_models/admin_view_model.dart';
import '../widgets/admin_3d_card.dart';

class AdminSchedulesTab extends StatelessWidget {
  const AdminSchedulesTab({super.key});

  void _showEditDepartureDialog(BuildContext context, AdminViewModel adminVM) {
    final firstCtrl = TextEditingController(text: adminVM.firstBusDepartureTime);
    final secondCtrl = TextEditingController(text: adminVM.secondBusDepartureTime);
    final returnCtrl = TextEditingController(text: adminVM.returnTripTimes);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: PadmaTheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.edit_calendar_rounded, color: PadmaTheme.primaryTeal, size: 22),
              SizedBox(width: 8),
              Text('Edit Bus Departure Hours', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstCtrl,
                style: const TextStyle(fontSize: 13, color: PadmaTheme.textPrimary),
                decoration: InputDecoration(
                  labelText: '1st Bus Starting Time (Mirpur 12)',
                  labelStyle: const TextStyle(color: PadmaTheme.textMuted, fontSize: 12),
                  filled: true,
                  fillColor: PadmaTheme.surfaceElevated,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: secondCtrl,
                style: const TextStyle(fontSize: 13, color: PadmaTheme.textPrimary),
                decoration: InputDecoration(
                  labelText: '2nd Bus Starting Time (Mirpur 12)',
                  labelStyle: const TextStyle(color: PadmaTheme.textMuted, fontSize: 12),
                  filled: true,
                  fillColor: PadmaTheme.surfaceElevated,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: returnCtrl,
                style: const TextStyle(fontSize: 13, color: PadmaTheme.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Campus Return Trips Schedule',
                  labelStyle: const TextStyle(color: PadmaTheme.textMuted, fontSize: 12),
                  filled: true,
                  fillColor: PadmaTheme.surfaceElevated,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: PadmaTheme.textMuted)),
            ),
            ElevatedButton(
              onPressed: () {
                adminVM.updateDepartureTimes(
                  firstBusTime: firstCtrl.text.trim(),
                  secondBusTime: secondCtrl.text.trim(),
                  returnTimes: returnCtrl.text.trim(),
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Bus departure schedule updated successfully!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: PadmaTheme.primaryTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }

  void _showEditStoppageDialog(BuildContext context, AdminViewModel adminVM, int index, AdminBusStoppage stop1, AdminBusStoppage stop2) {
    final eta1Ctrl = TextEditingController(text: stop1.eta);
    final eta2Ctrl = TextEditingController(text: stop2.eta);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: PadmaTheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.pin_drop_rounded, color: PadmaTheme.primaryTeal, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Edit Stoppage: ${stop1.name}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Stoppage #${index + 1}: ${stop1.name}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: PadmaTheme.textSecondary),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: eta1Ctrl,
                style: const TextStyle(fontSize: 13, color: PadmaTheme.textPrimary),
                decoration: InputDecoration(
                  labelText: '1st Bus ETA (e.g. 06:45 AM or ৬:৪৫)',
                  labelStyle: const TextStyle(color: PadmaTheme.textMuted, fontSize: 12),
                  filled: true,
                  fillColor: PadmaTheme.surfaceElevated,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: eta2Ctrl,
                style: const TextStyle(fontSize: 13, color: PadmaTheme.textPrimary),
                decoration: InputDecoration(
                  labelText: '2nd Bus ETA (e.g. 08:30 AM or ৮:৩০)',
                  labelStyle: const TextStyle(color: PadmaTheme.textMuted, fontSize: 12),
                  filled: true,
                  fillColor: PadmaTheme.surfaceElevated,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: PadmaTheme.textMuted)),
            ),
            ElevatedButton(
              onPressed: () {
                if (eta1Ctrl.text.trim().isNotEmpty) {
                  adminVM.updateStoppageEta(isFirstBus: true, index: index, newEta: eta1Ctrl.text.trim());
                }
                if (eta2Ctrl.text.trim().isNotEmpty) {
                  adminVM.updateStoppageEta(isFirstBus: false, index: index, newEta: eta2Ctrl.text.trim());
                }
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('✅ Updated ETA for ${stop1.name}')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: PadmaTheme.primaryTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Save Stoppage', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminVM = context.watch<AdminViewModel>();
    final firstStoppages = AdminViewModel.currentFirstBusStoppages;
    final secondStoppages = AdminViewModel.currentSecondBusStoppages;

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
              Text(
                'Confirm which bus operates as the 1st Bus (${adminVM.firstBusDepartureTime} departure from Mirpur 12) vs 2nd Bus (${adminVM.secondBusDepartureTime} departure). Students receive instant live alerts upon confirmation.',
                style: const TextStyle(fontSize: 12, color: PadmaTheme.textSecondary, height: 1.4),
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
                              adminVM.isBus1First ? '1st Bus • ${adminVM.firstBusDepartureTime}' : '2nd Bus • ${adminVM.secondBusDepartureTime}',
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
                              !adminVM.isBus1First ? '1st Bus • ${adminVM.firstBusDepartureTime}' : '2nd Bus • ${adminVM.secondBusDepartureTime}',
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
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showEditDepartureDialog(context, adminVM),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: PadmaTheme.borderLine),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.edit_note_rounded, size: 18, color: PadmaTheme.textPrimary),
                      label: const Text('Edit Hours', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
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
                      label: const Text('Confirm & Broadcast', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 2. Official Fall 25 Bus Schedule Table with Live Editing
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
                  ElevatedButton.icon(
                    onPressed: () => _showEditDepartureDialog(context, adminVM),
                    icon: const Icon(Icons.edit_calendar_rounded, size: 12),
                    label: const Text('Edit Hours', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PadmaTheme.primaryTealContainer,
                      foregroundColor: PadmaTheme.primaryTeal,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
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
                    const SizedBox(width: 24), // Space for action column
                  ],
                ),
              ),
              const SizedBox(height: 4),

              // 14 Stoppage Rows with Direct Edit Button
              ...List.generate(firstStoppages.length, (idx) {
                final stop1 = firstStoppages[idx];
                final stop2 = (idx < secondStoppages.length) ? secondStoppages[idx] : stop1;
                final isEven = idx % 2 == 0;

                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
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
                      IconButton(
                        icon: const Icon(Icons.edit_rounded, size: 14, color: PadmaTheme.primaryTeal),
                        tooltip: 'Edit ETA for ${stop1.name}',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                        onPressed: () => _showEditStoppageDialog(context, adminVM, idx, stop1, stop2),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 12),

              // Return Trips & Notice Banner
              GestureDetector(
                onTap: () => _showEditDepartureDialog(context, adminVM),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7A1010),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.directions_bus_filled_rounded, color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'ফিরতি বাস: ${adminVM.returnTripTimes}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.edit_rounded, color: Colors.white70, size: 12),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'বিঃদ্রঃ- স্টপেজে উল্লেখিত নির্ধারিত সময়ের ১০ মিনিট পূর্বে স্টপেজে দাঁড়ানোর জন্য অনুরোধ করা হলো।',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 10.5, color: Colors.white70, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
