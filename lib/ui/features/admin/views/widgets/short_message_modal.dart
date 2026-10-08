import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme.dart';
import '../../../channels/view_models/channels_view_model.dart';
import '../../../channels/views/bus_telemetry_chat_view.dart';
import '../../view_models/admin_view_model.dart';

class ShortMessageModal extends StatefulWidget {
  final AdminBusItem bus;

  const ShortMessageModal({super.key, required this.bus});

  static void show(BuildContext context, {required AdminBusItem bus}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ShortMessageModal(bus: bus),
    );
  }

  @override
  State<ShortMessageModal> createState() => _ShortMessageModalState();
}

class _ShortMessageModalState extends State<ShortMessageModal> {
  late String _selectedPlace;
  late String _selectedTime;
  String _templateType = 'wait'; // 'wait', 'traffic', 'departure', 'custom'
  late TextEditingController _customMsgController;
  final TextEditingController _customPlaceController = TextEditingController();

  bool _broadcastToGeneral = true;
  bool _broadcastToBusChannel = true;
  bool _pinToRouteProgression = true;
  bool _isCustomPlace = false;

  @override
  void initState() {
    super.initState();
    // Default place: if bus has an active stop or default to Mirpur 10 / DSS or current stop
    final isMirpur = widget.bus.id.contains('1') || widget.bus.title.toLowerCase().contains('mirpur');
    if (isMirpur) {
      _selectedPlace = 'Mirpur 10';
    } else {
      _selectedPlace = 'DSS';
    }

    // Default time: ~12:30 or now + 6 mins
    final now = DateTime.now();
    final waitTarget = now.add(const Duration(minutes: 6));
    _selectedTime = DateFormat('hh:mm a').format(waitTarget);

    _customMsgController = TextEditingController(text: _computeMessage());
  }

  @override
  void dispose() {
    _customMsgController.dispose();
    _customPlaceController.dispose();
    super.dispose();
  }

  String get _currentPlaceName => _isCustomPlace && _customPlaceController.text.trim().isNotEmpty
      ? _customPlaceController.text.trim()
      : _selectedPlace;

  String _computeMessage() {
    final place = _currentPlaceName;
    final time = _selectedTime;
    switch (_templateType) {
      case 'wait':
        return 'The bus will wait at $place untill $time';
      case 'traffic':
        return 'The bus is held up in traffic near $place untill $time';
      case 'departure':
        return 'The bus will depart from $place at $time';
      case 'custom':
      default:
        return _customMsgController.text.isNotEmpty
            ? _customMsgController.text
            : 'The bus will wait at $place untill $time';
    }
  }

  void _updateMessagePreview() {
    if (_templateType != 'custom') {
      _customMsgController.text = _computeMessage();
    }
    setState(() {});
  }

  void _setTimeDelta(int minutes) {
    final now = DateTime.now();
    final target = now.add(Duration(minutes: minutes));
    _selectedTime = DateFormat('hh:mm a').format(target);
    _updateMessagePreview();
  }

