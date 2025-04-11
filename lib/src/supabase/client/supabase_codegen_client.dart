import 'package:meta/meta.dart';
import 'package:supabase/supabase.dart';

/// Supabase Codegen Client
abstract class SupabaseCodegenClientBase {
  /// Default env path
  final String defaultEnvPath = '';

  /// Client type
  @visibleForTesting
  String platform = '';

  /// Are we running in a test environment
  @visibleForTesting
  bool isRunningInTest = false;

  /// Cached client
  @visibleForTesting
  SupabaseClient? supabaseClient;

  /// Set the [supabaseClient] to be used by classes generated by the package
  SupabaseClient setClient(SupabaseClient client);

  /// Create the supabase client with the provided [url] and [key]
  Future<SupabaseClient> createClient(String url, String key);

  /// Load the supabase client using environment variables
  @visibleForTesting
  Future<SupabaseClient> loadClient([String envPath = '.env']);

  /// Load the supabase client
  SupabaseClient loadSupabaseClient([String envPath = '.env']);

  /// Load the mock supabase client
  @visibleForTesting
  SupabaseClient loadMockSupabaseClient();
}
