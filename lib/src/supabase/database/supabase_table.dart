import 'package:logger/logger.dart';
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
    required PostgrestTransformBuilder<DictionaryList> Function(
      PostgrestFilterBuilder<DictionaryList>,
    ) queryFn,
    int? limit,
  }) {
    final select = _select();
    var query = queryFn(select);
    query = limit != null ? query.limit(limit) : query;
    return query.select().then(_rowsAsList);
  }

  /// Query a single row using the [queryFn] provided
  Future<T?> querySingleRow({
    required PostgrestTransformBuilder<DictionaryList> Function(
      PostgrestFilterBuilder<DictionaryList>,
    ) queryFn,
  }) =>
      queryFn(_select())
          .limit(1)
          .select()
          .maybeSingle()
          .catchError((dynamic e) {
        Logger().e('Error querying row: $e'); // coverage:ignore-line
        return null;
      }).then((r) => r != null ? createRow(r) : null);

  /// Insert a row into the table
  Future<T> insertRow(T row) => insert(row.data);

  /// Insert the [data] into the table and return
  /// the [SupabaseDataRow] representation of that row
  Future<T> insert(Map<String, dynamic> data) async {
    final row = await dbTable.insert(data).select().limit(1);
    return createRow(row.first);
  }

  /// Upsert a row into the table
  Future<T> upsertRow(
    T row, {
    String? onConflict,
    bool ignoreDuplicates = false,
    bool defaultToNull = true,
  }) =>
      upsert(
        row.data,
        onConflict: onConflict,
        ignoreDuplicates: ignoreDuplicates,
        defaultToNull: defaultToNull,
      );

  /// Upsert the [data] in the table and return
  /// the [SupabaseDataRow] representation of that row.
  ///
  /// By specifying the [onConflict] parameter, you can make UPSERT work on
  /// a column(s) that has a UNIQUE constraint.
  /// [ignoreDuplicates] Specifies if duplicate rows should be ignored
  /// and not inserted.
  ///
  /// When inserting multiple rows in bulk, [defaultToNull] is used to
  /// set the values of fields missing in a proper subset of rows to be
  /// either NULL or the default value of these columns.
  /// Fields missing in all rows always use the default value of these columns.
  ///
  /// For single row insertions, missing fields will be set to default
  /// values when applicable.
  Future<T> upsert(
    Map<String, dynamic> data, {
    String? onConflict,
    bool ignoreDuplicates = false,
    bool defaultToNull = true,
  }) async {
    final row = await dbTable
        .upsert(
          data,
          onConflict: onConflict,
          ignoreDuplicates: ignoreDuplicates,
          defaultToNull: defaultToNull,
        )
        .select()
        .limit(1);
    return createRow(row.first);
  }

  /// Update the rows that fulfill [matchingRows] with the
  /// [data] or [row] provided.
  ///
  /// Notes:
  /// - if both [data] or [row] is provided [data] will take precedence.
  /// - If [returnRows] is true, then the updated rows will be converted to
  /// their [SupabaseDataRow] representation and returned as a List
  Future<List<T>> update({
    required PostgrestTransformBuilder<dynamic> Function(
      PostgrestFilterBuilder<dynamic>,
    ) matchingRows,
    Map<String, dynamic>? data,
    T? row,
    bool returnRows = false,
  }) async {
    /// Use row data
    data ??= row?.data;

    /// Stop if no data present
    if (data == null) {
      throw AssertionError('data or row must be provided for update');
    }

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
    required PostgrestTransformBuilder<dynamic> Function(
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
