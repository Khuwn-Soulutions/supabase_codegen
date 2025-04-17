import 'package:meta/meta.dart';
import 'package:supabase_codegen_flutter/supabase_codegen_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Client to use for loading
final _client = SupabaseCodegenFlutterClient();

/// Set the [SupabaseClient] to be used by classes generated by the package
SupabaseClient setClient(SupabaseClient client) => _client.setClient(client);

/// Create the supabase client with the provided [url] and [key]
Future<SupabaseClient> createClient(String url, String key) =>
    _client.createClient(url, key);

/// Load a new supabase client using environment variables at [envPath]
///
/// The default path is [SupabaseCodegenFlutterClient.defaultEnvPath]
Future<SupabaseClient> loadClientFromEnv([String? envPath]) async =>
    _client.loadClientFromEnv(envPath);

/// Load the current instance of the [SupabaseClient].
///
/// This should be called after [createClient] or [loadClientFromEnv]
///
/// If no current instance, an [AssertionError] is thrown
SupabaseClient loadSupabaseClient() {
  return _client.loadSupabaseClient();
}

/// Load the mock supabase client
// ignore: invalid_use_of_visible_for_testing_member
@visibleForTesting
Future<SupabaseClient> loadMockSupabaseClient() =>
    // Only exposed in tests
    // ignore: invalid_use_of_visible_for_testing_member
    MockSupabaseCodegenClient().loadMockSupabaseClient();
