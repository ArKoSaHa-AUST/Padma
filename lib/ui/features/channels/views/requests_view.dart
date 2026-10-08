import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../auth/view_models/auth_view_model.dart';
import '../view_models/channels_view_model.dart';
import '../../../../data/models/lost_found_model.dart';
import 'submit_complain_view.dart';

class RequestsView extends StatefulWidget {
  final VoidCallback onOpenDrawer;
  final String activeSubTab; // 'blood-request', 'lost-found', 'contact-admin', 'submit-complain'

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

  @override
  void initState() {
    super.initState();
    int initialIdx = 0;
    if (widget.activeSubTab == 'lost-found') initialIdx = 1;
    if (widget.activeSubTab == 'contact-admin') initialIdx = 2;
    if (widget.activeSubTab == 'submit-complain') initialIdx = 3;

    _tabController = TabController(length: 4, vsync: this, initialIndex: initialIdx);
  }

  @override
  void didUpdateWidget(covariant RequestsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeSubTab != oldWidget.activeSubTab) {
      int idx = 0;
      if (widget.activeSubTab == 'lost-found') idx = 1;
      if (widget.activeSubTab == 'contact-admin') idx = 2;
      if (widget.activeSubTab == 'submit-complain') idx = 3;
      _tabController.animateTo(idx);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _contactChatController.dispose();
    super.dispose();
  }

  // Dialog to Post Blood Request
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
                            const Text('Required Date (optional)', style: TextStyle(fontSize: 11, color: PadmaTheme.textSecondary, fontWeight: FontWeight.w600)),
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
                      hintText: 'Provide any additional context or urgency details...',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                    ),
                  ),
                  const SizedBox(height: 10),

                  const Text('Extra Information (optional)', style: TextStyle(fontSize: 11, color: PadmaTheme.textSecondary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: extraInfoCtrl,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: PadmaTheme.surfaceElevated,
                      hintText: 'e.g. Transportation will be provided for donor',
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
                      const SnackBar(content: Text('Please fill in all required fields (Title, Blood Group, Hospital, Contact, Email)')),
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

  // Dialog to Post Lost and Found
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
                      hintText: 'Describe the item, color, markings, and where it was lost/found...',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                    ),
                  ),
                  const SizedBox(height: 10),

                  const Text('Picture URL (optional)', style: TextStyle(fontSize: 11, color: PadmaTheme.textSecondary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: imgUrlCtrl,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: PadmaTheme.surfaceElevated,
                      hintText: 'https://... or photo link',
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
          tabs: const [
            Tab(icon: Icon(Icons.bloodtype_rounded, size: 18), text: 'Blood Request'),
            Tab(icon: Icon(Icons.search_rounded, size: 18), text: 'Lost and Found'),
            Tab(icon: Icon(Icons.support_agent_rounded, size: 18), text: 'Contact Admin'),
            Tab(icon: Icon(Icons.description_outlined, size: 18), text: 'Submit Complain'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. BLOOD REQUEST TAB
          _buildBloodRequestTab(context, channelsVM),

          // 2. LOST AND FOUND TAB
          _buildLostFoundTab(context, channelsVM),

          // 3. CONTACT ADMIN (1-on-1 Private Chat)
          _buildContactAdminTab(context, channelsVM, user),

          // 4. SUBMIT COMPLAIN (Google Docs Form)
          SubmitComplainView(onOpenDrawer: widget.onOpenDrawer),
        ],
      ),
    );
  }

  Widget _buildBloodRequestTab(BuildContext context, ChannelsViewModel channelsVM) {
    final list = channelsVM.bloodRequests;

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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  req.title,
                                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary),
                                ),
                                Text(
                                  'Posted by ${req.requesterName} (@${req.requesterTag})',
                                  style: const TextStyle(fontSize: 11, color: PadmaTheme.textMuted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.local_hospital_rounded, size: 16, color: PadmaTheme.urgentRed),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              req.hospitalName,
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: PadmaTheme.textPrimary),
                            ),
                          ),
                        ],
                      ),
                      if (req.patientDetails != null) ...[
                        const SizedBox(height: 4),
                        Text('Patient: ${req.patientDetails!}', style: const TextStyle(fontSize: 12, color: PadmaTheme.textSecondary)),
                      ],
                      if (req.messageBody != null) ...[
                        const SizedBox(height: 6),
                        Text(req.messageBody!, style: const TextStyle(fontSize: 12.5, color: PadmaTheme.textPrimary)),
                      ],
                      if (req.requiredDate != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 14, color: PadmaTheme.primaryTeal),
                            const SizedBox(width: 6),
                            Text('Needed: ${req.requiredDate!}', style: const TextStyle(fontSize: 11.5, color: PadmaTheme.primaryTeal, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                      if (req.extraInformation != null) ...[
                        const SizedBox(height: 4),
                        Text('Info: ${req.extraInformation!}', style: const TextStyle(fontSize: 11.5, color: PadmaTheme.textMuted)),
                      ],
                      const SizedBox(height: 12),

                      // Contact actions
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: PadmaTheme.urgentRed),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.call_rounded, size: 16, color: PadmaTheme.urgentRed),
                              label: Text(req.contactNumber, style: const TextStyle(fontSize: 12, color: PadmaTheme.urgentRed, fontWeight: FontWeight.w700)),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Calling attendant: ${req.contactNumber}')),
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
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Thank you! Contact details sent to requester.')),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildLostFoundTab(BuildContext context, ChannelsViewModel channelsVM) {
    final list = channelsVM.lostFoundItems;

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
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.title,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
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
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Posted by @${item.authorTag}', style: const TextStyle(fontSize: 10.5, color: PadmaTheme.primaryTeal, fontFamily: 'monospace')),
                          if (item.contact != null)
                            TextButton.icon(
                              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(40, 20)),
                              icon: const Icon(Icons.call_rounded, size: 14, color: PadmaTheme.primaryTeal),
                              label: Text(item.contact!, style: const TextStyle(fontSize: 11, color: PadmaTheme.primaryTeal, fontWeight: FontWeight.w600)),
                              onPressed: () {},
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

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
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 12,
                              backgroundColor: Color(0xFF8B5CF6),
                              child: Text('RI', style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w800)),
                            ),
                            const SizedBox(width: 6),
                            const Expanded(
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
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 12,
                              backgroundColor: Color(0xFF8B5CF6),
                              child: Text('SR', style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w800)),
                            ),
                            const SizedBox(width: 6),
                            const Expanded(
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
