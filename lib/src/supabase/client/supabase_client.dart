import 'package:meta/meta.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_codegen/supabase_codegen.dart';

/// Client to use for loading
final _client = SupabaseCodegenClient();

/// Create the supabase client with the provided [url] and [key]
Future<SupabaseClient> createClient(String url, String key) =>
    _client.createClient(url, key);

/// Load a new supabase client using environment variables at [envPath]
///
/// The default path is the value of [SupabaseCodegenClient.defaultEnvPath]
/// for the current environment
Future<SupabaseClient> loadClientFromEnv([String? envPath]) async =>
    _client.loadClientFromEnv(envPath);

/// Load the current instance of the [SupabaseClient].
/// If no current instance, load the environment variables at [envPath]
/// and creates a new instance.
///
/// The default path is the value of [SupabaseCodegenClient.defaultEnvPath]
/// for the current environment
SupabaseClient loadSupabaseClient([String? envPath]) {
  return _client.loadSupabaseClient(envPath);
}

/// Load the mock supabase client
@visibleForTesting
SupabaseClient loadMockSupabaseClient() {
  // Only exposed in tests
  // ignore: invalid_use_of_visible_for_testing_member
  return _client.loadMockSupabaseClient();
}
