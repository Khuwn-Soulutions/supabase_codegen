import 'dart:io';

import 'package:dcli/dcli.dart';

import 'package:supabase_codegen/init/init_functions/init_functions.dart';
import 'package:supabase_codegen/src/generator/generator.dart';

/// Main function export
Future<void> main() => init();

/// Initialize the configuation to be used for database type generation
Future<void> init({
  bool forFlutter = false,
  String? defaultEnvPath,
  String? defaultOutputPath,
  String? defaultTag,
  String? configPath,
}) async {
  /// Set location for env file
  final env = await configureEnv(
    forFlutter: forFlutter,
    defaultEnvPath: defaultEnvPath,
  );
  echo('Env: $env', newline: true);

  /// Choose the folder to output the generated files
  final output = chooseOutputFolder(defaultOutputPath);
  echo('Output: $output', newline: true);

  /// Get tag to use in header of generated files
  final tag = getTag(tag: defaultTag);
  if (tag.isNotEmpty) {
    echo('Tag: $tag', newline: true);
  }

  /// Write the configuration to a file
  final configFilePath =
      configPath ?? defaultValues[CmdOption.configYaml] as String;
  withOpenFile(configFilePath, (file) {
    file
      ..write('# Supabase codegen config.')
      ..append(
        '# See https://pub.dev/packages/supabase_codegen#yaml-configuration '
        'for more info',
      )
      ..append('${CmdOption.env}: $env')
      ..append('${CmdOption.output}: $output');

    // Add the tag if it is not empty
    if (tag.isNotEmpty) file.append('${CmdOption.tag}: $tag');
  });

  // Print the config file path
  echo(green('Config file created at: $configFilePath ✅'), newline: true);
  exit(0);
}
