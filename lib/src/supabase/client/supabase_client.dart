import 'package:dotenv/dotenv.dart';
import 'package:meta/meta.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_codegen/supabase_codegen.dart';

/// Cached client
@visibleForTesting
SupabaseClient? supabaseClient;

/// Load the supabase client
SupabaseClient loadSupabaseClient([String envPath = '.env']) {
  return supabaseClient ??= loadClient(envPath);
}

/// Load the mock supabase client
@visibleForTesting
SupabaseClient loadMockSupabaseClient() {
  // Hide warning as the method is marked visible for testing
  // ignore: invalid_use_of_visible_for_testing_member
  return supabaseClient = mockSupabase;
}

/// Load the supabase client using environment variables
@visibleForTesting
SupabaseClient loadClient([String envPath = '.env']) {
  final dotenv = DotEnv()..load([envPath]);

  /// Ensure all keys are present
  final keys = ['SUPABASE_URL', 'SUPABASE_KEY'];
  if (!dotenv.isEveryDefined(keys)) {
    throw Exception(
      'Please ensure all supabase keys are defined: ${keys.join(',')}',
    );
  }

  /// Return supabase client
  return SupabaseClient(dotenv['SUPABASE_URL']!, dotenv['SUPABASE_KEY']!);
}
