import 'expected.dart';

/// Expected Row class
const expectedRowClass = '''
/// Test Generate Row
class TestGenerateRow extends SupabaseDataRow {
  /// Test Generate Row
  TestGenerateRow({
    required String isNotNullable,
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
  }): super({
    'is_not_nullable': supaSerialize(isNotNullable),
    if (id != null) 'id': supaSerialize(id),
    if (createdAt != null) 'created_at': supaSerialize(createdAt),
    if (isNullable != null) 'is_nullable': supaSerialize(isNullable),
    if (isArray != null) 'is_array': supaSerialize(isArray),
    if (isInt != null) 'is_int': supaSerialize(isInt),
    if (isDouble != null) 'is_double': supaSerialize(isDouble),
    if (isBool != null) 'is_bool': supaSerialize(isBool),
    if (isJson != null) 'is_json': supaSerialize(isJson),
    if (status != null) 'status': supaSerialize(status),
    if (isDynamic != null) 'is_dynamic': supaSerialize(isDynamic),
    if (isUuid != null) 'is_uuid': supaSerialize(isUuid),
  });

  /// Test Generate Row
  const TestGenerateRow._(super.data);

  /// Create Test Generate Row from a [data] map
  factory TestGenerateRow.fromJson(Map<String, dynamic> data) => TestGenerateRow._(data.cleaned);
$expectedRowFields$expectedCopyWith}

''';

final expectedFlutterRowClass =
    expectedRowClass.replaceAll('SupabaseDataRow', 'SupabaseFlutterDataRow');
