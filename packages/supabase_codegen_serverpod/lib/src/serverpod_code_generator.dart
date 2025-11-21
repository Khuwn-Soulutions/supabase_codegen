import 'package:supabase_codegen/supabase_codegen_generator.dart';
import 'package:supabase_codegen_serverpod/supabase_codegen_serverpod.dart';

/// Supabase code generator
class ServerpodCodeGenerator extends SupabaseCodeGenerator {
  /// Constructor
  const ServerpodCodeGenerator({
    super.schemaGenerator = const ServerpodSchemaGenerator(),
  });
}
