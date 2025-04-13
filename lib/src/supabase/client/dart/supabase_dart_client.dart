import 'package:dotenv/dotenv.dart';
import 'package:meta/meta.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_codegen/supabase_codegen.dart';
// Ensure correct extract keys
// ignore: always_use_package_imports
import 'dotenv_extension.dart';

/// Supabase Codegen Client
class SupabaseCodegenClient implements SupabaseCodegenClientBase {
  /// Default env path
  @override
  final defaultEnvPath = '.env';

  /// Client type
  @override
  @visibleForTesting
  String platform = 'dart';

  /// Are we running in a test environment
  @override
  @visibleForTesting
  bool isRunningInTest = false;

  /// Cached client
  @override
  @visibleForTesting
  SupabaseClient? supabaseClient;

  /// Set the [supabaseClient] to be used by classes generated by the package
  @override
  SupabaseClient setClient(SupabaseClient client) => supabaseClient = client;

  /// Create the supabase client with the provided [url] and [key]
  @override
  Future<SupabaseClient> createClient(String url, String key) async =>
      setClient(SupabaseClient(url, key));

  /// Load the supabase client using environment variables at [envPath]
  @override
  @visibleForTesting
  Future<SupabaseClient> loadClientFromEnv([String? envPath]) async =>
      _loadClientFromEnv(envPath ?? defaultEnvPath);

  /// Load the supabase client
  @override
  SupabaseClient loadSupabaseClient([String? envPath]) {
    return supabaseClient ??= _loadClientFromEnv(envPath ?? defaultEnvPath);
  }

  /// Load the mock supabase client
  @override
  @visibleForTesting
  SupabaseClient loadMockSupabaseClient() {
    // Hide warning as the method is marked visible for testing
    // ignore: invalid_use_of_visible_for_testing_member
    return setClient(mockSupabase);
  }

  /// Load the [SupabaseClient] getting the credentials from [envPath]
  SupabaseClient _loadClientFromEnv(String envPath) {
    final (:supabaseUrl, :supabaseKey) = DotEnv().extractKeys(envPath);
    final supabaseClient = SupabaseClient(supabaseUrl, supabaseKey);
    return setClient(supabaseClient);
  }
}
