import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../../data/models/emergency_request.dart';
import '../view_models/channels_view_model.dart';

class RequestsView extends StatelessWidget {
  final VoidCallback onOpenDrawer;

  const RequestsView({super.key, required this.onOpenDrawer});

  @override
  Widget build(BuildContext context) {
    final channelsVM = context.watch<ChannelsViewModel>();
    final requests = channelsVM.requests;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: onOpenDrawer,
        ),
        titleSpacing: 0,
        title: const Row(
          children: [
            Icon(Icons.emergency_rounded, size: 20, color: PadmaTheme.urgentRed),
            SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Emergency & Requests', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                Text('Blood requests & campus assistance', style: TextStyle(fontSize: 10, color: PadmaTheme.textMuted)),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: PadmaTheme.urgentRed,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Post Request', style: TextStyle(fontWeight: FontWeight.w700)),
        onPressed: () {
          _showNewRequestDialog(context);
        },
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: PadmaTheme.surface,
            child: Row(
              children: [
                _buildFilterChip(context, label: 'All Requests', value: 'all', selected: channelsVM.selectedRequestFilter == 'all'),
                const SizedBox(width: 8),
                _buildFilterChip(context, label: '🩸 Blood Only', value: 'blood', selected: channelsVM.selectedRequestFilter == 'blood'),
                const SizedBox(width: 8),
                _buildFilterChip(context, label: '⚠️ Urgent', value: 'urgent', selected: channelsVM.selectedRequestFilter == 'urgent'),
              ],
            ),
          ),

          // Requests List
          Expanded(
            child: requests.isEmpty
                ? const Center(
                    child: Text('No emergency requests found', style: TextStyle(color: PadmaTheme.textMuted)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final req = requests[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: PadmaTheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: req.urgency == RequestUrgency.critical
                                ? PadmaTheme.urgentRed.withValues(alpha: 0.5)
                                : PadmaTheme.borderLine,
                            width: req.urgency == RequestUrgency.critical ? 1.2 : 0.8,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (req.bloodGroup != 'N/A')
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: PadmaTheme.urgentRedContainer,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      req.bloodGroup,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: PadmaTheme.urgentRed),
                                    ),
                                  ),
                                if (req.bloodGroup != 'N/A') const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        req.title,
                                        style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary),
                                      ),
                                      Text(
                                        'Posted by ${req.postedBy}',
                                        style: const TextStyle(fontSize: 11, color: PadmaTheme.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              req.description,
                              style: const TextStyle(fontSize: 13, color: PadmaTheme.textSecondary, height: 1.35),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, size: 16, color: PadmaTheme.textMuted),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    req.patientLocation,
                                    style: const TextStyle(fontSize: 12, color: PadmaTheme.textMuted),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  req.contactNumber,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: PadmaTheme.primaryTeal),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Dialing ${req.contactNumber}...')),
                                    );
                                  },
                                  icon: const Icon(Icons.call_rounded, size: 16),
                                  label: const Text('Contact', style: TextStyle(fontSize: 12)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: PadmaTheme.surfaceElevated,
                                    foregroundColor: PadmaTheme.textPrimary,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, {required String label, required String value, required bool selected}) {
    final channelsVM = context.read<ChannelsViewModel>();
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? PadmaTheme.onPrimary : PadmaTheme.textSecondary)),
      selected: selected,
      selectedColor: PadmaTheme.primaryTeal,
      backgroundColor: PadmaTheme.surfaceElevated,
      side: BorderSide(color: selected ? PadmaTheme.primaryTeal : PadmaTheme.borderLine),
      onSelected: (_) => channelsVM.setRequestFilter(value),
    );
  }

  void _showNewRequestDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final locController = TextEditingController();
    final phoneController = TextEditingController();
    String selectedBlood = 'B+';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Container(
          decoration: const BoxDecoration(
            color: PadmaTheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Post Emergency Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 14),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title / Patient Need', filled: true, fillColor: PadmaTheme.surfaceElevated),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Description & Urgency Details', filled: true, fillColor: PadmaTheme.surfaceElevated),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: locController,
                  decoration: const InputDecoration(labelText: 'Hospital / Location', filled: true, fillColor: PadmaTheme.surfaceElevated),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Contact Phone Number', filled: true, fillColor: PadmaTheme.surfaceElevated),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      context.read<ChannelsViewModel>().addEmergencyRequest(
                        EmergencyRequest(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: titleController.text,
                          description: descController.text,
                          patientLocation: locController.text.isNotEmpty ? locController.text : 'AUST Campus',
                          bloodGroup: selectedBlood,
                          category: RequestCategory.blood,
                          urgency: RequestUrgency.critical,
                          contactNumber: phoneController.text.isNotEmpty ? phoneController.text : '+880 1700-000000',
                          postedBy: 'Current Student',
                          postedAt: DateTime.now(),
                        ),
                      );
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Emergency request posted to AUST network.')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PadmaTheme.urgentRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Broadcast Emergency Request', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