  void _pickCustomTime() async {
    final timeOfDay = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: PadmaTheme.primaryTeal,
              surface: PadmaTheme.surface,
              onSurface: PadmaTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (timeOfDay != null) {
      final now = DateTime.now();
      final dt = DateTime(now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
      setState(() {
        _selectedTime = DateFormat('hh:mm a').format(dt);
        _updateMessagePreview();
      });
    }
  }

  void _sendShortMessage() {
    final adminVM = context.read<AdminViewModel>();
    final channelsVM = context.read<ChannelsViewModel>();
    final busChannel = (widget.bus.id == 'bus_1' || widget.bus.id == 'bus-1') ? 'bus-1-mirpur' : 'bus-2-uttara';
    final message = _customMsgController.text.trim().isNotEmpty ? _customMsgController.text.trim() : _computeMessage();

    // 1. If pin to route progression is enabled, update bus wait notice
    if (_pinToRouteProgression) {
      adminVM.setStoppageWaitNotice(
        busId: widget.bus.id,
        stoppageName: _currentPlaceName,
        untilTime: _selectedTime,
        message: message,
        broadcastToGeneral: false, // We'll broadcast directly with custom tag
        broadcastToBusChannel: false,
      );
    }

    // 2. Broadcast to General Client Side Channel
    if (_broadcastToGeneral) {
      channelsVM.broadcastDispatchMessage(
        'general',
        '⏱️ **STATION WAIT NOTICE**: $message',
        senderName: 'Padma Dispatch Control (Admin)',
        senderRole: 'Transport Admin',
        badgeText: 'OFFICIAL ALERT',
      );
    }

    // 3. Broadcast to Bus Route Channel
    if (_broadcastToBusChannel) {
      channelsVM.broadcastDispatchMessage(
        busChannel,
        '⏱️ **WAIT NOTICE**: $message',
        senderName: 'Padma Dispatch Control (Admin)',
        senderRole: 'Transport Admin',
        badgeText: 'WAIT ALERT',
      );
    }

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: PadmaTheme.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: PadmaTheme.primaryTeal),
        ),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: PadmaTheme.successGreen, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Short message broadcasted to ${_broadcastToGeneral ? "#general" : ""} ${_broadcastToBusChannel ? "#$busChannel" : ""}!',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: PadmaTheme.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBus1 = widget.bus.id == 'bus_1' || widget.bus.id == 'bus-1';
    final busChannel = isBus1 ? 'bus-1-mirpur' : 'bus-2-uttara';
    final activeWait = widget.bus.activeWaitNotice;

