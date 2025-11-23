/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;
import 'package:supabase_codegen_serverpod/json_class.dart' as _i2;

abstract class DefaultValue
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  DefaultValue._({
    this.id,
    DateTime? defaultDateTime,
    bool? defaultBool,
    double? defaultDouble,
    int? defaultInt,
    String? defaultString,
    this.defaultJson,
  }) : defaultDateTime = defaultDateTime ?? DateTime.now(),
       defaultBool = defaultBool ?? true,
       defaultDouble = defaultDouble ?? 10.5,
       defaultInt = defaultInt ?? 10,
       defaultString = defaultString ?? 'This is a string';

  factory DefaultValue({
    _i1.UuidValue? id,
    DateTime? defaultDateTime,
    bool? defaultBool,
    double? defaultDouble,
    int? defaultInt,
    String? defaultString,
    _i2.JsonClass? defaultJson,
  }) = _DefaultValueImpl;

  factory DefaultValue.fromJson(Map<String, dynamic> jsonSerialization) {
    return DefaultValue(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      defaultDateTime: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['defaultDateTime'],
      ),
      defaultBool: jsonSerialization['defaultBool'] as bool?,
      defaultDouble: (jsonSerialization['defaultDouble'] as num?)?.toDouble(),
      defaultInt: jsonSerialization['defaultInt'] as int?,
      defaultString: jsonSerialization['defaultString'] as String?,
      defaultJson: jsonSerialization['defaultJson'] == null
          ? null
          : _i2.JsonClass.fromJson(jsonSerialization['defaultJson']),
    );
  }

  static final t = DefaultValueTable();

  static const db = DefaultValueRepository._();

  @override
  _i1.UuidValue? id;

  DateTime defaultDateTime;

  bool? defaultBool;

  double? defaultDouble;

  int? defaultInt;

  String? defaultString;

  _i2.JsonClass? defaultJson;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [DefaultValue]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DefaultValue copyWith({
    _i1.UuidValue? id,
    DateTime? defaultDateTime,
    bool? defaultBool,
    double? defaultDouble,
    int? defaultInt,
    String? defaultString,
    _i2.JsonClass? defaultJson,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DefaultValue',
      if (id != null) 'id': id?.toJson(),
      'defaultDateTime': defaultDateTime.toJson(),
      if (defaultBool != null) 'defaultBool': defaultBool,
      if (defaultDouble != null) 'defaultDouble': defaultDouble,
      if (defaultInt != null) 'defaultInt': defaultInt,
      if (defaultString != null) 'defaultString': defaultString,
      if (defaultJson != null) 'defaultJson': defaultJson?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DefaultValue',
      if (id != null) 'id': id?.toJson(),
      'defaultDateTime': defaultDateTime.toJson(),
      if (defaultBool != null) 'defaultBool': defaultBool,
      if (defaultDouble != null) 'defaultDouble': defaultDouble,
      if (defaultInt != null) 'defaultInt': defaultInt,
      if (defaultString != null) 'defaultString': defaultString,
      if (defaultJson != null)
        'defaultJson':
            // ignore: unnecessary_type_check
            defaultJson is _i1.ProtocolSerialization
            ? (defaultJson as _i1.ProtocolSerialization).toJsonForProtocol()
            : defaultJson?.toJson(),
    };
  }

  static DefaultValueInclude include() {
    return DefaultValueInclude._();
  }

  static DefaultValueIncludeList includeList({
    _i1.WhereExpressionBuilder<DefaultValueTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<DefaultValueTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<DefaultValueTable>? orderByList,
    DefaultValueInclude? include,
  }) {
    return DefaultValueIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DefaultValue.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(DefaultValue.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DefaultValueImpl extends DefaultValue {
  _DefaultValueImpl({
    _i1.UuidValue? id,
    DateTime? defaultDateTime,
    bool? defaultBool,
    double? defaultDouble,
    int? defaultInt,
    String? defaultString,
    _i2.JsonClass? defaultJson,
  }) : super._(
         id: id,
         defaultDateTime: defaultDateTime,
         defaultBool: defaultBool,
         defaultDouble: defaultDouble,
         defaultInt: defaultInt,
         defaultString: defaultString,
         defaultJson: defaultJson,
       );

  /// Returns a shallow copy of this [DefaultValue]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DefaultValue copyWith({
    Object? id = _Undefined,
    DateTime? defaultDateTime,
    Object? defaultBool = _Undefined,
    Object? defaultDouble = _Undefined,
    Object? defaultInt = _Undefined,
    Object? defaultString = _Undefined,
    Object? defaultJson = _Undefined,
  }) {
    return DefaultValue(
      id: id is _i1.UuidValue? ? id : this.id,
      defaultDateTime: defaultDateTime ?? this.defaultDateTime,
      defaultBool: defaultBool is bool? ? defaultBool : this.defaultBool,
      defaultDouble: defaultDouble is double?
          ? defaultDouble
          : this.defaultDouble,
      defaultInt: defaultInt is int? ? defaultInt : this.defaultInt,
      defaultString: defaultString is String?
          ? defaultString
          : this.defaultString,
      defaultJson: defaultJson is _i2.JsonClass?
          ? defaultJson
          : this.defaultJson?.copyWith(),
    );
  }
}

class DefaultValueUpdateTable extends _i1.UpdateTable<DefaultValueTable> {
  DefaultValueUpdateTable(super.table);

  _i1.ColumnValue<DateTime, DateTime> defaultDateTime(DateTime value) =>
      _i1.ColumnValue(
        table.defaultDateTime,
        value,
      );

  _i1.ColumnValue<bool, bool> defaultBool(bool? value) => _i1.ColumnValue(
    table.defaultBool,
    value,
  );

