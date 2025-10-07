/// Overrides for a column in the generated dart class
class ColumnOverride {
  /// Constructor
  const ColumnOverride({
    this.dataType,
    this.isNullable,
    this.columnDefault,
  });

  /// Create a [ColumnOverride] from a JSON map
  factory ColumnOverride.fromJson(Map<dynamic, dynamic> json) => ColumnOverride(
        dataType: json['data_type'] as String?,
        isNullable: json['is_nullable'] as bool?,
        columnDefault: json['column_default'],
      );

  /// The data type of the column
  final String? dataType;

  /// Whether the column is nullable
  final bool? isNullable;

  /// The default value of the column
  final dynamic columnDefault;

  /// Convert this [ColumnOverride] to a JSON map
  Map<String, dynamic> toJson() => {
        if (dataType != null) 'data_type': dataType,
        if (isNullable != null) 'is_nullable': isNullable,
        if (columnDefault != null) 'column_default': columnDefault,
      };

  /// String representation of [ColumnOverride]
  @override
  String toString() => toJson().toString();
}
