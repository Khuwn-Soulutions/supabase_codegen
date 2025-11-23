import 'package:supabase_codegen/supabase_codegen_generator.dart';

/// Default identifier
const String defaultIdentifier = 'default';

/// Default persist identifier
const String defaultPersistIdentifier = 'defaultPersist';

/// Extract the default value from the default value from the database
String extractDefaultValue(String defaultValue, String dartType) {
  if (defaultValue.isEmpty) return '';

  // Serial values
  if (defaultValue.startsWith('nextval')) {
    return 'serial';
  }

  // Now
  if (defaultValue.contains('now') || defaultValue == 'CURRENT_TIMESTAMP') {
    return 'now';
  }

  // Uuid
  if (defaultValue.contains('gen_random_uuid')) {
    return defaultValue
        .replaceAll('gen_random_uuid', 'random')
        .replaceAll('()', '');
  }

  // Other types
  const separator = '::';
  if (!defaultValue.contains(separator)) {
    return defaultValue;
  }

  final [value, type] = defaultValue.split(separator);
  final unquotedValue = value.replaceAll("'", '');

  // List/Json (ignore defaults)
  if (dartType.contains(DartType.list) || type.contains('json')) {
    return '';
  }

  if (dartType == DartType.dateTime) {
    final dt = DateTime.tryParse(unquotedValue);
    return dt == null ? '' : dt.toIso8601String();
  }

  // Default
  return dartType == DartType.string ? value : unquotedValue;
}
