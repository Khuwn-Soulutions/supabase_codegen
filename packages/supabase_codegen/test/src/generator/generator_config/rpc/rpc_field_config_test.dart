import 'package:supabase_codegen/src/generator/generator_config/rpc/rpc_field_config.dart';
import 'package:test/test.dart';

void main() {
  group('RpcFieldConfig', () {
    test('instantiates correctly', () {
      const config = RpcFieldConfig(
        name: 'test',
        type: 'String',
        isList: false,
        defaultValue: 'default',
      );
      expect(config.name, 'test');
      expect(config.type, 'String');
      expect(config.isList, false);
      expect(config.defaultValue, 'default');
      expect(config.parameterName, 'test');
      expect(config.paramType, 'String');
    });

    group('fromJson', () {
      test('creates instance from valid json', () {
        final json = {
          'name': 'test_arg',
          'type': 'int',
          'isList': true,
          'defaultValue': '0',
        };
        final config = RpcFieldConfig.fromJson(json);
        expect(config.name, 'test_arg');
        expect(config.type, 'int');
        expect(config.isList, true);
        expect(config.defaultValue, '0');
      });
    });

    group('fromNameAndRawType', () {
      test('creates instance for integer', () {
        final config = RpcFieldConfig.fromNameAndRawType(
          rawType: 'integer',
          name: 'count',
        );
        expect(config.name, 'count');
        expect(config.type, 'int');
        expect(config.isList, false);
        expect(config.defaultValue, null);
        expect(config.hasDefault, false);
        // int default is '0'
        expect(config.defaultValueJson, '0');
      });

      test('creates instance for text[]', () {
        final config = RpcFieldConfig.fromNameAndRawType(
          rawType: 'text[]',
          name: 'tags',
        );
        expect(config.name, 'tags');
        expect(config.type, 'String');
        expect(config.isList, true);
        expect(config.defaultValue, null);
        expect(config.hasDefault, false);
        // List default
        expect(config.defaultValueJson, '[]');
      });

      test('creates instance for text', () {
        final config = RpcFieldConfig.fromNameAndRawType(
          rawType: 'text',
          name: 'tag',
        );
        expect(config.name, 'tag');
        expect(config.type, 'String');
        expect(config.isList, false);
        expect(config.defaultValue, null);
        expect(config.hasDefault, false);
        // String default is ''
        expect(config.defaultValueJson, "''");
      });

      test('uses provided defaultValue if available', () {
        final config = RpcFieldConfig.fromNameAndRawType(
          rawType: 'integer',
          name: 'count',
          defaultValue: '10',
        );
        expect(config.defaultValue, '10');
        expect(config.hasDefault, true);
        expect(config.defaultValueJson, '10');
      });

      test('infers name from baseType if name not provided', () {
        final config = RpcFieldConfig.fromNameAndRawType(rawType: 'users');
        expect(config.name, 'users');
      });
    });

    group('fromArgString', () {
      test('parses simple argument', () {
        final config = RpcFieldConfig.fromArgString('param1 integer');
        expect(config.name, 'param1');
        expect(config.type, 'int');
        expect(config.isList, false);
        expect(config.defaultValue, null);
        expect(config.hasDefault, false);
        expect(config.defaultValueJson, '0');
      });

      test('parses argument with simple default', () {
        final config = RpcFieldConfig.fromArgString('param2 integer DEFAULT 0');
        expect(config.name, 'param2');
        expect(config.type, 'int');
        expect(config.isList, false);
        expect(config.defaultValue, '0');
        expect(config.hasDefault, true);
        expect(config.defaultValueJson, '0');
      });

      test('parses argument with string default', () {
        final config = RpcFieldConfig.fromArgString(
          "param3 text DEFAULT 'hello'",
        );
        expect(config.name, 'param3');
        expect(config.type, 'String');
        expect(config.isList, false);
        expect(config.defaultValue, "'hello'");
        expect(config.hasDefault, true);
        expect(config.defaultValueJson, "'hello'");
      });

      test('parses array argument', () {
        final config = RpcFieldConfig.fromArgString('param3 text[]');
        expect(config.name, 'param3');
        expect(config.type, 'String');
        expect(config.isList, true);
        expect(config.defaultValue, null);
        expect(config.hasDefault, false);
        expect(config.defaultValueJson, '[]');
      });

      test('throws exception for invalid format', () {
        expect(() => RpcFieldConfig.fromArgString('invalid'), throwsException);
      });
    });

    test('toJson returns correct map', () {
      const config = RpcFieldConfig(
        name: 'test',
        type: 'int',
        isList: true,
        defaultValue: '0',
      );
      final json = config.toJson();
      expect(json['name'], 'test');
      expect(json['parameterName'], 'test');
      expect(json['baseType'], 'int');
      expect(json['paramType'], 'List<int>');
      expect(json['isList'], true);
      expect(json['hasDefault'], true);
      expect(json['defaultValue'], '0');
    });

    test('equality', () {
      const config1 = RpcFieldConfig(
        name: 'a',
        type: 'int',
        isList: false,
        defaultValue: '0',
      );
      const config2 = RpcFieldConfig(
        name: 'a',
        type: 'int',
        isList: false,
        defaultValue: '0',
      );
      const config3 = RpcFieldConfig(
        name: 'b',
        type: 'int',
        isList: false,
        defaultValue: '0',
      );

      expect(config1, equals(config2));
      expect(config1.hashCode, equals(config2.hashCode));
      expect(config1, isNot(equals(config3)));
    });

    test('toString returns correct representation', () {
      const config = RpcFieldConfig(
        name: 'test',
        type: 'String',
        isList: false,
        defaultValue: 'null',
      );

      final description = config.toString();
      expect(description, contains('RpcFieldConfig('));
      expect(description, contains('name: test'));
      expect(description, contains('type: String'));
      expect(description, contains('isList: false'));
      expect(description, contains('defaultValue: null'));
    });

    group('paramType', () {
      test('returns correct type for scalar', () {
        const config = RpcFieldConfig(name: 'a', type: 'int', isList: false);
        expect(config.paramType, 'int');
      });

      test('returns correct type for list', () {
        const config = RpcFieldConfig(name: 'a', type: 'int', isList: true);
        expect(config.paramType, 'List<int>');
      });
    });
  });
}
