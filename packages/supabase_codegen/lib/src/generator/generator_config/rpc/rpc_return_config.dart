import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:supabase_codegen/supabase_codegen_generator.dart';

/// {@template rpc_return_config}
/// Rpc Return Configuration
/// {@endtemplate}
@immutable
class RpcReturnTypeConfig {
  /// {@macro rpc_return_config}
  const RpcReturnTypeConfig({required this.returnType, required this.fields});

  /// Create [RpcReturnTypeConfig] from [json]
  factory RpcReturnTypeConfig.fromJson(Map<String, dynamic> json) =>
      RpcReturnTypeConfig(
        returnType: RpcReturnType.values.byName(json['returnType'] as String),
        fields: (json['fields'] as List<dynamic>? ?? [])
            .map((e) => RpcArgumentConfig.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// Create an empty [RpcReturnTypeConfig]
  factory RpcReturnTypeConfig.empty() =>
      const RpcReturnTypeConfig(returnType: RpcReturnType.scalar, fields: []);

  /// Return type
  final RpcReturnType returnType;

  /// Fields to generate return type
  final List<RpcArgumentConfig> fields;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other is RpcReturnTypeConfig &&
        other.returnType == returnType &&
        listEquals(other.fields, fields);
  }

  /// Create json representation of [RpcReturnTypeConfig]
  Map<String, dynamic> toJson() => {
    'returnType': returnType.name,
    'returnsTable': returnType == RpcReturnType.table,
    'returnsSetOf': returnType == RpcReturnType.setOf,
    'returnsScalar': returnType == RpcReturnType.scalar,
    'fields': fields.map((x) => x.toJson()).toList(),
  };

  /// Copy [RpcReturnTypeConfig] with new values
  RpcReturnTypeConfig copyWith({
    RpcReturnType? returnType,
    List<RpcArgumentConfig>? fields,
  }) {
    return RpcReturnTypeConfig(
      returnType: returnType ?? this.returnType,
      fields: fields ?? this.fields,
    );
  }

  @override
  int get hashCode =>
      returnType.hashCode ^ const DeepCollectionEquality().hash(fields);

  @override
  String toString() =>
      'RpcReturnTypeConfig(returnType: ${returnType.name}, fields: $fields)';
}
