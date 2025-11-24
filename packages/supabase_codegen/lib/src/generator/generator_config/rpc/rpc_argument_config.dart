import 'package:change_case/change_case.dart';
import 'package:meta/meta.dart';
import 'package:supabase_codegen/src/generator/generate_types/get_types.dart';

/// {@template rpc_argument_config}
/// RPC Argument Config
/// {@endtemplate}
@immutable
class RpcArgumentConfig {
  /// {@macro rpc_argument_config}
  const RpcArgumentConfig({
    required this.name,
    required this.type,
    required this.isList,
  });

  /// Create [RpcArgumentConfig] from [json]
  factory RpcArgumentConfig.fromJson(Map<String, dynamic> json) =>
      RpcArgumentConfig(
        name: json['name'] as String,
        type: json['type'] as String,
        isList: json['isList'] as bool,
      );

  /// Create [RpcArgumentConfig] from [name] and [rawType]
  factory RpcArgumentConfig.fromNameAndRawType({
    required String name,
    required String rawType,
  }) {
    const arraySuffix = '[]';
    final isList = rawType.endsWith(arraySuffix);
    final type = getBaseDartType(rawType.replaceAll(arraySuffix, ''));

    return RpcArgumentConfig(name: name, type: type, isList: isList);
  }

  /// Argument name
  final String name;

  /// Parameter name
  String get parameterName => name.toCamelCase();

  /// Argument type
  final String type;

  /// Is list
  final bool isList;

  /// Parameter type
  String get paramType => isList ? 'List<$type>' : type;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RpcArgumentConfig &&
        other.name == name &&
        other.type == type &&
        other.isList == isList;
  }

  @override
  int get hashCode => name.hashCode ^ type.hashCode ^ isList.hashCode;

  /// Create json representation of [RpcArgumentConfig]
  Map<String, dynamic> toJson() => {
    'name': name,
    'parameterName': parameterName,
    'baseType': type,
    'paramType': paramType,
    'isList': isList,
  };

  /// String representation of [RpcArgumentConfig]
  @override
  String toString() =>
      'RpcArgumentConfig(name: $name, type: $type, isList: $isList)';
}
