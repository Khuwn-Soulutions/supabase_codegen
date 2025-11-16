import 'dart:convert';

import 'package:supabase_codegen/supabase_codegen_generator.dart';

/// Default option values
const defaultValues = <String, dynamic>{
  CmdOption.env: '.env',
  CmdOption.output: 'supabase/types',
  CmdOption.tag: '',
  CmdOption.configYaml: '.supabase_codegen.yaml',
  CmdOption.barrelFiles: true,
};

/// Helper to get the default value for a given Dart type.
String getDefaultValue(
  String dartType, {
  dynamic defaultValue,
  bool isEnum = false,
}) {
  final fallback =
      defaultValue
          ?.toString()
          // Serparate value from type
          .split('::')
          .first
          // Remove all single quotes
          .replaceAll("'", '')
          // Remove all functions
          .replaceAll(RegExp(r'\w+\(\)'), '') ??
      '';
  final fallbackValue = fallback.isNotEmpty ? fallback : null;

  logger.detail(
    'Default value: $defaultValue, type: $dartType, fallback: $fallbackValue',
  );

  switch (dartType) {
    case DartType.int:
      return fallbackValue ?? '0';
    case DartType.double:
      return fallbackValue ?? '0.0';
    case DartType.bool:
      return fallbackValue ?? 'false';
    case DartType.string:
      return "'${fallbackValue ?? ""}'";
    case DartType.dateTime:
      return DateTime.tryParse(fallbackValue ?? '') != null
          ? "DateTime.parse('$fallbackValue')"
          : 'DateTime.now()';
    case DartType.uuidValue:
      return switch (defaultValue) {
        'gen_random_uuid()' => 'const Uuid().v4obj()',
        'gen_random_uuid_v7()' => 'const Uuid().v7obj()',
        _ => 'const Uuid().v4obj()',
      };
    default:
      // Enum
      if (isEnum) {
        return fallbackValue != null ? '$dartType.$fallbackValue' : 'null';
      }
      // List
      if (dartType.startsWith('${DartType.list}<')) {
        final genericType = getGenericType(dartType);
        // Replace the enclosing {} of sql list to get comma separated list
        final fallbackList =
            fallbackValue?.replaceAll(RegExp('[{}]'), '') ?? '';
        final values = fallbackList.isEmpty
            ? <String>[]
            : fallbackList
                  .split(',')
                  .map(
                    (item) => switch (genericType) {
                      DartType.string => "'$item'",
                      _ => item,
                    },
                  )
                  .toList();
        logger.detail('Values: $values');

        return 'const <$genericType>[${values.join(', ')}]';
      }

      // Default (e.g. dynamic)
      if (fallbackValue != null) {
        try {
          // Check if the fallbackValue is valid json
          jsonDecode(fallbackValue);
          return fallbackValue.replaceAll('"', "'");
        }
        // Catch the FormatException with invalid json so we can return null
        on Exception catch (_) {
          return DartType.nullString;
        }
      }

      return DartType.nullString;
  }
}
