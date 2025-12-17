import 'package:change_case/change_case.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:supabase_codegen/supabase_codegen_generator.dart';

/// {@template rpc_config}
/// RPC configuration
/// {@endtemplate}
@immutable
class RpcConfig {
  /// {@macro rpc_config}
  const RpcConfig({
    required this.functionName,
    required this.args,
    required this.returnType,
  });

  /// Create empty [RpcConfig]
  factory RpcConfig.empty() => RpcConfig(
    functionName: '',
    args: const <RpcFieldConfig>[],
    returnType: RpcReturnTypeConfig.empty(),
  );

  /// Create [RpcConfig] from [json]
  factory RpcConfig.fromJson(Map<String, dynamic> json) => RpcConfig(
    functionName: json['functionName'] as String,
    args: (json['args'] as List<dynamic>? ?? [])
        .map((e) => RpcFieldConfig.fromJson(e as Map<String, dynamic>))
        .toList(),
    returnType: RpcReturnTypeConfig.fromJson(
      json['returnType'] as Map<String, dynamic>,
    ),
  );

  /// Function name
  final String functionName;

  /// Method name
  String get methodName => functionName.toCamelCase();

  /// Class name
  String get className => functionName.toPascalCase();

  /// Has arguments
  bool get hasArgs => args.isNotEmpty;

  /// Arguments
  final List<RpcFieldConfig> args;

  /// Return type config
  final RpcReturnTypeConfig returnType;

  /// Base Type Returned
  String get returnsBaseType => switch (returnType.type) {
    RpcReturnType.table => '${className}Response',
    RpcReturnType.setOf => returnType.fields.firstOrNull?.type ?? 'dynamic',
    RpcReturnType.scalar =>
      returnType.fields.firstOrNull?.paramType ?? 'dynamic',
  };

  /// Class name returned
  String get returnsClassName => switch (returnType.type) {
    RpcReturnType.setOf =>
      returnType.fields.firstOrNull?.type != null
          ? '${returnType.fields.first.type}Row'
          : 'dynamic',
    _ => returnsBaseType,
  };

  /// Type name returned
  String get returnsTypeName => switch (returnType.type) {
    RpcReturnType.scalar => returnsBaseType,
    _ => 'List<$returnsClassName>',
  };

  /// Returns true if the RPC returns a list of scalar values
  bool get returnsScalarList =>
      returnType.type == RpcReturnType.scalar &&
      returnType.fields.isNotEmpty &&
      returnType.fields.first.isList == true;

  /// Copy [RpcConfig] with new values
  RpcConfig copyWith({
    String? functionName,
    List<RpcFieldConfig>? args,
    RpcReturnTypeConfig? returnType,
  }) {
    return RpcConfig(
      functionName: functionName ?? this.functionName,
      args: args ?? this.args,
      returnType: returnType ?? this.returnType,
    );
  }

  /// Create json representation of [RpcConfig]
  Map<String, dynamic> toJson() => {
    'functionName': functionName,
    'methodName': methodName,
    'className': className,
    'hasArgs': hasArgs,
    'args': args.map((x) => x.toJson()).toList(),
    'returnType': returnType.toJson(),
    'returnsBaseType': returnsBaseType,
    'returnsClassName': returnsClassName,
    'returnsTypeName': returnsTypeName,
    'returnsScalarList': returnsScalarList,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RpcConfig &&
        other.functionName == functionName &&
        const DeepCollectionEquality().equals(other.args, args) &&
        other.returnType == returnType;
  }

  @override
  int get hashCode =>
      stableHash(functionName) ^
      const DeepCollectionEquality().hash(args) ^
      returnType.hashCode;

  @override
  String toString() =>
      'RpcConfig(functionName: $functionName, args: $args, '
      'returnType: $returnType)';
}
