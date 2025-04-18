import 'package:supabase_codegen_flutter/supabase_codegen_flutter.dart';

/// Supabase Flutter table
abstract class SupabaseFlutterTable<T extends SupabaseDataRow>
    extends SupabaseTable<T> {
  /// Supabase Flutter table
  SupabaseFlutterTable() : super(client: loadSupabaseClient());
}
