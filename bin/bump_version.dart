import 'dart:io';

import 'package:logger/logger.dart';
import 'package:yaml/yaml.dart';

void main(List<String> args) async {
  final versionPart = args.first;
  final logger = Logger(
    level: Level.all,
    filter: ProductionFilter(),
    printer: PrettyPrinter(
      methodCount: 0,
      excludeBox: {Level.debug: true, Level.info: true},
    ),
  )..i('Bumping version $versionPart');

  /// Bump version
  final result = await Process.run('cider', ['bump', versionPart]);
  logger.i(result.stdout);

  /// Get version from pubspec
  final pubSpecFile = File('pubspec.yaml');
  final pubspecContents = pubSpecFile.readAsStringSync();
  final pubspec = loadYaml(pubspecContents) as YamlMap;
  final version = pubspec['version'] as String;
  logger.i('New version: $version');

  /// Overwrite version in src/version.dart
  final versionFile = File('lib/src/generator/version.dart');
  final versionContents = versionFile.readAsStringSync();
  versionFile.writeAsStringSync(
    versionContents.replaceAll(
      RegExp("const version = '(.+)';"),
      "const version = '$version';",
    ),
  );
  logger.i('Version file updated');

  /// Overwrite the version in the README.md file
  final readmeFile = File('README.md');
  final readmeContents = readmeFile.readAsStringSync();
  readmeFile.writeAsStringSync(
    readmeContents
        .replaceAll(
          RegExp(r'supabase_codegen: \^(.+)'),
          'supabase_codegen: ^$version',
        )
        .replaceAll(
          RegExp(r'supabase_codegen \((.+)\)'),
          'supabase_codegen ($version)',
        ),
  );
  logger.i('README.md updated');
}
