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
    super.fileType,
    this.tables = const [],
    this.enums = const [],
    this.rpcs = const [],
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

  // coverage:ignore-start
  /// Create [GeneratorConfig] from [json]
  factory GeneratorConfig.fromJson(Map<String, dynamic> json) =>
      GeneratorConfig(
        package: json['package'] as String,
        version: json['version'] as String,
        forFlutter: json['forFlutter'] as bool,
        tag: json['tag'] as String,
        barrelFiles: json['barrelFiles'] as bool,
        fileType: json['fileType'] as String? ?? dartFileType,
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
        rpcs: (json['rpcs'] as List<dynamic>? ?? [])
            .map<RpcConfig>(
              (config) => RpcConfig.fromJson(config as Map<String, dynamic>),
            )
            .toList(),
        date: json['date'] == null
            ? null
            : DateTime.parse(json['date'] as String),
      );
  // coverage:ignore-end

  /// Create [GeneratorConfig] from [params] with the [tables] and [enums]
  factory GeneratorConfig.fromParams({
    required GeneratorConfigParams params,
    List<TableConfig> tables = const [],
    List<EnumConfig> enums = const [],
    List<RpcConfig> rpcs = const [],
  }) => GeneratorConfig(
    package: params.package,
    version: params.version,
    forFlutter: params.forFlutter,
    tag: params.tag,
    barrelFiles: params.barrelFiles,
    fileType: params.fileType,
    tables: tables,
    enums: enums,
    rpcs: rpcs,
  );

  /// Date created
  final DateTime date;

  /// Tables
  final List<TableConfig> tables;

  /// Enums
  final List<EnumConfig> enums;

  /// RPCs
  final List<RpcConfig> rpcs;

  /// Create json representation of [GeneratorConfig]
  Map<String, dynamic> toJson() {
    final hasTables = tables.isNotEmpty;
    final hasEnums = enums.isNotEmpty;
    final hasRpcs = rpcs.isNotEmpty;
    return {
      'date': date.toString(),
      'package': package,
      'version': version,
      'forFlutter': forFlutter,
      'tag': tag,
      'barrelFiles': barrelFiles,
      'fileType': fileType,
      'hasTag': tag.isNotEmpty,
      // Important!!
      // Arrays used to generate files must be null if there are
      // no items to generate
      'tables': hasTables
          ? tables.map((table) => table.toJson()).toList()
          : null,
      'hasTables': hasTables,
      'enums': hasEnums
          ? enums.map((config) => config.toJson()).toList()
          : null,
      'hasEnums': hasEnums,
      'rpcs': hasRpcs ? rpcs.map((config) => config.toJson()).toList() : null,
      'hasRpcs': hasRpcs,
    };
  }

  /// Create a copy of [GeneratorConfig] with the provided properties overridden
  GeneratorConfig copyWith({
    DateTime? date,
    String? package,
    String? version,
    bool? forFlutter,
    bool? barrelFiles,
    String? fileType,
    String? tag,
    List<TableConfig>? tables,
    List<EnumConfig>? enums,
    List<RpcConfig>? rpcs,
  }) => GeneratorConfig(
    date: date ?? this.date,
    package: package ?? this.package,
    version: version ?? this.version,
    forFlutter: forFlutter ?? this.forFlutter,
    tag: tag ?? this.tag,
    barrelFiles: barrelFiles ?? this.barrelFiles,
    fileType: fileType ?? this.fileType,
    tables: tables ?? this.tables,
    enums: enums ?? this.enums,
    rpcs: rpcs ?? this.rpcs,
  );
}
