import 'package:supabase_codegen/supabase_codegen_generator.dart';
import 'package:test/test.dart';

void main() {
  group('ColumnConfig', () {
    test('empty creates an empty ColumnConfig', () {
      final config = ColumnConfig.empty();
      expect(config.dartType, '');
      expect(config.isNullable, false);
      expect(config.hasDefault, false);
      expect(config.columnName, '');
      expect(config.isArray, false);
      expect(config.isEnum, false);
      expect(config.parameterName, '');
      expect(config.constructor, equals(ColumnConstructorConfig.empty()));
      expect(config.field, equals(ColumnFieldConfig.empty()));
    });

    test('fromJson creates a ColumnConfig from a map', () {
      final json = {
        'dartType': 'String',
        'isNullable': true,
        'hasDefault': true,
        'defaultValue': 'default',
        'columnName': 'col_name',
        'isArray': false,
        'isEnum': false,
        'parameterName': 'paramName',
        'constructor': ColumnConstructorConfig.empty().toJson(),
        'field': ColumnFieldConfig.empty().toJson(),
      };
      final config = ColumnConfig.fromJson(json);
      expect(config.dartType, 'String');
      expect(config.isNullable, true);
      expect(config.hasDefault, true);
      expect(config.defaultValue, 'default');
      expect(config.columnName, 'col_name');
      expect(config.isArray, false);
      expect(config.isEnum, false);
      expect(config.parameterName, 'paramName');
      expect(config.constructor, equals(ColumnConstructorConfig.empty()));
      expect(config.field, equals(ColumnFieldConfig.empty()));
    });

    test('toJson converts ColumnConfig to a map', () {
      final config = ColumnConfig(
        dartType: 'String',
        isNullable: true,
        hasDefault: true,
        defaultValue: 'default',
        columnName: 'col_name',
        isArray: false,
        isEnum: false,
        parameterName: 'paramName',
        constructor: ColumnConstructorConfig.empty(),
        field: ColumnFieldConfig.empty(),
      );
      final json = config.toJson();
      expect(json['dartType'], 'String');
      expect(json['isNullable'], true);
      expect(json['hasDefault'], true);
      expect(json['defaultValue'], 'default');
      expect(json['columnName'], 'col_name');
      expect(json['isArray'], false);
      expect(json['isEnum'], false);
      expect(json['parameterName'], 'paramName');
      expect(
        json['constructor'],
        equals(ColumnConstructorConfig.empty().toJson()),
      );
      expect(json['field'], equals(ColumnFieldConfig.empty().toJson()));
    });

    test('copyWith creates a copy with updated fields', () {
      final config = ColumnConfig.empty();
      final updated = config.copyWith(dartType: 'int', isNullable: true);
      expect(updated.dartType, 'int');
      expect(updated.isNullable, true);
      expect(updated.columnName, config.columnName);
    });

    test('equality works correctly', () {
      final config1 = ColumnConfig.empty();
      final config2 = ColumnConfig.empty();
      expect(config1, equals(config2));
      expect(config1.hashCode, equals(config2.hashCode));
    });

    group('fromColumnData creates correct config for', () {
      test('required non-nullable field', () {
        const columnData = (
          dartType: 'String',
          isNullable: false,
          hasDefault: false,
          defaultValue: null,
          columnName: 'col_name',
          isArray: false,
          isEnum: false,
        );
        final config = ColumnConfig.fromColumnData(
          fieldName: 'fieldName',
          columnData: columnData,
        );

        expect(config.dartType, 'String');
        expect(config.isNullable, false);
        expect(config.hasDefault, false);
        expect(config.columnName, 'col_name');
        expect(config.parameterName, 'fieldName');

        // Constructor checks
        expect(config.constructor.isOptional, false);
        expect(config.constructor.qualifier, 'required ');
        expect(config.constructor.question, '');

        // Field checks
        expect(config.field.name, 'fieldNameField');
        expect(config.field.question, '');
        expect(config.field.bang, '!');
      });

      test('nullable field', () {
        const columnData = (
          dartType: 'String',
          isNullable: true,
          hasDefault: false,
          defaultValue: null,
          columnName: 'col_name',
          isArray: false,
          isEnum: false,
        );
        final config = ColumnConfig.fromColumnData(
          fieldName: 'fieldName',
          columnData: columnData,
        );

        expect(config.isNullable, true);

        // Constructor checks
        expect(config.constructor.isOptional, true);
        expect(config.constructor.qualifier, '');
        expect(config.constructor.question, '?');

        // Field checks
        expect(config.field.question, '?');
        expect(config.field.bang, '');
      });

      test('field with default value', () {
        const columnData = (
          dartType: 'int',
          isNullable: false,
          hasDefault: true,
          defaultValue: 42,
          columnName: 'col_name',
          isArray: false,
          isEnum: false,
        );
        final config = ColumnConfig.fromColumnData(
          fieldName: 'fieldName',
          columnData: columnData,
        );

        expect(config.hasDefault, true);

        // Constructor checks
        expect(config.constructor.isOptional, true);
        expect(config.constructor.qualifier, '');
        expect(config.constructor.question, '?');

        // Field checks
        expect(config.field.defaultValue, '42');
      });

      test('field with default value evaluated as ${DartType.nullString}', () {
        const columnData = (
          dartType: DartType.dynamic,
          isNullable: false,
          hasDefault: true,
          defaultValue: "'{invalid json}'::jsonb",
          columnName: 'col_name',
          isArray: false,
          isEnum: false,
        );
        final config = ColumnConfig.fromColumnData(
          fieldName: 'fieldName',
          columnData: columnData,
        );

        expect(config.hasDefault, true);

        // Constructor checks
        expect(config.constructor.isOptional, true);
        expect(config.constructor.qualifier, '');
        expect(config.constructor.question, '');

        // Field checks
        expect(config.field.defaultValue, DartType.nullString);
        expect(config.field.question, '');
      });

      test('serial int field', () {
        const columnData = (
          dartType: 'int',
          isNullable: false,
          hasDefault: true,
          defaultValue: "nextval('tb_id_seq'::regclass)",
          columnName: 'col_name',
          isArray: false,
          isEnum: false,
        );
        final config = ColumnConfig.fromColumnData(
          fieldName: 'fieldName',
          columnData: columnData,
        );

        expect(config.hasDefault, true);

        // Constructor checks
        expect(config.constructor.isOptional, true);
        expect(config.constructor.qualifier, '');
        expect(config.constructor.question, '?');

        // Field checks
        expect(config.field.defaultValue, '0');
        expect(config.field.question, '');
      });

      test('dynamic type', () {
        const columnData = (
          dartType: 'dynamic',
          isNullable: false,
          hasDefault: false,
          defaultValue: null,
          columnName: 'col_name',
          isArray: false,
          isEnum: false,
        );
        final config = ColumnConfig.fromColumnData(
          fieldName: 'fieldName',
          columnData: columnData,
        );

        // Constructor checks
        expect(config.constructor.isOptional, true);
        expect(config.constructor.qualifier, '');
        expect(config.constructor.question, '');

        // Field checks
        expect(config.field.bang, '');
        expect(config.field.question, '');
        expect(config.field.defaultValue, '');
      });
    });
  });
}
