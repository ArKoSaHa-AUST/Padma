import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme.dart';
import '../../view_models/admin_view_model.dart';
import '../widgets/admin_3d_card.dart';

class AdminLostFoundTab extends StatelessWidget {
  const AdminLostFoundTab({super.key});

  @override
  Widget build(BuildContext context) {
    final adminVM = context.watch<AdminViewModel>();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: adminVM.lostFoundItems.length,
      itemBuilder: (context, index) {
        final item = adminVM.lostFoundItems[index];
        final isClaimed = item.status == 'Claimed';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Admin3dCard(
            borderColor: isClaimed ? PadmaTheme.borderLine : PadmaTheme.busAmber.withValues(alpha: 0.4),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isClaimed ? PadmaTheme.surfaceElevated : PadmaTheme.busAmberContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.inventory_2_rounded,
                        color: isClaimed ? PadmaTheme.textMuted : PadmaTheme.busAmber,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.itemName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary)),
                          const SizedBox(height: 2),
                          Text('${item.busNumber} • Found at ${item.foundLocation}', style: const TextStyle(fontSize: 11, color: PadmaTheme.textSecondary)),
                          const SizedBox(height: 2),
                          Text('Recovered on ${item.dateFound}', style: const TextStyle(fontSize: 10, color: PadmaTheme.textMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isClaimed ? PadmaTheme.successGreen.withValues(alpha: 0.18) : PadmaTheme.busAmberContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isClaimed ? PadmaTheme.successGreen : PadmaTheme.busAmber,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        if (!isClaimed)
                          ElevatedButton.icon(
                            onPressed: () {
                              adminVM.updateLostFoundStatus(item.id, 'Claimed');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${item.itemName} marked as CLAIMED by student!')),
                              );
                            },
                            icon: const Icon(Icons.check_rounded, size: 14),
                            label: const Text('Mark Claimed', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: PadmaTheme.successGreen,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            ),
                          )
                        else
                          TextButton(
                            onPressed: () {
                              adminVM.updateLostFoundStatus(item.id, 'In Transport Office');
                            },
                            child: const Text('Reopen Entry', style: TextStyle(fontSize: 11, color: PadmaTheme.textMuted)),
                          ),
                      ],
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
