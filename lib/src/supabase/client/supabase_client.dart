import 'package:dotenv/dotenv.dart';
import 'package:meta/meta.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_codegen/supabase_codegen.dart';

/// Cached client
SupabaseClient? _client;

/// Load the supabase client
SupabaseClient loadSupabaseClient() {
  return _client ??= _loadClient();
}

/// Load the mock supabase client
@visibleForTesting
SupabaseClient loadMockSupabaseClient() {
  return _client = mockSupabase;
}

SupabaseClient _loadClient() {
  final dotenv = DotEnv()..load();

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
