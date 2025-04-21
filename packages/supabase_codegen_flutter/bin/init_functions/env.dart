// Create env file
// ignore_for_file: avoid_print

import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:supabase_codegen_flutter/src/default_env.dart';

import 'package:yaml/yaml.dart';

/// Configure env file
Future<String> configureEnv() async {
  // Get the value by prompt
  final envPath = ask(blue('Path to env file:'), defaultValue: defaultEnvFile);

  // confirm that the file exists
  if (!exists(envPath)) {
    printerr(red('File does not exist: $envPath\n'));

    final created = createEnvFile(envPath);
    if (!created) exit(1);
  }
  // confirm that the file matches the expected format
  final validated = validateEnvFile(envPath);
  if (!validated) {
    printerr(red('Env file not validated ❌'));
    exit(1);
  }

  print(green('Env file validated ✅'));

  // Ask the user if they wish to load the supabase client using the env file
  final loadClientWithEnv = confirm(
    blue(
      'Would you like to use the env file to load '
      'the Supabase client in your application?',
    ),
    defaultValue: true,
  );

  // Write the location of the env file to the assets in pubspec
  if (loadClientWithEnv) {
    final added = await addEnvFileToAssets(envPath);
    print(
      green('${added ? 'Env file added to' : 'Env file present in'} '
          'flutter assets ✅'),
    );
  }

  return envPath;
}

/// Create env file
bool createEnvFile(
  String envPath, {
  // Used for testing
  ({bool? create, String? url, String? key})? defaults,
}) {
  final created = confirm(
    blue('Would you like to create the env file? ($envPath)'),
    defaultValue: defaults?.create ?? true,
  );

  // Create the file and write the values
  if (created) {
    // Create the file
    touch(envPath, create: true);
    // Get the variables
    final url = ask(
      blue('Enter the url to your Supabase instance:'),
      validator: Ask.url(protocols: ['http', 'https']),
      defaultValue: defaults?.url ?? '',
    );
    final key = ask(
      blue('Enter the anon key for your Supabase instance:'),
      hidden: true,
      defaultValue: defaults?.key ?? '',
    );
    // Write the values to the file
    withOpenFile(envPath, (file) {
      file
        ..write('SUPABASE_URL=$url')
        ..append('SUPABASE_ANON_KEY=$key');

      print(
        green('\nSupabase credentials written to '
            'the environment file created at $envPath\n'),
      );
    });
  }
  return created;
}

/// Validate the env file
bool validateEnvFile(String envPath) {
  final contents = read(envPath).toParagraph();
  return RegExp(
    r'^SUPABASE_URL=.*$\r?\n^SUPABASE_ANON_KEY=.*$',
    multiLine: true,
  ).hasMatch(contents);
}

/// Write env file to pubspec assets
Future<bool> addEnvFileToAssets(
  String envPath, {
  String pubspecPath = 'pubspec.yaml',
}) async {
  final pubSpecContents = read(pubspecPath).toParagraph();
  final pubspec = loadYaml(pubSpecContents) as YamlMap;

  final assetsEntry = '''
  assets:
    - $envPath
''';

  /// Write full flutter entry if no flutter
  final flutter = pubspec['flutter'] as YamlMap?;
  if (!pubspec.containsKey('flutter')) {
    pubspecPath.write(
      '''
$pubSpecContents

flutter:
$assetsEntry
''',
    );
    return true;
  }

  final assets = flutter?['assets'] as YamlList?;

  /// Write assets directly under flutter
  if (assets == null) {
    pubspecPath.write(
      pubSpecContents.replaceFirst('flutter:', 'flutter:\n$assetsEntry'),
    );
    return true;
  }

  /// Stop if present in assets
  if (assets.contains(envPath)) return false;

  /// Add env path directly under assets
  pubspecPath
      .write(pubSpecContents.replaceFirst('assets:', assetsEntry.trim()));
  return true;
}
