import 'package:change_case/change_case.dart';
import 'package:meta/meta.dart';
import 'package:supabase_codegen/supabase_codegen_generator.dart';

/// {@template rpc_field_config}
/// RPC Field Config
/// {@endtemplate}
@immutable
class RpcFieldConfig {
  /// {@macro rpc_field_config}
  const RpcFieldConfig({
    required this.name,
    required this.type,
    required this.isList,
    this.defaultValue,
  });

  /// Create [RpcFieldConfig] from [json]
  factory RpcFieldConfig.fromJson(Map<String, dynamic> json) => RpcFieldConfig(
    name: json['name'] as String,
    type: json['type'] as String,
    isList: json['isList'] as bool,
    defaultValue: json['defaultValue'] as String?,
  );

  /// Create [RpcFieldConfig] from [name] and [rawType]
  factory RpcFieldConfig.fromNameAndRawType({
    required String rawType,
    String? name,
    String? defaultValue,
  }) {
    const arraySuffix = '[]';
    final isList = rawType.endsWith(arraySuffix);
    final baseType = rawType.replaceAll(arraySuffix, '');
    final type = getBaseDartType(baseType);

    return RpcFieldConfig(
      name: name ?? baseType,
      type: type,
      isList: isList,
      defaultValue: defaultValue,
    );
  }

  /// Create [RpcFieldConfig] from String representation of [arg]
  ///
  /// Expected format: "name type [DEFAULT value]"
  /// Example: "param1 int", "param2 int DEFAULT 0", "param3 text[]"
  factory RpcFieldConfig.fromArgString(String arg) {
    final regex = RegExp(r'^(\S+)\s+(\S+)(?:\s+DEFAULT\s+(.+))?$');
    final match = regex.firstMatch(arg);

    if (match == null) {
      final message = 'Could not parse argument: "$arg"';
      logger.warn(message);
      throw Exception(message);
    }

    final name = match.group(1)!;
    final typeRaw = match.group(2)!;
    final defaultValue = match.group(3);
    return RpcFieldConfig.fromNameAndRawType(
      name: name,
      rawType: typeRaw,
      defaultValue: defaultValue,
    );
  }

  /// Argument name
  final String name;

  /// Parameter name
  String get parameterName => name.toCamelCase();

  /// Argument type
  final String type;

  /// Is list
  final bool isList;

  /// Default value
  final String? defaultValue;

  /// Parameter type
  String get paramType => isList ? 'List<$type>' : type;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RpcFieldConfig &&
        other.name == name &&
        other.type == type &&
        other.isList == isList &&
        other.defaultValue == defaultValue;
  }

  @override
  int get hashCode =>
      stableHash(name) ^
      stableHash(type) ^
      isList.hashCode ^
      stableHash(defaultValue ?? '');

  /// Create json representation of [RpcFieldConfig]
  Map<String, dynamic> toJson() => {
    'name': name,
    'parameterName': parameterName,
    'baseType': type,
    'paramType': paramType,
    'isList': isList,
    'hasDefault': defaultValue != null,
    'defaultValue': defaultValue,
  };

  /// String representation of [RpcFieldConfig]
  @override
  String toString() =>
      'RpcFieldConfig('
      'name: $name, '
      'type: $type, '
      'isList: $isList, '
      'defaultValue: $defaultValue'
      ')';
}
