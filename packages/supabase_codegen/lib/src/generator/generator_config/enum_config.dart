import 'dart:convert';

import 'package:change_case/change_case.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

/// {@template enum_config}
/// A class that holds the configuration for a single enum.
///
/// This class is used to define how a specific enum from the database should be
/// generated in the Dart code.
/// {@endtemplate}
@immutable
class EnumConfig {
  /// {@macro enum_config}
  const EnumConfig({
    required this.enumName,
    required this.formattedEnumName,
    required this.values,
  });

  /// An empty factory for [EnumConfig].
  factory EnumConfig.empty() =>
      const EnumConfig(enumName: '', formattedEnumName: '', values: []);

  /// Creates an [EnumConfig] from a JSON object.
  ///
  /// The [json] object should be a map with string keys and dynamic values.
  // coverage:ignore-start
  factory EnumConfig.fromJson(Map<String, dynamic> json) {
    return EnumConfig(
      enumName: json['enumName'] as String,
      formattedEnumName: json['formattedEnumName'] as String,
      values: (json['values'] as List<dynamic>).cast<String>(),
    );
  }
  // coverage:ignore-end

  /// The original name of the enum from the database.
  final String enumName;

  /// The formatted name of the enum to be used in the generated Dart code.
  final String formattedEnumName;

  /// The list of values for the enum.
  final List<String> values;

  /// Does any of the values use ALL_CAPS_WITH_UNDERSCORES
  bool get hasConstantIdentifier => values.any((value) => value.isUpperCase());

  /// File name
  String get fileName => formattedEnumName.toSnakeCase();

  /// Converts the [EnumConfig] to a JSON object.
  Map<String, dynamic> toJson() {
    return {
      'enumName': enumName,
      'formattedEnumName': formattedEnumName,
      'values': values,
      'hasConstantIdentifier': hasConstantIdentifier,
      'fileName': fileName,
    };
  }

  /// Get string representation of [EnumConfig]
  // coverage:ignore-start
  @override
  String toString() => jsonEncode(toJson());

  /// Creates a copy of this [EnumConfig] but with the given fields replaced
  /// with the new values.
  EnumConfig copyWith({
    String? enumName,
    String? formattedEnumName,
    List<String>? values,
  }) {
    return EnumConfig(
      enumName: enumName ?? this.enumName,
      formattedEnumName: formattedEnumName ?? this.formattedEnumName,
      values: values ?? this.values,
    );
  }
  // coverage:ignore-end

  @override
  int get hashCode =>
      enumName.hashCode ^
      formattedEnumName.hashCode ^
      const DeepCollectionEquality().hash(values);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnumConfig &&
          runtimeType == other.runtimeType &&
          enumName == other.enumName &&
          formattedEnumName == other.formattedEnumName &&
          const DeepCollectionEquality().equals(values, other.values);
}
