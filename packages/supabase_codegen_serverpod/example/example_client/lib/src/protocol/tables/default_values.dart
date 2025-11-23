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
import 'package:supabase_codegen_serverpod/json_class.dart' as _i2;

abstract class DefaultValue implements _i1.SerializableModel {
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

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _i1.UuidValue? id;

  DateTime defaultDateTime;

  bool? defaultBool;

  double? defaultDouble;

  int? defaultInt;

  String? defaultString;

  _i2.JsonClass? defaultJson;

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
