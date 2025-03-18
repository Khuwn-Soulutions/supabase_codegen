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
    Map<String, dynamic>? isJson,
    Status? status,
  }) =>
    TestGenerateRow.fromJson({
      'is_not_nullable': isNotNullable ?? data['is_not_nullable'],
      'id': id ?? data['id'],
      'created_at': createdAt ?? data['created_at'],
      'is_nullable': isNullable ?? data['is_nullable'],
      'is_array': isArray ?? data['is_array'],
      'is_int': isInt ?? data['is_int'],
      'is_double': isDouble ?? data['is_double'],
      'is_bool': isBool ?? data['is_bool'],
      'is_json': isJson ?? data['is_json'],
      'status': status?.name ?? data['status'],
    });
''';
