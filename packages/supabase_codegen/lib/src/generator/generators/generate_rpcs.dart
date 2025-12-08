import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:supabase_codegen/supabase_codegen_generator.dart';

/// Generate [RpcConfig] list
Future<List<RpcConfig>> generateRpcConfigs({
  List<TableConfig> tables = const [],
}) async {
  final rpcs = await fetchRpcFunctions();
  return rpcs.map((rpc) {
    final args = parseArguments(rpc.arguments);
    final returnType = parseReturnType(rpc.returnType, tables: tables);

    return RpcConfig(
      functionName: rpc.functionName,
      args: args,
      returnType: returnType,
    );
  }).toList();
}

/// Fetch RPC functions from the database
Future<List<GetRpcFunctionsResponse>> fetchRpcFunctions() async {
  final progress = logger.progress('Fetching RPC functions from database...');
  try {
    const includeInternals = bool.fromEnvironment('INCLUDE_INTERNAL_RPCS');
    final response = await client.getRpcFunctions(
      // Value may be true or false, but analyzer interprets as false
      // due to default value from bool.fromEnvironment
      // ignore: avoid_redundant_argument_values
      includeInternals: includeInternals,
    );
    progress.complete('Database RPC functions fetched');
    return response;
  }
  // coverage:ignore-start
  on Exception catch (e) {
    progress.fail('Failed to fetch RPC functions from database');
    logger.err('Error retrieving RPC functions: $e');
    rethrow;
  }
  // coverage:ignore-end
}

/// Parse the [arguments] for an [RpcConfig]
@visibleForTesting
List<RpcArgumentConfig> parseArguments(String arguments) {
  if (arguments.isEmpty) return [];

  final argsList = arguments.split(', ');
  return argsList.map(RpcArgumentConfig.fromArgString).toList();
}

/// Parse the return type for an [RpcConfig]
@visibleForTesting
RpcReturnTypeConfig parseReturnType(
  String returnTypeRaw, {
  List<TableConfig> tables = const [],
}) {
  final (:returnType, :content) = RpcReturnType.parse(returnTypeRaw);
  final fields = <RpcArgumentConfig>[];
  switch (returnType) {
    case RpcReturnType.table:
      fields.addAll(parseArguments(content));

    case RpcReturnType.setOf:
      final table = tables.firstWhereOrNull((table) => table.name == content);
      // No table found, set to dynamic
      if (table == null) {
        logger.warn('Table $content not found, setting to dynamic');
        fields.add(
          RpcArgumentConfig(name: content, type: 'dynamic', isList: true),
        );
      }
      // Table found, set to table class name
      else {
        fields.add(
          RpcArgumentConfig(
            name: table.name,
            type: table.className,
            isList: true,
          ),
        );
      }

    case RpcReturnType.scalar:
      fields.add(RpcArgumentConfig.fromNameAndRawType(rawType: content));
  }

  return RpcReturnTypeConfig(type: returnType, fields: fields);
}
