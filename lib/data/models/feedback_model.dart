enum FeedbackCategory {
  busDelay,
  driverConduct,
  overcrowding,
  appBug,
  routeSuggestion,
  other;

  String get label {
    switch (this) {
      case FeedbackCategory.busDelay:
        return 'Bus Delay';
      case FeedbackCategory.driverConduct:
        return 'Driver / Staff Conduct';
      case FeedbackCategory.overcrowding:
        return 'Overcrowding';
      case FeedbackCategory.appBug:
        return 'App Bug / Issue';
      case FeedbackCategory.routeSuggestion:
        return 'Route Suggestion';
      case FeedbackCategory.other:
        return 'Other';
    }
  }
}

class FeedbackModel {
  final String id;
  final String userId;
  final String userName;
  final FeedbackCategory category;
  final String message;
  final String? attachmentUrl;
  final DateTime createdAt;

  const FeedbackModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.category,
    required this.message,
    this.attachmentUrl,
    required this.createdAt,
  });
}
