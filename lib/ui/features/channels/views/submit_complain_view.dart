import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../auth/view_models/auth_view_model.dart';
import '../view_models/channels_view_model.dart';
import '../../../../data/models/complaint_model.dart';

class SubmitComplainView extends StatefulWidget {
  final VoidCallback onOpenDrawer;

  const SubmitComplainView({
    super.key,
    required this.onOpenDrawer,
  });

  @override
  State<SubmitComplainView> createState() => _SubmitComplainViewState();
}

class _SubmitComplainViewState extends State<SubmitComplainView> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _imageController = TextEditingController();
  bool _submittedSuccess = false;
  String _lastSubmittedId = '';

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    final image = _imageController.text.trim();

    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in both the complaint title and body.'),
          backgroundColor: PadmaTheme.urgentRed,
        ),
      );
      return;
    }

    final authVM = context.read<AuthViewModel>();
    final user = authVM.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be signed in to submit a grievance.'),
          backgroundColor: PadmaTheme.urgentRed,
        ),
      );
      return;
    }

    final channelsVM = context.read<ChannelsViewModel>();
    final newId = 'CMP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    channelsVM.submitComplaint(
      title: title,
      body: body,
      imageUrl: image.isNotEmpty ? image : null,
      studentName: user.name,
      studentId: user.studentId,
      department: user.department,
      semester: user.semester,
      email: user.email,
      pickupDestination: user.pickupDestination,
    );

    setState(() {
      _submittedSuccess = true;
      _lastSubmittedId = newId;
    });

    _titleController.clear();
    _bodyController.clear();
    _imageController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Complaint submitted successfully to AUST Administration.'),
        backgroundColor: PadmaTheme.successGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final user = authVM.currentUser;
    final channelsVM = context.watch<ChannelsViewModel>();
    final isAdmin = authVM.isAdmin;

    return Scaffold(
      backgroundColor: PadmaTheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Info Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    PadmaTheme.primary.withOpacity(0.15),
                    PadmaTheme.surface,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: PadmaTheme.borderLine, width: 0.8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: PadmaTheme.primary.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.description_outlined, color: PadmaTheme.primary, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Submit Complain (Official Grievance Form)',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: PadmaTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isAdmin
                              ? 'Admin View: Review confidential student complaints below.'
                              : 'Submissions are confidential and delivered strictly to Padma AUST Administration. Other students cannot view this.',
                          style: const TextStyle(
                            fontSize: 12,
                            color: PadmaTheme.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // IF ADMIN: Render Admin Complaints Inbox
            if (isAdmin) ...[
              Row(
                children: [
                  const Icon(Icons.shield_outlined, color: PadmaTheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Administrative Triage (${channelsVM.complaints.length} Submissions)',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: PadmaTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (channelsVM.complaints.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: PadmaTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: PadmaTheme.borderLine, width: 0.8),
                  ),
                  child: const Center(
                    child: Column(
                      children: [
                        Icon(Icons.folder_open_outlined, color: PadmaTheme.textMuted, size: 40),
                        SizedBox(height: 8),
                        Text(
                          'No complaints submitted yet.',
                          style: TextStyle(color: PadmaTheme.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: channelsVM.complaints.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final complaint = channelsVM.complaints[index];
                    return _buildAdminComplaintCard(complaint);
                  },
                ),
              const SizedBox(height: 24),
              const Divider(color: PadmaTheme.borderLine),
              const SizedBox(height: 12),
              const Text(
                'Submit a Test / Admin Logged Grievance',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: PadmaTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Submission Form (Google Docs inspired style)
            if (_submittedSuccess && !isAdmin)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: PadmaTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: PadmaTheme.successGreen.withOpacity(0.4)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, color: PadmaTheme.successGreen, size: 48),
                    const SizedBox(height: 12),
                    const Text(
                      'Grievance Submitted Successfully',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: PadmaTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Reference: $_lastSubmittedId\nYour report has been securely filed with AUST Admin.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: PadmaTheme.textSecondary, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _submittedSuccess = false;
                        });
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Submit Another Complain'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PadmaTheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: PadmaTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: PadmaTheme.borderLine, width: 0.8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Google Docs-like toolbar header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: const BoxDecoration(
                        color: PadmaTheme.surfaceLight,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        border: Border(bottom: BorderSide(color: PadmaTheme.borderLine)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.article_rounded, color: PadmaTheme.primary, size: 18),
                          const SizedBox(width: 8),
                          const Text(
                            'AUST Padma Grievance Document',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: PadmaTheme.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: PadmaTheme.background,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: PadmaTheme.borderLine),
                            ),
                            child: const Text(
                              'Private to Admin',
                              style: TextStyle(fontSize: 10, color: PadmaTheme.textMuted, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Auto Student Info Card
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: PadmaTheme.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: PadmaTheme.borderLine),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.badge_outlined, color: PadmaTheme.primary, size: 15),
                                    SizedBox(width: 6),
                                    Text(
                                      'Auto-attached Student Identification',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: PadmaTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 6,
                                  children: [
                                    _infoBadge('Name', user?.name ?? 'Anonymous'),
                                    _infoBadge('Student ID', user?.studentId ?? 'N/A'),
                                    _infoBadge('Dept', user?.department ?? 'CSE'),
                                    _infoBadge('Semester', user?.semester ?? 'N/A'),
                                    _infoBadge('Pickup', user?.pickupDestination ?? 'N/A'),
                                    _infoBadge('Email', user?.email ?? 'aust.edu'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Title Field
                          const Text(
                            'Subject / Title *',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: PadmaTheme.textSecondary),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _titleController,
                            style: const TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'e.g., Padma 1 AC malfunctioning / Schedule delay issue',
                              hintStyle: const TextStyle(fontSize: 13, color: PadmaTheme.textMuted),
                              filled: true,
                              fillColor: PadmaTheme.background,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.primary)),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Body / Description Field
                          const Text(
                            'Statement / Description *',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: PadmaTheme.textSecondary),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _bodyController,
                            maxLines: 6,
                            style: const TextStyle(fontSize: 14, height: 1.4),
                            decoration: InputDecoration(
                              hintText: 'Type your detailed statement, location, date/time, and specific grievances here...',
                              hintStyle: const TextStyle(fontSize: 13, color: PadmaTheme.textMuted),
                              filled: true,
                              fillColor: PadmaTheme.background,
                              contentPadding: const EdgeInsets.all(14),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.primary)),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Optional Picture Field
                          const Text(
                            'Evidence / Image URL (Optional)',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: PadmaTheme.textSecondary),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _imageController,
                            style: const TextStyle(fontSize: 13),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.link_rounded, size: 18, color: PadmaTheme.textMuted),
                              hintText: 'https://images.unsplash.com/... or image link',
                              hintStyle: const TextStyle(fontSize: 12, color: PadmaTheme.textMuted),
                              filled: true,
                              fillColor: PadmaTheme.background,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.primary)),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Submit Action
                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: ElevatedButton.icon(
                              onPressed: _handleSubmit,
                              icon: const Icon(Icons.send_rounded, size: 18),
                              label: const Text(
                                'Submit Confidential Complain',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: PadmaTheme.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoBadge(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: PadmaTheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: PadmaTheme.borderLine),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 10, color: PadmaTheme.textMuted, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 10, color: PadmaTheme.textPrimary, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminComplaintCard(ComplaintModel complaint) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PadmaTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PadmaTheme.borderLine, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: PadmaTheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  complaint.id,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: PadmaTheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  complaint.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: PadmaTheme.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: PadmaTheme.urgentRed.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  complaint.status,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: PadmaTheme.urgentRed,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            complaint.body,
            style: const TextStyle(fontSize: 12, color: PadmaTheme.textSecondary, height: 1.4),
          ),
          if (complaint.imageUrl != null && complaint.imageUrl!.isNotEmpty) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                complaint.imageUrl!,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 60,
                  color: PadmaTheme.background,
                  child: const Center(child: Text('Attachment linked', style: TextStyle(fontSize: 11, color: PadmaTheme.textMuted))),
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          const Divider(color: PadmaTheme.borderLine, height: 1),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            children: [
              Text('Student: ${complaint.studentName} (${complaint.studentId})', style: const TextStyle(fontSize: 10, color: PadmaTheme.textMuted)),
              Text('Dept: ${complaint.department} (${complaint.semester})', style: const TextStyle(fontSize: 10, color: PadmaTheme.textMuted)),
              Text('Pickup: ${complaint.pickupDestination}', style: const TextStyle(fontSize: 10, color: PadmaTheme.textMuted)),
              Text('Email: ${complaint.email}', style: const TextStyle(fontSize: 10, color: PadmaTheme.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}