    // Quick Place presets including Mirpur 10 & DSS (which usually wait extra 5-6 mins)
    final quickPlaces = ['Mirpur 10', 'DSS', ...widget.bus.stoppages.map((s) => s.name)];
    final uniquePlaces = quickPlaces.toSet().toList();

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
        border: Border(top: BorderSide(color: PadmaTheme.primaryTeal, width: 2)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Modal Handle & Header
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: PadmaTheme.textMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: PadmaTheme.primaryTeal.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: PadmaTheme.primaryTeal.withValues(alpha: 0.4)),
                      ),
                      child: const Icon(Icons.quickreply_rounded, color: PadmaTheme.primaryTeal, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dispatch Short Message',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: PadmaTheme.textPrimary),
                        ),
                        Text(
                          'Broadcast stoppage wait alert to general students',
                          style: const TextStyle(fontSize: 11, color: PadmaTheme.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: PadmaTheme.textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Active Wait Alert Banner (if one exists)
            if (activeWait != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: PadmaTheme.busAmber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: PadmaTheme.busAmber.withValues(alpha: 0.6)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.hourglass_top_rounded, color: PadmaTheme.busAmber, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Active Wait Notice on Timeline',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: PadmaTheme.busAmber),
                          ),
                          Text(
                            activeWait.message,
                            style: const TextStyle(fontSize: 11.5, color: PadmaTheme.textPrimary),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<AdminViewModel>().clearStoppageWaitNotice(widget.bus.id);
                        setState(() {});
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: PadmaTheme.urgentRed,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                      child: const Text('Clear', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),

            // 1. Template Type Chips
            const Text(
              'MESSAGE TEMPLATE',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: PadmaTheme.textMuted, letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTemplateChip(
                    id: 'wait',
                    icon: Icons.timer_rounded,
                    label: 'Stoppage Wait (Extra 5-6m)',
                    isSelected: _templateType == 'wait',
                  ),
                  const SizedBox(width: 8),
                  _buildTemplateChip(
                    id: 'traffic',
                    icon: Icons.traffic_rounded,
                    label: 'Traffic Hold',
                    isSelected: _templateType == 'traffic',
                  ),
                  const SizedBox(width: 8),
                  _buildTemplateChip(
                    id: 'departure',
                    icon: Icons.departure_board_rounded,
                    label: 'Departure Time',
                    isSelected: _templateType == 'departure',
                  ),
                  const SizedBox(width: 8),
                  _buildTemplateChip(
                    id: 'custom',
                    icon: Icons.edit_note_rounded,
                    label: 'Custom Edit',
                    isSelected: _templateType == 'custom',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Select Stoppage Place
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '1. SELECT PLACE / STOPPAGE',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: PadmaTheme.textMuted, letterSpacing: 0.5),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _isCustomPlace = !_isCustomPlace;
                      _updateMessagePreview();
                    });
                  },
                  icon: Icon(_isCustomPlace ? Icons.list_rounded : Icons.add_location_alt_rounded, size: 14),
                  label: Text(
                    _isCustomPlace ? 'Choose From List' : 'Custom Place',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: PadmaTheme.primaryTeal),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (_isCustomPlace)
              TextField(
                controller: _customPlaceController,
                onChanged: (_) => _updateMessagePreview(),
                style: const TextStyle(fontSize: 13, color: PadmaTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: 'e.g. Mirpur 10, DSS, Farmgate, DOHS Gate',
                  hintStyle: const TextStyle(fontSize: 13, color: PadmaTheme.textMuted),
                  filled: true,
                  fillColor: PadmaTheme.surfaceElevated,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.primaryTeal)),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: uniquePlaces.map((place) {
                  final isSelected = _selectedPlace == place;
                  final isSpecialWaitStop = place.toLowerCase().contains('mirpur 10') || place.toLowerCase().contains('dss');

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedPlace = place;
                        _updateMessagePreview();
                      });
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? PadmaTheme.primaryTeal.withValues(alpha: 0.2)
                            : PadmaTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? PadmaTheme.primaryTeal
                              : (isSpecialWaitStop ? PadmaTheme.busAmber.withValues(alpha: 0.4) : PadmaTheme.borderLine),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSpecialWaitStop ? Icons.stars_rounded : Icons.location_on_rounded,
                            size: 13,
                            color: isSelected
                                ? PadmaTheme.primaryTeal
                                : (isSpecialWaitStop ? PadmaTheme.busAmber : PadmaTheme.textMuted),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            place,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? PadmaTheme.primaryTeal : PadmaTheme.textPrimary,
                            ),
                          ),
                          if (isSpecialWaitStop) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: PadmaTheme.busAmberContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('Wait Point', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: PadmaTheme.busAmber)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 16),

            // 3. Select Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '2. SET WAIT TIME / DEADLINE',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: PadmaTheme.textMuted, letterSpacing: 0.5),
                ),
                TextButton.icon(
                  onPressed: _pickCustomTime,
                  icon: const Icon(Icons.access_time_rounded, size: 14),
                  label: const Text('Pick Exact Time', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: PadmaTheme.primaryTeal)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildQuickTimeChip('+5 Mins', () => _setTimeDelta(5)),
                _buildQuickTimeChip('+6 Mins', () => _setTimeDelta(6)),
                _buildQuickTimeChip('+10 Mins', () => _setTimeDelta(10)),
                _buildQuickTimeChip('+15 Mins', () => _setTimeDelta(15)),
                _buildExactTimeChip('12:30 PM'),
                _buildExactTimeChip('12:45 PM'),
                _buildExactTimeChip('01:15 PM'),
                _buildExactTimeChip('01:30 PM'),
              ],
            ),
            const SizedBox(height: 16),

            // 4. Live Message Preview Box
            const Text(
              'LIVE DISPATCH MESSAGE PREVIEW',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: PadmaTheme.textMuted, letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: PadmaTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: PadmaTheme.primaryTeal.withValues(alpha: 0.6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: PadmaTheme.primaryTealContainer,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.campaign_rounded, size: 14, color: PadmaTheme.primaryTeal),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Padma Dispatch Control (Admin)',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: PadmaTheme.primaryTealContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'OFFICIAL ALERT',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: PadmaTheme.primaryTeal),
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'Just now',
                        style: TextStyle(fontSize: 10, color: PadmaTheme.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (_templateType == 'custom')
                    TextField(
                      controller: _customMsgController,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 13.5, color: PadmaTheme.textPrimary, height: 1.3),
                      decoration: const InputDecoration(
                        hintText: 'Enter dispatch text...',
                        hintStyle: TextStyle(fontSize: 13, color: PadmaTheme.textMuted),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    )
                  else
                    Text(
                      '"${_computeMessage()}"',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: PadmaTheme.textPrimary,
                        height: 1.35,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 5. Target Broadcast Destinations
            const Text(
              'BROADCAST TARGETS',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: PadmaTheme.textMuted, letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: PadmaTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: PadmaTheme.borderLine),
              ),
              child: Column(
                children: [
                  CheckboxListTile(
                    value: _broadcastToGeneral,
                    onChanged: (val) => setState(() => _broadcastToGeneral = val ?? true),
                    dense: true,
                    activeColor: PadmaTheme.primaryTeal,
                    title: const Row(
                      children: [
                        Icon(Icons.tag_rounded, size: 16, color: PadmaTheme.textPrimary),
                        SizedBox(width: 6),
                        Text('General Client Channel (#general)', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    subtitle: const Text('Visible to all students on the campus community chat', style: TextStyle(fontSize: 10.5, color: PadmaTheme.textMuted)),
                  ),
                  const Divider(height: 1),
                  CheckboxListTile(
                    value: _broadcastToBusChannel,
                    onChanged: (val) => setState(() => _broadcastToBusChannel = val ?? true),
                    dense: true,
                    activeColor: PadmaTheme.primaryTeal,
                    title: Row(
                      children: [
                        const Icon(Icons.alt_route_rounded, size: 16, color: PadmaTheme.busAmber),
                        const SizedBox(width: 6),
                        Text('Bus Route Feed (#$busChannel)', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    subtitle: Text('Directly notify commuters registered for ${widget.bus.title}', style: const TextStyle(fontSize: 10.5, color: PadmaTheme.textMuted)),
                  ),
                  const Divider(height: 1),
                  CheckboxListTile(
                    value: _pinToRouteProgression,
                    onChanged: (val) => setState(() => _pinToRouteProgression = val ?? true),
                    dense: true,
                    activeColor: PadmaTheme.primaryTeal,
                    title: const Row(
                      children: [
                        Icon(Icons.timeline_rounded, size: 16, color: PadmaTheme.successGreen),
                        SizedBox(width: 6),
                        Text('Pin to Route Progression & Stops', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    subtitle: const Text('Shows live wait indicator badge on client & admin tracker map', style: TextStyle(fontSize: 10.5, color: PadmaTheme.textMuted)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 6. Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _sendShortMessage,
                    icon: const Icon(Icons.send_rounded, size: 16),
                    label: const Text('Broadcast Short Message', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PadmaTheme.primaryTeal,
                      foregroundColor: PadmaTheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Center(
              child: TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BusTelemetryChatView(
                        onOpenDrawer: () => Navigator.pop(context),
                        channelId: busChannel,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.forum_outlined, size: 14, color: PadmaTheme.textMuted),
                label: Text('Open Full #${busChannel} Chat', style: const TextStyle(fontSize: 11.5, color: PadmaTheme.textMuted)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateChip({
    required String id,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          _templateType = id;
          _updateMessagePreview();
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? PadmaTheme.primaryTeal.withValues(alpha: 0.2) : PadmaTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? PadmaTheme.primaryTeal : PadmaTheme.borderLine,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isSelected ? PadmaTheme.primaryTeal : PadmaTheme.textMuted),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? PadmaTheme.primaryTeal : PadmaTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickTimeChip(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: PadmaTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: PadmaTheme.primaryTeal.withValues(alpha: 0.4)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: PadmaTheme.primaryTeal),
        ),
      ),
    );
  }

  Widget _buildExactTimeChip(String timeStr) {
    final isSelected = _selectedTime == timeStr;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTime = timeStr;
          _updateMessagePreview();
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? PadmaTheme.primaryTeal.withValues(alpha: 0.2) : PadmaTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? PadmaTheme.primaryTeal : PadmaTheme.borderLine,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          timeStr,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? PadmaTheme.primaryTeal : PadmaTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}
