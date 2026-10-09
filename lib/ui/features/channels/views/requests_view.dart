import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../auth/view_models/auth_view_model.dart';
import '../view_models/channels_view_model.dart';
import '../../../../data/models/blood_request_model.dart';
import '../../../../data/models/lost_found_model.dart';
import '../../../../data/models/post_response_model.dart';
import '../../../../data/models/post_comment_model.dart';
import 'submit_complain_view.dart';

class RequestsView extends StatefulWidget {
  final VoidCallback onOpenDrawer;
  final String activeSubTab; // 'blood-request', 'lost-found', 'post-responses', 'contact-admin', 'submit-complain'

  const RequestsView({
    super.key,
    required this.onOpenDrawer,
    this.activeSubTab = 'blood-request',
  });

  @override
  State<RequestsView> createState() => _RequestsViewState();
}

class _RequestsViewState extends State<RequestsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _contactChatController = TextEditingController();
  final Map<String, TextEditingController> _commentControllers = {};
  final Set<String> _expandedCommentsPostIds = {};

  String _responseFilter = 'all'; // 'all', 'blood', 'lost_found', 'received', 'sent'
  String? _filterPostId;

  @override
  void initState() {
    super.initState();
    int initialIdx = 0;
    if (widget.activeSubTab == 'lost-found') initialIdx = 1;
    if (widget.activeSubTab == 'post-responses' || widget.activeSubTab == 'responses') initialIdx = 2;
    if (widget.activeSubTab == 'contact-admin') initialIdx = 3;
    if (widget.activeSubTab == 'submit-complain') initialIdx = 4;

    _tabController = TabController(length: 5, vsync: this, initialIndex: initialIdx);
  }

  @override
  void didUpdateWidget(covariant RequestsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeSubTab != oldWidget.activeSubTab) {
      int idx = 0;
      if (widget.activeSubTab == 'lost-found') idx = 1;
      if (widget.activeSubTab == 'post-responses' || widget.activeSubTab == 'responses') idx = 2;
      if (widget.activeSubTab == 'contact-admin') idx = 3;
      if (widget.activeSubTab == 'submit-complain') idx = 4;
      _tabController.animateTo(idx);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _contactChatController.dispose();
    for (var c in _commentControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _showEditCommentDialog(BuildContext context, PostCommentModel comment) {
    final ctrl = TextEditingController(text: comment.content);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: PadmaTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: PadmaTheme.borderLine),
        ),
        title: const Text('Edit Comment', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          autofocus: true,
          style: const TextStyle(fontSize: 13, color: PadmaTheme.textPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor: PadmaTheme.surfaceElevated,
            hintText: 'Write your comment...',
            hintStyle: const TextStyle(color: PadmaTheme.textMuted, fontSize: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: PadmaTheme.borderLine),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: PadmaTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: PadmaTheme.primaryTeal,
              foregroundColor: PadmaTheme.onPrimary,
            ),
            onPressed: () {
              final newTxt = ctrl.text.trim();
              if (newTxt.isNotEmpty) {
                context.read<ChannelsViewModel>().updatePostComment(comment.id, newTxt);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Comment updated!')),
                );
              }
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // 1. Volunteer as Blood Donor Dialog ("I Can Donate")
  // -------------------------------------------------------------
  void _showDonorResponseDialog(BuildContext context, BloodRequestModel req) {
    final authVM = context.read<AuthViewModel>();
    final user = authVM.currentUser;

    final nameCtrl = TextEditingController(text: user?.name ?? 'Padma Student');
    final deptCtrl = TextEditingController(text: user?.department ?? 'CSE');
    final semCtrl = TextEditingController(text: user?.semester ?? '4-1');
    final phoneCtrl = TextEditingController(text: user?.phone ?? '');
    final fbLinkCtrl = TextEditingController(text: 'https://facebook.com/');
    final availCtrl = TextEditingController(text: 'Available today after class');
    final notesCtrl = TextEditingController(text: 'Verified donor ready to assist with emergency.');

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: PadmaTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: PadmaTheme.borderLine),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: PadmaTheme.urgentRed.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.volunteer_activism_rounded, color: PadmaTheme.urgentRed, size: 22),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('I Can Donate Blood', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  Text('Send contact info to requester', style: TextStyle(fontSize: 11, color: PadmaTheme.textMuted)),
                ],
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Request Context Card
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: PadmaTheme.urgentRed.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: PadmaTheme.urgentRed.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: PadmaTheme.urgentRed,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        req.bloodGroup,
                        style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            req.title,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${req.hospitalName} • By @${req.requesterTag}',
                            style: const TextStyle(fontSize: 10.5, color: PadmaTheme.textMuted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              const Text('Full Name *', style: TextStyle(fontSize: 11, color: PadmaTheme.textSecondary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: PadmaTheme.surfaceElevated,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                ),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Department *', style: TextStyle(fontSize: 11, color: PadmaTheme.textSecondary, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        TextField(
                          controller: deptCtrl,
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: PadmaTheme.surfaceElevated,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Semester *', style: TextStyle(fontSize: 11, color: PadmaTheme.textSecondary, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        TextField(
                          controller: semCtrl,
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: PadmaTheme.surfaceElevated,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              const Text('Contact Phone Number *', style: TextStyle(fontSize: 11, color: PadmaTheme.textSecondary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: '017xxxxxxxx',
                  filled: true,
                  fillColor: PadmaTheme.surfaceElevated,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                ),
              ),
              const SizedBox(height: 10),

              const Text('Facebook Profile / Messenger Link', style: TextStyle(fontSize: 11, color: PadmaTheme.textSecondary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              TextField(
                controller: fbLinkCtrl,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'https://facebook.com/... or m.me/...',
                  filled: true,
                  fillColor: PadmaTheme.surfaceElevated,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                ),
              ),
              const SizedBox(height: 10),

              const Text('Availability / Preferred Time', style: TextStyle(fontSize: 11, color: PadmaTheme.textSecondary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              TextField(
                controller: availCtrl,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'e.g. Immediately or Today after 3 PM',
                  filled: true,
                  fillColor: PadmaTheme.surfaceElevated,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                ),
              ),
              const SizedBox(height: 10),

              const Text('Short Note to Requester', style: TextStyle(fontSize: 11, color: PadmaTheme.textSecondary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              TextField(
                controller: notesCtrl,
                maxLines: 2,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'e.g. O+ verified donor, last donated 5 months ago',
                  filled: true,
                  fillColor: PadmaTheme.surfaceElevated,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel', style: TextStyle(color: PadmaTheme.textMuted)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: PadmaTheme.urgentRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.send_rounded, size: 16),
            label: const Text('Submit Response', style: TextStyle(fontWeight: FontWeight.w700)),
            onPressed: () {
              final phone = phoneCtrl.text.trim();
              if (phone.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter your contact phone number')),
                );
                return;
              }

              context.read<ChannelsViewModel>().addPostResponse(
                    postId: req.id,
                    postType: 'blood',
                    postTitle: req.title,
                    postSummary: '${req.bloodGroup} at ${req.hospitalName}',
                    requesterId: req.authorTag,
                    requesterName: req.requesterName,
                    requesterTag: req.requesterTag,
                    responderId: user?.id ?? 'user_student',
                    responderName: nameCtrl.text.trim(),
                    responderTag: user?.chatTag ?? 'Student_CSE_4-1_Campus',
                    department: deptCtrl.text.trim(),
                    semester: semCtrl.text.trim(),
                    contactNumber: phone,
                    fbLink: fbLinkCtrl.text.trim(),
                    availability: availCtrl.text.trim(),
                    notes: notesCtrl.text.trim(),
                  );

              Navigator.pop(dialogCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Thank you! Response sent directly to @${req.authorTag}')),
              );
            },
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // 2. Respond to Lost & Found Notice Dialog
  // -------------------------------------------------------------
  void _showLostFoundResponseDialog(BuildContext context, LostFoundModel item) {
    final authVM = context.read<AuthViewModel>();
    final user = authVM.currentUser;

    final isLost = item.type == LostFoundType.lost;
    final nameCtrl = TextEditingController(text: user?.name ?? 'Padma Student');
    final deptCtrl = TextEditingController(text: user?.department ?? 'CSE');
    final semCtrl = TextEditingController(text: user?.semester ?? '4-1');
    final phoneCtrl = TextEditingController(text: user?.phone ?? '');
    final fbLinkCtrl = TextEditingController(text: 'https://facebook.com/');
    final notesCtrl = TextEditingController(text: isLost ? 'I found this item and have it safe.' : 'This is my item. I can verify ownership.');

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: PadmaTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: PadmaTheme.borderLine),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: PadmaTheme.busAmber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.verified_rounded, color: PadmaTheme.busAmber, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isLost ? 'I Found This Item' : 'Claim Found Item',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Title: ${item.title}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: PadmaTheme.primaryTeal)),
              const SizedBox(height: 10),

              const Text('Your Name *', style: TextStyle(fontSize: 11, color: PadmaTheme.textSecondary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: PadmaTheme.surfaceElevated,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                ),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: deptCtrl,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Department',
                        filled: true,
                        fillColor: PadmaTheme.surfaceElevated,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: semCtrl,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Semester',
                        filled: true,
                        fillColor: PadmaTheme.surfaceElevated,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              const Text('Contact Phone Number *', style: TextStyle(fontSize: 11, color: PadmaTheme.textSecondary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: '017xxxxxxxx',
                  filled: true,
                  fillColor: PadmaTheme.surfaceElevated,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                ),
              ),
              const SizedBox(height: 10),

              const Text('Facebook Profile / Messenger Link', style: TextStyle(fontSize: 11, color: PadmaTheme.textSecondary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              TextField(
                controller: fbLinkCtrl,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: PadmaTheme.surfaceElevated,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                ),
              ),
              const SizedBox(height: 10),

              const Text('Message / Details *', style: TextStyle(fontSize: 11, color: PadmaTheme.textSecondary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              TextField(
                controller: notesCtrl,
                maxLines: 2,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: PadmaTheme.surfaceElevated,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel', style: TextStyle(color: PadmaTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: PadmaTheme.busAmber,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              final phone = phoneCtrl.text.trim();
              if (phone.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter your contact phone number')),
                );
                return;
              }

              context.read<ChannelsViewModel>().addPostResponse(
                    postId: item.id,
                    postType: 'lost_found',
                    postTitle: item.title,
                    postSummary: item.location ?? 'AUST Campus',
                    requesterId: item.authorTag,
                    requesterName: item.authorName,
                    requesterTag: item.authorTag,
                    responderId: user?.id ?? 'user_student',
                    responderName: nameCtrl.text.trim(),
                    responderTag: user?.chatTag ?? 'Student_CSE_4-1_Campus',
                    department: deptCtrl.text.trim(),
                    semester: semCtrl.text.trim(),
                    contactNumber: phone,
                    fbLink: fbLinkCtrl.text.trim(),
                    availability: 'Campus Handover',
                    notes: notesCtrl.text.trim(),
                  );

              Navigator.pop(dialogCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Response sent to @${item.authorTag}')),
              );
            },
            child: const Text('Send Response', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // 3. Edit & Delete Response Dialog
  // -------------------------------------------------------------
  void _showEditResponseDialog(BuildContext context, PostResponseModel resp) {
    final phoneCtrl = TextEditingController(text: resp.contactNumber);
    final fbLinkCtrl = TextEditingController(text: resp.fbLink ?? '');
    final availCtrl = TextEditingController(text: resp.availability ?? '');
    final notesCtrl = TextEditingController(text: resp.notes ?? '');

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: PadmaTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: PadmaTheme.borderLine)),
        title: const Text('Edit Your Response', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Contact Phone Number *', style: TextStyle(fontSize: 11, color: PadmaTheme.textSecondary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              TextField(
                controller: phoneCtrl,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: PadmaTheme.surfaceElevated,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                ),
              ),
              const SizedBox(height: 10),

              const Text('Facebook Profile Link', style: TextStyle(fontSize: 11, color: PadmaTheme.textSecondary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              TextField(
                controller: fbLinkCtrl,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: PadmaTheme.surfaceElevated,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                ),
              ),
              const SizedBox(height: 10),

              const Text('Availability', style: TextStyle(fontSize: 11, color: PadmaTheme.textSecondary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              TextField(
                controller: availCtrl,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: PadmaTheme.surfaceElevated,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                ),
              ),
              const SizedBox(height: 10),

              const Text('Notes', style: TextStyle(fontSize: 11, color: PadmaTheme.textSecondary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              TextField(
                controller: notesCtrl,
                maxLines: 2,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: PadmaTheme.surfaceElevated,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel', style: TextStyle(color: PadmaTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: PadmaTheme.primaryTeal,
              foregroundColor: PadmaTheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              final updated = resp.copyWith(
                contactNumber: phoneCtrl.text.trim(),
                fbLink: fbLinkCtrl.text.trim(),
                availability: availCtrl.text.trim(),
                notes: notesCtrl.text.trim(),
              );
              context.read<ChannelsViewModel>().updatePostResponse(updated);
              Navigator.pop(dialogCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Response updated successfully!')),
              );
            },
            child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // 4. Create & Edit Blood Request Dialogs
  // -------------------------------------------------------------
  void _showNewBloodRequestDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final hospitalCtrl = TextEditingController();
    final patientDetailsCtrl = TextEditingController();
    final messageBodyCtrl = TextEditingController();
    final requiredDateCtrl = TextEditingController();
    final contactCtrl = TextEditingController(text: '+880 1711-');
    final emailCtrl = TextEditingController();
    final extraInfoCtrl = TextEditingController();
    String selectedBloodGroup = 'O+';

    final bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

    final authVM = context.read<AuthViewModel>();
    final user = authVM.currentUser;
    if (user != null && emailCtrl.text.isEmpty) {
      emailCtrl.text = user.email;
    }

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: PadmaTheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: PadmaTheme.borderLine)),
            title: const Row(
              children: [
                Icon(Icons.bloodtype_rounded, color: PadmaTheme.urgentRed, size: 24),
                SizedBox(width: 8),
                Text('Post Blood Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Title *', style: TextStyle(fontSize: 11, color: PadmaTheme.textSecondary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: titleCtrl,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: PadmaTheme.surfaceElevated,
                      hintText: 'e.g. Urgent O+ Blood for Surgery',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Blood Group *', style: TextStyle(fontSize: 11, color: PadmaTheme.textSecondary, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            DropdownButtonFormField<String>(
                              value: selectedBloodGroup,
                              items: bloodGroups.map((bg) => DropdownMenuItem(value: bg, child: Text(bg, style: const TextStyle(fontSize: 13)))).toList(),
                              onChanged: (v) => setDialogState(() => selectedBloodGroup = v ?? 'O+'),
                              dropdownColor: PadmaTheme.surfaceElevated,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: PadmaTheme.surfaceElevated,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Required Date', style: TextStyle(fontSize: 11, color: PadmaTheme.textSecondary, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            TextField(
                              controller: requiredDateCtrl,
                              style: const TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: PadmaTheme.surfaceElevated,
                                hintText: 'e.g. Tomorrow 9 AM',
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  const Text('Hospital Name *', style: TextStyle(fontSize: 11, color: PadmaTheme.textSecondary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: hospitalCtrl,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: PadmaTheme.surfaceElevated,
                      hintText: 'e.g. Dhaka Medical College Hospital (DMCH)',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                    ),
                  ),
                  const SizedBox(height: 10),

                  const Text('Contact Phone Number *', style: TextStyle(fontSize: 11, color: PadmaTheme.textSecondary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: contactCtrl,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: PadmaTheme.surfaceElevated,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                    ),
                  ),
                  const SizedBox(height: 10),

                  const Text('Email Address *', style: TextStyle(fontSize: 11, color: PadmaTheme.textSecondary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: emailCtrl,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: PadmaTheme.surfaceElevated,
                      hintText: 'e.g. student@aust.edu',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                    ),
                  ),
                  const SizedBox(height: 10),

                  const Text('Patient Details (optional)', style: TextStyle(fontSize: 11, color: PadmaTheme.textSecondary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: patientDetailsCtrl,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: PadmaTheme.surfaceElevated,
                      hintText: 'e.g. Ward 4, Cabin 102',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                    ),
                  ),
                  const SizedBox(height: 10),

                  const Text('Message Body (optional)', style: TextStyle(fontSize: 11, color: PadmaTheme.textSecondary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: messageBodyCtrl,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: PadmaTheme.surfaceElevated,
                      hintText: 'Provide any additional context...',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Cancel', style: TextStyle(color: PadmaTheme.textMuted)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: PadmaTheme.urgentRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  if (titleCtrl.text.trim().isEmpty || hospitalCtrl.text.trim().isEmpty || contactCtrl.text.trim().isEmpty || emailCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill in all required fields')),
                    );
                    return;
                  }

                  context.read<ChannelsViewModel>().addBloodRequest(
                        title: titleCtrl.text.trim(),
                        bloodGroup: selectedBloodGroup,
                        hospitalName: hospitalCtrl.text.trim(),
                        patientDetails: patientDetailsCtrl.text.trim().isNotEmpty ? patientDetailsCtrl.text.trim() : null,
                        messageBody: messageBodyCtrl.text.trim().isNotEmpty ? messageBodyCtrl.text.trim() : null,
                        requiredDate: requiredDateCtrl.text.trim().isNotEmpty ? requiredDateCtrl.text.trim() : null,
                        contactNumber: contactCtrl.text.trim(),
                        emailAddress: emailCtrl.text.trim(),
                        extraInformation: extraInfoCtrl.text.trim().isNotEmpty ? extraInfoCtrl.text.trim() : null,
                        requesterName: user?.name ?? 'AUST Student',
                        requesterTag: user?.chatTag ?? 'Student_CSE_4-1_Campus',
                      );

                  Navigator.pop(dialogCtx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Blood Request published to campus roster!')),
                  );
                },
                child: const Text('Broadcast Request', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditBloodRequestDialog(BuildContext context, BloodRequestModel req) {
    final titleCtrl = TextEditingController(text: req.title);
    final hospitalCtrl = TextEditingController(text: req.hospitalName);
    final patientDetailsCtrl = TextEditingController(text: req.patientDetails ?? '');
    final messageBodyCtrl = TextEditingController(text: req.messageBody ?? '');
    final requiredDateCtrl = TextEditingController(text: req.requiredDate ?? '');
    final contactCtrl = TextEditingController(text: req.contactNumber);
    final emailCtrl = TextEditingController(text: req.emailAddress);
    final extraInfoCtrl = TextEditingController(text: req.extraInformation ?? '');
    String selectedBloodGroup = req.bloodGroup;

    final bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: PadmaTheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: PadmaTheme.borderLine)),
            title: const Text('Edit Blood Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Title *', style: TextStyle(fontSize: 11, color: PadmaTheme.textSecondary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: titleCtrl,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: PadmaTheme.surfaceElevated,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedBloodGroup,
                          items: bloodGroups.map((bg) => DropdownMenuItem(value: bg, child: Text(bg, style: const TextStyle(fontSize: 13)))).toList(),
                          onChanged: (v) => setDialogState(() => selectedBloodGroup = v ?? 'O+'),
                          dropdownColor: PadmaTheme.surfaceElevated,
                          decoration: InputDecoration(
                            labelText: 'Blood Group',
                            filled: true,
                            fillColor: PadmaTheme.surfaceElevated,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: requiredDateCtrl,
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            labelText: 'Date Needed',
                            filled: true,
                            fillColor: PadmaTheme.surfaceElevated,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  const Text('Hospital Name *', style: TextStyle(fontSize: 11, color: PadmaTheme.textSecondary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: hospitalCtrl,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: PadmaTheme.surfaceElevated,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                    ),
                  ),
                  const SizedBox(height: 10),

                  const Text('Contact Phone Number *', style: TextStyle(fontSize: 11, color: PadmaTheme.textSecondary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: contactCtrl,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: PadmaTheme.surfaceElevated,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                    ),
                  ),
                  const SizedBox(height: 10),

                  const Text('Message Body', style: TextStyle(fontSize: 11, color: PadmaTheme.textSecondary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: messageBodyCtrl,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: PadmaTheme.surfaceElevated,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Cancel', style: TextStyle(color: PadmaTheme.textMuted)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: PadmaTheme.primaryTeal,
                  foregroundColor: PadmaTheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  final updated = req.copyWith(
                    title: titleCtrl.text.trim(),
                    bloodGroup: selectedBloodGroup,
                    hospitalName: hospitalCtrl.text.trim(),
                    patientDetails: patientDetailsCtrl.text.trim(),
                    messageBody: messageBodyCtrl.text.trim(),
                    requiredDate: requiredDateCtrl.text.trim(),
                    contactNumber: contactCtrl.text.trim(),
                    emailAddress: emailCtrl.text.trim(),
                    extraInformation: extraInfoCtrl.text.trim(),
                  );
                  context.read<ChannelsViewModel>().updateBloodRequest(updated);
                  Navigator.pop(dialogCtx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Blood Request updated!')),
                  );
                },
                child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          );
        },
      ),
    );
  }

  // -------------------------------------------------------------
  // 5. Create & Edit Lost and Found Dialogs
  // -------------------------------------------------------------
  void _showNewLostFoundDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final locCtrl = TextEditingController();
    final contactCtrl = TextEditingController();
    final imgUrlCtrl = TextEditingController();
    LostFoundType type = LostFoundType.lost;

    final authVM = context.read<AuthViewModel>();
    final user = authVM.currentUser;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: PadmaTheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: PadmaTheme.borderLine)),
            title: const Row(
              children: [
                Icon(Icons.search_rounded, color: PadmaTheme.busAmber, size: 24),
                SizedBox(width: 8),
                Text('Post Lost / Found Item', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Lost Item'),
                        selected: type == LostFoundType.lost,
                        selectedColor: PadmaTheme.urgentRed,
                        onSelected: (_) => setDialogState(() => type = LostFoundType.lost),
                      ),
                      const SizedBox(width: 10),
                      ChoiceChip(
                        label: const Text('Found Item'),
                        selected: type == LostFoundType.found,
                        selectedColor: PadmaTheme.successGreen,
                        onSelected: (_) => setDialogState(() => type = LostFoundType.found),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  const Text('Title *', style: TextStyle(fontSize: 11, color: PadmaTheme.textSecondary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: titleCtrl,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: PadmaTheme.surfaceElevated,
                      hintText: 'e.g. Lost ID card in Padma 1',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                    ),
                  ),
                  const SizedBox(height: 10),

                  const Text('Body / Description *', style: TextStyle(fontSize: 11, color: PadmaTheme.textSecondary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: descCtrl,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: PadmaTheme.surfaceElevated,
                      hintText: 'Describe the item, color, markings, and location...',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                    ),
                  ),
                  const SizedBox(height: 10),

                  const Text('Location & Contact info (optional)', style: TextStyle(fontSize: 11, color: PadmaTheme.textSecondary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: locCtrl,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: PadmaTheme.surfaceElevated,
                      hintText: 'e.g. Padma 1 Upper Deck • Phone: +880 17...',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Cancel', style: TextStyle(color: PadmaTheme.textMuted)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: PadmaTheme.busAmber,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  if (titleCtrl.text.trim().isEmpty || descCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter Title and Description')),
                    );
                    return;
                  }

                  context.read<ChannelsViewModel>().addLostFoundItem(
                        title: titleCtrl.text.trim(),
                        description: descCtrl.text.trim(),
                        type: type,
                        location: locCtrl.text.trim().isNotEmpty ? locCtrl.text.trim() : null,
                        contact: contactCtrl.text.trim().isNotEmpty ? contactCtrl.text.trim() : null,
                        imageUrl: imgUrlCtrl.text.trim().isNotEmpty ? imgUrlCtrl.text.trim() : null,
                        authorName: user?.name ?? 'AUST Student',
                        authorTag: user?.chatTag ?? 'Student_CSE_4-1_Campus',
                      );

                  Navigator.pop(dialogCtx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Item posted to Lost and Found!')),
                  );
                },
                child: const Text('Post Item', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditLostFoundDialog(BuildContext context, LostFoundModel item) {
    final titleCtrl = TextEditingController(text: item.title);
    final descCtrl = TextEditingController(text: item.description);
    final locCtrl = TextEditingController(text: item.location ?? '');
    final contactCtrl = TextEditingController(text: item.contact ?? '');
    LostFoundType type = item.type;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: PadmaTheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: PadmaTheme.borderLine)),
            title: const Text('Edit Notice', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Lost Item'),
                        selected: type == LostFoundType.lost,
                        selectedColor: PadmaTheme.urgentRed,
                        onSelected: (_) => setDialogState(() => type = LostFoundType.lost),
                      ),
                      const SizedBox(width: 10),
                      ChoiceChip(
                        label: const Text('Found Item'),
                        selected: type == LostFoundType.found,
                        selectedColor: PadmaTheme.successGreen,
                        onSelected: (_) => setDialogState(() => type = LostFoundType.found),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  const Text('Title *', style: TextStyle(fontSize: 11, color: PadmaTheme.textSecondary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: titleCtrl,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: PadmaTheme.surfaceElevated,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                    ),
                  ),
                  const SizedBox(height: 10),

                  const Text('Body / Description *', style: TextStyle(fontSize: 11, color: PadmaTheme.textSecondary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: descCtrl,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: PadmaTheme.surfaceElevated,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                    ),
                  ),
                  const SizedBox(height: 10),

                  const Text('Location / Contact', style: TextStyle(fontSize: 11, color: PadmaTheme.textSecondary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: locCtrl,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: PadmaTheme.surfaceElevated,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Cancel', style: TextStyle(color: PadmaTheme.textMuted)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: PadmaTheme.primaryTeal,
                  foregroundColor: PadmaTheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  final updated = item.copyWith(
                    title: titleCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    type: type,
                    location: locCtrl.text.trim(),
                    contact: contactCtrl.text.trim(),
                  );
                  context.read<ChannelsViewModel>().updateLostFoundItem(updated);
                  Navigator.pop(dialogCtx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notice updated!')),
                  );
                },
                child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final channelsVM = context.watch<ChannelsViewModel>();
    final authVM = context.watch<AuthViewModel>();
    final user = authVM.currentUser;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: widget.onOpenDrawer,
        ),
        titleSpacing: 0,
        title: const Text('Student Assistance & Hub', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: PadmaTheme.primaryTeal,
          unselectedLabelColor: PadmaTheme.textMuted,
          indicatorColor: PadmaTheme.primaryTeal,
          tabs: [
            const Tab(icon: Icon(Icons.bloodtype_rounded, size: 18), text: 'Blood Request'),
            const Tab(icon: Icon(Icons.search_rounded, size: 18), text: 'Lost and Found'),
            Tab(
              icon: Badge(
                isLabelVisible: channelsVM.postResponses.isNotEmpty,
                label: Text('${channelsVM.postResponses.length}', style: const TextStyle(fontSize: 9)),
                child: const Icon(Icons.mark_chat_read_rounded, size: 18),
              ),
              text: 'Responses',
            ),
            const Tab(icon: Icon(Icons.support_agent_rounded, size: 18), text: 'Contact Admin'),
            const Tab(icon: Icon(Icons.description_outlined, size: 18), text: 'Submit Complain'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. BLOOD REQUEST TAB
          _buildBloodRequestTab(context, channelsVM, user),

          // 2. LOST AND FOUND TAB
          _buildLostFoundTab(context, channelsVM, user),

          // 3. POST RESPONSES TAB (Realtime responses to Blood & Lost/Found)
          _buildPostResponsesTab(context, channelsVM, user),

          // 4. CONTACT ADMIN (1-on-1 Private Chat)
          _buildContactAdminTab(context, channelsVM, user),

          // 5. SUBMIT COMPLAIN (Google Docs Form)
          SubmitComplainView(onOpenDrawer: widget.onOpenDrawer),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Tab 1: Blood Request Feed
  // -------------------------------------------------------------
  Widget _buildBloodRequestTab(BuildContext context, ChannelsViewModel channelsVM, dynamic user) {
    final list = channelsVM.bloodRequests;
    final allResponses = channelsVM.postResponses;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: PadmaTheme.urgentRed,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Post Blood Request', style: TextStyle(fontWeight: FontWeight.w700)),
        onPressed: () => _showNewBloodRequestDialog(context),
      ),
      body: list.isEmpty
          ? const Center(child: Text('No blood requests posted yet', style: TextStyle(color: PadmaTheme.textMuted)))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final req = list[index];
                final isOwner = user != null && (user.id == req.id || user.chatTag == req.authorTag || user.role == 'admin');
                final responsesCount = allResponses.where((r) => r.postId == req.id).length;

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: PadmaTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: PadmaTheme.urgentRed.withValues(alpha: 0.5), width: 1.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: PadmaTheme.urgentRed,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  req.bloodGroup,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Needed: ${req.requiredDate ?? "Immediate"}',
                                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: PadmaTheme.urgentRed),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                '@${req.authorTag}',
                                style: const TextStyle(fontSize: 10.5, color: PadmaTheme.textMuted, fontFamily: 'monospace'),
                              ),
                              if (isOwner) ...[
                                const SizedBox(width: 4),
                                IconButton(
                                  icon: const Icon(Icons.edit_rounded, size: 16, color: PadmaTheme.primaryTeal),
                                  onPressed: () => _showEditBloodRequestDialog(context, req),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, size: 16, color: PadmaTheme.urgentRed),
                                  onPressed: () {
                                    channelsVM.deleteBloodRequest(req.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Blood request deleted')),
                                    );
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        req.title,
                        style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary),
                      ),
                      if (req.messageBody != null) ...[
                        const SizedBox(height: 4),
                        Text(req.messageBody!, style: const TextStyle(fontSize: 12.5, color: PadmaTheme.textSecondary)),
                      ],
                      const SizedBox(height: 8),

                      // Hospital location box
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: PadmaTheme.surfaceElevated,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.local_hospital_rounded, size: 16, color: PadmaTheme.urgentRed),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    req.hospitalName,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: PadmaTheme.textPrimary),
                                  ),
                                ),
                              ],
                            ),
                            if (req.patientDetails != null) ...[
                              const SizedBox(height: 4),
                              Text('Patient: ${req.patientDetails!}', style: const TextStyle(fontSize: 11.5, color: PadmaTheme.textMuted)),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Action Row (Call & I Can Donate)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: PadmaTheme.primaryTeal),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.call_rounded, size: 16, color: PadmaTheme.primaryTeal),
                              label: const Text('Call Attendant', style: TextStyle(fontSize: 12, color: PadmaTheme.primaryTeal, fontWeight: FontWeight.w700)),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Dialing ${req.contactNumber}...')),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: PadmaTheme.urgentRed,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.volunteer_activism_rounded, size: 16),
                              label: const Text('I Can Donate', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                              onPressed: () => _showDonorResponseDialog(context, req),
                            ),
                          ),
                        ],
                      ),

                      // View Responses count row
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _filterPostId = req.id;
                            _responseFilter = 'all';
                          });
                          _tabController.animateTo(2); // Jump to Responses tab
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.mark_chat_read_rounded, size: 15, color: PadmaTheme.primaryTeal),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$responsesCount Donor Response${responsesCount != 1 ? "s" : ""}',
                                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: PadmaTheme.primaryTeal),
                                  ),
                                ],
                              ),
                              const Text('View Responses →', style: TextStyle(fontSize: 11, color: PadmaTheme.textMuted)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  // -------------------------------------------------------------
  // Tab 2: Lost and Found Feed
  // -------------------------------------------------------------
  Widget _buildLostFoundTab(BuildContext context, ChannelsViewModel channelsVM, dynamic user) {
    final list = channelsVM.lostFoundItems;
    final allResponses = channelsVM.postResponses;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: PadmaTheme.busAmber,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Post Item', style: TextStyle(fontWeight: FontWeight.w700)),
        onPressed: () => _showNewLostFoundDialog(context),
      ),
      body: list.isEmpty
          ? const Center(child: Text('No lost & found items posted yet', style: TextStyle(color: PadmaTheme.textMuted)))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final item = list[index];
                final isLost = item.type == LostFoundType.lost;
                final isOwner = user != null && (user.id == item.id || user.chatTag == item.authorTag || user.role == 'admin');
                final responsesCount = allResponses.where((r) => r.postId == item.id).length;

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: PadmaTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: PadmaTheme.borderLine),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isLost ? PadmaTheme.urgentRed.withValues(alpha: 0.15) : PadmaTheme.successGreen.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isLost ? 'LOST' : 'FOUND',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: isLost ? PadmaTheme.urgentRed : PadmaTheme.successGreen,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Text('Posted by @${item.authorTag}', style: const TextStyle(fontSize: 10.5, color: PadmaTheme.textMuted, fontFamily: 'monospace')),
                              if (isOwner) ...[
                                const SizedBox(width: 4),
                                IconButton(
                                  icon: const Icon(Icons.edit_rounded, size: 16, color: PadmaTheme.primaryTeal),
                                  onPressed: () => _showEditLostFoundDialog(context, item),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, size: 16, color: PadmaTheme.urgentRed),
                                  onPressed: () {
                                    channelsVM.deleteLostFoundItem(item.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Notice deleted')),
                                    );
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(item.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary)),
                      const SizedBox(height: 4),
                      Text(item.description, style: const TextStyle(fontSize: 12.5, color: PadmaTheme.textSecondary)),
                      if (item.location != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded, size: 14, color: PadmaTheme.textMuted),
                            const SizedBox(width: 4),
                            Text(item.location!, style: const TextStyle(fontSize: 11.5, color: PadmaTheme.textMuted)),
                          ],
                        ),
                      ],
                      const SizedBox(height: 12),

                      // Action Row (Response, Offers, Comments)
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: PadmaTheme.busAmber,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.verified_rounded, size: 15),
                              label: Text(isLost ? 'I Found This' : 'This Is Mine', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                              onPressed: () => _showLostFoundResponseDialog(context, item),
                            ),
                          ),
                          const SizedBox(width: 6),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: PadmaTheme.borderLine),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            icon: const Icon(Icons.mark_chat_read_rounded, size: 14, color: PadmaTheme.primaryTeal),
                            label: Text('$responsesCount', style: const TextStyle(fontSize: 11.5, color: PadmaTheme.textPrimary, fontWeight: FontWeight.w600)),
                            onPressed: () {
                              setState(() {
                                _filterPostId = item.id;
                                _responseFilter = 'all';
                              });
                              _tabController.animateTo(2);
                            },
                          ),
                          const SizedBox(width: 6),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: _expandedCommentsPostIds.contains(item.id) ? PadmaTheme.busAmber : PadmaTheme.borderLine),
                              backgroundColor: _expandedCommentsPostIds.contains(item.id) ? PadmaTheme.busAmber.withValues(alpha: 0.12) : null,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            icon: Icon(Icons.chat_bubble_outline_rounded, size: 14, color: _expandedCommentsPostIds.contains(item.id) ? PadmaTheme.busAmber : PadmaTheme.textSecondary),
                            label: Text('${channelsVM.getCommentsForPost(item.id).length}', style: TextStyle(fontSize: 11.5, color: _expandedCommentsPostIds.contains(item.id) ? PadmaTheme.busAmber : PadmaTheme.textSecondary, fontWeight: FontWeight.w700)),
                            onPressed: () {
                              setState(() {
                                if (_expandedCommentsPostIds.contains(item.id)) {
                                  _expandedCommentsPostIds.remove(item.id);
                                } else {
                                  _expandedCommentsPostIds.add(item.id);
                                }
                              });
                            },
                          ),
                        ],
                      ),

                      // Expandable Comments Section
                      if (_expandedCommentsPostIds.contains(item.id)) ...[
                        const SizedBox(height: 12),
                        _buildCommentsSection(
                          context,
                          channelsVM,
                          item,
                          user,
                          channelsVM.getCommentsForPost(item.id),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }

  // -------------------------------------------------------------
  // Lost & Found Comments Section Widget
  // -------------------------------------------------------------
  Widget _buildCommentsSection(
    BuildContext context,
    ChannelsViewModel channelsVM,
    LostFoundModel item,
    dynamic user,
    List<PostCommentModel> comments,
  ) {
    final commentCtrl = _commentControllers.putIfAbsent(item.id, () => TextEditingController());
    final currentUserId = user?.id ?? 'user_student_padma';
    final currentUserName = user?.name ?? 'Padma Student';
    final currentUserTag = user?.chatTag ?? 'Padma_CSE_4-1_Mirpur10';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PadmaTheme.surfaceElevated.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PadmaTheme.borderLine.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.chat_bubble_rounded, size: 14, color: PadmaTheme.busAmber),
                  const SizedBox(width: 6),
                  Text(
                    'Comments & Discussion (${comments.length})',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    _expandedCommentsPostIds.remove(item.id);
                  });
                },
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.close_rounded, size: 16, color: PadmaTheme.textMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Comments List
          if (comments.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              child: const Text(
                'No comments yet. Be the first to leave a comment or question!',
                style: TextStyle(fontSize: 11.5, color: PadmaTheme.textMuted, fontStyle: FontStyle.italic),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, idx) {
                final c = comments[idx];
                final isMyComment = c.userId == currentUserId || c.userTag == currentUserTag;
                final isPostAuthor = item.authorTag == currentUserTag;
                final initials = c.userName.isNotEmpty
                    ? c.userName.substring(0, c.userName.length >= 2 ? 2 : 1).toUpperCase()
                    : 'ST';

                return Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: PadmaTheme.surfaceElevated.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: PadmaTheme.borderLine.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 10,
                                backgroundColor: PadmaTheme.primaryTeal.withValues(alpha: 0.2),
                                child: Text(initials, style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800, color: PadmaTheme.primaryTeal)),
                              ),
                              const SizedBox(width: 6),
                              Text(c.userName, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary)),
                              const SizedBox(width: 4),
                              Text('@${c.userTag}', style: const TextStyle(fontSize: 10, color: PadmaTheme.textMuted, fontFamily: 'monospace')),
                            ],
                          ),
                          if (isMyComment || isPostAuthor)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isMyComment)
                                  InkWell(
                                    onTap: () => _showEditCommentDialog(context, c),
                                    child: const Padding(
                                      padding: EdgeInsets.all(2),
                                      child: Icon(Icons.edit_rounded, size: 14, color: PadmaTheme.primaryTeal),
                                    ),
                                  ),
                                const SizedBox(width: 4),
                                InkWell(
                                  onTap: () {
                                    channelsVM.deletePostComment(c.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Comment deleted')),
                                    );
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(2),
                                    child: Icon(Icons.delete_outline_rounded, size: 14, color: PadmaTheme.urgentRed),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.only(left: 26),
                        child: Text(
                          c.content,
                          style: const TextStyle(fontSize: 12, color: PadmaTheme.textSecondary, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

          const SizedBox(height: 10),

          // Comment Input Box
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: commentCtrl,
                  style: const TextStyle(fontSize: 12, color: PadmaTheme.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Write a comment... (@ to mention)',
                    hintStyle: const TextStyle(color: PadmaTheme.textMuted, fontSize: 11.5),
                    filled: true,
                    fillColor: PadmaTheme.surface,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: PadmaTheme.borderLine),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: PadmaTheme.busAmber),
                    ),
                  ),
                  onSubmitted: (val) {
                    if (val.trim().isNotEmpty) {
                      channelsVM.addPostComment(
                        postId: item.id,
                        userId: currentUserId,
                        userName: currentUserName,
                        userTag: currentUserTag,
                        content: val.trim(),
                      );
                      commentCtrl.clear();
                    }
                  },
                ),
              ),
              const SizedBox(width: 6),
              Container(
                decoration: BoxDecoration(
                  color: PadmaTheme.busAmber,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: const Icon(Icons.send_rounded, size: 16, color: Colors.black),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  onPressed: () {
                    if (commentCtrl.text.trim().isNotEmpty) {
                      channelsVM.addPostComment(
                        postId: item.id,
                        userId: currentUserId,
                        userName: currentUserName,
                        userTag: currentUserTag,
                        content: commentCtrl.text.trim(),
                      );
                      commentCtrl.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Comment posted in real-time!')),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Tab 3: Post Responses Channel Feed
  // -------------------------------------------------------------
  Widget _buildPostResponsesTab(BuildContext context, ChannelsViewModel channelsVM, dynamic user) {
    var responses = channelsVM.postResponses;

    // Apply Filter
    if (_filterPostId != null) {
      responses = responses.where((r) => r.postId == _filterPostId).toList();
    } else if (_responseFilter == 'blood') {
      responses = responses.where((r) => r.postType == 'blood').toList();
    } else if (_responseFilter == 'lost_found') {
      responses = responses.where((r) => r.postType == 'lost_found').toList();
    } else if (_responseFilter == 'received') {
      responses = responses.where((r) => user != null && (r.requesterTag == user.chatTag || r.requesterId == user.id)).toList();
    } else if (_responseFilter == 'sent') {
      responses = responses.where((r) => user != null && (r.responderTag == user.chatTag || r.responderId == user.id)).toList();
    }

    return Column(
      children: [
        // Filter Tabs Row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: PadmaTheme.surfaceElevated,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                if (_filterPostId != null) ...[
                  InputChip(
                    label: const Text('Filtered Post (Clear)'),
                    labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: PadmaTheme.onPrimary),
                    backgroundColor: PadmaTheme.primaryTeal,
                    deleteIconColor: PadmaTheme.onPrimary,
                    onDeleted: () => setState(() => _filterPostId = null),
                  ),
                  const SizedBox(width: 8),
                ],
                _buildFilterChip('all', 'All Responses'),
                _buildFilterChip('blood', '🩸 Blood Donors'),
                _buildFilterChip('lost_found', '🔍 Lost & Found'),
                _buildFilterChip('received', '📬 Received on My Posts'),
                _buildFilterChip('sent', '📤 My Sent Offers'),
              ],
            ),
          ),
        ),

        // Responses List
        Expanded(
          child: responses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.mark_chat_read_rounded, size: 48, color: PadmaTheme.textMuted),
                      const SizedBox(height: 8),
                      const Text('No responses found', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary)),
                      const SizedBox(height: 4),
                      const Text('Donation offers and lost & found claims will appear here.', style: TextStyle(fontSize: 12, color: PadmaTheme.textMuted)),
                      if (_filterPostId != null) ...[
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => setState(() => _filterPostId = null),
                          child: const Text('View All Responses'),
                        ),
                      ],
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: responses.length,
                  itemBuilder: (context, index) {
                    final resp = responses[index];
                    final isBlood = resp.postType == 'blood';
                    final isMine = user != null && (user.id == resp.responderId || user.chatTag == resp.responderTag);
                    final isPostOwner = user != null && (user.id == resp.requesterId || user.chatTag == resp.requesterTag || user.role == 'admin');

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: PadmaTheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: PadmaTheme.borderLine),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: Post Reference + Status Badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    isBlood ? Icons.bloodtype_rounded : Icons.search_rounded,
                                    size: 16,
                                    color: isBlood ? PadmaTheme.urgentRed : PadmaTheme.busAmber,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    resp.postTitle,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: resp.status == 'accepted'
                                      ? PadmaTheme.successGreen.withValues(alpha: 0.15)
                                      : (resp.status == 'contacted' ? PadmaTheme.primaryTeal.withValues(alpha: 0.15) : PadmaTheme.busAmber.withValues(alpha: 0.15)),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  resp.status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: resp.status == 'accepted'
                                        ? PadmaTheme.successGreen
                                        : (resp.status == 'contacted' ? PadmaTheme.primaryTeal : PadmaTheme.busAmber),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 16),

                          // Responder Profile Details
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: isBlood ? PadmaTheme.urgentRed.withValues(alpha: 0.2) : PadmaTheme.busAmber.withValues(alpha: 0.2),
                                child: Text(
                                  resp.responderName.isNotEmpty ? resp.responderName.substring(0, 1).toUpperCase() : 'S',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: isBlood ? PadmaTheme.urgentRed : PadmaTheme.busAmber,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(resp.responderName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                                        const SizedBox(width: 4),
                                        Text('(${resp.department} ${resp.semester})', style: const TextStyle(fontSize: 11, color: PadmaTheme.textMuted)),
                                      ],
                                    ),
                                    Text('@${resp.responderTag}', style: const TextStyle(fontSize: 10.5, color: PadmaTheme.primaryTeal, fontFamily: 'monospace')),
                                  ],
                                ),
                              ),
                              if (isMine || isPostOwner)
                                Row(
                                  children: [
                                    if (isMine)
                                      IconButton(
                                        icon: const Icon(Icons.edit_rounded, size: 16, color: PadmaTheme.primaryTeal),
                                        onPressed: () => _showEditResponseDialog(context, resp),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                                      ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, size: 16, color: PadmaTheme.urgentRed),
                                      onPressed: () {
                                        channelsVM.deletePostResponse(resp.id);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Response deleted')),
                                        );
                                      },
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Availability and Notes
                          if (resp.availability != null && resp.availability!.isNotEmpty) ...[
                            Row(
                              children: [
                                const Icon(Icons.schedule_rounded, size: 13, color: PadmaTheme.textMuted),
                                const SizedBox(width: 4),
                                Text('Availability: ${resp.availability!}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: PadmaTheme.textSecondary)),
                              ],
                            ),
                            const SizedBox(height: 4),
                          ],
                          if (resp.notes != null && resp.notes!.isNotEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: PadmaTheme.surfaceElevated,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(resp.notes!, style: const TextStyle(fontSize: 12, color: PadmaTheme.textPrimary)),
                            ),
                          const SizedBox(height: 12),

                          // Direct Contact Buttons (Call & FB Link)
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: PadmaTheme.primaryTeal,
                                    foregroundColor: PadmaTheme.onPrimary,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                  icon: const Icon(Icons.call_rounded, size: 15),
                                  label: Text('Call (${resp.contactNumber})', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Calling ${resp.contactNumber}...')),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFF1877F2)),
                                    foregroundColor: const Color(0xFF1877F2),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                  icon: const Icon(Icons.open_in_new_rounded, size: 15),
                                  label: const Text('Facebook Link', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Opening Facebook profile: ${resp.fbLink ?? "None"}')),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),

                          // Post Owner Triage Bar
                          if (isPostOwner) ...[
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Text('Mark Status: ', style: TextStyle(fontSize: 10, color: PadmaTheme.textMuted, fontWeight: FontWeight.w700)),
                                const SizedBox(width: 6),
                                InkWell(
                                  onTap: () => channelsVM.updateResponseStatus(resp.id, 'contacted'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(color: PadmaTheme.surfaceElevated, borderRadius: BorderRadius.circular(6)),
                                    child: const Text('Contacted', style: TextStyle(fontSize: 10.5, color: PadmaTheme.primaryTeal, fontWeight: FontWeight.w700)),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                InkWell(
                                  onTap: () => channelsVM.updateResponseStatus(resp.id, 'accepted'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(color: PadmaTheme.successGreen.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                                    child: const Text('Accept', style: TextStyle(fontSize: 10.5, color: PadmaTheme.successGreen, fontWeight: FontWeight.w700)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _responseFilter == key && _filterPostId == null;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? PadmaTheme.onPrimary : PadmaTheme.textSecondary,
          ),
        ),
        selected: isSelected,
        selectedColor: PadmaTheme.primaryTeal,
        backgroundColor: PadmaTheme.surface,
        onSelected: (_) => setState(() {
          _responseFilter = key;
          _filterPostId = null;
        }),
      ),
    );
  }

  // -------------------------------------------------------------
  // Tab 4: Contact Admin
  // -------------------------------------------------------------
  Widget _buildContactAdminTab(BuildContext context, ChannelsViewModel channelsVM, dynamic user) {
    final selectedAdmin = channelsVM.selectedContactAdminId;
    final userId = user?.id ?? 'user_student_padma';
    final messages = channelsVM.getContactAdminMessagesForUser(userId, selectedAdmin);

    return Column(
      children: [
        // Admin Selection Dropdown / Selector Bar
        Container(
          padding: const EdgeInsets.all(12),
          color: PadmaTheme.surfaceElevated,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🔒 PRIVATE 1-ON-1 ADMIN CHAT (Only you & chosen admin can see this conversation)',
                style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF8B5CF6)),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => channelsVM.setSelectedContactAdmin('admin_1'),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: selectedAdmin == 'admin_1' ? PadmaTheme.surface : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selectedAdmin == 'admin_1' ? const Color(0xFF8B5CF6) : PadmaTheme.borderLine,
                            width: selectedAdmin == 'admin_1' ? 1.5 : 0.8,
                          ),
                        ),
                        child: const Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: Color(0xFF8B5CF6),
                              child: Text('RI', style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w800)),
                            ),
                            SizedBox(width: 6),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Admin 1 (Rafiqul)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                                  Text('Transport Officer', style: TextStyle(fontSize: 9, color: PadmaTheme.textMuted)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: () => channelsVM.setSelectedContactAdmin('admin_2'),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: selectedAdmin == 'admin_2' ? PadmaTheme.surface : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selectedAdmin == 'admin_2' ? const Color(0xFF8B5CF6) : PadmaTheme.borderLine,
                            width: selectedAdmin == 'admin_2' ? 1.5 : 0.8,
                          ),
                        ),
                        child: const Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: Color(0xFF8B5CF6),
                              child: Text('SR', style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w800)),
                            ),
                            SizedBox(width: 6),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Admin 2 (Shahed)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                                  Text('Student Welfare', style: TextStyle(fontSize: 9, color: PadmaTheme.textMuted)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Messages Feed
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final msg = messages[index];
              final isAdminMsg = msg.senderRole.contains('Admin');

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                alignment: isAdminMsg ? Alignment.centerLeft : Alignment.centerRight,
                child: Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isAdminMsg ? PadmaTheme.surfaceElevated : PadmaTheme.primaryTeal.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isAdminMsg ? const Color(0xFF8B5CF6).withValues(alpha: 0.4) : PadmaTheme.primaryTeal.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            msg.senderName,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: isAdminMsg ? const Color(0xFF8B5CF6) : PadmaTheme.primaryTeal,
                            ),
                          ),
                          if (msg.badgeText != null) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(color: const Color(0xFF8B5CF6), borderRadius: BorderRadius.circular(3)),
                              child: Text(msg.badgeText!, style: const TextStyle(fontSize: 7.5, color: Colors.white, fontWeight: FontWeight.w800)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(msg.text, style: const TextStyle(fontSize: 13, color: PadmaTheme.textPrimary)),
                      const SizedBox(height: 4),
                      Text(
                        '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 9.5, color: PadmaTheme.textMuted),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Message input bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: const BoxDecoration(
            color: PadmaTheme.surface,
            border: Border(top: BorderSide(color: PadmaTheme.borderLine)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _contactChatController,
                  style: const TextStyle(fontSize: 13.5, color: PadmaTheme.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Message ${selectedAdmin == 'admin_1' ? 'Engr. Rafiqul Islam' : 'Dr. Shahed Rahman'} (Private)...',
                    hintStyle: const TextStyle(fontSize: 12, color: PadmaTheme.textMuted),
                    filled: true,
                    fillColor: PadmaTheme.surfaceElevated,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.send_rounded, size: 18),
                onPressed: () {
                  final text = _contactChatController.text.trim();
                  if (text.isEmpty) return;

                  channelsVM.sendContactAdminMessage(
                    text: text,
                    senderName: user?.name ?? 'Padma Student',
                    senderTag: user?.chatTag ?? 'Student_CSE_4-1_Campus',
                    adminId: selectedAdmin,
                    studentId: user?.id ?? 'user_student_padma',
                  );
                  _contactChatController.clear();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
