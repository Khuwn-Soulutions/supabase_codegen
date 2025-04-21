import 'package:dcli/dcli.dart';
import 'package:supabase_codegen/src/generator/generate_types/generate_types.dart';

/// Choose the output folder
String chooseOutputFolder() => ask(
      green('Choose the output folder:'),
      defaultValue: defaultValues[CmdOption.output] as String,
    );
