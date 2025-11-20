import 'package:change_case/change_case.dart';
import 'package:pluralize/pluralize.dart';
import 'package:supabase_codegen/supabase_codegen_generator.dart';
import 'package:supabase_codegen_serverpod/supabase_codegen_serverpod.dart';

/// Table config extensions
extension TableConfigExtensions on TableConfig {
  /// Converts this [TableConfig] to a json map
  /// for use in generating Serverpod models
  Map<String, dynamic> toServerpodJson() {
    return <String, dynamic>{
      'name': name,
      'tableClass': Pluralize().singular(name.toPascalCase()),
      'columns': columns.map(parseSpyColumnMap).toList(),
    };
  }
}

/// Parse the map to use to generate the spy model file from the
/// [column] config provided
Map<String, dynamic> parseSpyColumnMap(ColumnConfig column) {
  final isId = column.parameterName == 'id';
  final isOptional = column.isNullable || column.hasDefault || isId;
  final hasColumnAlias = column.parameterName != column.columnName;
  final rawDefaultValue = (column.columnData?.defaultValue ?? '').toString();
  final defaultValue = extractDefaultValue(
    rawDefaultValue,
    column.dartType,
  );
  final hasDefault = defaultValue.isNotEmpty;
  final defaultKey = isId ? defaultPersistIdentifier : defaultIdentifier;

  return {
    'parameterName': column.parameterName,
    'type': column.dartType.isDynamic ? 'JsonClass' : column.dartType,
    'question': isOptional ? '?' : '',
    'hasColumnAlias': hasColumnAlias,
    'columnName': hasColumnAlias ? column.columnName : '',
    'hasDefault': hasDefault,
    'defaultValue': defaultValue,
    'defaultKey': hasDefault ? defaultKey : '',
  };
}
