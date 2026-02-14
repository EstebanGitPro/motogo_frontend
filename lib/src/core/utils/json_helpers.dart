/// Shared JSON parsing utilities to avoid duplication across models.
///
/// These helpers centralize common JSON-to-Dart conversion patterns
/// used throughout the data layer.
class JsonHelpers {
  JsonHelpers._();

  /// Safely parses a list of strings from a JSON dynamic value.
  ///
  /// Handles `null`, non-list types, and mixed-type lists by converting
  /// each element to its string representation.
  ///
  /// Used by models that parse string-list fields such as `brands`
  /// and `displacement_ranges`.
  static List<String> parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  /// Safely parses a double from a dynamic JSON value.
  ///
  /// Handles `double`, `int`, `String`, and `null` inputs.
  /// Returns `0.0` for unparseable values.
  static double parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
