import 'package:supabase_codegen/supabase_codegen_generator.dart';

/// Generator configuration model
class GeneratorConfig extends GeneratorConfigBase {
  /// Constructor
  GeneratorConfig({
    required super.package,
    required super.version,
    required super.forFlutter,
    required super.tag,
    required super.barrelFiles,
    this.tables = const [],
    this.enums = const [],
    DateTime? date,
  }) : date = date ?? DateTime.now();

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
        tables: (json['tables'] as List<dynamic>? ?? [])
            .map<TableConfig>(
              (table) => TableConfig.fromJson(table as Map<String, dynamic>),
            )
            .toList(),
        enums: (json['enums'] as List<dynamic>? ?? [])
            .map<EnumConfig>(
              (config) => EnumConfig.fromJson(config as Map<String, dynamic>),
            )
            .toList(),
        date: json['date'] == null
            ? null
            : DateTime.parse(json['date'] as String),
      );

  /// Date created
  final DateTime date;

  /// Tables
  final List<TableConfig> tables;

  /// Enums
  final List<EnumConfig> enums;

  /// Create json representation of [GeneratorConfig]
  Map<String, dynamic> toJson() => {
    'date': date.toString(),
    'package': package,
    'version': version,
    'forFlutter': forFlutter,
    'tag': tag,
    'barrelFiles': barrelFiles,
    'hasTag': tag.isNotEmpty,
    // Important!!
    // Set arrays used to generate files to null if no items to generate
    'tables': tables.isEmpty
        ? null
        : tables.map((table) => table.toJson()).toList(),
    'enums': enums.isEmpty
        ? null
        : enums.map((config) => config.toJson()).toList(),
  };

  /// Create a copy of [GeneratorConfig] with the provided properties overridden
  GeneratorConfig copyWith({
    DateTime? date,
    String? package,
    String? version,
    bool? forFlutter,
    bool? barrelFiles,
    String? tag,
    List<TableConfig>? tables,
    List<EnumConfig>? enums,
  }) => GeneratorConfig(
    date: date ?? this.date,
    package: package ?? this.package,
    version: version ?? this.version,
    forFlutter: forFlutter ?? this.forFlutter,
    tag: tag ?? this.tag,
    barrelFiles: barrelFiles ?? this.barrelFiles,
    tables: tables ?? this.tables,
    enums: enums ?? this.enums,
  );
}
