import 'dart:io';

import 'package:logger/logger.dart';
import 'package:yaml/yaml.dart';

void main(List<String> args) async {
  final versionPart = args.first;
  final logger = Logger()..i('Bumping version $versionPart');
  final result = await Process.run('cider', ['bump', versionPart]);
  logger.i(result.stdout);

  /// Get version from pubspec
  final pubSpecFile = File('pubspec.yaml');
  final pubspecContents = pubSpecFile.readAsStringSync();
  final pubspec = loadYaml(pubspecContents) as YamlMap;
  final version = pubspec['version'] as String;
  logger.i('New version: $version');

  /// Overwrite version in src/version.dart
  final versionFile = File('bin/src/version.dart');
  final versionContents = versionFile.readAsStringSync();
  versionFile.writeAsStringSync(
    versionContents.replaceAll(
      RegExp("const version = '(.+)';"),
      "const version = '$version';",
    ),
  );
  logger.i('Version file updated');
}
