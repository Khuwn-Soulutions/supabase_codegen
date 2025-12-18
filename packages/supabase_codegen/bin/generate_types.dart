import 'package:supabase_codegen/src/generator/generator.dart';
import 'add_codegen_functions.dart';

/// Main function
void main(List<String> args) async {
  await checkMigration();
  await runGenerateTypes(args, config: GeneratorConfigParams.empty());
}
