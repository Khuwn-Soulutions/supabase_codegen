import 'package:collection/collection.dart';
import 'package:mason/mason.dart';
import 'package:meta/meta.dart';
import 'package:supabase_codegen/supabase_codegen.dart';
import 'package:supabase_codegen/supabase_codegen_generator.dart';
import 'package:yaml/yaml.dart';

/// Class representation of the lock file for a previous file generation process
@immutable
class GeneratorLockfile {
  /// Constructor
  const GeneratorLockfile({
    required this.date,
    required this.package,
    required this.version,
    required this.forFlutter,
    required this.tag,
    required this.barrelFiles,
    this.tables = const {},
    this.enums = const {},
  });

  /// Create an empty [GeneratorLockfile]
  factory GeneratorLockfile.empty() => GeneratorLockfile(
    date: DateTime.now(),
    package: '',
    version: '',
    forFlutter: false,
    tag: '',
    barrelFiles: false,
  );

  /// Create [GeneratorLockfile] from [json]
  factory GeneratorLockfile.fromJson(Map<String, dynamic> json) =>
      GeneratorLockfile(
        date: DateTime.parse(json['date'] as String),
        package: json['package'] as String,
        version: json['version'] as String,
        forFlutter: json['forFlutter'] as bool,
        tag: json['tag'] == null ? '' : json['tag'] as String,
        barrelFiles: json['barrelFiles'] as bool,
        tables: json['tables'] != null
            ? Map<String, int>.from(json['tables'] as Map)
            : {},
        enums: json['enums'] != null
            ? Map<String, int>.from(json['enums'] as Map)
            : {},
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
        tables: config.tables.fold(<String, int>{}, (tables, table) {
          tables[table.name] = table.hashCode;
          return tables;
        }),
        enums: config.enums.fold(<String, int>{}, (enums, enumConfig) {
          enums[enumConfig.fileName] = enumConfig.hashCode;
          return enums;
        }),
      );

  /// Create json representation of [GeneratorLockfile]
  Map<String, dynamic> toJson() => {
    'date': date.toString(),
    'package': package,
    'version': version,
    'forFlutter': forFlutter,
    'barrelFiles': barrelFiles,
    'tag': tag.isEmpty ? null : tag,
    'tables': tables.isEmpty ? null : tables,
    'enums': enums.isEmpty ? null : enums,
  }.cleaned;

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

  /// Tables (Map of table name to [TableConfig] hashCode)
  final Map<String, int> tables;

  /// Enums (Map of filename to [EnumConfig] hashCode)
  final Map<String, int> enums;

  /// Get the current lockfile without the data (tables and enums)
  GeneratorLockfile withoutData() => copyWith(tables: {}, enums: {});

  @override
  int get hashCode =>
      date.hashCode ^
      package.hashCode ^
      version.hashCode ^
      forFlutter.hashCode ^
      barrelFiles.hashCode ^
      tag.hashCode ^
      const DeepCollectionEquality().hash(tables) ^
      const DeepCollectionEquality().hash(enums);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeneratorLockfile &&
          package == other.package &&
          version == other.version &&
          forFlutter == other.forFlutter &&
          barrelFiles == other.barrelFiles &&
          tag == other.tag &&
          const DeepCollectionEquality().equals(tables, other.tables) &&
          const DeepCollectionEquality().equals(enums, other.enums);

  /// Creates a copy of this [GeneratorLockfile] with the given fields
  /// replaced with the new values.]
  GeneratorLockfile copyWith({
    DateTime? date,
    String? package,
    String? version,
    bool? forFlutter,
    bool? barrelFiles,
    String? tag,
    Map<String, int>? tables,
    Map<String, int>? enums,
  }) {
    return GeneratorLockfile(
      date: date ?? this.date,
      package: package ?? this.package,
      version: version ?? this.version,
      forFlutter: forFlutter ?? this.forFlutter,
      barrelFiles: barrelFiles ?? this.barrelFiles,
      tag: tag ?? this.tag,
      tables: tables ?? this.tables,
      enums: enums ?? this.enums,
    );
  }
}
