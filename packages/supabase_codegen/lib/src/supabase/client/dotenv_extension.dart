import 'dart:developer';
import 'dart:io';

import 'package:dotenv/dotenv.dart';
import 'package:supabase_codegen/src/supabase/client/supabase_env_keys.dart';

/// Dotenv extension
extension DotenvExtension on DotEnv {
  /// Extract the required keys from the environment file at [envPath]
  ({String supabaseUrl, String supabaseKey}) extractKeys(
    String envPath, [
    Map<String, String>? env,
  ]) {
    return extractFromPlatformEnv() ?? extractFromPath(envPath);
  }

  /// Extract the keys from the platform environment
  ({String supabaseKey, String supabaseUrl})? extractFromPlatformEnv([
    Map<String, String>? env,
  ]) {
    final environment = env ?? Platform.environment;
    final hasUrl = environment.containsKey(supabaseEnvKeys.url);
    if (!hasUrl) {
      return null;
    }
    final supabaseKey =
        environment[supabaseEnvKeys.anonKey] ??
        environment[supabaseEnvKeys.key] ??
        '';
    if (supabaseKey.isEmpty) {
      return null;
    }

    return (
      supabaseUrl: environment[supabaseEnvKeys.url]!,
      supabaseKey: supabaseKey,
    );
  }

  /// Extract the required keys from the [envPath]
  ({String supabaseKey, String supabaseUrl}) extractFromPath(String envPath) {
    load([envPath]);
    final hasUrl = isEveryDefined([supabaseEnvKeys.url]);
    if (!hasUrl) {
      log('Unable to find env: ${File.fromUri(Uri.file(envPath)).path}');
      throw Exception('Missing ${supabaseEnvKeys.url} in $envPath file. ');
    }

    final supabaseKey = getOrElse(
      supabaseEnvKeys.anonKey,
      () => this[supabaseEnvKeys.key] ?? '',
    );
    if (supabaseKey.isEmpty) {
      throw Exception(
        'Ensure that either ${supabaseEnvKeys.anonKey} '
        'or ${supabaseEnvKeys.anonKey} is set to ensure access to the database',
      );
    }

    // Get the config from env
    final supabaseUrl = this[supabaseEnvKeys.url]!;
    return (supabaseUrl: supabaseUrl, supabaseKey: supabaseKey);
  }
}
