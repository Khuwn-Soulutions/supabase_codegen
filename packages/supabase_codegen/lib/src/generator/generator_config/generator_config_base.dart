/// {@template generator_config_base}
/// Generator Config Base Class
/// {@endtemplate}
abstract class GeneratorConfigBase {
  /// {@macro generator_config_base}
  const GeneratorConfigBase({
    required this.package,
    required this.version,
    required this.forFlutter,
    required this.tag,
    required this.barrelFiles,
    this.fileType = dartFileType,
  });

  /// Package name
  final String package;

  /// Package version
  final String version;

  /// Are the files being generated for use in Flutter?
  final bool forFlutter;

  /// Should barrel files be generated
  final bool barrelFiles;

  /// Tag
  final String tag;

  /// File type
  final String fileType;
}

/// Dart file type
const dartFileType = 'dart';
