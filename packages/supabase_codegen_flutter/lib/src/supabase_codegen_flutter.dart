import 'package:supabase_flutter/supabase_flutter.dart';

// coverage:ignore-file

/// Supabase instance
Supabase get supabase => Supabase.instance;

/// Client instance
SupabaseClient get supabaseClient => supabase.client;

/// Auth client instance
GoTrueClient get authClient => supabaseClient.auth;

/// Realtime client instance
RealtimeClient get realtimeClient => supabaseClient.realtime;

/// Storage client instance
SupabaseStorageClient get storageClient => supabaseClient.storage;

/// Functions client instance
FunctionsClient get functionsClient => supabaseClient.functions;
