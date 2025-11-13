import 'package:meta/meta.dart';
import 'package:supabase_codegen/supabase_codegen_generator.dart';

/// {@template column_config}
/// The configuration for a column in the generated table row class.
/// {@endtemplate}
@immutable
class ColumnConfig {
  /// {@macro column_config}
  const ColumnConfig({
    required this.dartType,
    required this.isNullable,
    required this.hasDefault,
    required this.columnName,
    required this.isArray,
    required this.isEnum,
    required this.parameterName,
    required this.constructor,
    required this.field,
    this.defaultValue,
  });

  /// Creates an empty [ColumnConfig].
  factory ColumnConfig.empty() => ColumnConfig(
        dartType: '',
        isNullable: false,
        hasDefault: false,
        columnName: '',
        isArray: false,
        isEnum: false,
        parameterName: '',
        constructor: ColumnConstructorConfig.empty(),
        field: ColumnFieldConfig.empty(),
      );

  /// Creates a [ColumnConfig] from a json map.
  factory ColumnConfig.fromJson(Map<String, dynamic> map) {
    return ColumnConfig(
      dartType: map['dartType'] as String,
      isNullable: map['isNullable'] as bool,
      hasDefault: map['hasDefault'] as bool,
      defaultValue: map['defaultValue'] as dynamic,
      columnName: map['columnName'] as String,
      isArray: map['isArray'] as bool,
      isEnum: map['isEnum'] as bool,
      parameterName: map['parameterName'] as String,
      constructor: ColumnConstructorConfig.fromJson(
        map['constructor'] as Map<String, dynamic>,
      ),
      field: ColumnFieldConfig.fromJson(map['field'] as Map<String, dynamic>),
    );
  }

  /// Create a [ColumnConfig] from the [fieldName] and [ColumnData]
  factory ColumnConfig.fromColumnData({
    required String fieldName,
    required ColumnData columnData,
  }) {
    final (
      :dartType,
      :isNullable,
      :hasDefault,
      :defaultValue,
      :columnName,
      :isArray,
      :isEnum
    ) = columnData;

    /// Constructor
    final isOptional = dartType.isDynamic || isNullable || hasDefault;
    final constructor = ColumnConstructorConfig(
      isOptional: isOptional,
      qualifier: isOptional ? '' : 'required ',
      question: isOptional && dartType.isNotDynamic ? '?' : '',
    );

    // Field
    final isOptionalField = dartType.isNotDynamic && isNullable && !hasDefault;
    final field = ColumnFieldConfig(
      name: '${fieldName}Field',
      defaultValue: hasDefault
          ? getDefaultValue(
              dartType,
              defaultValue: defaultValue,
              isEnum: isEnum,
            )
          : '',
      genericType: isArray ? getGenericType(dartType) : '',
      question: isOptionalField ? '?' : '',
      bang: dartType.isDynamic || isOptionalField ? '' : '!',
    );
    return ColumnConfig(
      dartType: dartType,
      isNullable: isNullable,
      hasDefault: hasDefault,
      defaultValue: defaultValue,
      columnName: columnName,
      isArray: isArray,
      isEnum: isEnum,
      parameterName: fieldName,
      constructor: constructor,
      field: field,
    );
  }

  /// The dart type of the column.
  final String dartType;

  /// Whether the column is nullable.
  final bool isNullable;

  /// Whether the column has a default value.
  final bool hasDefault;

  /// The default value of the column.
  final dynamic defaultValue;

  /// The name of the column in the database.
  final String columnName;

  /// Whether the column is an array.
  final bool isArray;

  /// Whether the column is an enum.
  final bool isEnum;

  /// The name of the parameter in the generated constructor.
  final String parameterName;

  /// The configuration for the constructor parameter of the column.
  final ColumnConstructorConfig constructor;

  /// The configuration for the field of the column.
  final ColumnFieldConfig field;

  /// Creates a copy of this [ColumnConfig] but with the given fields
  /// replaced with the new values.
  ColumnConfig copyWith({
    String? dartType,
    bool? isNullable,
    bool? hasDefault,
    dynamic defaultValue,
    String? columnName,
    bool? isArray,
    bool? isEnum,
    String? parameterName,
    ColumnConstructorConfig? constructor,
    ColumnFieldConfig? field,
  }) {
    return ColumnConfig(
      dartType: dartType ?? this.dartType,
      isNullable: isNullable ?? this.isNullable,
      hasDefault: hasDefault ?? this.hasDefault,
      defaultValue: defaultValue ?? this.defaultValue,
      columnName: columnName ?? this.columnName,
      isArray: isArray ?? this.isArray,
      isEnum: isEnum ?? this.isEnum,
      parameterName: parameterName ?? this.parameterName,
      constructor: constructor ?? this.constructor,
      field: field ?? this.field,
    );
  }

  /// Converts this [ColumnConfig] to a json map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'dartType': dartType,
      'isDynamic': dartType.isDynamic,
      'isNullable': isNullable,
      'hasDefault': hasDefault,
      'defaultValue': defaultValue,
      'columnName': columnName,
      'isArray': isArray,
      'isEnum': isEnum,
      'parameterName': parameterName,
      'constructor': constructor.toJson(),
      'field': field.toJson(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ColumnConfig &&
        other.dartType == dartType &&
        other.isNullable == isNullable &&
        other.hasDefault == hasDefault &&
        other.defaultValue == defaultValue &&
        other.columnName == columnName &&
        other.isArray == isArray &&
        other.isEnum == isEnum &&
        other.parameterName == parameterName &&
        other.constructor == constructor &&
        other.field == field;
  }

  @override
  int get hashCode {
    return dartType.hashCode ^
        isNullable.hashCode ^
        hasDefault.hashCode ^
        defaultValue.hashCode ^
        columnName.hashCode ^
        isArray.hashCode ^
        isEnum.hashCode ^
        parameterName.hashCode ^
        constructor.hashCode ^
        field.hashCode;
  }
}
