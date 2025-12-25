import 'package:supabase_codegen/init/init.dart';
import 'package:supabase_codegen_flutter/src/default_env.dart';

/// Default output path for the generated code
const defaultOutputPath = 'lib/types';

/// Call the supabase_codegen init with relevant environment
void main() => initializeConfiguration(
  forFlutter: true,
  defaultEnvPath: defaultEnvFile,
  defaultOutputPath: defaultOutputPath,
);
