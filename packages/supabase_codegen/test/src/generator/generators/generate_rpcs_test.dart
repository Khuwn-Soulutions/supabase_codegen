import 'package:supabase_codegen/src/generator/generator.dart';
import 'package:test/test.dart';

void main() {
  group('Generate RPCs', () {
    group('parseArguments', () {
      final arguments = [
        (
          args: 'a integer, b integer',
          expected: [
            const RpcFieldConfig(name: 'a', type: 'int', isList: false),
            const RpcFieldConfig(name: 'b', type: 'int', isList: false),
          ],
        ),
        (
          args: 'a integer, b integer DEFAULT 1',
          expected: [
            const RpcFieldConfig(name: 'a', type: 'int', isList: false),
            const RpcFieldConfig(
              name: 'b',
              type: 'int',
              isList: false,
              defaultValue: '1',
            ),
          ],
        ),
        (
          args: 'arr integer[]',
          expected: [
            const RpcFieldConfig(name: 'arr', type: 'int', isList: true),
          ],
        ),
        (
          args: 'parts text[]',
          expected: [
            const RpcFieldConfig(name: 'parts', type: 'String', isList: true),
          ],
        ),
        (
          args: 'payload jsonb',
          expected: [
            const RpcFieldConfig(
              name: 'payload',
              type: 'dynamic',
              isList: false,
            ),
          ],
        ),
        (
          args: 'encoded_base64 text',
          expected: [
            const RpcFieldConfig(
              name: 'encoded_base64',
              type: 'String',
              isList: false,
            ),
          ],
        ),
      ];

      for (final (:args, :expected) in arguments) {
        test('should parse arguments correctly for $args', () {
          final arguments = parseArguments(args);
          expect(arguments, expected);
        });
      }

      test('should throw exception for invalid arguments', () {
        expect(() => parseArguments('invalid'), throwsException);
      });
    });

    group('parseReturnType', () {
      final returnTypes = [
        (
          returnType: 'TABLE(enum_name text, enum_value text)',
          expected: const RpcReturnTypeConfig(
            type: RpcReturnType.table,
            fields: [
              RpcFieldConfig(name: 'enum_name', type: 'String', isList: false),
              RpcFieldConfig(name: 'enum_value', type: 'String', isList: false),
            ],
          ),
        ),
        (
          returnType: 'integer',
          expected: const RpcReturnTypeConfig(
            type: RpcReturnType.scalar,
            fields: [
              RpcFieldConfig(name: 'integer', type: 'int', isList: false),
            ],
          ),
        ),
        (
          returnType: 'jsonb',
          expected: const RpcReturnTypeConfig(
            type: RpcReturnType.scalar,
            fields: [
              RpcFieldConfig(name: 'jsonb', type: 'dynamic', isList: false),
            ],
          ),
        ),
        (
          returnType: 'boolean',
          expected: const RpcReturnTypeConfig(
            type: RpcReturnType.scalar,
            fields: [
              RpcFieldConfig(name: 'boolean', type: 'bool', isList: false),
            ],
          ),
        ),
        (
          returnType: 'SETOF users',
          expected: const RpcReturnTypeConfig(
            type: RpcReturnType.setOf,
            fields: [
              RpcFieldConfig(name: 'users', type: 'Users', isList: true),
            ],
          ),
        ),
        (
          returnType: 'SETOF unknown',
          expected: const RpcReturnTypeConfig(
            type: RpcReturnType.setOf,
            fields: [
              RpcFieldConfig(name: 'unknown', type: 'dynamic', isList: true),
            ],
          ),
        ),
        (
          returnType: 'integer[]',
          expected: const RpcReturnTypeConfig(
            type: RpcReturnType.scalar,
            fields: [
              RpcFieldConfig(name: 'integer', type: 'int', isList: true),
            ],
          ),
        ),
        (
          returnType: 'text[]',
          expected: const RpcReturnTypeConfig(
            type: RpcReturnType.scalar,
            fields: [
              RpcFieldConfig(name: 'text', type: 'String', isList: true),
            ],
          ),
        ),
      ];

      for (final (:returnType, :expected) in returnTypes) {
        test('should parse return type correctly for $returnType', () {
          final tables = [TableConfig.empty().copyWith(name: 'users')];
          final result = parseReturnType(returnType, tables: tables);
          expect(result, expected);
        });
      }
    });
  });
}
