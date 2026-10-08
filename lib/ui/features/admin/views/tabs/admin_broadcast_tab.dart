import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme.dart';
import '../../view_models/admin_view_model.dart';
import '../widgets/ai_copilot_sheet.dart';

class AdminBroadcastTab extends StatefulWidget {
  const AdminBroadcastTab({super.key});

  @override
  State<AdminBroadcastTab> createState() => _AdminBroadcastTabState();
}

class _AdminBroadcastTabState extends State<AdminBroadcastTab> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  String _selectedPriority = 'High';
  String _selectedRoute = 'All Routes';
  bool _isPinned = true;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _publishAnnouncement(AdminViewModel adminVM) {
    if (_titleController.text.trim().isEmpty || _bodyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide both title and body.')),
      );
      return;
    }

    adminVM.addAnnouncement(
      title: _titleController.text.trim(),
      body: _bodyController.text.trim(),
      priority: _selectedPriority,
      targetRoute: _selectedRoute,
      isPinned: _isPinned,
    );

    _titleController.clear();
    _bodyController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('📢 Announcement published to all student feeds!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminVM = context.watch<AdminViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Announcement Creation Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: PadmaTheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: PadmaTheme.borderLine),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.campaign_rounded, color: PadmaTheme.primaryTeal, size: 20),
                        SizedBox(width: 8),
                        Text('Publish Official Broadcast', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary)),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        AiCopilotSheet.show(
                          context,
                          onApply: (title, body, priority) {
                            setState(() {
                              _titleController.text = title;
                              _bodyController.text = body;
                              _selectedPriority = priority;
                            });
                          },
                        );
                      },
                      icon: const Icon(Icons.auto_awesome_rounded, size: 14),
                      label: const Text('AI Draft', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PadmaTheme.primaryTealContainer,
                        foregroundColor: PadmaTheme.primaryTeal,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Title field
                const Text('Broadcast Title', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: PadmaTheme.textSecondary)),
                const SizedBox(height: 6),
                TextField(
                  controller: _titleController,
                  style: const TextStyle(fontSize: 13, color: PadmaTheme.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'e.g. Traffic Delay Advisory — Mirpur Route',
                    hintStyle: const TextStyle(color: PadmaTheme.textMuted, fontSize: 13),
                    filled: true,
                    fillColor: PadmaTheme.surfaceElevated,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: PadmaTheme.primaryTeal)),
                  ),
                ),
                const SizedBox(height: 14),

                // Body field
                const Text('Message Body', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: PadmaTheme.textSecondary)),
                const SizedBox(height: 6),
                TextField(
                  controller: _bodyController,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 13, color: PadmaTheme.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Provide complete details for students and drivers...',
                    hintStyle: const TextStyle(color: PadmaTheme.textMuted, fontSize: 13),
                    filled: true,
                    fillColor: PadmaTheme.surfaceElevated,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: PadmaTheme.primaryTeal)),
                  ),
                ),
                const SizedBox(height: 14),

                // Priority & Target Route Selectors
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Priority Level', style: TextStyle(fontSize: 11, color: PadmaTheme.textMuted)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: PadmaTheme.surfaceElevated,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: PadmaTheme.borderLine),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedPriority,
                                dropdownColor: PadmaTheme.surfaceElevated,
                                isExpanded: true,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: PadmaTheme.textPrimary),
                                items: ['Standard', 'High', 'Urgent'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                                onChanged: (val) => setState(() => _selectedPriority = val!),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Target Route', style: TextStyle(fontSize: 11, color: PadmaTheme.textMuted)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: PadmaTheme.surfaceElevated,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: PadmaTheme.borderLine),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedRoute,
                                dropdownColor: PadmaTheme.surfaceElevated,
                                isExpanded: true,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: PadmaTheme.textPrimary),
                                items: ['All Routes', 'Mirpur Route (Padma 1)', 'Uttara Route (Padma 2)'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                                onChanged: (val) => setState(() => _selectedRoute = val!),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Pin toggle & Submit
                Row(
                  children: [
                    Checkbox(
                      value: _isPinned,
                      activeColor: PadmaTheme.primaryTeal,
                      onChanged: (v) => setState(() => _isPinned = v ?? false),
                    ),
                    const Text('Pin to top of Student Dashboard', style: TextStyle(fontSize: 12, color: PadmaTheme.textSecondary)),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _publishAnnouncement(adminVM),
                    icon: const Icon(Icons.send_rounded, size: 16),
                    label: const Text('Publish Broadcast Immediately', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PadmaTheme.primaryTeal,
                      foregroundColor: PadmaTheme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Active Broadcasts List
          const Text('Active Official Broadcasts', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary)),
          const SizedBox(height: 10),
          ...adminVM.announcements.map((item) {
            final isUrgent = item.priority == 'Urgent' || item.priority == 'High';
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: PadmaTheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isUrgent ? PadmaTheme.urgentRed.withValues(alpha: 0.4) : PadmaTheme.borderLine),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isUrgent ? PadmaTheme.urgentRed.withValues(alpha: 0.18) : PadmaTheme.primaryTealContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.priority.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: isUrgent ? PadmaTheme.urgentRed : PadmaTheme.primaryTeal,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(item.targetRoute, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: PadmaTheme.textMuted)),
                      if (item.isPinned) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.push_pin_rounded, size: 12, color: PadmaTheme.busAmber),
                      ],
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 18, color: PadmaTheme.textMuted),
                        onPressed: () => adminVM.deleteAnnouncement(item.id),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(item.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary)),
                  const SizedBox(height: 4),
                  Text(item.body, style: const TextStyle(fontSize: 12, color: PadmaTheme.textSecondary, height: 1.3)),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('hh:mm a • dd MMM yyyy').format(item.timestamp),
                    style: const TextStyle(fontSize: 10, color: PadmaTheme.textMuted),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
