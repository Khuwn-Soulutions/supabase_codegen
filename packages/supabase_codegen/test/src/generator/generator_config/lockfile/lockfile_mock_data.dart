final configJson = {
  'date': '2025-11-23 23:38:34.916560',
  'package': 'test_package',
  'version': '1.0.0',
  'forFlutter': true,
  'tag': 'test_tag',
  'barrelFiles': true,
  'hasTag': true,
  'tables': [
    {'name': 'my_table', 'columns': <Map<String, dynamic>>[]},
  ],
  'enums': [
    {
      'enumName': 'my_enum',
      'formattedEnumName': 'MyEnum',
      'values': ['a', 'b'],
    },
  ],
  'rpcs': [
    {
      'functionName': 'my_rpc',
      'args': <Map<String, dynamic>>[],
      'returnType': {'type': 'scalar', 'fields': <Map<String, dynamic>>[]},
    },
    {
      'functionName': 'rpc_with_args',
      'args': [
        {'name': 'param1', 'type': 'text', 'isList': false},
        {'name': 'param2', 'type': 'integer', 'isList': true},
      ],
      'returnType': {'type': 'scalar', 'fields': <Map<String, dynamic>>[]},
    },
    {
      'functionName': 'rpc_array_return',
      'args': <Map<String, dynamic>>[],
      'returnType': {
        'type': 'scalar',
        'isList': true,
        'fields': <Map<String, dynamic>>[],
      },
    },
    {
      'functionName': 'rpc_table_return',
      'args': <Map<String, dynamic>>[],
      'returnType': {
        'type': 'table',
        'fields': [
          {'name': 'col1', 'type': 'text', 'isList': false},
          {'name': 'col2', 'type': 'integer', 'isList': false},
        ],
        'isList': true,
      },
    },
  ],
};

final lockfileJson = {
  'date': '2025-11-23 23:38:34.916560',
  'package': 'test_package',
  'version': '1.0.0',
  'forFlutter': true,
  'barrelFiles': true,
  'tag': 'test_tag',
  'tables': {'my_table': 1328570872},
  'enums': {'my_enum': 2619322029},
  'rpcs': {
    'my_rpc': 2649842866,
    'rpc_with_args': 769154930,
    'rpc_array_return': 2817707040,
    'rpc_table_return': 2081508374,
  },
};
