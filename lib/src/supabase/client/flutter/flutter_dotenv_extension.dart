import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_codegen/src/supabase/client/supabase_env_keys.dart';

/// Dotenv extension
extension DotenvExtension on DotEnv {
  /// Extract the required keys from the environment file at [envPath]
  Future<({String supabaseUrl, String supabaseKey})> extractKeys(
    String envPath,
  ) async {
    await load(fileName: envPath);
    final hasUrl = isEveryDefined([envKeys.url]);
    if (!hasUrl) {
      throw Exception(
        '[GenerateTypes] Missing ${envKeys.url} in $envPath file. ',
      );
    }

    final supabaseKey = get(
      envKeys.anonKey,
      fallback: get(envKeys.key, fallback: ''),
    );
    if (supabaseKey.isEmpty) {
      throw Exception(
        '[GenerateTypes] Ensure that either ${envKeys.anonKey} '
        'or ${envKeys.anonKey} is set to ensure access to the database',
      );
    }

    // Get the config from env
    final supabaseUrl = get(envKeys.url);
    return (supabaseUrl: supabaseUrl, supabaseKey: supabaseKey);
  }
}
