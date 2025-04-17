import 'dart:convert';

// All classes and methods visible only in tests
// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:supabase_codegen_flutter/supabase_codegen_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Copied from package:supabase_flutter/test/utils.dart
/// Construct session data for a given expiration date
@visibleForTesting
({String accessToken, String sessionString}) getSessionData(
  DateTime accessTokenExpireDateTime,
) {
  final accessTokenExpiresAt =
      accessTokenExpireDateTime.millisecondsSinceEpoch ~/ 1000;
  final accessTokenMid = base64.encode(
    utf8.encode(
      json.encode(
        {
          'exp': accessTokenExpiresAt,
          'sub': '1234567890',
          'role': 'authenticated',
        },
      ),
    ),
  );
  final accessToken = 'any.$accessTokenMid.any';
  final sessionString = '''
  {
    "access_token":"$accessToken",
    "expires_in": ${accessTokenExpireDateTime.difference(DateTime.now()).inSeconds},
    "refresh_token":"-yeS4omysFs9tpUYBws9Rg",
    "token_type":"bearer",
    "provider_token":null,
    "provider_refresh_token":null,
    "user":{
      "id":"4d2583da-8de4-49d3-9cd1-37a9a74f55bd",
      "app_metadata":{
        "provider":"email",
        "providers":["email"]
      },
      "user_metadata":{
        "Hello":"World"
      },
      "aud":"",
      "email":"fake1680338105@email.com",
      "phone":"",
      "created_at":"2023-04-01T08:35:05.208586Z",
      "confirmed_at":null,
      "email_confirmed_at":"2023-04-01T08:35:05.220096086Z",
      "phone_confirmed_at":null,
      "last_sign_in_at":"2023-04-01T08:35:05.222755878Z",
      "role":"",
      "updated_at":"2023-04-01T08:35:05.226938Z"
    }
  }
''';
  return (accessToken: accessToken, sessionString: sessionString);
}

/// Copied from package:supabase_flutter/test/widget_test_stubs.dart
@visibleForTesting
class MockLocalStorage extends LocalStorage {
  @override
  Future<void> initialize() async {}
  @override
  Future<String?> accessToken() async {
    return getSessionData(DateTime.now().add(const Duration(hours: 1)))
        .sessionString;
  }

  @override
  Future<bool> hasAccessToken() async => true;
  @override
  Future<void> persistSession(String persistSessionString) async {}
  @override
  Future<void> removePersistedSession() async {}
}

/// Copied from package:supabase_flutter/test/widget_test_stubs.dart
@visibleForTesting
class MockAsyncStorage extends GotrueAsyncStorage {
  final Map<String, String> _map = {};

  @override
  Future<String?> getItem({required String key}) async {
    return _map[key];
  }

  @override
  Future<void> removeItem({required String key}) async {
    _map.remove(key);
  }

  @override
  Future<void> setItem({required String key, required String value}) async {
    _map[key] = value;
  }
}

/// Mock Supabase Codegen Client
@visibleForTesting
class MockSupabaseCodegenClient extends SupabaseCodegenFlutterClient {
  @override
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
      authOptions: FlutterAuthClientOptions(
        localStorage: MockLocalStorage(),
        pkceAsyncStorage: MockAsyncStorage(),
      ),
      httpClient: httpClient,
    );
    supabaseInitialized = true;
  }
}
