/// Json extensions
extension JsonExtensions on Map<String, dynamic> {
  /// Returns a clean JSON where all null key value pairs have been removed
  Map<String, dynamic> get cleaned {
    final cleanedJson = <String, dynamic>{};
    forEach((key, value) {
      if (value != null) {
        cleanedJson[key] = value;
      }
    });
    return cleanedJson;
  }
}
