import 'package:supabase/supabase.dart';
import 'package:supabase_codegen/supabase_codegen.dart';

/// A list of dictionaries (`Map<String, dynamic>`)
typedef DictionaryList = List<Map<String, dynamic>>;

/// Supabase table base class
abstract class SupabaseTable<T extends SupabaseDataRow> {
  /// Supabase Table
  SupabaseTable({SupabaseClient? client})
      : _client = client ?? loadSupabaseClient();

  /// Supabase Client
  final SupabaseClient _client;

  /// Table name
  String get tableName;

  /// Create a row
  T createRow(Map<String, dynamic> data);

  /// Get the database table
  SupabaseQueryBuilder get dbTable => _client.from(tableName);

  /// Cast rows as a list
  List<T> _rowsAsList(List<Map<String, dynamic>> rows) =>
      rows.map(createRow).toList();

  /// Select all fields from the table
  PostgrestFilterBuilder<DictionaryList> _select() => dbTable.select();

  /// Query rows using the [queryFn] provided, with an optional [limit]
  Future<List<T>> queryRows({
    required PostgrestTransformBuilder<T> Function(
      PostgrestFilterBuilder<dynamic>,
    ) queryFn,
    int? limit,
  }) {
    final select = _select();
    var query = queryFn(select);
    query = limit != null ? query.limit(limit) : query;
    return query.select().then(_rowsAsList);
  }

  /// Query a single row using the [queryFn] provided
  Future<List<T>> querySingleRow({
    required PostgrestTransformBuilder<T> Function(
      PostgrestFilterBuilder<DictionaryList>,
    ) queryFn,
  }) =>
      queryFn(_select())
          .limit(1)
          .select()
          .maybeSingle()
          .catchError((dynamic e) {
        // Debug Error
        // ignore: avoid_print
        print('Error querying row: $e');
        return <T>[];
      }).then((r) => [if (r != null) createRow(r)]);

  /// Insert the [data] into the table and return
  /// the [SupabaseDataRow] representation of that row
  Future<T> insert(Map<String, dynamic> data) =>
      dbTable.insert(data).select().limit(1).single().then(createRow);

  /// Update the rows that fulfill [matchingRows] with the [data] provided.
  ///
  /// If [returnRows] is true, then the updated rows will be converted to their
  /// [SupabaseDataRow] representation and returned as a List
  Future<List<T>> update({
    required Map<String, dynamic> data,
    required PostgrestTransformBuilder<T> Function(
      PostgrestFilterBuilder<dynamic>,
    ) matchingRows,
    bool returnRows = false,
  }) async {
    final update = matchingRows(dbTable.update(data));
    if (!returnRows) {
      await update;
      return [];
    }
    return update.select().then(_rowsAsList);
  }

  /// Delete the rows that fulfill [matchingRows].
  ///
  /// If [returnRows] is true, then the deleted rows will be converted to their
  /// [SupabaseDataRow] representation and returned as a List
  Future<List<T>> delete({
    required PostgrestTransformBuilder<T> Function(
      PostgrestFilterBuilder<dynamic>,
    ) matchingRows,
    bool returnRows = false,
  }) async {
    final delete = matchingRows(dbTable.delete());
    if (!returnRows) {
      await delete;
      return [];
    }
    return delete.select().then(_rowsAsList);
  }
}
