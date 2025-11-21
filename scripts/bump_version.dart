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

/// Supabase Codegen Serverpod path
const supabaseCodegenServerpodPath = 'packages/supabase_codegen_serverpod';

const paths = [
  supabaseCodegenPath,
  supabaseCodegenFlutterPath,
  supabaseCodegenServerpodPath,
];

/// Overwrite version file
void updateVersionFile(String version) {
  final versionFile = File(
    '$supabaseCodegenPath/lib/src/generator/helpers/version.dart',
  );
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
  for (final path in paths) {
    final pubspecFile = File('$path/pubspec.yaml');
    final pubspecContents = pubspecFile.readAsStringSync();
    pubspecFile.writeAsStringSync(
      pubspecContents.replaceAll(RegExp('version: (.+)'), 'version: $version'),
    );
    talker.info('pubspec.yaml at $path updated');
  }
}

/// Overwrite the supabase_codegen version
void updateSupabaseCodegenVersion(String version) {
  final files = paths.fold(<File>[], (files, path) {
    files.addAll([File('$path/README.md'), File('$path/pubspec.yaml')]);
    return files;
  });

  for (final file in files) {
    final contents = file.readAsStringSync();
    file.writeAsStringSync(
      contents.replaceAll(
        RegExp(r'supabase_codegen: \^(.+)'),
        'supabase_codegen: ^$version',
      ),
    );
    talker.info('supabase_codegen version in ${file.path} updated');
  }
}
