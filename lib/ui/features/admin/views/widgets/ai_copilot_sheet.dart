import 'package:flutter/material.dart';
import '../../../../core/theme.dart';

class AiCopilotSheet extends StatefulWidget {
  final Function(String title, String body, String priority) onApplyAnnouncement;

  const AiCopilotSheet({super.key, required this.onApplyAnnouncement});

  static void show(BuildContext context, {required Function(String title, String body, String priority) onApply}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AiCopilotSheet(onApplyAnnouncement: onApply),
    );
  }

  @override
  State<AiCopilotSheet> createState() => _AiCopilotSheetState();
}

class _AiCopilotSheetState extends State<AiCopilotSheet> {
  final TextEditingController _promptController = TextEditingController();
  bool _isGenerating = false;
  String? _generatedTitle;
  String? _generatedBody;
  String _generatedPriority = 'High';

  final List<Map<String, String>> _templates = [
    {
      'label': '🌧️ Severe Rain & Route Detour',
      'title': 'Severe Rain Advisory & Corridor Detour',
      'body': 'Due to waterlogging around Rokeya Sarani and Agargaon, Bus 1 will follow the Mirpur 14 flyover bypass. Please expect +15 mins delay.',
      'priority': 'High',
    },
    {
      'label': '🚦 Mohakhali Flyover Traffic Jam',
      'title': 'Tejgaon / Mohakhali Gridlock Notice',
      'body': 'Heavy traffic congestion reported approaching Mohakhali. Departure from AUST campus held for 15 minutes to allow fleet realignment.',
      'priority': 'High',
    },
    {
      'label': '📝 Final Exam Special Schedule',
      'title': 'Semester Final Exam Bus Timetable',
      'body': 'Additional morning trips scheduled at 7:15 AM and 8:00 AM across all routes to accommodate examination shifts.',
      'priority': 'Standard',
    },
    {
      'label': '🚨 Emergency Bus Breakdown',
      'title': 'Urgent: Bus 2 Mechanical Issue',
      'body': 'Bus 2 (Uttara Route) has encountered a tire puncture near Airport Road. Rescue bus is being dispatched immediately.',
      'priority': 'Urgent',
    },
  ];

  void _selectTemplate(Map<String, String> t) {
    setState(() {
      _generatedTitle = t['title'];
      _generatedBody = t['body'];
      _generatedPriority = t['priority']!;
    });
  }

  void _generateFromPrompt() async {
    if (_promptController.text.trim().isEmpty) return;

    setState(() => _isGenerating = true);
    await Future.delayed(const Duration(milliseconds: 700));

    final query = _promptController.text.trim();
    setState(() {
      _isGenerating = false;
      _generatedTitle = 'Official Advisory: $query';
      _generatedBody =
          'AUST Transport Directorate Announcement regarding "$query". All drivers and students on designated routes are advised to follow official transit staff directives.';
      _generatedPriority = 'High';
    });
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: PadmaTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: PadmaTheme.primaryTeal, width: 1.5)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: PadmaTheme.primaryTeal.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, color: PadmaTheme.primaryTeal, size: 22),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Padma AI Transit Copilot', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary)),
                    Text('Generate official announcements with GenAI', style: TextStyle(fontSize: 11, color: PadmaTheme.textMuted)),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: PadmaTheme.textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Quick AI Prompt Input
            const Text('Prompt or Scenario:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: PadmaTheme.textSecondary)),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _promptController,
                    style: const TextStyle(fontSize: 13, color: PadmaTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'e.g., Heavy rain delay on Mirpur road...',
                      hintStyle: const TextStyle(color: PadmaTheme.textMuted, fontSize: 13),
                      filled: true,
                      fillColor: PadmaTheme.surfaceElevated,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: PadmaTheme.primaryTeal)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _isGenerating ? null : _generateFromPrompt,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PadmaTheme.primaryTeal,
                    foregroundColor: PadmaTheme.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                  child: _isGenerating
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Row(
                          children: [
                            Icon(Icons.bolt_rounded, size: 16),
                            SizedBox(width: 4),
                            Text('Draft', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                          ],
                        ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // One-Tap Instant Templates
            const Text('Or Select AI Scenario Template:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: PadmaTheme.textSecondary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _templates.map((t) {
                return ActionChip(
                  label: Text(t['label']!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: PadmaTheme.textPrimary)),
                  backgroundColor: PadmaTheme.surfaceElevated,
                  side: const BorderSide(color: PadmaTheme.borderLine),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  onPressed: () => _selectTemplate(t),
                );
              }).toList(),
            ),

            if (_generatedTitle != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: PadmaTheme.surfaceLowest,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: PadmaTheme.primaryTeal.withValues(alpha: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle_outline_rounded, color: PadmaTheme.primaryTeal, size: 16),
                        const SizedBox(width: 6),
                        const Text('AI Draft Preview', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: PadmaTheme.primaryTeal)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _generatedPriority == 'Urgent'
                                ? PadmaTheme.urgentRed.withValues(alpha: 0.2)
                                : PadmaTheme.busAmberContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Priority: $_generatedPriority',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: _generatedPriority == 'Urgent' ? PadmaTheme.urgentRed : PadmaTheme.busAmber,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(_generatedTitle!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary)),
                    const SizedBox(height: 4),
                    Text(_generatedBody!, style: const TextStyle(fontSize: 12, color: PadmaTheme.textSecondary)),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          widget.onApplyAnnouncement(_generatedTitle!, _generatedBody!, _generatedPriority);
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.send_rounded, size: 16),
                        label: const Text('Apply & Broadcast This Announcement', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PadmaTheme.primaryTeal,
                          foregroundColor: PadmaTheme.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
