/// Remote procedure call return type
enum RpcReturnType {
  /// Table return type
  table(pattern: r'TABLE\((.*)\)'),

  /// Set of known tables within database
  setOf(pattern: 'SETOF (.*)'),

  /// Scalar return type
  scalar(pattern: '(.*)');

  const RpcReturnType({required this.pattern});

  /// Keyword in string representation to identify the type
  final String pattern;

  /// Get the return type from the provided [value]
  static ({RpcReturnType returnType, String content}) parse(String value) {
    for (final type in RpcReturnType.values) {
      // The scalar type should always be checked last, as its pattern (.*)
      // matches everything.
      // We explicitly skip it here and handle it as a fallback.
      if (type == RpcReturnType.scalar) continue;

      final matches = RegExp('^${type.pattern}\$').allMatches(value);
      if (matches.isEmpty) continue;

      final content = matches.first.group(1) ?? '';
      return (returnType: type, content: content);
    }
    // If no specific type matches, it's considered a scalar.
    // The content for scalar is the entire value itself.
    return (returnType: RpcReturnType.scalar, content: value);
  }
}
