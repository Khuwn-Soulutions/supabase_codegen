import 'package:meta/meta.dart';

/// {@template column_constructor_config}
/// The configuration for a column's constructor parameter in the generated
/// table row class.
/// {@endtemplate}
@immutable
class ColumnConstructorConfig {
  /// {@macro column_constructor_config}
  const ColumnConstructorConfig({
    required this.isOptional,
    required this.qualifier,
    required this.question,
  });

  /// Creates an empty [ColumnConstructorConfig].
  factory ColumnConstructorConfig.empty() => const ColumnConstructorConfig(
    isOptional: false,
    qualifier: '',
    question: '',
  );

  // coverage:ignore-start
  /// Creates a [ColumnConstructorConfig] from a json map.
  factory ColumnConstructorConfig.fromJson(Map<String, dynamic> map) {
    return ColumnConstructorConfig(
      isOptional: map['isOptional'] as bool,
      qualifier: map['qualifier'] as String,
      question: map['question'] as String,
    );
  }
  // coverage:ignore-end

  /// Whether the parameter is optional in the constructor.
  final bool isOptional;

  /// The qualifier for the parameter in the constructor (e.g. `required`).
  final String qualifier;

  /// A `?` if the parameter is nullable, otherwise an empty string.
  final String question;

  /// Creates a copy of this [ColumnConstructorConfig] but with the given
  /// fields replaced with the new values.
  // coverage:ignore-start
  ColumnConstructorConfig copyWith({
    bool? isOptional,
    String? qualifier,
    String? question,
  }) {
    return ColumnConstructorConfig(
      isOptional: isOptional ?? this.isOptional,
      qualifier: qualifier ?? this.qualifier,
      question: question ?? this.question,
    );
  }
  // coverage:ignore-end

  /// Converts this [ColumnConstructorConfig] to a json map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'isOptional': isOptional,
      'qualifier': qualifier,
      'question': question,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ColumnConstructorConfig &&
        other.isOptional == isOptional &&
        other.qualifier == qualifier &&
        other.question == question;
  }

  @override
  int get hashCode =>
      isOptional.hashCode ^ qualifier.hashCode ^ question.hashCode;
}
