import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/feedback_model.dart';
import 'feedback_repository.dart';
import '../services/supabase_service.dart';

/// Dynamic Supabase-backed implementation of [FeedbackRepository].
class SupabaseFeedbackRepository implements FeedbackRepository {
  final SupabaseClient _client;

  SupabaseFeedbackRepository({SupabaseClient? client})
      : _client = client ?? SupabaseService.instance.client;

  @override
  Future<void> submitFeedback({
    required String userId,
    required String userName,
    required FeedbackCategory category,
    required String message,
    String? attachmentUrl,
  }) async {
    final fbId = 'fb_${DateTime.now().millisecondsSinceEpoch}';
    try {
      await _client.from('feedback').insert({
        'id': fbId,
        'user_id': userId,
        'user_name': userName,
        'category': category.name,
        'message': message,
        'attachment_url': attachmentUrl,
        'status': 'open',
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('[SupabaseFeedbackRepository] submitFeedback error: $e');
    }
  }
}
