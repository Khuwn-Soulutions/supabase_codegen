import 'package:supabase_codegen/supabase_codegen_generator.dart';

/// Generator configuration model
class GeneratorConfig {
  /// Constructor
  GeneratorConfig({
    required this.package,
    required this.version,
    required this.forFlutter,
    required this.tag,
    required this.barrelFiles,
    this.tables = const [],
    this.enums = const [],
  });

  /// Create empty [GeneratorConfig]
  factory GeneratorConfig.empty() => GeneratorConfig(
        package: '',
        version: '',
        forFlutter: false,
        tag: '',
        barrelFiles: true,
      );

  /// Create [GeneratorConfig] from [json]
  factory GeneratorConfig.fromJson(Map<String, dynamic> json) =>
      GeneratorConfig(
        package: json['package'] as String,
        version: json['version'] as String,
        forFlutter: json['forFlutter'] as bool,
        tag: json['tag'] as String,
        barrelFiles: json['barrelFiles'] as bool,
        tables: (json['tables'] as List<dynamic>)
            .map<TableConfig>(
              (table) => TableConfig.fromJson(table as Map<String, dynamic>),
            )
            .toList(),
        enums: (json['enums'] as List<dynamic>)
            .map<EnumConfig>(
              (config) => EnumConfig.fromJson(config as Map<String, dynamic>),
            )
            .toList(),
      );

  /// Create json representation of [GeneratorConfig]
  Map<String, dynamic> toJson() => {
        'date': DateTime.now().toString(),
        'package': package,
        'version': version,
        'forFlutter': forFlutter,
        'tag': tag,
        'barrelFiles': barrelFiles,
        'hasTag': tag.isNotEmpty,
        'tables': tables.map((table) => table.toJson()).toList(),
        'enums': enums.map((config) => config.toJson()).toList(),
      };

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

  /// Tables
  final List<TableConfig> tables;

  /// Enums
  final List<EnumConfig> enums;
}
