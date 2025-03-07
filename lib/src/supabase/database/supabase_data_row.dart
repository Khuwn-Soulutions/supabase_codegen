import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:supabase_codegen/supabase_codegen.dart';

/// Supabase data row
@immutable
abstract class SupabaseDataRow {
  /// Supabase data row
  const SupabaseDataRow(this.data);

  /// Database table within which row is stored
  SupabaseTable get table;

  /// Row data
  final Map<String, dynamic> data;

  /// Get the table name for the row
  String get tableName => table.tableName;

  /// Get the value of a field, returning the [defaultValue] if not found
  T? getField<T>(
    String fieldName, {
    T? defaultValue,
    List<T> enumValues = const [],
  }) =>
      supaDeserialize<T>(data[fieldName], enumValues: enumValues) ??
      defaultValue;

  /// Set the value of a field in the [data]
  void setField<T>(String fieldName, T? value) {
    data[fieldName] = supaSerialize<T>(value);
  }

  /// Get a field within the [data] as a List
  List<T> getListField<T>(String fieldName) =>
      supaDeserializeList<T>(data[fieldName]) ?? [];

  /// Set the List [value] of the [fieldName] within [data]
  void setListField<T>(String fieldName, List<T>? value) =>
      data[fieldName] = supaSerializeList(value);

  @override
  String toString() => '''
Table: $tableName
Row Data: {
${data.entries.map(
            (e) => '  (${e.value.runtimeType}) "${e.key}": ${e.value},\n',
          ).join()}}
''';

  @override
  int get hashCode => Object.hash(
        tableName,
        Object.hashAllUnordered(
          data.entries.map((e) => Object.hash(e.key, e.value)),
        ),
      );

  @override
  bool operator ==(Object other) =>
      other is SupabaseDataRow &&
      const DeepCollectionEquality().equals(other.data, data);
}
