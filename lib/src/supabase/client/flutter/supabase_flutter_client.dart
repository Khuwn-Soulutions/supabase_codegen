import 'dart:async';

import 'package:flutter_dotenv/flutter_dotenv.dart';
// Imported for testing
// ignore: depend_on_referenced_packages
import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:supabase_codegen/supabase_codegen.dart' hide DotenvExtension;
import 'package:supabase_flutter/supabase_flutter.dart';

// Ensure correct extract keys
// ignore: always_use_package_imports
import 'flutter_dotenv_extension.dart';

/// Supabase Codegen Client
class SupabaseCodegenClient implements SupabaseCodegenClientBase {
  /// Default env path
  @override
  final defaultEnvPath = 'config.env';

  /// Client type
  @override
  @visibleForTesting
  String platform = 'flutter';

  /// Was [Supabase] initialized
  @visibleForTesting
  bool supabaseInitialized = false;

  /// Are we running in a test environment
  @override
  @visibleForTesting
  bool isRunningInTest = false;

  /// Cached client
  @override
  @visibleForTesting
  SupabaseClient? supabaseClient;

  /// Set the [supabaseClient] to be used by classes generated by the package
  @override
  SupabaseClient setClient(SupabaseClient client) => supabaseClient = client;

  /// Create the supabase client with the provided [url] and [key]
  @override
  Future<SupabaseClient> createClient(String url, String key) async {
    await initSupabase(url: url, key: key);
    return setClient(Supabase.instance.client);
  }

  /// Load the supabase client using environment variables
  @override
  Future<SupabaseClient> loadClientFromEnv([String? envPath]) async {
    final (:supabaseUrl, :supabaseKey) =
        await DotEnv().extractKeys(envPath ?? defaultEnvPath);
    return createClient(supabaseUrl, supabaseKey);
  }

  /// Init Supabase
  // coverage:ignore-start
  @visibleForTesting
  Future<void> initSupabase({
    required String url,
    required String key,
    Client? httpClient,
  }) async {
    final accessToken = isRunningInTest ? () async => 'Bearer: $key' : null;
    await Supabase.initialize(
      url: url,
      anonKey: key,
      accessToken: accessToken,
      httpClient: httpClient,
    );
    supabaseInitialized = true;
  }
  // coverage:ignore-end

  /// Load the supabase client
  @override
  SupabaseClient loadSupabaseClient([String? envPath]) {
    if (supabaseClient == null) {
      throw AssertionError('You must call createClient or loadClient first');
    }
    return supabaseClient!;
  }

  /// Load the mock supabase client
  @override
  @visibleForTesting
  SupabaseClient loadMockSupabaseClient() {
    unawaited(
      initSupabase(
        url: 'url',
        key: 'key',
        // Used within testing only
        // ignore: invalid_use_of_visible_for_testing_member
        httpClient: mockSupabaseHttpClient,
      ),
    );
    // Hide warning as the method is marked visible for testing
    // ignore: invalid_use_of_visible_for_testing_member
    return setClient(Supabase.instance.client = mockSupabase);
  }
}
