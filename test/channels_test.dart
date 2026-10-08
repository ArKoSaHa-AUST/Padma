import 'package:flutter_test/flutter_test.dart';
import 'package:padma/data/models/emergency_request.dart';
import 'package:padma/ui/features/channels/view_models/channels_view_model.dart';

void main() {
  group('ChannelsViewModel Unit Tests', () {
    test('Can send message in general channel', () {
      final channelsVM = ChannelsViewModel();
      final initialCount = channelsVM.generalMessages.length;

      channelsVM.sendGeneralMessage('Hello AUST campus!');
      expect(channelsVM.generalMessages.length, initialCount + 1);
      expect(channelsVM.generalMessages.last.text, 'Hello AUST campus!');
    });

    test('Can filter emergency requests by blood only', () {
      final channelsVM = ChannelsViewModel();
      channelsVM.setRequestFilter('blood');

      for (var req in channelsVM.requests) {
        expect(req.category, RequestCategory.blood);
      }
    });

    test('Can toggle reaction on a message', () {
      final channelsVM = ChannelsViewModel();
      final msg = channelsVM.generalMessages.first;
      final initialCount = msg.reactions.first.count;

      channelsVM.toggleReaction(msg, msg.reactions.first.emoji);
      expect(msg.reactions.first.count, isNot(equals(initialCount)));
    });

    test('Can broadcast official short messages to general and bus channels', () {
      final channelsVM = ChannelsViewModel();
      final initialGeneralCount = channelsVM.generalMessages.length;
      final initialBus1Count = channelsVM.bus1Messages.length;

      channelsVM.broadcastDispatchMessage(
        'general',
        '⏱️ **STATION WAIT NOTICE**: The bus will wait at mirpur 10 untill 12:30',
        senderName: 'Padma Dispatch Control (Admin)',
        senderRole: 'Transport Admin',
      );

      channelsVM.broadcastDispatchMessage(
        'bus-1-mirpur',
        '⏱️ **WAIT NOTICE**: The bus will wait at mirpur 10 untill 12:30',
        senderName: 'Padma Dispatch Control (Admin)',
        senderRole: 'Transport Admin',
      );

      expect(channelsVM.generalMessages.length, initialGeneralCount + 1);
      expect(channelsVM.generalMessages.last.text, contains('The bus will wait at mirpur 10 untill 12:30'));
      expect(channelsVM.generalMessages.last.senderRole, 'Transport Admin');

      expect(channelsVM.bus1Messages.length, initialBus1Count + 1);
      expect(channelsVM.bus1Messages.last.text, contains('The bus will wait at mirpur 10 untill 12:30'));
    });

    test('Supports all client channels in admin portal', () {
      final channelsVM = ChannelsViewModel();
      expect(channelsVM.getMessagesForChannel('general'), isNotEmpty);
      expect(channelsVM.getMessagesForChannel('announcements'), isNotEmpty);
      expect(channelsVM.getMessagesForChannel('bus-1-mirpur'), isNotEmpty);
      expect(channelsVM.getMessagesForChannel('bus-2-uttara'), isNotEmpty);
      expect(channelsVM.getMessagesForChannel('emergency-blood'), isNotEmpty);
      expect(channelsVM.getMessagesForChannel('ride-share'), isNotEmpty);
    });
  });
}
