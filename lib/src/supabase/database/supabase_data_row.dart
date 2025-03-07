import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:latlng/latlng.dart';
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
      _supaDeserialize<T>(data[fieldName], enumValues: enumValues) ??
      defaultValue;

  /// Set the value of a field in the [data]
  void setField<T>(String fieldName, T? value) {
    data[fieldName] = supaSerialize<T>(value);
  }

  /// Get a field within the [data] as a List
  List<T> getListField<T>(String fieldName) =>
      _supaDeserializeList<T>(data[fieldName]) ?? [];

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

  /// Serialize the [value] provided
  dynamic supaSerialize<T>(T? value) {
    /// Handle null value
    if (value == null) {
      return null;
    }

    switch (value) {
      case DateTime _:
        return (value as DateTime).toIso8601String();
      case PostgresTime _:
        return (value as PostgresTime).toIso8601String();
      case LatLng _:
        final latLng = value as LatLng;
        return {'lat': latLng.latitude, 'lng': latLng.longitude};
      case final Enum enumValue:
        return enumValue.name;
      default:
        return value;
    }
  }

  /// Serialize a list
  List<T>? supaSerializeList<T>(List<T>? value) {
    final values = value?.map((v) => supaSerialize<T>(v));
    return values == null ? null : List<T>.from(values);
  }

  /// Deserialize a value
  T? _supaDeserialize<T>(dynamic value, {List<T> enumValues = const []}) {
    /// Handle null value
    if (value == null) {
      return null;
    }

    /// Handle enum deserialization
    if (enumValues.isNotEmpty) {
      return (enumValues as List<Enum>)
          .firstWhereOrNull((val) => val.name == value) as T?;
    }

    /// Handle other types
    switch (T) {
      case const (int):
        return (value as num).round() as T?;
      case const (double):
        return (value as num).toDouble() as T?;
      case const (DateTime):
        return DateTime.tryParse(value as String)?.toLocal() as T?;
      case const (PostgresTime):
        return PostgresTime.tryParse(value as String) as T?;
      case const (LatLng):
        final latLng =
            value is Map ? value : json.decode(value as String) as Map;
        final lat = latLng['lat'] ?? latLng['latitude'];
        final lng = latLng['lng'] ?? latLng['longitude'];
        return lat is num && lng is num
            ? LatLng.degree(lat.toDouble(), lng.toDouble()) as T?
            : null;
      default:
        return value as T;
    }
  }

  /// Deserialize a list
  List<T>? _supaDeserializeList<T>(dynamic value) => value is List
      ? value
          .map((v) => _supaDeserialize<T>(v))
          .where((v) => v != null)
          .map((v) => v as T)
          .toList()
      : null;
}
