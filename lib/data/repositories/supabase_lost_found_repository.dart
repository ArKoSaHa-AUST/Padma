import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/lost_found_model.dart';
import '../mock/mock_lost_found.dart';
import 'lost_found_repository.dart';
import '../services/supabase_service.dart';

/// Dynamic Supabase-backed implementation of [LostFoundRepository].
/// Streams real-time lost and found posts from PostgreSQL `lost_found_items` table.
class SupabaseLostFoundRepository implements LostFoundRepository {
  final SupabaseClient _client;

  List<LostFoundModel> _items = List.from(MockLostFound.initialItems);
  final _controller = StreamController<List<LostFoundModel>>.broadcast();
  StreamSubscription<List<Map<String, dynamic>>>? _subscription;

  SupabaseLostFoundRepository({SupabaseClient? client})
      : _client = client ?? SupabaseService.instance.client {
    _initStream();
  }

  void _initStream() {
    try {
      _subscription = _client
          .from('lost_found_items')
          .stream(primaryKey: ['id'])
          .order('created_at', ascending: false)
          .listen((records) {
        final List<LostFoundModel> list = records.map((r) {
          final typeStr = r['type']?.toString() ?? 'lost';
          final type = typeStr == 'found' ? LostFoundType.found : LostFoundType.lost;

          return LostFoundModel(
            id: r['id']?.toString() ?? '',
            title: r['title']?.toString() ?? '',
            description: r['description']?.toString() ?? '',
            type: type,
            location: r['location']?.toString() ?? '',
            contact: r['contact']?.toString() ?? '',
            imageUrl: r['image_url']?.toString(),
            authorName: r['author_name']?.toString() ?? 'AUST Student',
            createdAt: r['created_at'] != null
                ? DateTime.tryParse(r['created_at'].toString()) ?? DateTime.now()
                : DateTime.now(),
          );
        }).toList();

        if (list.isNotEmpty) {
          _items = list;
        }

        _emit();
      }, onError: (err) {
        debugPrint('[SupabaseLostFoundRepository] Stream error: $err');
      });
    } catch (e) {
      debugPrint('[SupabaseLostFoundRepository] Init stream exception: $e');
    }
  }

  void _emit() {
    if (!_controller.isClosed) {
      _controller.add(List.unmodifiable(_items));
    }
  }

  @override
  Stream<List<LostFoundModel>> getItemsStream() {
    Future.microtask(_emit);
    return _controller.stream;
  }

  @override
  Future<void> addItem({
    required String title,
    required String description,
    required LostFoundType type,
    required String location,
    required String contact,
    String? imageUrl,
    required String authorName,
  }) async {
    final itemId = 'lf_${DateTime.now().millisecondsSinceEpoch}';
    final newItem = LostFoundModel(
      id: itemId,
      title: title,
      description: description,
      type: type,
      location: location,
      contact: contact,
      imageUrl: imageUrl,
      authorName: authorName,
      createdAt: DateTime.now(),
    );

    _items.insert(0, newItem);
    _emit();

    try {
      await _client.from('lost_found_items').insert({
        'id': itemId,
        'title': title,
        'description': description,
        'type': type.name,
        'location': location,
        'contact': contact,
        'image_url': imageUrl,
        'author_name': authorName,
        'status': 'active',
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('[SupabaseLostFoundRepository] Error adding item: $e');
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
