import 'package:meta/meta.dart';
import 'package:mock_supabase_http_client/mock_supabase_http_client.dart';
import 'package:supabase/supabase.dart' show SupabaseClient;

/// Mock Supabse Http Client
@visibleForTesting
final mockSupabaseHttpClient = MockSupabaseHttpClient();

/// Mock Supabase
@visibleForTesting
final mockSupabase = SupabaseClient(
  'https://mock.supabase.co',
  'fakeAnonKey',
  httpClient: mockSupabaseHttpClient,
);
