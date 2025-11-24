import 'package:supabase_codegen/supabase_codegen_generator.dart';
import 'package:test/test.dart';

void main() {
  group('Generate RPCs', () {
    group('parseArguments', () {
      final arguments = [
        (
          args: 'a integer, b integer',
          expected: [
            const RpcArgumentConfig(name: 'a', type: 'int', isList: false),
            const RpcArgumentConfig(name: 'b', type: 'int', isList: false),
          ],
        ),
        (
          args: 'arr integer[]',
          expected: [
            const RpcArgumentConfig(name: 'arr', type: 'int', isList: true),
          ],
        ),
        (
          args: 'parts text[]',
          expected: [
            const RpcArgumentConfig(
              name: 'parts',
              type: 'String',
              isList: true,
            ),
          ],
        ),
        (
          args: 'payload jsonb',
          expected: [
            const RpcArgumentConfig(
              name: 'payload',
              type: 'dynamic',
              isList: false,
            ),
          ],
        ),
        (
          args: 'encoded_base64 text',
          expected: [
            const RpcArgumentConfig(
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
    });

    group('parseReturnType', () {
      final returnTypes = [
        (
          returnType: 'TABLE(enum_name text, enum_value text)',
          expected: const RpcReturnTypeConfig(
            returnType: RpcReturnType.table,
            fields: [
              RpcArgumentConfig(
                name: 'enum_name',
                type: 'String',
                isList: false,
              ),
              RpcArgumentConfig(
                name: 'enum_value',
                type: 'String',
                isList: false,
              ),
            ],
          ),
        ),
        (
          returnType: 'integer',
          expected: const RpcReturnTypeConfig(
            returnType: RpcReturnType.scalar,
            fields: [
              RpcArgumentConfig(name: 'integer', type: 'int', isList: false),
            ],
          ),
        ),
        (
          returnType: 'jsonb',
          expected: const RpcReturnTypeConfig(
            returnType: RpcReturnType.scalar,
            fields: [
              RpcArgumentConfig(name: 'jsonb', type: 'dynamic', isList: false),
            ],
          ),
        ),
        (
          returnType: 'boolean',
          expected: const RpcReturnTypeConfig(
            returnType: RpcReturnType.scalar,
            fields: [
              RpcArgumentConfig(name: 'boolean', type: 'bool', isList: false),
            ],
          ),
        ),
        (
          returnType: 'SETOF users',
          expected: const RpcReturnTypeConfig(
            returnType: RpcReturnType.setOf,
            fields: [
              RpcArgumentConfig(name: 'users', type: 'Users', isList: true),
            ],
          ),
        ),
        (
          returnType: 'SETOF unknown',
          expected: const RpcReturnTypeConfig(
            returnType: RpcReturnType.setOf,
            fields: [
              RpcArgumentConfig(name: 'unknown', type: 'dynamic', isList: true),
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
