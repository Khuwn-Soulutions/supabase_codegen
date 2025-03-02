import 'package:dotenv/dotenv.dart';
import 'package:supabase/supabase.dart';

/// Cached client
SupabaseClient? _client;

/// Load the supabase client
SupabaseClient loadSupabaseClient() {
  return _client ??= _loadClient();
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
