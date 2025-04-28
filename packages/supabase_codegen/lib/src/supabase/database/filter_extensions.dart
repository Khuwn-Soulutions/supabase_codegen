import 'package:supabase/supabase.dart';

/// Applies a filter if the [value] is not `null`.
/// Otherwise, returns the builder unchanged.
///
/// - Parameters:
///   - [column]: The column to filter on.
///   - [value]: The value to compare against.
///   - [filterFn]: The filter function to apply (e.g., `eq`, `neq`).
T? _applyFilterOrNull<T>({
  required String column,
  required Object? value,
  required T Function(String, Object) filterFn,
}) {
  return (value != null ? filterFn(column, value) : null);
}

/// Extension to add null-safe filtering methods to [PostgrestFilterBuilder<T>].
extension NullSafePostgrestFilters<T> on PostgrestFilterBuilder<T> {
  /// Applies an equality filter (`eq`) if [value] is not `null`.
  PostgrestFilterBuilder<T> eqOrNull(String column, Object? value) =>
      _applyFilterOrNull(column: column, value: value, filterFn: eq) ?? this;

  /// Applies a not-equal filter (`neq`) if [value] is not `null`.
  PostgrestFilterBuilder<T> neqOrNull(String column, Object? value) =>
      _applyFilterOrNull(column: column, value: value, filterFn: neq) ?? this;

  /// Applies a less-than filter (`lt`) if [value] is not `null`.
  PostgrestFilterBuilder<T> ltOrNull(String column, Object? value) =>
      _applyFilterOrNull(column: column, value: value, filterFn: lt) ?? this;

  /// Applies a less-than-or-equal filter (`lte`) if [value] is not `null`.
  PostgrestFilterBuilder<T> lteOrNull(String column, Object? value) =>
      _applyFilterOrNull(column: column, value: value, filterFn: lte) ?? this;

  /// Applies a greater-than filter (`gt`) if [value] is not `null`.
  PostgrestFilterBuilder<T> gtOrNull(String column, Object? value) =>
      _applyFilterOrNull(column: column, value: value, filterFn: gt) ?? this;

  /// Applies a greater-than-or-equal filter (`gte`) if [value] is not `null`.
  PostgrestFilterBuilder<T> gteOrNull(String column, Object? value) =>
      _applyFilterOrNull(column: column, value: value, filterFn: gte) ?? this;

  /// Applies a contains filter (`contains`) if [value] is not `null`.
  PostgrestFilterBuilder<T> containsOrNull(String column, Object? value) =>
      _applyFilterOrNull(column: column, value: value, filterFn: contains) ??
      this;

  /// Applies an overlaps filter (`overlaps`) if [value] is not `null`.
  PostgrestFilterBuilder<T> overlapsOrNull(String column, Object? value) =>
      _applyFilterOrNull(column: column, value: value, filterFn: overlaps) ??
      this;

  /// Applies an `in` filter (`inFilter`) if [values] is not `null`.
  PostgrestFilterBuilder<T> inFilterOrNull(
    String column,
    List<dynamic>? values,
  ) {
    return values != null ? inFilter(column, values) : this;
  }
}

/// Extension to add null-safe filtering methods to
/// [SupabaseStreamFilterBuilder].
extension NullSafeSupabaseStreamFilters on SupabaseStreamFilterBuilder {
  /// Applies an equality filter (`eq`) if [value] is not `null`.
  SupabaseStreamBuilder eqOrNull(String column, Object? value) =>
      _applyFilterOrNull(column: column, value: value, filterFn: eq) ?? this;

  /// Applies a not-equal filter (`neq`) if [value] is not `null`.
  SupabaseStreamBuilder neqOrNull(String column, Object? value) =>
      _applyFilterOrNull(column: column, value: value, filterFn: neq) ?? this;

  /// Applies a less-than filter (`lt`) if [value] is not `null`.
  SupabaseStreamBuilder ltOrNull(String column, Object? value) =>
      _applyFilterOrNull(column: column, value: value, filterFn: lt) ?? this;

  /// Applies a less-than-or-equal filter (`lte`) if [value] is not `null`.
  SupabaseStreamBuilder lteOrNull(String column, Object? value) =>
      _applyFilterOrNull(column: column, value: value, filterFn: lte) ?? this;

  /// Applies a greater-than filter (`gt`) if [value] is not `null`.
  SupabaseStreamBuilder gtOrNull(String column, Object? value) =>
      _applyFilterOrNull(column: column, value: value, filterFn: gt) ?? this;

  /// Applies a greater-than-or-equal filter (`gte`) if [value] is not `null`.
  SupabaseStreamBuilder gteOrNull(String column, Object? value) =>
      _applyFilterOrNull(column: column, value: value, filterFn: gte) ?? this;

  /// Applies an `in` filter (`inFilter`) if [values] is not `null`.
  SupabaseStreamBuilder inFilterOrNull(String column, List<Object>? values) {
    return values != null ? inFilter(column, values) : this;
  }
}
