import 'package:meta/meta.dart';

/// {@template column_field_config}
/// The configuration for a column's field in the generated table row class.
/// {@endtemplate}
@immutable
class ColumnFieldConfig {
  /// {@macro column_field_config}
  const ColumnFieldConfig({
    required this.name,
    required this.defaultValue,
    required this.genericType,
    required this.question,
    required this.bang,
  });

  /// Creates an empty [ColumnFieldConfig].
  factory ColumnFieldConfig.empty() => const ColumnFieldConfig(
    name: '',
    defaultValue: '',
    genericType: '',
    question: '',
    bang: '',
  );

  // coverage:ignore-start
  /// Creates a [ColumnFieldConfig] from a json map.
  factory ColumnFieldConfig.fromJson(Map<String, dynamic> map) {
    return ColumnFieldConfig(
      name: map['name'] as String,
      defaultValue: map['defaultValue'] as String,
      genericType: map['genericType'] as String,
      question: map['question'] as String,
      bang: map['bang'] as String,
    );
  }
  // coverage:ignore-end

  /// The name of the static field in the generated table row class that holds
  /// the column name.
  ///
  /// e.g. `myColumnField`
  final String name;

  /// The default value for the field, as a string.
  final String defaultValue;

  /// If the column is an array, this is the generic type of the list.
  ///
  /// e.g. `String` for `List<String>`
  final String genericType;

  /// A `?` if the field is nullable and has no default value, otherwise an
  /// empty string.
  ///
  /// Used for the getter.
  final String question;

  /// A `!` if the field is not nullable, otherwise an empty string.
  ///
  /// Used for the getter.
  final String bang;

  /// Creates a copy of this [ColumnFieldConfig] but with the given fields
  /// replaced with the new values.
  // coverage:ignore-start
  ColumnFieldConfig copyWith({
    String? name,
    String? defaultValue,
    String? genericType,
    String? question,
    String? bang,
  }) {
    return ColumnFieldConfig(
      name: name ?? this.name,
      defaultValue: defaultValue ?? this.defaultValue,
      genericType: genericType ?? this.genericType,
      question: question ?? this.question,
      bang: bang ?? this.bang,
    );
  }
  // coverage:ignore-end

  /// Converts this [ColumnFieldConfig] to a json map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'defaultValue': defaultValue,
      'genericType': genericType,
      'question': question,
      'bang': bang,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ColumnFieldConfig &&
        other.name == name &&
        other.defaultValue == defaultValue &&
        other.genericType == genericType &&
        other.question == question &&
        other.bang == bang;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        defaultValue.hashCode ^
        genericType.hashCode ^
        question.hashCode ^
        bang.hashCode;
  }
}
