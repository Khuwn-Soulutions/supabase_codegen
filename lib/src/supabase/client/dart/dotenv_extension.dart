import 'package:dotenv/dotenv.dart';
import 'package:supabase_codegen/src/supabase/client/supabase_env_keys.dart';

/// Dotenv extension
extension DotenvExtension on DotEnv {
  /// Extract the required keys from the environment file at [envPath]
  ({String supabaseUrl, String supabaseKey}) extractKeys(String envPath) {
    load([envPath]);
    final hasUrl = isEveryDefined([envKeys.url]);
    if (!hasUrl) {
      throw Exception(
        '[GenerateTypes] Missing ${envKeys.url} in $envPath file. ',
      );
    }

    final supabaseKey = getOrElse(
      envKeys.anonKey,
      () => this[envKeys.key] ?? '',
    );
    if (supabaseKey.isEmpty) {
      throw Exception(
        '[GenerateTypes] Ensure that either ${envKeys.anonKey} '
        'or ${envKeys.anonKey} is set to ensure access to the database',
      );
    }

    // Get the config from env
    final supabaseUrl = this[envKeys.url]!;
    return (supabaseUrl: supabaseUrl, supabaseKey: supabaseKey);
  }
}
