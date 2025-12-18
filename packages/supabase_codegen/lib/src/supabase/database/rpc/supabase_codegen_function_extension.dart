import 'package:supabase/supabase.dart';

/// A wrapper class that provides access to generated Supabase RPC
/// (Remote Procedure Call) functions.
///
/// This class serves as a namespace container for codegen-generated
/// RPC function extensions,
/// preventing naming conflicts with other SupabaseClient methods and allowing
/// for organized access to database stored procedures.
///
/// The class is lazily initialized per SupabaseClient instance and
/// holds a reference
/// to the client's rpc method for executing remote procedure calls.
///
/// Example:
/// ```dart
/// final client = SupabaseClient(url, key);
/// final result = await client.fn.someGeneratedRpcMethod();
/// ```
class SupabaseCodegenFunctions {
  /// Creates a [SupabaseCodegenFunctions] instance with the given [rpc] method.
  ///
  /// The [rpc] parameter is typically the `rpc` method from a [SupabaseClient]
  /// instance, which is used to execute remote procedure calls against the
  /// Supabase database.
  ///
  /// This constructor is typically not called directly by users, but rather
  /// through the [SupabaseClient] instance's `fn` getter.
  const SupabaseCodegenFunctions(this.rpc);

  /// The underlying RPC method used to call stored procedures in the database.
  ///
  /// This method signature matches the `rpc` method from [SupabaseClient] and
  /// allows calling database functions with optional parameters.
  final PostgrestFilterBuilder<T> Function<T>(
    String fn, {
    Map<String, dynamic>? params,
    bool get,
  })
  rpc;
}

/// Internal storage mechanism for maintaining a single
/// [SupabaseCodegenFunctions] instance per [SupabaseClient].
///
/// This [Expando] ensures that each client gets its own lazily-initialized
/// [SupabaseCodegenFunctions] instance without using global state or requiring
/// manual cleanup.
final _functionsExpando = Expando<SupabaseCodegenFunctions>();

/// Extension on [SupabaseClient] that provides access to
/// generated RPC functions.
///
/// This extension adds a [functions] getter to all [SupabaseClient] instances,
/// which serves as an access point for codegen-generated RPC function methods.
///
/// The extension uses lazy initialization to create a single
/// [SupabaseCodegenFunctions] instance per client,
/// ensuring efficient resource usage and preventing
/// namespace collisions with generated database table methods.
///
/// Example:
/// ```dart
/// final client = SupabaseClient(url, key);
///
/// // Access generated RPC functions through functions
/// final users = await client.fn.getActiveUsers();
/// final stats = await client.fn.calculateStatistics(year: 2024);
/// ```
extension SupabaseCodegenFunctionsExtension on SupabaseClient {
  /// Gets the [SupabaseCodegenFunctions] instance for this client.
  ///
  /// This getter provides lazy initialization -
  /// the [SupabaseCodegenFunctions] is only created on first access and then
  /// cached for subsequent calls.
  ///
  /// The returned instance contains the client's `rpc` method and serves as
  /// a namespace for all generated RPC function extensions, preventing naming
  /// conflicts with other SupabaseClient methods.
  ///
  /// Returns a [SupabaseCodegenFunctions] instance that can be used to call
  /// generated RPC methods.
  ///
  /// Example:
  /// ```dart
  /// final client = SupabaseClient(url, key);
  ///
  /// // Use the functions getter to call generated methods
  /// await client.fn.someGeneratedMethod();
  /// ```
  SupabaseCodegenFunctions get fn {
    return _functionsExpando[this] ??= SupabaseCodegenFunctions(rpc);
  }
}
