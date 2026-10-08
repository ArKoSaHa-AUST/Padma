import '../models/channel_model.dart';

class MockChannels {
  static const List<ChannelModel> allChannels = [
    // INFO
    ChannelModel(
      id: 'announcements',
      name: 'announcements',
      subtitle: 'Official Transport Notices',
      category: ChannelCategory.info,
      type: ChannelType.announcement,
      isReadOnlyForStudents: true,
      unreadCount: 2,
    ),
    ChannelModel(
      id: 'schedule',
      name: 'schedule',
      subtitle: 'Official Campus Timetables',
      category: ChannelCategory.info,
      type: ChannelType.schedule,
      isReadOnlyForStudents: true,
      unreadCount: 0,
    ),

    // COMMUNITY
    ChannelModel(
      id: 'requests',
      name: 'requests',
      subtitle: 'Emergency Blood & Urgent Aid',
      category: ChannelCategory.community,
      type: ChannelType.request,
      isReadOnlyForStudents: false,
      unreadCount: 3,
    ),
    ChannelModel(
      id: 'general',
      name: 'general',
      subtitle: 'AUST Student Transit Lounge',
      category: ChannelCategory.community,
      type: ChannelType.general,
      isReadOnlyForStudents: false,
      unreadCount: 5,
    ),
    ChannelModel(
      id: 'lost-and-found',
      name: 'lost-and-found',
      subtitle: 'Recover Items Left in Buses',
      category: ChannelCategory.community,
      type: ChannelType.lostFound,
      isReadOnlyForStudents: false,
      unreadCount: 1,
    ),
    ChannelModel(
      id: 'feedback',
      name: 'feedback-and-complaints',
      subtitle: 'Direct Line to Transport Office',
      category: ChannelCategory.community,
      type: ChannelType.feedback,
      isReadOnlyForStudents: false,
      unreadCount: 0,
    ),

    // BUSES
    ChannelModel(
      id: 'bus-1-mirpur',
      name: 'bus-1-mirpur',
      subtitle: 'Mirpur 12 ⇄ AUST Campus',
      category: ChannelCategory.buses,
      type: ChannelType.bus,
      busId: 'bus_1',
      unreadCount: 1,
    ),
    ChannelModel(
      id: 'bus-2-uttara',
      name: 'bus-2-uttara',
      subtitle: 'Uttara House Building ⇄ AUST Campus',
      category: ChannelCategory.buses,
      type: ChannelType.bus,
      busId: 'bus_2',
      unreadCount: 0,
    ),
    ChannelModel(
      id: 'bus-3-mohammadpur',
      name: 'bus-3-mohammadpur',
      subtitle: 'Mohammadpur ⇄ AUST Campus',
      category: ChannelCategory.buses,
      type: ChannelType.bus,
      busId: 'bus_3',
      unreadCount: 0,
    ),
  ];
}
