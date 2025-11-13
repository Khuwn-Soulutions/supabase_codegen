import 'package:mason/mason.dart';
import 'package:supabase_codegen/supabase_codegen_generator.dart';
import 'package:yaml/yaml.dart';

/// Class representation of the lock file for a previous file generation process
class GeneratorLockfile {
  /// Constructor
  GeneratorLockfile({
    required this.date,
    required this.package,
    required this.version,
    required this.forFlutter,
    required this.tag,
    required this.barrelFiles,
    this.tables = const {},
    this.enums = const {},
  });

  /// Create [GeneratorLockfile] from [json]
  factory GeneratorLockfile.fromJson(Map<String, dynamic> json) =>
      GeneratorLockfile(
        date: DateTime.parse(json['date'] as String),
        package: json['package'] as String,
        version: json['version'] as String,
        forFlutter: json['forFlutter'] as bool,
        tag: json['tag'] as String,
        barrelFiles: json['barrelFiles'] as bool,
        tables: Map<String, int>.from(json['tables'] as Map),
        enums: Map<String, int>.from(json['enums'] as Map),
      );

  /// Create a [GeneratorLockfile] from [yamlContent]
  factory GeneratorLockfile.fromYaml(String yamlContent) {
    final json = Map<String, dynamic>.from(loadYaml(yamlContent) as YamlMap);
    return GeneratorLockfile.fromJson(json);
  }

  /// Create [GeneratorLockfile] from [GeneratorConfig]
  factory GeneratorLockfile.fromConfig(GeneratorConfig config) =>
      GeneratorLockfile(
        date: config.date,
        package: config.package,
        version: config.version,
        forFlutter: config.forFlutter,
        tag: config.tag,
        barrelFiles: config.barrelFiles,
        tables: config.tables.fold(
          <String, int>{},
          (tables, table) {
            tables[table.name] = table.hashCode;
            return tables;
          },
        ),
        enums: config.enums.fold(
          <String, int>{},
          (enums, enumConfig) {
            enums[enumConfig.formattedEnumName] = enumConfig.hashCode;
            return enums;
          },
        ),
      );

  /// Create json representation of [GeneratorLockfile]
  Map<String, dynamic> toJson() => {
        'date': date.toString(),
        'package': package,
        'version': version,
        'forFlutter': forFlutter,
        'tag': tag,
        'barrelFiles': barrelFiles,
        'tables': tables,
        'enums': enums,
      };

  /// Create yaml representation of the [GeneratorLockfile]
  String toYaml() => Yaml.encode(toJson());

  /// Lockfile generation date
  final DateTime date;

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
  final Map<String, int> tables;

  /// Enums
  final Map<String, int> enums;
}
