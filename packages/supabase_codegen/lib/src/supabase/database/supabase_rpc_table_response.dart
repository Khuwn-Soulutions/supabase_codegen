import 'package:meta/meta.dart';

/// {@template rpc_table_response}
/// Base class representing an RPC table response.
/// {@endtemplate}
@immutable
abstract class RpcTableResponse {
  /// {@macro rpc_table_response}
  const RpcTableResponse(this._json);

  /// The raw JSON data
  final Map<String, dynamic> _json;

  /// Raw access (advanced users)
  Map<String, dynamic> get raw => _json;

  /// Check if a field is null
  bool isNull(String field) =>
      !_json.containsKey(field) || _json[field] == null;
}
