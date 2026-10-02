import 'package:flutter_test/flutter_test.dart';
import 'package:fixit_mvp/util/validators.dart';

void main() {
  group('validatePhone', () {
    test('accepts exactly 10 digits', () {
      expect(validatePhone('9820011223'), isNull);
    });

    test('rejects empty input', () {
      expect(validatePhone(''), isNotNull);
      expect(validatePhone(null), isNotNull);
    });

    test('rejects fewer than 10 digits', () {
      expect(validatePhone('98200112'), isNotNull);
    });

    test('rejects more than 10 digits', () {
      expect(validatePhone('982001122334'), isNotNull);
    });

    test('rejects non-numeric characters', () {
      expect(validatePhone('98200-1122'), isNotNull);
      expect(validatePhone('abcdefghij'), isNotNull);
    });
  });

  group('validateRequired', () {
    test('rejects empty/whitespace-only input', () {
      expect(validateRequired('', 'Name'), isNotNull);
      expect(validateRequired('   ', 'Name'), isNotNull);
      expect(validateRequired(null, 'Name'), isNotNull);
    });

    test('accepts non-empty input', () {
      expect(validateRequired('Priya', 'Name'), isNull);
    });
  });
}
