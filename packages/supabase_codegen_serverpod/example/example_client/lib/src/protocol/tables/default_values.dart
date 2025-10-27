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
import 'package:serverpod_client/serverpod_client.dart' as _i1;

abstract class DefaultValue implements _i1.SerializableModel {
  DefaultValue._({
    this.id,
    DateTime? defaultDateTime,
    bool? defaultBool,
    double? defaultDouble,
    int? defaultInt,
    String? defaultString,
  })  : defaultDateTime = defaultDateTime ?? DateTime.now(),
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
  }) = _DefaultValueImpl;

  factory DefaultValue.fromJson(Map<String, dynamic> jsonSerialization) {
    return DefaultValue(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      defaultDateTime: jsonSerialization['default_date_time'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['default_date_time']),
      defaultBool: jsonSerialization['default_bool'] as bool?,
      defaultDouble: (jsonSerialization['default_double'] as num?)?.toDouble(),
      defaultInt: jsonSerialization['default_int'] as int?,
      defaultString: jsonSerialization['default_string'] as String?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _i1.UuidValue? id;

  DateTime? defaultDateTime;

  bool? defaultBool;

  double? defaultDouble;

  int? defaultInt;

  String? defaultString;

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
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id?.toJson(),
      if (defaultDateTime != null)
        'default_date_time': defaultDateTime?.toJson(),
      if (defaultBool != null) 'default_bool': defaultBool,
      if (defaultDouble != null) 'default_double': defaultDouble,
      if (defaultInt != null) 'default_int': defaultInt,
      if (defaultString != null) 'default_string': defaultString,
    };
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
  }) : super._(
          id: id,
          defaultDateTime: defaultDateTime,
          defaultBool: defaultBool,
          defaultDouble: defaultDouble,
          defaultInt: defaultInt,
          defaultString: defaultString,
        );

  /// Returns a shallow copy of this [DefaultValue]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DefaultValue copyWith({
    Object? id = _Undefined,
    Object? defaultDateTime = _Undefined,
    Object? defaultBool = _Undefined,
    Object? defaultDouble = _Undefined,
    Object? defaultInt = _Undefined,
    Object? defaultString = _Undefined,
  }) {
    return DefaultValue(
      id: id is _i1.UuidValue? ? id : this.id,
      defaultDateTime:
          defaultDateTime is DateTime? ? defaultDateTime : this.defaultDateTime,
      defaultBool: defaultBool is bool? ? defaultBool : this.defaultBool,
      defaultDouble:
          defaultDouble is double? ? defaultDouble : this.defaultDouble,
      defaultInt: defaultInt is int? ? defaultInt : this.defaultInt,
      defaultString:
          defaultString is String? ? defaultString : this.defaultString,
    );
  }
}
