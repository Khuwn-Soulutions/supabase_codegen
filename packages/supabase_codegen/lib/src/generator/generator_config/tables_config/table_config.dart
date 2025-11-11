import 'package:supabase_codegen/src/generator/generator_config/tables_config/column_config.dart';

/// {@template table_config}
/// The configuration for a table in the generated table row class.
/// {@endtemplate}
class TableConfig {
  /// {@macro table_config}
  const TableConfig({
    required this.name,
    required this.columns,
  });

  /// Creates an empty [TableConfig].
  factory TableConfig.empty() => const TableConfig(
        name: '',
        columns: [],
      );

  /// Creates a [TableConfig] from a json map.
  factory TableConfig.fromJson(Map<String, dynamic> map) {
    return TableConfig(
      name: map['name'] as String,
      columns: List<ColumnConfig>.from(
        (map['columns'] as List<dynamic>).map<ColumnConfig>(
          (x) => ColumnConfig.fromJson(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  /// The name of the table.
  final String name;

  /// The configuration for the columns in the table.
  final List<ColumnConfig> columns;

  /// Creates a copy of this [TableConfig] but with the given fields
  /// replaced with the new values.
  TableConfig copyWith({
    String? name,
    List<ColumnConfig>? columns,
  }) {
    return TableConfig(
      name: name ?? this.name,
      columns: columns ?? this.columns,
    );
  }

  /// Converts this [TableConfig] to a json map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'columns': columns.map((x) => x.toJson()).toList(),
    };
  }
}