  _i1.ColumnValue<double, double> defaultDouble(double? value) =>
      _i1.ColumnValue(
        table.defaultDouble,
        value,
      );

  _i1.ColumnValue<int, int> defaultInt(int? value) => _i1.ColumnValue(
    table.defaultInt,
    value,
  );

  _i1.ColumnValue<String, String> defaultString(String? value) =>
      _i1.ColumnValue(
        table.defaultString,
        value,
      );

  _i1.ColumnValue<_i2.JsonClass, _i2.JsonClass> defaultJson(
    _i2.JsonClass? value,
  ) => _i1.ColumnValue(
    table.defaultJson,
    value,
  );
}

class DefaultValueTable extends _i1.Table<_i1.UuidValue?> {
  DefaultValueTable({super.tableRelation})
    : super(tableName: 'default_values') {
    updateTable = DefaultValueUpdateTable(this);
    defaultDateTime = _i1.ColumnDateTime(
      'default_date_time',
      this,
      hasDefault: true,
      fieldName: 'defaultDateTime',
    );
    defaultBool = _i1.ColumnBool(
      'default_bool',
      this,
      hasDefault: true,
      fieldName: 'defaultBool',
    );
    defaultDouble = _i1.ColumnDouble(
      'default_double',
      this,
      hasDefault: true,
      fieldName: 'defaultDouble',
    );
    defaultInt = _i1.ColumnInt(
      'default_int',
      this,
      hasDefault: true,
      fieldName: 'defaultInt',
    );
    defaultString = _i1.ColumnString(
      'default_string',
      this,
      hasDefault: true,
      fieldName: 'defaultString',
    );
    defaultJson = _i1.ColumnSerializable<_i2.JsonClass>(
      'default_json',
      this,
      fieldName: 'defaultJson',
    );
  }

  late final DefaultValueUpdateTable updateTable;

  late final _i1.ColumnDateTime defaultDateTime;

  late final _i1.ColumnBool defaultBool;

  late final _i1.ColumnDouble defaultDouble;

  late final _i1.ColumnInt defaultInt;

  late final _i1.ColumnString defaultString;

  late final _i1.ColumnSerializable<_i2.JsonClass> defaultJson;

  @override
  List<_i1.Column> get columns => [
    id,
    defaultDateTime,
    defaultBool,
    defaultDouble,
    defaultInt,
    defaultString,
    defaultJson,
  ];
}

class DefaultValueInclude extends _i1.IncludeObject {
  DefaultValueInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => DefaultValue.t;
}

class DefaultValueIncludeList extends _i1.IncludeList {
  DefaultValueIncludeList._({
    _i1.WhereExpressionBuilder<DefaultValueTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(DefaultValue.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => DefaultValue.t;
}

class DefaultValueRepository {
  const DefaultValueRepository._();

  /// Returns a list of [DefaultValue]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<DefaultValue>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<DefaultValueTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<DefaultValueTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<DefaultValueTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<DefaultValue>(
      where: where?.call(DefaultValue.t),
      orderBy: orderBy?.call(DefaultValue.t),
      orderByList: orderByList?.call(DefaultValue.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [DefaultValue] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<DefaultValue?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<DefaultValueTable>? where,
    int? offset,
    _i1.OrderByBuilder<DefaultValueTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<DefaultValueTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<DefaultValue>(
      where: where?.call(DefaultValue.t),
      orderBy: orderBy?.call(DefaultValue.t),
      orderByList: orderByList?.call(DefaultValue.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [DefaultValue] by its [id] or null if no such row exists.
  Future<DefaultValue?> findById(
    _i1.Session session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<DefaultValue>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [DefaultValue]s in the list and returns the inserted rows.
  ///
  /// The returned [DefaultValue]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<DefaultValue>> insert(
    _i1.Session session,
    List<DefaultValue> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<DefaultValue>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [DefaultValue] and returns the inserted row.
  ///
  /// The returned [DefaultValue] will have its `id` field set.
  Future<DefaultValue> insertRow(
    _i1.Session session,
    DefaultValue row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<DefaultValue>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [DefaultValue]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<DefaultValue>> update(
    _i1.Session session,
    List<DefaultValue> rows, {
    _i1.ColumnSelections<DefaultValueTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<DefaultValue>(
      rows,
      columns: columns?.call(DefaultValue.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DefaultValue]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<DefaultValue> updateRow(
    _i1.Session session,
    DefaultValue row, {
    _i1.ColumnSelections<DefaultValueTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<DefaultValue>(
      row,
      columns: columns?.call(DefaultValue.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DefaultValue] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<DefaultValue?> updateById(
    _i1.Session session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<DefaultValueUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<DefaultValue>(
      id,
      columnValues: columnValues(DefaultValue.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [DefaultValue]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<DefaultValue>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<DefaultValueUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<DefaultValueTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<DefaultValueTable>? orderBy,
    _i1.OrderByListBuilder<DefaultValueTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<DefaultValue>(
      columnValues: columnValues(DefaultValue.t.updateTable),
      where: where(DefaultValue.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DefaultValue.t),
      orderByList: orderByList?.call(DefaultValue.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [DefaultValue]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<DefaultValue>> delete(
    _i1.Session session,
    List<DefaultValue> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<DefaultValue>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [DefaultValue].
  Future<DefaultValue> deleteRow(
    _i1.Session session,
    DefaultValue row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<DefaultValue>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<DefaultValue>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<DefaultValueTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<DefaultValue>(
      where: where(DefaultValue.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<DefaultValueTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<DefaultValue>(
      where: where?.call(DefaultValue.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
