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
import 'greeting.dart' as _i2;
import 'tables/default_values.dart' as _i3;
import 'tables/recipes.dart' as _i4;
import 'package:supabase_codegen_serverpod/json_class.dart' as _i5;
import 'package:example_client/src/protocol/tables/recipes.dart' as _i6;
export 'greeting.dart';
export 'tables/default_values.dart';
export 'tables/recipes.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != t.toString()) {
      return deserializeByClassName({
        'className': dataClassName,
        'data': data,
      });
    }

    if (t == _i2.Greeting) {
      return _i2.Greeting.fromJson(data) as T;
    }
    if (t == _i3.DefaultValue) {
      return _i3.DefaultValue.fromJson(data) as T;
    }
    if (t == _i4.Recipe) {
      return _i4.Recipe.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.Greeting?>()) {
      return (data != null ? _i2.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.DefaultValue?>()) {
      return (data != null ? _i3.DefaultValue.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.Recipe?>()) {
      return (data != null ? _i4.Recipe.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.JsonClass?>()) {
      return (data != null ? _i5.JsonClass.fromJson(data) : null) as T;
    }
    if (t == List<_i6.Recipe>) {
      return (data as List).map((e) => deserialize<_i6.Recipe>(e)).toList()
          as T;
    }
    if (t == _i5.JsonClass) {
      return _i5.JsonClass.fromJson(data) as T;
    }
    if (t == _i1.getType<_i5.JsonClass?>()) {
      return (data != null ? _i5.JsonClass.fromJson(data) : null) as T;
    }
    return super.deserialize<T>(data, t);
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('example.', '');
    }

    switch (data) {
      case _i5.JsonClass():
        return 'JsonClass';
      case _i2.Greeting():
        return 'Greeting';
      case _i3.DefaultValue():
        return 'DefaultValue';
      case _i4.Recipe():
        return 'Recipe';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'JsonClass') {
      return deserialize<_i5.JsonClass>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i2.Greeting>(data['data']);
    }
    if (dataClassName == 'DefaultValue') {
      return deserialize<_i3.DefaultValue>(data['data']);
    }
    if (dataClassName == 'Recipe') {
      return deserialize<_i4.Recipe>(data['data']);
    }
    return super.deserializeByClassName(data);
  }
}
