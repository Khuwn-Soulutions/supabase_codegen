import 'dart:io';

import 'package:change_case/change_case.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_codegen/supabase_codegen.dart';
import 'package:test/test.dart';

import '../../../bin/src/src.dart';

void main() {
  group('generateEnumsFile', () {
    late Directory testEnumsDir;
    const enumRpc = 'get_enum_types';
    const testEnumName = 'enum_test';
    const testOutputFolder = 'test/test_output_enums';
    logger = Logger(
      level: Level.off,
      filter: ProductionFilter(),
      printer: PrettyPrinter(
        methodCount: 0,
        excludeBox: {Level.debug: true, Level.info: true},
        printEmojis: false,
      ),
    );

    setUp(() {
      client = mockSupabase;
      mockSupabaseHttpClient.reset();
      final dirPath =
          path.join(Directory.current.path, '$testOutputFolder/enums');
      testEnumsDir = Directory(dirPath);

      // Ensure test output directory exists
      if (!testEnumsDir.existsSync()) {
        testEnumsDir.createSync(recursive: true);
      }
    });

    tearDown(() {
      // Clean up test output
      if (testEnumsDir.parent.existsSync()) {
        testEnumsDir.parent.deleteSync(recursive: true);
      }
    });

    Future<String> generateEnumWithData(dynamic enumData) async {
      mockSupabaseHttpClient.registerRpcFunction(
        enumRpc,
        (params, tables) => enumData,
      );
      await generateEnumsFile(testEnumsDir);

      final enumFile = File('${testEnumsDir.path}/$enumsFileName.dart');
      expect(enumFile.existsSync(), isTrue);
      return enumFile.readAsStringSync();
    }

    test('generates enum file successfully with proper content', () async {
      final enumContent = await generateEnumWithData([
        {'enum_name': testEnumName, 'enum_value': 'value1'},
        {'enum_name': testEnumName, 'enum_value': 'value2'},
      ]);

      expect(enumContent, contains('enum ${testEnumName.toPascalCase()}'));
      expect(enumContent, contains('value1'));
      expect(enumContent, contains('value2'));
      expect(enumContent, contains('/// ${testEnumName.toCapitalCase()} enum'));
      expect(enumContent, contains('Generated by supabase_codegen'));
    });

    test('generates multiple enums', () async {
      final enumContent = await generateEnumWithData([
        {'enum_name': 'enum_one', 'enum_value': 'value1'},
        {'enum_name': 'enum_one', 'enum_value': 'value2'},
        {'enum_name': 'enum_two', 'enum_value': 'valueA'},
        {'enum_name': 'enum_two', 'enum_value': 'valueB'},
      ]);

      expect(enumContent, contains('enum EnumOne'));
      expect(enumContent, contains('value1'));
      expect(enumContent, contains('value2'));
      expect(enumContent, contains('enum EnumTwo'));
      expect(enumContent, contains('valueA'));
      expect(enumContent, contains('valueB'));
    });

    test('handles enum names with underscores and "Enum" suffix', () async {
      final enumContent = await generateEnumWithData([
        {'enum_name': 'my_test_enum_enum', 'enum_value': 'value1'},
        {'enum_name': 'my_test_enum_enum', 'enum_value': 'value2'},
        {'enum_name': 'another_enum', 'enum_value': 'valueA'},
      ]);

      expect(enumContent, contains('enum MyTestEnum'));
      expect(enumContent, contains('enum Another'));
    });

    test('handles enum values with slashes', () async {
      final enumContent = await generateEnumWithData([
        {'enum_name': 'slash_enum', 'enum_value': 'value/1'},
        {'enum_name': 'slash_enum', 'enum_value': 'value/2'},
      ]);

      expect(enumContent, contains('value_1'));
      expect(enumContent, contains('value_2'));
    });

    test('handles empty enum response', () async {
      final enumContent = await generateEnumWithData(<dynamic>[]);

      expect(enumContent, contains('//'));
      expect(enumContent, contains('Generated file. Do not edit.'));
      expect(enumContent, contains('Generated by supabase_codegen'));
    });

    test('throws exception when fetching enums fails', () async {
      mockSupabaseHttpClient.registerRpcFunction(
        enumRpc,
        (params, tables) => throw Exception('Failed to fetch'),
      );

      expect(
        () => generateEnumsFile(testEnumsDir),
        throwsException,
      );
    });

    test('handles a different response format', () async {
      final enumData = {
        'data': [
          {'enum_name': 'diff_types', 'enum_value': 'value1'},
          {'enum_name': 'diff_types', 'enum_value': 'value2'},
        ],
      };
      final enumContent = await generateEnumWithData(enumData);

      expect(enumContent, contains('enum DiffTypes'));
      expect(enumContent, contains('value1'));
      expect(enumContent, contains('value2'));
    });
  });
}
