import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noise_guardian/core/crypto/canonical_json.dart';
import 'package:noise_guardian/data/services/encryption_service.dart';
import 'package:noise_guardian/data/services/signing_service.dart';
import '../fakes/fake_key_store.dart';

void main() {
  group('canonical JSON + crypto', () {
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

    test('ECDSA sign and verify succeeds', () async {
      final keyStore = FakeKeyStore();
      final signing = EcdsaSigningService(keyStore: keyStore);
      await signing.generateOrLoadKey();
      const payload = '{"metrics":{"laeq_db":58.2}}';
      final sig = await signing.sign(payload);
      final pub = await signing.exportPublicKeyHex();
      expect(await signing.verify(payload, sig, pub), isTrue);
    });

    test('tampered payload fails verify', () async {
      final keyStore = FakeKeyStore();
      final signing = EcdsaSigningService(keyStore: keyStore);
      await signing.generateOrLoadKey();
      const payload = 'original';
      final sig = await signing.sign(payload);
      final pub = await signing.exportPublicKeyHex();
      expect(await signing.verify('tampered', sig, pub), isFalse);
    });

    test('AES-256 encrypt/decrypt round-trip', () async {
      final keyStore = FakeKeyStore();
      final encryption = AesEncryptionService(keyStore: keyStore);
      const plaintext = '{"evidence":"packet"}';
      final cipher = await encryption.encrypt(plaintext);
      final restored = await encryption.decrypt(cipher);
      expect(restored, plaintext);
      expect(cipher, isNot(equals(plaintext)));
    });
  });
}
