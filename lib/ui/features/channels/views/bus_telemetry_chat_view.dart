import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../admin/view_models/admin_view_model.dart';
import '../view_models/channels_view_model.dart';

class BusTelemetryChatView extends StatefulWidget {
  final VoidCallback onOpenDrawer;
  final String channelId;

  const BusTelemetryChatView({
    super.key,
    required this.onOpenDrawer,
    this.channelId = 'bus-1-mirpur',
  });

  @override
  State<BusTelemetryChatView> createState() => _BusTelemetryChatViewState();
}

class _BusTelemetryChatViewState extends State<BusTelemetryChatView> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  String? _selectedStoppage;

  final List<String> _quickPings = [
    '📍 Standing at stoppage',
    '💺 Any empty seat left?',
    '⚠️ Heavy traffic reported ahead',
    '🚌 Bus passing current stop',
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage([String? text]) {
    final msgText = text ?? _textController.text;
    if (msgText.trim().isEmpty) return;
    final channelsVM = context.read<ChannelsViewModel>();

    if (widget.channelId == 'bus-2-uttara' || widget.channelId == 'bus_2') {
      channelsVM.sendBus2Message(msgText);
    } else {
      channelsVM.sendBus1Message(msgText);
    }

    _textController.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final channelsVM = context.watch<ChannelsViewModel>();
    final adminVM = context.watch<AdminViewModel>();

    final isBus2 = widget.channelId == 'bus-2-uttara' || widget.channelId == 'bus_2' || widget.channelId == 'bus-2';
    final targetBusId = isBus2 ? 'bus_2' : 'bus_1';
    final channelName = isBus2 ? 'bus-2-uttara' : 'bus-1-mirpur';
    final routeTitle = isBus2 ? 'Uttara House Building ➔ AUST Tejgaon' : 'Mirpur 12 ➔ AUST Tejgaon';
    final busPillLabel = isBus2 ? 'PADMA 2' : 'PADMA 1';

    final bus = adminVM.fleet.firstWhere(
      (b) => b.id == targetBusId,
      orElse: () => adminVM.fleet.first,
    );

    _selectedStoppage ??= bus.currentStop;

    final messages = channelsVM.getMessagesForChannel(channelName);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: widget.onOpenDrawer,
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            const Icon(Icons.alt_route_rounded, size: 20, color: PadmaTheme.busAmber),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(channelName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                Text(routeTitle, style: const TextStyle(fontSize: 10, color: PadmaTheme.textMuted)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // 1. Pinned Live Telemetry Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: PadmaTheme.surfaceElevated,
              border: Border(bottom: BorderSide(color: PadmaTheme.borderLine)),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: bus.isTripEnded ? PadmaTheme.urgentRed : PadmaTheme.successGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    bus.isTripEnded
                        ? 'Status: Trip Ended • Bus currently offline at depot'
                        : 'Live: ${bus.currentSpeed} km/h • Current: ${bus.currentStop} ➔ Next: ${bus.nextStop} (${bus.etaMinutes}m)',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: PadmaTheme.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: PadmaTheme.busAmberContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    busPillLabel,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: PadmaTheme.busAmber),
                  ),
                ),
              ],
            ),
          ),

          // 2. STOPPAGE DISPATCH UPDATE BAR (DROPDOWN + GREEN TICK BUTTON)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: PadmaTheme.surface,
              border: const Border(bottom: BorderSide(color: PadmaTheme.borderLine)),
            ),
            child: Row(
              children: [
                const Icon(Icons.edit_location_alt_rounded, size: 16, color: PadmaTheme.primaryTeal),
                const SizedBox(width: 6),
                const Text('Update Stop:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: PadmaTheme.textMuted)),
                const SizedBox(width: 8),
                // Stoppage Dropdown
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                      color: PadmaTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: PadmaTheme.borderLine),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        isDense: true,
                        value: bus.stoppages.any((s) => s.name == _selectedStoppage)
                            ? _selectedStoppage
                            : bus.stoppages.first.name,
                        dropdownColor: PadmaTheme.surfaceElevated,
                        icon: const Icon(Icons.arrow_drop_down, color: PadmaTheme.primaryTeal, size: 18),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: PadmaTheme.textPrimary),
                        items: bus.stoppages.map((stoppage) {
                          final idx = bus.stoppages.indexOf(stoppage) + 1;
                          return DropdownMenuItem<String>(
                            value: stoppage.name,
                            child: Text(
                              '$idx. ${stoppage.name}',
                              style: const TextStyle(fontSize: 12, color: PadmaTheme.textPrimary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedStoppage = value;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // GREEN TICK / MARKDOWN CONFIRM BUTTON
                InkWell(
                  onTap: () {
                    final selectedStop = _selectedStoppage ?? bus.currentStop;
                    adminVM.updateBusStoppage(
                      bus.id,
                      selectedStop,
                      onBroadcastMessage: (cId, msg) {
                        channelsVM.broadcastDispatchMessage(cId, msg);
                      },
                    );

                    Future.delayed(const Duration(milliseconds: 150), () {
                      if (_scrollController.hasClients) {
                        _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                        );
                      }
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✅ Bus arrived at $selectedStop. Heading towards ${bus.nextStop}'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: PadmaTheme.successGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_rounded, size: 16, color: Colors.black),
                        SizedBox(width: 4),
                        Text(
                          'Update',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final timeFormatted = DateFormat('hh:mm a').format(msg.timestamp);

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: msg.isTelemetry ? const EdgeInsets.all(12) : EdgeInsets.zero,
                  decoration: msg.isTelemetry
                      ? BoxDecoration(
                          color: PadmaTheme.primaryTealContainer.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: PadmaTheme.primaryTeal.withValues(alpha: 0.3)),
                        )
                      : null,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: msg.isTelemetry ? PadmaTheme.primaryTealContainer : PadmaTheme.surfaceElevated,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            msg.isTelemetry ? Icons.satellite_alt_rounded : Icons.person,
                            size: 18,
                            color: msg.isTelemetry ? PadmaTheme.primaryTeal : PadmaTheme.textMuted,
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
                                Text(
                                  msg.senderName,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: msg.isTelemetry ? PadmaTheme.primaryTeal : PadmaTheme.textPrimary,
                                  ),
                                ),
                                if (msg.badgeText != null) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: PadmaTheme.primaryTealContainer,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      msg.badgeText!,
                                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: PadmaTheme.primaryTeal),
                                    ),
                                  ),
                                ],
                                const Spacer(),
                                Text(
                                  timeFormatted,
                                  style: const TextStyle(fontSize: 10, color: PadmaTheme.textMuted),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              msg.text,
                              style: const TextStyle(fontSize: 13, color: PadmaTheme.textPrimary, height: 1.3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // 4. Quick Pings Carousel
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: _quickPings.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final ping = _quickPings[index];
                return InkWell(
                  onTap: () => _sendMessage(ping),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: PadmaTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: PadmaTheme.borderLine),
                    ),
                    child: Center(
                      child: Text(
                        ping,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: PadmaTheme.textSecondary),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 5. Message Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: PadmaTheme.surface,
              border: Border(top: BorderSide(color: PadmaTheme.borderLine)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: PadmaTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: PadmaTheme.borderLine),
                      ),
                      child: TextField(
                        controller: _textController,
                        style: const TextStyle(fontSize: 13, color: PadmaTheme.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Message #$channelName...',
                          hintStyle: const TextStyle(fontSize: 13, color: PadmaTheme.textMuted),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send_rounded, color: PadmaTheme.primaryTeal),
                    onPressed: () => _sendMessage(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
