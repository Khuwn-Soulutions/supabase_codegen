/// Expected copy with result
const expectedCopyWith = '''
  /// Make a copy of the current [TestGenerateRow] 
  /// overriding the provided fields
  TestGenerateRow copyWith({
    String? isNotNullable,
    String? id,
    DateTime? createdAt,
    String? isNullable,
    List<String>? isArray,
    int? isInt,
    double? isDouble,
    bool? isBool,
    dynamic isJson,
    Status? status,
    dynamic isDynamic,
    UuidValue? isUuid,
  }) =>
    TestGenerateRow.fromJson({
      'is_not_nullable': supaSerialize(isNotNullable) ?? data['is_not_nullable'],
      'id': supaSerialize(id) ?? data['id'],
      'created_at': supaSerialize(createdAt) ?? data['created_at'],
      'is_nullable': supaSerialize(isNullable) ?? data['is_nullable'],
      'is_array': supaSerialize(isArray) ?? data['is_array'],
      'is_int': supaSerialize(isInt) ?? data['is_int'],
      'is_double': supaSerialize(isDouble) ?? data['is_double'],
      'is_bool': supaSerialize(isBool) ?? data['is_bool'],
      'is_json': supaSerialize(isJson) ?? data['is_json'],
      'status': supaSerialize(status) ?? data['status'],
      'is_dynamic': supaSerialize(isDynamic) ?? data['is_dynamic'],
      'is_uuid': supaSerialize(isUuid) ?? data['is_uuid'],
    });
''';
