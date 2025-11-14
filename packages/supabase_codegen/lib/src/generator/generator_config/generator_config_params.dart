import 'package:supabase_codegen/supabase_codegen_generator.dart';

/// {@template generator_config_params}
/// Generator configuration parameters
/// {@endtemplate}
class GeneratorConfigParams extends GeneratorConfigBase {
  /// {@macro generator_config_params}
  const GeneratorConfigParams({
    required this.envFilePath,
    required this.outputFolder,
    required super.package,
    required super.version,
    required super.forFlutter,
    required super.tag,
    required super.barrelFiles,
    this.overrides = const {},
  });

  /// Create empty [GeneratorConfigParams]
  factory GeneratorConfigParams.empty() => const GeneratorConfigParams(
    envFilePath: '',
    outputFolder: '',
    package: '',
    version: '',
    forFlutter: false,
    tag: '',
    barrelFiles: true,
  );

  /// Create [GeneratorConfigParams] from [json]
  factory GeneratorConfigParams.fromJson(Map<String, dynamic> json) =>
      GeneratorConfigParams(
        envFilePath: json['envFilePath'] as String,
        outputFolder: json['outputFolder'] as String,
        package: json['package'] as String,
        version: json['version'] as String,
        forFlutter: json['forFlutter'] as bool,
        tag: json['tag'] as String,
        barrelFiles: json['barrelFiles'] as bool,
        overrides: SchemaOverrides.from(
          json['overrides'] as Map<String, dynamic>? ?? {},
        ),
      );

  /// Environment file path
  final String envFilePath;

  /// Output Folder Path
  final String outputFolder;

  /// Overrides for table and column configurations
  final SchemaOverrides overrides;

  /// Create json representation of [GeneratorConfigParams]
  Map<String, dynamic> toJson() => {
    'envFilePath': envFilePath,
    'outputFolder': outputFolder,
    'package': package,
    'version': version,
    'forFlutter': forFlutter,
    'tag': tag,
    'barrelFiles': barrelFiles,
    'hasTag': tag.isNotEmpty,
    'overrides': overrides,
  };

  /// Create a copy of [GeneratorConfigParams] with the
  /// provided properties overridden
  GeneratorConfigParams copyWith({
    String? envFilePath,
    String? outputFolder,
    String? package,
    String? version,
    bool? forFlutter,
    bool? barrelFiles,
    String? tag,
    List<TableConfig>? tables,
    List<EnumConfig>? enums,
    SchemaOverrides? overrides,
  }) => GeneratorConfigParams(
    envFilePath: envFilePath ?? this.envFilePath,
    outputFolder: outputFolder ?? this.outputFolder,
    package: package ?? this.package,
    version: version ?? this.version,
    forFlutter: forFlutter ?? this.forFlutter,
    tag: tag ?? this.tag,
    barrelFiles: barrelFiles ?? this.barrelFiles,
    overrides: overrides ?? this.overrides,
  );
}
