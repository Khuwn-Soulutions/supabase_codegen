/// Postgres time
class PostgresTime {
  /// Postgres time
  PostgresTime(this.time);

  /// Original [DateTime]
  DateTime? time;

  /// Parse the [formattedString] as [PostgresTime]
  /// returning `null` if the [formattedString] cannot be parsed.
  static PostgresTime? tryParse(String formattedString) {
    final datePrefix = DateTime.now().toIso8601String().split('T').first;
    return PostgresTime(
      DateTime.tryParse('${datePrefix}T$formattedString')?.toLocal(),
    );
  }

  /// Get the Iso8601 string representation of the time
  String? toIso8601String() {
    return time?.toIso8601String().split('T').last;
  }

  @override
  String toString() {
    return toIso8601String() ?? '';
  }
}
