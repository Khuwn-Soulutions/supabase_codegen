/// Json object wrapper
library;

/// Class wrapping a json serializable object
class JsonClass {
  /// Constructor
  const JsonClass(this.json);

  /// Generate from a [json] map
  factory JsonClass.fromJson(Map<String, dynamic> json) => JsonClass(json);

  /// Json value
  final Map<String, dynamic> json;

  /// Json representation
  Map<String, dynamic> toJson() => json;

  /// Copy with new [json]
  JsonClass copyWith([Map<String, dynamic>? json]) =>
      JsonClass(json ?? this.json);
}
