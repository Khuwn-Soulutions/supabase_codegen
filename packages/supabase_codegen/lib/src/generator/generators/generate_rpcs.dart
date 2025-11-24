import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:supabase_codegen/src/generator/generator.dart';

/// Generate [RpcConfig] list
Future<List<RpcConfig>> generateRpcConfigs({
  List<TableConfig> tables = const [],
}) async {
  final rpcs = await fetchRpcFunctions();
  return rpcs.map((rpc) {
    final functionName = rpc['function_name'] as String;
    final arguments = rpc['arguments'] as String;
    final returnTypeRaw = rpc['return_type'] as String;

    final args = parseArguments(arguments);
    final returnType = parseReturnType(returnTypeRaw, tables: tables);

    return RpcConfig(
      functionName: functionName,
      args: args,
      returnType: returnType,
    );
  }).toList();
}

/// Fetch RPC functions from the database
Future<List<Map<String, dynamic>>> fetchRpcFunctions() async {
  final progress = logger.progress('Fetching RPC functions from database...');
  try {
    final response = await client.rpc<List<dynamic>>('get_rpc_functions');
    progress.complete('Database RPC functions fetched');
    return List<Map<String, dynamic>>.from(response);
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
  // Basic parsing, might need more robust regex for complex types
  final argsList = arguments.split(', ');
  final args = argsList.map((arg) {
    final [name, typeRaw] = arg.split(' ');
    return RpcArgumentConfig.fromNameAndRawType(name: name, rawType: typeRaw);
  });
  return args.toList();
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
      fields.add(
        RpcArgumentConfig.fromNameAndRawType(name: content, rawType: content),
      );
  }

  return RpcReturnTypeConfig(returnType: returnType, fields: fields);
}
