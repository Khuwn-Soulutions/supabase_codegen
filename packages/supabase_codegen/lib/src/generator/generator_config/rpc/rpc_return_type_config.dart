import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:supabase_codegen/supabase_codegen_generator.dart';

/// {@template rpc_return_config}
/// Rpc Return Configuration
/// {@endtemplate}

@immutable
class RpcReturnTypeConfig {
  /// {@macro rpc_return_config}
  const RpcReturnTypeConfig({required this.type, required this.fields});

  /// Create [RpcReturnTypeConfig] from [json]
  factory RpcReturnTypeConfig.fromJson(Map<String, dynamic> json) =>
      RpcReturnTypeConfig(
        type: RpcReturnType.values.byName(json['type'] as String),
        fields: (json['fields'] as List<dynamic>? ?? [])
            .map((e) => RpcArgumentConfig.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// Create an empty [RpcReturnTypeConfig]
  factory RpcReturnTypeConfig.empty() =>
      const RpcReturnTypeConfig(type: RpcReturnType.scalar, fields: []);

  /// Type
  final RpcReturnType type;

  /// Fields to generate return type
  final List<RpcArgumentConfig> fields;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other is RpcReturnTypeConfig &&
        other.type == type &&
        listEquals(other.fields, fields);
  }

  /// Create json representation of [RpcReturnTypeConfig]
  Map<String, dynamic> toJson() => {
    'type': type.name,
    'returnsTable': type == RpcReturnType.table,
    'returnsSetOf': type == RpcReturnType.setOf,
    'returnsScalar': type == RpcReturnType.scalar,
    'fields': fields.map((x) => x.toJson()).toList(),
  };

  /// Copy [RpcReturnTypeConfig] with new values
  RpcReturnTypeConfig copyWith({
    RpcReturnType? type,
    List<RpcArgumentConfig>? fields,
  }) {
    return RpcReturnTypeConfig(
      type: type ?? this.type,
      fields: fields ?? this.fields,
    );
  }

  @override
  int get hashCode =>
      stableHash(type.name) ^ const DeepCollectionEquality().hash(fields);

  @override
  String toString() =>
      'RpcReturnTypeConfig(type: ${type.name}, fields: $fields)';
}
