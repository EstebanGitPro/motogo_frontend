import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/core/utils/json_helpers.dart';

void main() {
  group('JsonHelpers', () {
    group('parseStringList', () {
      test('returns list of strings from string list', () {
        expect(JsonHelpers.parseStringList(['a', 'b', 'c']), ['a', 'b', 'c']);
      });

      test('converts non-string items to strings', () {
        expect(JsonHelpers.parseStringList([1, 2, 3]), ['1', '2', '3']);
      });

      test('returns empty list for null', () {
        expect(JsonHelpers.parseStringList(null), isEmpty);
      });

      test('returns empty list for non-list value', () {
        expect(JsonHelpers.parseStringList('not a list'), isEmpty);
      });

      test('handles empty list', () {
        expect(JsonHelpers.parseStringList(<dynamic>[]), isEmpty);
      });

      test('handles mixed types in list', () {
        expect(JsonHelpers.parseStringList(['a', 1, true]), ['a', '1', 'true']);
      });
    });

    group('parseDouble', () {
      test('returns double from double', () {
        expect(JsonHelpers.parseDouble(4.5), 4.5);
      });

      test('converts int to double', () {
        expect(JsonHelpers.parseDouble(5), 5.0);
      });

      test('parses string to double', () {
        expect(JsonHelpers.parseDouble('3.14'), 3.14);
      });

      test('returns 0.0 for unparseable string', () {
        expect(JsonHelpers.parseDouble('abc'), 0.0);
      });

      test('returns 0.0 for null', () {
        expect(JsonHelpers.parseDouble(null), 0.0);
      });

      test('returns 0.0 for unsupported type', () {
        expect(JsonHelpers.parseDouble(true), 0.0);
      });

      test('handles negative double', () {
        expect(JsonHelpers.parseDouble(-74.0698), -74.0698);
      });

      test('handles negative string', () {
        expect(JsonHelpers.parseDouble('-74.0698'), -74.0698);
      });
    });
  });
}
