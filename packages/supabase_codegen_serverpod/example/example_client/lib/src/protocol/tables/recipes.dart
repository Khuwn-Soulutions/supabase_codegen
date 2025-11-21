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

abstract class Recipe implements _i1.SerializableModel {
  Recipe._({
    this.id,
    required this.author,
    required this.text,
    required this.ingredients,
    DateTime? createdAt,
    this.metadata,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Recipe({
    int? id,
    required String author,
    required String text,
    required String ingredients,
    DateTime? createdAt,
    _i2.JsonClass? metadata,
  }) = _RecipeImpl;

  factory Recipe.fromJson(Map<String, dynamic> jsonSerialization) {
    return Recipe(
      id: jsonSerialization['id'] as int?,
      author: jsonSerialization['author'] as String,
      text: jsonSerialization['text'] as String,
      ingredients: jsonSerialization['ingredients'] as String,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      metadata: jsonSerialization['metadata'] == null
          ? null
          : _i2.JsonClass.fromJson(jsonSerialization['metadata']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String author;

  String text;

  String ingredients;

  DateTime createdAt;

  _i2.JsonClass? metadata;

  /// Returns a shallow copy of this [Recipe]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Recipe copyWith({
    int? id,
    String? author,
    String? text,
    String? ingredients,
    DateTime? createdAt,
    _i2.JsonClass? metadata,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Recipe',
      if (id != null) 'id': id,
      'author': author,
      'text': text,
      'ingredients': ingredients,
      'createdAt': createdAt.toJson(),
      if (metadata != null) 'metadata': metadata?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RecipeImpl extends Recipe {
  _RecipeImpl({
    int? id,
    required String author,
    required String text,
    required String ingredients,
    DateTime? createdAt,
    _i2.JsonClass? metadata,
  }) : super._(
         id: id,
         author: author,
         text: text,
         ingredients: ingredients,
         createdAt: createdAt,
         metadata: metadata,
       );

  /// Returns a shallow copy of this [Recipe]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Recipe copyWith({
    Object? id = _Undefined,
    String? author,
    String? text,
    String? ingredients,
    DateTime? createdAt,
    Object? metadata = _Undefined,
  }) {
    return Recipe(
      id: id is int? ? id : this.id,
      author: author ?? this.author,
      text: text ?? this.text,
      ingredients: ingredients ?? this.ingredients,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata is _i2.JsonClass?
          ? metadata
          : this.metadata?.copyWith(),
    );
  }
}
