/// Extension to determine if
extension IsDynamicExtension on String {
  /// Is this a dynamic type
  bool get isDynamic => this == 'dynamic';

  /// Is this not a dynamic type
  bool get isNotDynamic => !isDynamic;
}
