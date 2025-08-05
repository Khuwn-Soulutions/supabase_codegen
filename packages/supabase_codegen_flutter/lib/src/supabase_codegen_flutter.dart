import 'package:supabase_flutter/supabase_flutter.dart';

/// {@template supabase_codegen_flutter}
/// Supabase Codegen Flutter Package
/// {@endtemplate}
class SupabaseCodegenFlutter {
  /// Supabase instance
  static Supabase get supabase => Supabase.instance;

  /// Client instance
  static SupabaseClient get client => supabase.client;

  /// Auth client instance
  static GoTrueClient get auth => client.auth;

  /// Realtime client instance
  static RealtimeClient get realtime => client.realtime;

  /// Storage client instance
  static SupabaseStorageClient get storage => client.storage;

  /// Functions client instance
  static FunctionsClient get functions => client.functions;
}
