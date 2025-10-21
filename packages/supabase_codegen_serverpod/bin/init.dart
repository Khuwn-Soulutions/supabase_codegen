import 'package:supabase_codegen/init/init.dart';

/// Default output path for the generated code
const defaultOutputPath = 'lib/src/models';

/// Call the supabase_codegen init with relevant environment
void main() => init(
  defaultOutputPath: defaultOutputPath,
);
