import 'package:supabase_codegen/supabase_codegen_generator.dart';
import 'package:supabase_codegen_serverpod/supabase_codegen_serverpod.dart';
import 'init.dart';

/// Main function
void main(List<String> args) async {
  await runGenerateTypes(
    args,
    generator: const ServerpodCodeGenerator(),
    config: GeneratorConfigParams.empty().copyWith(
      package: 'supabase_codegen_serverpod',
      outputFolder: defaultOutputPath,
    ),
  );
}
