import 'dart:io';

import 'package:talker/talker.dart';

/// talker instance
final talker = Talker();

void main(List<String> args) async {
  if (args.isEmpty) {
    talker.error(
      'No version provided. Usage: dart scripts/bump_version.dart <version>',
    );
    exit(1);
  }

  final version = args.first;
  talker.info('Bumping version to $version');

  /// Overwrite version file
  updateVersionFile(version);

  /// Overwrite the version in pubspec.yaml
  updatePubspecVersion(version);

  /// Overwrite the supabase_codegen version
  updateSupabaseCodegenVersion(version);
  talker.info('Version bump to $version complete!');
}

/// Supabase Codegen path
const supabaseCodegenPath = 'packages/supabase_codegen';

/// Supabase Codegen Flutter path
const supabaseCodegenFlutterPath = 'packages/supabase_codegen_flutter';

/// Overwrite version file
void updateVersionFile(String version) {
  final versionFile =
      File('$supabaseCodegenPath/lib/src/generator/version.dart');
  final versionContents = versionFile.readAsStringSync();
  versionFile.writeAsStringSync(
    versionContents.replaceAll(
      RegExp("const version = '(.+)';"),
      "const version = '$version';",
    ),
  );
  talker.info('Version file updated');
}

/// Overwrite the version in the pubspec.yaml file(s)
void updatePubspecVersion(String version) {
  for (final path in [supabaseCodegenPath, supabaseCodegenFlutterPath]) {
    final pubspecFile = File('$path/pubspec.yaml');
    final pubspecContents = pubspecFile.readAsStringSync();
    pubspecFile.writeAsStringSync(
      pubspecContents.replaceAll(
        RegExp('version: (.+)'),
        'version: $version',
      ),
    );
    talker.info('pubspec.yaml at $path updated');
  }
}

/// Overwrite the supabase_codegen version
void updateSupabaseCodegenVersion(String version) {
  final files = [
    File('$supabaseCodegenPath/README.md'),
    File('$supabaseCodegenFlutterPath/README.md'),
    File('$supabaseCodegenFlutterPath/pubspec.yaml'),
  ];

  for (final file in files) {
    final readmeContents = file.readAsStringSync();
    file.writeAsStringSync(
      readmeContents.replaceAll(
        RegExp(r'supabase_codegen: \^(.+)'),
        'supabase_codegen: ^$version',
      ),
    );
    talker.info('supabase_codegen version in ${file.path} updated');
  }
}
