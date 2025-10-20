import 'package:supabase_codegen/supabase_codegen_generator.dart';
import 'package:supabase_codegen_serverpod/src/src.dart';

/// Main function
void main(List<String> args) async {
  await runGenerateTypes(
    args,
    generator: const ServerpodCodeGenerator(),
    package: 'supabase_codegen_serverpod',
  );
}
