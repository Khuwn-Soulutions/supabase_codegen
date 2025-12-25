import 'dart:io';

import 'package:change_case/change_case.dart';
import 'package:dcli/dcli.dart';
import 'package:supabase_codegen/init/init_functions/init_functions.dart';
import 'package:supabase_codegen/src/generator/generator.dart';

/// Main function export
Future<void> main() => initializeConfiguration();

/// Initialize the configuation to be used for database type generation
Future<void> initializeConfiguration({
  bool forFlutter = false,
  String? package,
  String? defaultEnvPath,
  String? defaultOutputPath,
  String? defaultTag,
  String? configPath,
}) async {
  /// Write the configuration to a file
  final configFilePath =
      configPath ?? defaultValues[CmdOption.configYaml] as String;

  if (File(configFilePath).existsSync()) {
    final overwrite = confirm(
      yellow(
        'Config file already exists at: $configFilePath '
        'are you sure you want to overwrite it?',
      ),
      defaultValue: false,
    );
    if (!overwrite) {
      exit(1);
    }
  }

  /// Set location for env file
  final env = await configureEnv(
    forFlutter: forFlutter,
    defaultEnvPath: defaultEnvPath,
  );
  echo('Env: $env', newline: true);

  /// Choose the folder to output the generated files
  final output = chooseOutputFolder(defaultOutputPath);
  echo('Output: $output', newline: true);

  /// Get tag to use in footer of generated files
  final tag = getTag(tag: defaultTag);
  if (tag.isNotEmpty) {
    echo('Tag: $tag', newline: true);
  }

  /// Write the configuration to a file
  final configPackage = package ?? defaultPackageName;
  withOpenFile(configFilePath, (file) {
    file
      ..write('# ${configPackage.toSentenceCase()} config.')
      ..append(
        '# See https://pub.dev/packages/$configPackage#yaml-configuration '
        'for more info',
      );

    // Add env if it is not the default
    if (env != (defaultEnvPath ?? defaultValues[CmdOption.env] as String)) {
      file.append('${CmdOption.env}: $env');
    }

    // Add output if it is not the default
    if (output !=
        (defaultOutputPath ?? defaultValues[CmdOption.output] as String)) {
      file.append('${CmdOption.output}: $output');
    }

    // Add the tag if it is not empty
    if (tag.isNotEmpty) {
      file.append('${CmdOption.tag}: $tag');
    }
  });

  // Print the config file path
  echo(green('Config file created at: $configFilePath ✅'), newline: true);
}
