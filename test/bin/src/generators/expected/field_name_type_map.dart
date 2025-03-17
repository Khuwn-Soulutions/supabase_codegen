import '../../../../../bin/src/src.dart';

/// Test [FieldNameTypeMap]
const FieldNameTypeMap testFieldNameTypeMap = {
  'isNotNullable': (
    dartType: 'String',
    isNullable: false,
    hasDefault: false,
    columnName: 'is_not_nullable',
    isArray: false,
    isEnum: false,
  ),
  'id': (
    dartType: 'String',
    isNullable: true,
    hasDefault: true,
    columnName: 'id',
    isArray: false,
    isEnum: false,
  ),
  'createdAt': (
    dartType: 'DateTime',
    isNullable: true,
    hasDefault: true,
    columnName: 'created_at',
    isArray: false,
    isEnum: false,
  ),
  'isNullable': (
    dartType: 'String',
    isNullable: true,
    hasDefault: false,
    columnName: 'is_nullable',
    isArray: false,
    isEnum: false,
  ),
  'isArray': (
    dartType: 'List<String>',
    isNullable: true,
    hasDefault: false,
    columnName: 'is_array',
    isArray: true,
    isEnum: false,
  ),
  'isInt': (
    dartType: 'int',
    isNullable: true,
    hasDefault: false,
    columnName: 'is_int',
    isArray: false,
    isEnum: false,
  ),
  'isDouble': (
    dartType: 'double',
    isNullable: true,
    hasDefault: false,
    columnName: 'is_double',
    isArray: false,
    isEnum: false,
  ),
  'isBool': (
    dartType: 'bool',
    isNullable: true,
    hasDefault: false,
    columnName: 'is_bool',
    isArray: false,
    isEnum: false,
  ),
  'isJson': (
    dartType: 'Map<String, dynamic>',
    isNullable: true,
    hasDefault: false,
    columnName: 'is_json',
    isArray: false,
    isEnum: false,
  ),
  'status': (
    dartType: 'Status',
    isNullable: true,
    hasDefault: false,
    columnName: 'status',
    isArray: false,
    isEnum: true,
  ),
};

/// Test [FieldNameTypeMap] entries
final testFieldNameTypeMapEntries = testFieldNameTypeMap.entries.toList();
