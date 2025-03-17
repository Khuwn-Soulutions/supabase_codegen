/// Expected row fields
const expectedRowFields = '''
  /// Get the [SupabaseTable] for this row
  @override
  SupabaseTable get table => TestGenerateTable();

  /// Is Not Nullable field name
  static const String isNotNullableField = 'is_not_nullable';

  /// Is Not Nullable
  String get isNotNullable => getField<String>(isNotNullableField)!;
  set isNotNullable(String value) => setField<String>(isNotNullableField, value);

  /// Id field name
  static const String idField = 'id';

  /// Id
  String get id => getField<String>(idField, defaultValue: '')!;
  set id(String value) => setField<String>(idField, value);

  /// Created At field name
  static const String createdAtField = 'created_at';

  /// Created At
  DateTime get createdAt => getField<DateTime>(createdAtField, defaultValue: DateTime.now())!;
  set createdAt(DateTime value) => setField<DateTime>(createdAtField, value);

  /// Is Nullable field name
  static const String isNullableField = 'is_nullable';

  /// Is Nullable
  String? get isNullable => getField<String>(isNullableField);
  set isNullable(String? value) => setField<String>(isNullableField, value);

  /// Is Array field name
  static const String isArrayField = 'is_array';

  /// Is Array
  List<String> get isArray => getListField<String>(isArrayField);
  set isArray(List<String>? value) => setListField<String>(isArrayField, value);

  /// Is Int field name
  static const String isIntField = 'is_int';

  /// Is Int
  int? get isInt => getField<int>(isIntField);
  set isInt(int? value) => setField<int>(isIntField, value);

  /// Is Double field name
  static const String isDoubleField = 'is_double';

  /// Is Double
  double? get isDouble => getField<double>(isDoubleField);
  set isDouble(double? value) => setField<double>(isDoubleField, value);

  /// Is Bool field name
  static const String isBoolField = 'is_bool';

  /// Is Bool
  bool? get isBool => getField<bool>(isBoolField);
  set isBool(bool? value) => setField<bool>(isBoolField, value);

  /// Is Json field name
  static const String isJsonField = 'is_json';

  /// Is Json
  Map<String, dynamic>? get isJson => getField<Map<String, dynamic>>(isJsonField);
  set isJson(Map<String, dynamic>? value) => setField<Map<String, dynamic>>(isJsonField, value);

  /// Status field name
  static const String statusField = 'status';

  /// Status
  Status? get status => getField<Status>(statusField, enumValues: Status.values);
  set status(Status? value) => setField<Status>(statusField, value);

''';
