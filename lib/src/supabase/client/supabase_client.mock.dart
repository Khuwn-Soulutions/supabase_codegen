import 'package:mock_supabase_http_client/mock_supabase_http_client.dart';
import 'package:supabase/supabase.dart';

/// Mock Supabse Http Client
final mockSupabaseHttpClient = MockSupabaseHttpClient();

/// Mock Supabase
final mockSupabase = SupabaseClient(
  'https://mock.supabase.co',
  'fakeAnonKey',
  httpClient: mockSupabaseHttpClient,
);
