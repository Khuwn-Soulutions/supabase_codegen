import 'package:supabase_codegen/init/init.dart';
import 'package:supabase_codegen_serverpod/supabase_codegen_serverpod.dart';

/// Default output path for the generated code
const defaultOutputPath = 'lib/src/models';

/// Call the supabase_codegen init with relevant environment
Future<void> main() async {
  await init(
    defaultOutputPath: defaultOutputPath,
  );
  await addExtraClassesToGeneratorConfig();
}
