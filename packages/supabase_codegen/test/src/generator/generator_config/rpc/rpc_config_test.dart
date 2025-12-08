import 'package:supabase_codegen/src/generator/generator_config/rpc/rpc_argument_config.dart';
import 'package:supabase_codegen/src/generator/generator_config/rpc/rpc_config.dart';
import 'package:supabase_codegen/src/generator/generator_config/rpc/rpc_return_config.dart';
import 'package:supabase_codegen/src/generator/generator_config/rpc/rpc_return_type.dart';
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
          'returnType': 'scalar',
          'fields': [
            {'name': 'result', 'type': 'String', 'isList': false},
          ],
        },
      };

      final config = RpcConfig.fromJson(json);

      expect(config.functionName, 'test_function');
      expect(config.args, hasLength(1));
      expect(config.args.first.name, 'arg1');
      expect(config.returnType.returnType, RpcReturnType.scalar);
    });

    test('toJson returns correct json map', () {
      const config = RpcConfig(
        functionName: 'test_function',
        args: [RpcArgumentConfig(name: 'arg1', type: 'int', isList: false)],
        returnType: RpcReturnTypeConfig(
          returnType: RpcReturnType.scalar,
          fields: [
            RpcArgumentConfig(name: 'result', type: 'String', isList: false),
          ],
        ),
      );

      final json = config.toJson();

      expect(json['functionName'], 'test_function');
      expect(json['methodName'], 'testFunction');
      expect(json['className'], 'TestFunction');
      expect(json['hasArgs'], true);
      expect(json['args'], hasLength(1));
      expect(json['rpcReturnType'], isNotNull);
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
          args: [
            const RpcArgumentConfig(name: 'a', type: 'int', isList: false),
          ],
        );
        expect(config.hasArgs, true);
      });

      test('returns false if args is empty', () {
        final config = RpcConfig.empty().copyWith(args: []);
        expect(config.hasArgs, false);
      });
    });

    group('returnsClassName', () {
      test('returns correct string for TABLE return type', () {
        const config = RpcConfig(
          functionName: 'get_users',
          args: [],
          returnType: RpcReturnTypeConfig(
            returnType: RpcReturnType.table,
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
            returnType: RpcReturnType.setOf,
            fields: [
              RpcArgumentConfig(name: 'user', type: 'User', isList: false),
            ],
          ),
        );
        expect(config.returnsClassName, 'List<User>');
      });
      test('returns correct string for SETOF return type '
          'when the fields list is empty', () {
        const config = RpcConfig(
          functionName: 'get_dynamics',
          args: [],
          returnType: RpcReturnTypeConfig(
            returnType: RpcReturnType.setOf,
            fields: [],
          ),
        );
        expect(config.returnsClassName, 'List<dynamic>');
      });

      test('returns correct string for SCALAR return type', () {
        const config = RpcConfig(
          functionName: 'get_count',
          args: [],
          returnType: RpcReturnTypeConfig(
            returnType: RpcReturnType.scalar,
            fields: [
              RpcArgumentConfig(name: 'count', type: 'int', isList: false),
            ],
          ),
        );
        expect(config.returnsClassName, 'int');
      });
    });

    group('returnsTypeName', () {
      test('returns correct string for SCALAR return type', () {
        const config = RpcConfig(
          functionName: 'get_count',
          args: [],
          returnType: RpcReturnTypeConfig(
            returnType: RpcReturnType.scalar,
            fields: [
              RpcArgumentConfig(name: 'count', type: 'int', isList: false),
            ],
          ),
        );
        expect(config.returnsTypeName, 'int');
      });

      test('returns correct string for non-SCALAR return type', () {
        const config = RpcConfig(
          functionName: 'get_users',
          args: [],
          returnType: RpcReturnTypeConfig(
            returnType: RpcReturnType.table,
            fields: [],
          ),
        );
        expect(config.returnsTypeName, 'List<GetUsersResponse>');
      });
    });

    test('supports value equality using == and hashCode', () {
      const arg = RpcArgumentConfig(name: 'count', type: 'int', isList: false);
      const returnType = RpcReturnTypeConfig(
        returnType: RpcReturnType.scalar,
        fields: [RpcArgumentConfig(name: 'count', type: 'int', isList: false)],
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
      const arg = RpcArgumentConfig(name: 'count', type: 'int', isList: false);
      const returnType = RpcReturnTypeConfig(
        returnType: RpcReturnType.scalar,
        fields: [RpcArgumentConfig(name: 'count', type: 'int', isList: false)],
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
      const arg = RpcArgumentConfig(name: 'count', type: 'int', isList: false);
      const config = RpcConfig(
        functionName: 'test',
        args: [arg],
        returnType: RpcReturnTypeConfig(
          returnType: RpcReturnType.scalar,
          fields: [
            RpcArgumentConfig(name: 'count', type: 'int', isList: false),
          ],
        ),
      );
      expect(
        config.toString(),
        'RpcConfig(functionName: test, args: '
        '[RpcArgumentConfig(name: count, type: int, isList: false, '
        'defaultValue: null)], '
        'returnType: RpcReturnTypeConfig(returnType: scalar, fields: '
        '[RpcArgumentConfig(name: count, type: int, isList: false, '
        'defaultValue: null)]))',
      );
    });
  });
}
