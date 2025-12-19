import 'package:supabase_codegen/src/generator/generator_config/rpc/rpc.dart';
import 'package:test/test.dart';

void main() {
  group('RpcConfig', () {
    test('empty creates an empty RpcConfig', () {
      final config = RpcConfig.empty();
      expect(config.functionName, isEmpty);
      expect(config.args, isEmpty);
      expect(config.returnType, equals(RpcReturnTypeConfig.empty()));
    });

    test('fromJson creates RpcConfig from json', () {
      final json = {
        'functionName': 'test_function',
        'args': [
          {'name': 'arg1', 'type': 'int', 'isList': false},
        ],
        'returnType': {
          'type': 'scalar',
          'fields': [
            {'name': 'result', 'type': 'String', 'isList': false},
          ],
        },
      };

      final config = RpcConfig.fromJson(json);

      expect(config.functionName, 'test_function');
      expect(config.args, hasLength(1));
      expect(config.args.first.name, 'arg1');
      expect(config.returnType.type, RpcReturnType.scalar);
    });

    test('toJson returns correct json map', () {
      const config = RpcConfig(
        functionName: 'test_function',
        args: [RpcFieldConfig(name: 'arg1', type: 'int', isList: false)],
        returnType: RpcReturnTypeConfig(
          type: RpcReturnType.scalar,
          fields: [
            RpcFieldConfig(name: 'result', type: 'String', isList: false),
          ],
        ),
      );

      final json = config.toJson();

      expect(json['functionName'], 'test_function');
      expect(json['methodName'], 'testFunction');
      expect(json['className'], 'TestFunction');
      expect(json['hasArgs'], true);
      expect(json['args'], hasLength(1));
      expect(json['returnType'], isNotNull);
      expect(json['returnsBaseType'], 'String');
      expect(json['returnsClassName'], 'String');
      expect(json['returnsTypeName'], 'String');
    });

    test('methodName returns camelCase function name', () {
      final config = RpcConfig.empty().copyWith(functionName: 'test_function');
      expect(config.methodName, 'testFunction');
    });

    test('className returns PascalCase function name', () {
      final config = RpcConfig.empty().copyWith(functionName: 'test_function');
      expect(config.className, 'TestFunction');
    });
    group('hasArgs', () {
      test('returns true if args is not empty', () {
        final config = RpcConfig.empty().copyWith(
          args: [const RpcFieldConfig(name: 'a', type: 'int', isList: false)],
        );
        expect(config.hasArgs, true);
      });

      test('returns false if args is empty', () {
        final config = RpcConfig.empty().copyWith(args: []);
        expect(config.hasArgs, false);
      });
    });

    group('returnsBaseType', () {
      test('returns correct string for TABLE return type', () {
        const config = RpcConfig(
          functionName: 'get_users',
          args: [],
          returnType: RpcReturnTypeConfig(
            type: RpcReturnType.table,
            fields: [],
          ),
        );
        expect(config.returnsBaseType, 'GetUsersResponse');
      });

      test('returns correct string for SETOF return type', () {
        const config = RpcConfig(
          functionName: 'get_users',
          args: [],
          returnType: RpcReturnTypeConfig(
            type: RpcReturnType.setOf,
            fields: [RpcFieldConfig(name: 'user', type: 'User', isList: false)],
          ),
        );
        expect(config.returnsBaseType, 'User');
      });

      test('returns correct string for SETOF return type '
          'when the fields list is empty', () {
        const config = RpcConfig(
          functionName: 'get_dynamics',
          args: [],
          returnType: RpcReturnTypeConfig(
            type: RpcReturnType.setOf,
            fields: [],
          ),
        );
        expect(config.returnsBaseType, 'dynamic');
      });

      test('returns correct string for SCALAR return type', () {
        const config = RpcConfig(
          functionName: 'get_count',
          args: [],
          returnType: RpcReturnTypeConfig(
            type: RpcReturnType.scalar,
            fields: [RpcFieldConfig(name: 'count', type: 'int', isList: false)],
          ),
        );
        expect(config.returnsBaseType, 'int');
      });

      test('returns correct string for SCALAR array return type', () {
        const config = RpcConfig(
          functionName: 'get_counts',
          args: [],
          returnType: RpcReturnTypeConfig(
            type: RpcReturnType.scalar,
            fields: [RpcFieldConfig(name: 'count', type: 'int', isList: true)],
          ),
        );
        expect(config.returnsBaseType, 'List<int>');
      });
    });

    group('returnsClassName', () {
      test('returns correct string for TABLE return type', () {
        const config = RpcConfig(
          functionName: 'get_users',
          args: [],
          returnType: RpcReturnTypeConfig(
            type: RpcReturnType.table,
            fields: [],
          ),
        );
        expect(config.returnsClassName, 'GetUsersResponse');
      });

      test('returns correct string for SETOF return type', () {
        const config = RpcConfig(
          functionName: 'get_users',
          args: [],
          returnType: RpcReturnTypeConfig(
            type: RpcReturnType.setOf,
            fields: [RpcFieldConfig(name: 'user', type: 'User', isList: false)],
          ),
        );
        expect(config.returnsClassName, 'UserRow');
      });
      test('returns correct string for SETOF return type '
          'when the fields list is empty', () {
        const config = RpcConfig(
          functionName: 'get_dynamics',
          args: [],
          returnType: RpcReturnTypeConfig(
            type: RpcReturnType.setOf,
            fields: [],
          ),
        );
        expect(config.returnsClassName, 'dynamic');
      });

      test('returns correct string for SCALAR return type', () {
        const config = RpcConfig(
          functionName: 'get_count',
          args: [],
          returnType: RpcReturnTypeConfig(
            type: RpcReturnType.scalar,
            fields: [RpcFieldConfig(name: 'count', type: 'int', isList: false)],
          ),
        );
        expect(config.returnsClassName, 'int');
      });

      test('returns correct string for SCALAR array return type', () {
        const config = RpcConfig(
          functionName: 'get_counts',
          args: [],
          returnType: RpcReturnTypeConfig(
            type: RpcReturnType.scalar,
            fields: [RpcFieldConfig(name: 'count', type: 'int', isList: true)],
          ),
        );
        expect(config.returnsClassName, 'List<int>');
      });
    });

    group('returnsTypeName', () {
      test('returns correct string for SCALAR return type', () {
        const config = RpcConfig(
          functionName: 'get_count',
          args: [],
          returnType: RpcReturnTypeConfig(
            type: RpcReturnType.scalar,
            fields: [RpcFieldConfig(name: 'count', type: 'int', isList: false)],
          ),
        );
        expect(config.returnsTypeName, 'int');
      });

      test('returns correct string for non-SCALAR return type', () {
        const config = RpcConfig(
          functionName: 'get_users',
          args: [],
          returnType: RpcReturnTypeConfig(
            type: RpcReturnType.table,
            fields: [],
          ),
        );
        expect(config.returnsTypeName, 'List<GetUsersResponse>');
      });

      test('returns correct string for SETOF return type', () {
        const config = RpcConfig(
          functionName: 'get_users',
          args: [],
          returnType: RpcReturnTypeConfig(
            type: RpcReturnType.setOf,
            fields: [RpcFieldConfig(name: 'user', type: 'User', isList: true)],
          ),
        );
        expect(config.returnsTypeName, 'List<UserRow>');
      });
    });

    test('supports value equality using == and hashCode', () {
      const arg = RpcFieldConfig(name: 'count', type: 'int', isList: false);
      const returnType = RpcReturnTypeConfig(
        type: RpcReturnType.scalar,
        fields: [RpcFieldConfig(name: 'count', type: 'int', isList: false)],
      );
      const config1 = RpcConfig(
        functionName: 'test',
        args: [arg],
        returnType: returnType,
      );
      const config2 = RpcConfig(
        functionName: 'test',
        args: [arg],
        returnType: returnType,
      );
      const config3 = RpcConfig(
        functionName: 'other',
        args: [arg],
        returnType: returnType,
      );

      expect(config1, equals(config2));
      expect(config1.hashCode, equals(config2.hashCode));
      expect(config1, isNot(equals(config3)));
      expect(config1.hashCode, isNot(equals(config3.hashCode)));
    });

    test('copyWith creates a new instance with updated values', () {
      const arg = RpcFieldConfig(name: 'count', type: 'int', isList: false);
      const returnType = RpcReturnTypeConfig(
        type: RpcReturnType.scalar,
        fields: [RpcFieldConfig(name: 'count', type: 'int', isList: false)],
      );
      const config = RpcConfig(
        functionName: 'test',
        args: [arg],
        returnType: returnType,
      );
      final updatedConfig = config.copyWith(functionName: 'updated');

      expect(updatedConfig.functionName, 'updated');
      expect(updatedConfig.args, const [arg]);
      expect(updatedConfig.returnType, returnType);
    });

    test('toString returns correct string', () {
      const arg = RpcFieldConfig(name: 'count', type: 'int', isList: false);
      const config = RpcConfig(
        functionName: 'test',
        args: [arg],
        returnType: RpcReturnTypeConfig(
          type: RpcReturnType.scalar,
          fields: [RpcFieldConfig(name: 'count', type: 'int', isList: false)],
        ),
      );

      final str = config.toString();

      // Check that all key parts of the toString output are present.
      expect(str, contains('functionName: test'));
      expect(str, contains('args:'));
      expect(str, contains('RpcFieldConfig(name: count'));
      expect(str, contains('type: int'));
      expect(str, contains('isList: false'));
      expect(str, contains('defaultValue: null'));
      expect(str, contains('returnType: RpcReturnTypeConfig'));
      expect(str, contains('type: scalar'));
      expect(str, contains('fields:'));
      expect(str, contains('RpcFieldConfig'));
      expect(str, contains('name: count'));
      expect(str, contains('type: int'));
      expect(str, contains('isList: false'));
      expect(str, contains('defaultValue: null'));
    });
  });
}
