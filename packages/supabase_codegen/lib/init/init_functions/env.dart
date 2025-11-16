// Create env file
// ignore_for_file: avoid_print

import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:supabase_codegen/src/generator/generator.dart';

import 'package:yaml/yaml.dart';

/// Create env file defaults
typedef CreateEnvDefaults = ({bool? create, String? url, String? key});

/// Configure env file
Future<String> configureEnv({
  bool forFlutter = false,
  String? defaultEnvPath,
  bool loadFlutterClient = true,
  // Used for testing
  CreateEnvDefaults? createDefaults,
  String pubspecPath = 'pubspec.yaml',
}) async {
  // Get the value by prompt
  final envPath = ask(
    blue('Path to env file:'),
    defaultValue: defaultEnvPath ?? defaultValues[CmdOption.env] as String,
  );

  // confirm that the file exists
  if (!exists(envPath)) {
    printerr(red('File does not exist: $envPath\n'));

    final created = createEnvFile(envPath, defaults: createDefaults);
    if (!created) {
      const message = 'Env file not created';
      printerr(red('$message ❌'));
      isRunningInTest ? throw Exception(message) : exit(1);
    }
  }
  // confirm that the file matches the expected format
  final validated = validateEnvFile(envPath);
  if (!validated) {
    const message = 'Env file not valid';
    printerr(red('$message ❌'));
    isRunningInTest ? throw Exception(message) : exit(1);
  }

  print(green('Env file validated ✅'));

  // Return current path if not for flutter
  if (!forFlutter) return envPath;

  // Ask the user if they wish to load the supabase client using the env file
  final loadClientWithEnv = confirm(
    blue(
      'Would you like to use the env file to load '
      'the Supabase client in your application?',
    ),
    defaultValue: loadFlutterClient,
  );

  // Write the location of the env file to the assets in pubspec
  if (loadClientWithEnv) {
    final added = await addEnvFileToAssets(envPath, pubspecPath: pubspecPath);
    print(
      green(
        '${added ? 'Env file added to' : 'Env file present in'} '
        'flutter assets ✅',
      ),
    );
  }

  return envPath;
}

/// Create env file
bool createEnvFile(
  String envPath, {
  // Used for testing
  CreateEnvDefaults? defaults,
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
        green(
          '\nSupabase credentials written to '
          'the environment file created at $envPath\n',
        ),
      );
    });
  }
  return created;
}

/// Validate the env file
bool validateEnvFile(String envPath) {
  final contents = read(envPath).toParagraph();
  return RegExp(
    r'^SUPABASE_URL\s*=\s*.*$.*^SUPABASE(_ANON)?_KEY\s*=\s*.*$',
    multiLine: true,
    dotAll: true,
  ).hasMatch(contents);
}

/// Write env file to pubspec assets
Future<bool> addEnvFileToAssets(
  String envPath, {
  String pubspecPath = 'pubspec.yaml',
}) async {
  final pubSpecContents = read(pubspecPath).toParagraph();
  final pubspec = loadYaml(pubSpecContents) as YamlMap;
  final pubSpecFile = File(pubspecPath);

  final assetsEntry =
      '''
  assets:
    - $envPath
''';

  /// Write full flutter entry if no flutter
  final flutter = pubspec['flutter'] as YamlMap?;
  if (!pubspec.containsKey('flutter')) {
    pubSpecFile.writeAsStringSync('''
$pubSpecContents

flutter:
$assetsEntry
''');
    return true;
  }

  final assets = flutter?['assets'] as YamlList?;

  /// Write assets directly under flutter
  if (assets == null) {
    final newPubSpec = pubSpecContents.replaceFirst(
      RegExp(r'^flutter:.*$', multiLine: true),
      'flutter:\n$assetsEntry',
    );
    pubSpecFile.writeAsStringSync(newPubSpec);
    return true;
  }

  /// Stop if present in assets
  if (assets.contains(envPath)) return false;

  /// Add env path directly under assets
  pubSpecFile.writeAsStringSync(
    pubSpecContents.replaceFirst('assets:', assetsEntry.trim()),
  );
  return true;
}
