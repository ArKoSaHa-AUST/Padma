/// Centralized Supabase configuration constants for Padma.
///
/// Values can be overridden at build-time using `--dart-define`:
/// ```bash
/// flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
/// ```
class SupabaseConfig {
  SupabaseConfig._();

  /// Supabase Project REST / Realtime URL
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://usherhmmpcfayggmkito.supabase.co',
  );

  /// Supabase Public Anonymous Key
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_AbsEe-WhHHl0w3wfAyVpdQ_elmxoArC',
  );

  /// Supabase JWKS endpoint for token validation
  static const String jwksUrl = String.fromEnvironment(
    'SUPABASE_JWKS_URL',
    defaultValue: 'https://usherhmmpcfayggmkito.supabase.co/auth/v1/.well-known/jwks.json',
  );

  /// PostgreSQL Direct Connection Host
  static const String dbHost = 'db.usherhmmpcfayggmkito.supabase.co';

  /// PostgreSQL Pooler Connection Host (ap-southeast-1)
  static const String dbPoolerHost = 'aws-0-ap-southeast-1.pooler.supabase.com';

  /// PostgreSQL Default Port
  static const int dbPort = 5432;

  /// PostgreSQL Database Name
  static const String dbName = 'postgres';
}
