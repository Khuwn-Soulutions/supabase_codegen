import 'package:supabase_codegen/src/generator/generator.dart';
import 'package:supabase_codegen/supabase_codegen.dart';
import 'package:test/test.dart';

import '../test_helpers/test_helpers.dart';

void main() {
  group('generateEnumsFile', () {
    const testEnumName = 'enum_test';
    const formattedTestEnumName = 'EnumTest';

    logger = testLogger;

    setUp(() {
      client = mockSupabase;
      mockSupabaseHttpClient.reset();
    });

    /// Generate the enums for the provided [enumData]
    Future<List<EnumConfig>> generateEnumWithData(
      List<Map<String, String>> enumData,
    ) async {
      mockEnumRpc(enumData);
      return generateEnumConfigs();
    }

    test('generates enum config with proper content', () async {
      final values = ['value1', 'value2'];
      final enumData = values
          .map((value) => {'enum_name': testEnumName, 'enum_value': value})
          .toList();
      final [enumConfig] = await generateEnumWithData(enumData);

      expect(
        enumConfig,
        const EnumConfig(
          enumName: testEnumName,
          formattedEnumName: formattedTestEnumName,
          values: ['value1', 'value2'],
        ),
      );
      expect(enumConfig.toJson(), {
        'enumName': testEnumName,
        'formattedEnumName': formattedTestEnumName,
        'values': values,
        'hasConstantIdentifier': false,
        'fileName': testEnumName,
      });
    });

    test('given multiple enums generates multiple enum configs', () async {
      final enums = await generateEnumWithData([
        ...testEnumOne,
        ...testEnumTwo,
      ]);

      expect(enums.length, 2, reason: 'Expected 2 enums');
      final [enumOne, enumTwo] = enums;
      expect(
        enumOne,
        const EnumConfig(
          enumName: enumOneName,
          formattedEnumName: 'EnumOne',
          values: enumOneValues,
        ),
      );
      expect(
        enumTwo,
        const EnumConfig(
          enumName: enumTwoName,
          formattedEnumName: 'EnumTwo',
          values: enumTwoValues,
        ),
      );
    });

    test('handles enum names with underscores and "Enum" suffix', () async {
      final enumContent = await generateEnumWithData([
        {'enum_name': 'my_test_enum_enum', 'enum_value': 'value1'},
        {'enum_name': 'my_test_enum_enum', 'enum_value': 'value2'},
        {'enum_name': 'another_enum', 'enum_value': 'valueA'},
      ]);

      expect(enumContent.length, 2, reason: 'Expected 2 enums');
      final [enumOne, enumTwo] = enumContent;
      expect(enumOne.formattedEnumName, 'MyTestEnum');
      expect(enumTwo.formattedEnumName, 'Another');
    });

    test('handles enum values with slashes', () async {
      final [enumContent] = await generateEnumWithData([
        {'enum_name': 'slash_enum', 'enum_value': 'value/1'},
        {'enum_name': 'slash_enum', 'enum_value': 'value/2'},
      ]);

      expect(enumContent.values, ['value_1', 'value_2']);
    });

    test('handles empty enum response', () async {
      final enumContent = await generateEnumWithData([]);

      expect(enumContent, isEmpty);
    });

    test('throws exception when fetching enums fails', () async {
      mockSupabaseHttpClient.registerRpcFunction(
        enumRpc,
        (params, tables) => throw Exception('Failed to fetch'),
      );

      expect(generateEnumConfigs, throwsException);
    });
  });
}
