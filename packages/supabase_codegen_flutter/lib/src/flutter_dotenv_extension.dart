import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_codegen/supabase_codegen.dart';

/// Dotenv extension
extension DotenvExtension on DotEnv {
  /// Extract the required keys from the environment file at [envPath]
  Future<({String supabaseUrl, String supabaseKey})> extractKeys(
    String envPath,
  ) async {
    await load(fileName: envPath);
    final hasUrl = isEveryDefined([supabaseEnvKeys.url]);
    if (!hasUrl) {
      throw Exception(
        '[GenerateTypes] Missing ${supabaseEnvKeys.url} in $envPath file. ',
      );
    }

    final supabaseKey = get(
      supabaseEnvKeys.anonKey,
      fallback: get(supabaseEnvKeys.key, fallback: ''),
    );
    if (supabaseKey.isEmpty) {
      throw Exception(
        '[GenerateTypes] Ensure that either ${supabaseEnvKeys.anonKey} '
        'or ${supabaseEnvKeys.anonKey} is set to ensure access to the database',
      );
    }

    // Get the config from env
    final supabaseUrl = get(supabaseEnvKeys.url);
    return (supabaseUrl: supabaseUrl, supabaseKey: supabaseKey);
  }
}
