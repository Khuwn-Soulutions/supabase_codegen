/// Expected copy with result
const expectedCopyWith = '''
  /// Make a copy of the current [TestGenerateRow] overriding the provided fields
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
  }) =>
    TestGenerateRow(
      isNotNullable: isNotNullable ?? this.isNotNullable,
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      isNullable: isNullable ?? this.isNullable,
      isArray: isArray ?? this.isArray,
      isInt: isInt ?? this.isInt,
      isDouble: isDouble ?? this.isDouble,
      isBool: isBool ?? this.isBool,
      isJson: isJson ?? this.isJson,
    );
''';
