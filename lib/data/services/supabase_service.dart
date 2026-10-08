import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';

/// Central singleton service wrapper for Supabase Client interactions in Padma.
class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Returns the underlying SupabaseClient.
  SupabaseClient get client {
    try {
      return Supabase.instance.client;
    } catch (e) {
      debugPrint('[SupabaseService] Client requested before full init: $e');
      rethrow;
    }
  }

  /// Initializes the Supabase client instance.
  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        // ignore: deprecated_member_use
        anonKey: SupabaseConfig.supabaseAnonKey,
        realtimeClientOptions: const RealtimeClientOptions(
          eventsPerSecond: 20,
        ),
      );
      _isInitialized = true;
      debugPrint('[SupabaseService] Initialized successfully with ${SupabaseConfig.supabaseUrl}');
    } catch (e) {
      debugPrint('[SupabaseService] Initialization failed: $e');
      // If already initialized, mark true
      if (e.toString().contains('already initialized')) {
        _isInitialized = true;
      }
    }
  }

  /// Safe helper to get current logged in Supabase user
  User? get currentAuthUser => _isInitialized ? client.auth.currentUser : null;

  /// Stream of Supabase Auth state changes
  Stream<AuthState>? get authStateChanges =>
      _isInitialized ? client.auth.onAuthStateChange : null;
}
