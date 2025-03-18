import 'dart:io';

import 'package:yaml/yaml.dart';

/// Get the code generator configuration
Map<String, dynamic> getCodegenConfig({
  required File configFile,
  File? pubspecFile,
}) {
  return configFile.existsSync()
      ? extractCodegenConfig(configFile)
      : getPubspecConfig(file: pubspecFile);
}

/// Get the code generator configuration from the root pubspec.yaml file
Map<String, dynamic> getPubspecConfig({
  File? file,
  String key = 'supabase_codegen',
}) {
  final pubSpecFile = file ?? File('pubspec.yaml');
  return pubSpecFile.existsSync()
      ? extractCodegenConfig(pubSpecFile, key: key)
      : {};
}

/// Extract the configuration from the provided [file]
Map<String, dynamic> extractCodegenConfig(File file, {String key = ''}) {
  final configFileContents = file.readAsStringSync();
  final pubspec = loadYaml(configFileContents) as YamlMap;
  final codegenConfig = key.isEmpty ? pubspec : pubspec[key] as YamlMap? ?? {};
  return Map<String, dynamic>.from(codegenConfig);
}
