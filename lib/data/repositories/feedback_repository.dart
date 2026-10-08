import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/feedback_model.dart';

abstract class FeedbackRepository {
  Future<void> submitFeedback({
    required String userId,
    required String userName,
    required FeedbackCategory category,
    required String message,
    String? attachmentUrl,
  });
}

class InMemoryFeedbackRepository implements FeedbackRepository {
  final List<FeedbackModel> _submissions = [];

  @override
  Future<void> submitFeedback({
    required String userId,
    required String userName,
    required FeedbackCategory category,
    required String message,
    String? attachmentUrl,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final item = FeedbackModel(
      id: 'fb_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      userName: userName,
      category: category,
      message: message,
      attachmentUrl: attachmentUrl,
      createdAt: DateTime.now(),
    );
    _submissions.add(item);
  }
}

final feedbackRepositoryProvider = Provider<FeedbackRepository>((ref) {
  return InMemoryFeedbackRepository();
});
