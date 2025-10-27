import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:latlng/latlng.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid_value.dart';

/// Serialize the [value] provided from [value]
/// with type [T] to json value
@protected
dynamic supaSerialize<T>(T? value) {
  /// Handle null value
  if (value == null) {
    return null;
  }

  switch (value) {
    case DateTime _:
      return (value as DateTime).toIso8601String();
    case LatLng _:
      final latLng = value as LatLng;
      return {'lat': latLng.latitude.degrees, 'lng': latLng.longitude.degrees};
    case UuidValue _:
      return (value as UuidValue).uuid;
    case final Enum enumValue:
      return enumValue.name;
    default:
      return value;
  }
}

/// Serialize a list
@protected
List<dynamic>? supaSerializeList<T>(List<T>? value) {
  final values = value?.map((v) => supaSerialize<T>(v));
  return values == null ? null : List<dynamic>.from(values);
}

/// Deserialize a value from json [value] to [T]
@protected
T? supaDeserialize<T>(dynamic value, {List<T> enumValues = const []}) {
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
    case const (LatLng):
      final latLng = value is Map ? value : json.decode(value as String) as Map;
      final lat = latLng['lat'] ?? latLng['latitude'];
      final lng = latLng['lng'] ?? latLng['longitude'];
      return lat is num && lng is num
          ? LatLng.degree(lat.toDouble(), lng.toDouble()) as T?
          : null;
    case const (UuidValue):
      return UuidValue.withValidation(value as String) as T?;
    default:
      return value as T;
  }
}

/// Deserialize a list
@protected
List<T>? supaDeserializeList<T>(
  dynamic value, {
  List<T> enumValues = const [],
}) =>
    value is List
        ? value
            .map((v) => supaDeserialize<T>(v, enumValues: enumValues))
            .where((v) => v != null)
            .map((v) => v as T)
            .toList()
        : null;
