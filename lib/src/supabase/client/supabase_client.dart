import 'package:meta/meta.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_codegen/supabase_codegen.dart';

/// Client to use for loading
final _client = SupabaseCodegenClient();

/// Create the supabase client with the provided [url] and [key]
Future<SupabaseClient> createClient(String url, String key) =>
    _client.createClient(url, key);

/// Load the supabase client using environment variables
Future<SupabaseClient> loadClient([String envPath = '.env']) async =>
    _client.loadClient(envPath);

/// Load the supabase client
SupabaseClient loadSupabaseClient([String envPath = '.env']) {
  return _client.loadSupabaseClient(envPath);
}

/// Load the mock supabase client
@visibleForTesting
SupabaseClient loadMockSupabaseClient() {
  // Only exposed in tests
  // ignore: invalid_use_of_visible_for_testing_member
  return _client.loadMockSupabaseClient();
}
