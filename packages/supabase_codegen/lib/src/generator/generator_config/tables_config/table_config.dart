import 'package:change_case/change_case.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:supabase_codegen/supabase_codegen_generator.dart';

/// {@template table_config}
/// The configuration for a table in the generated table row class.
/// {@endtemplate}
@immutable
class TableConfig {
  /// {@macro table_config}
  const TableConfig({required this.name, required this.columns});

  /// Creates an empty [TableConfig].
  // coverage:ignore-start
  factory TableConfig.empty() => const TableConfig(name: '', columns: []);

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
  // coverage:ignore-end

  /// Display name to use for the class
  String get displayName => name.toSentenceCase().toTitleCase();

  /// Class name
  String get className => name.toPascalCase();

  /// Row class name
  String get rowClass => '${className}Row';

  /// Table class name
  String get tableClass => '${className}Table';

  /// Imported files
  List<String> get importedFiles => columns
      .where((column) => column.dartType.isNotStandardType && column.isEnum)
      .map((column) => '../enums/${column.dartType.toSnakeCase()}.dart')
      .toList();

  /// The name of the table.
  final String name;

  /// The configuration for the columns in the table.
  final List<ColumnConfig> columns;

  /// Creates a copy of this [TableConfig] but with the given fields
  /// replaced with the new values.
  // coverage:ignore-start
  TableConfig copyWith({String? name, List<ColumnConfig>? columns}) {
    return TableConfig(
      name: name ?? this.name,
      columns: columns ?? this.columns,
    );
  }
  // coverage:ignore-end

  /// Converts this [TableConfig] to a json map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'displayName': displayName,
      'className': className,
      'rowClass': rowClass,
      'tableClass': tableClass,
      'hasImports': importedFiles.isNotEmpty,
      'importedFiles': importedFiles,
      'columns': columns.map((x) => x.toJson()).toList(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    const deepCollectionEquality = DeepCollectionEquality();

    return other is TableConfig &&
        other.name == name &&
        deepCollectionEquality.equals(other.columns, columns);
  }

  @override
  int get hashCode =>
      name.hashCode ^ const DeepCollectionEquality().hash(columns);
}
