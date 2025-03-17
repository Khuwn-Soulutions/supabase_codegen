import 'dart:io';

import 'package:yaml/yaml.dart';

/// Get the code genreator configuration from the root pubspec.yaml file
Map<String, dynamic> getPubspecConfig([File? file]) {
  final pubSpecFile = file ?? File('pubspec.yaml');
  final pubspecContents = pubSpecFile.readAsStringSync();
  final pubspec = loadYaml(pubspecContents) as YamlMap;
  final codegenConfig = pubspec['supabase_codegen'] as YamlMap? ?? {};
  return Map<String, dynamic>.from(codegenConfig);
}
