import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lost_found_model.dart';
import '../mock/mock_lost_found.dart';

abstract class LostFoundRepository {
  Stream<List<LostFoundModel>> getItemsStream();
  Future<void> addItem({
    required String title,
    required String description,
    required LostFoundType type,
    required String location,
    required String contact,
    String? imageUrl,
    required String authorName,
  });
  void dispose();
}

class InMemoryLostFoundRepository implements LostFoundRepository {
  final List<LostFoundModel> _items = List.from(MockLostFound.initialItems);
  final _controller = StreamController<List<LostFoundModel>>.broadcast();

  InMemoryLostFoundRepository() {
    _emit();
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
    final newItem = LostFoundModel(
      id: 'lf_${DateTime.now().millisecondsSinceEpoch}',
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
  }

  @override
  void dispose() {
    _controller.close();
  }
}

final lostFoundRepositoryProvider = Provider<LostFoundRepository>((ref) {
  final repo = InMemoryLostFoundRepository();
  ref.onDispose(repo.dispose);
  return repo;
});

final lostFoundItemsProvider = StreamProvider<List<LostFoundModel>>((ref) {
  final repo = ref.watch(lostFoundRepositoryProvider);
  return repo.getItemsStream();
});
