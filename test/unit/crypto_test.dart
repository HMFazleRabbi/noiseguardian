import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noise_guardian/core/crypto/canonical_json.dart';

void main() {
  group('canonical JSON + SHA-256', () {
    test('SHA-256 of canonical JSON is deterministic', () {
      final payload = canonicalJsonEncode({
        'b': 2,
        'a': 1,
        'nested': {'z': 3, 'y': 2},
      });
      final hash1 = sha256.convert(utf8.encode(payload)).toString();
      final hash2 = sha256.convert(utf8.encode(payload)).toString();
      expect(hash1, hash2);
      expect(payload.indexOf('"a"'), lessThan(payload.indexOf('"b"')));
    });
  });
}
