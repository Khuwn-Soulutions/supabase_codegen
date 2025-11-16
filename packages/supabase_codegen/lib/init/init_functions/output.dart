import 'package:dcli/dcli.dart';
import 'package:supabase_codegen/src/generator/generate_types/generate_types.dart';

/// Choose the output folder
String chooseOutputFolder([String? defaultOutputFolder]) => ask(
  green('Choose the output folder:'),
  defaultValue:
      defaultOutputFolder ?? defaultValues[CmdOption.output] as String,
);
