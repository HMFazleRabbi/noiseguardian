import 'dart:math';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:noise_guardian/data/services/key_store.dart';

const String _aesKeyStorageKey = 'aes256_queue_key_hex';

/// AES-256 encryption for queue-at-rest payloads.
abstract class EncryptionService {
  Future<String> encrypt(String plaintext);
  Future<String> decrypt(String ciphertext);
}

class AesEncryptionService implements EncryptionService {
  AesEncryptionService({required KeyStore keyStore}) : _keyStore = keyStore;

  final KeyStore _keyStore;
  enc.Key? _key;

  Future<enc.Key> _loadOrCreateKey() async {
    if (_key != null) {
      return _key!;
    }
    final stored = await _keyStore.read(_aesKeyStorageKey);
    if (stored != null && stored.length == 64) {
      _key = enc.Key(Uint8List.fromList(_hexToBytes(stored)));
      return _key!;
    }
    final random = Random.secure();
    final bytes = Uint8List(32);
    for (var i = 0; i < bytes.length; i++) {
      bytes[i] = random.nextInt(256);
    }
    _key = enc.Key(bytes);
    await _keyStore.write(_aesKeyStorageKey, _bytesToHex(bytes));
    return _key!;
  }

  @override
  Future<String> encrypt(String plaintext) async {
    final key = await _loadOrCreateKey();
    final iv = enc.IV.fromSecureRandom(16);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    final encrypted = encrypter.encrypt(plaintext, iv: iv);
    return '${_bytesToHex(iv.bytes)}:${encrypted.base64}';
  }

  @override
  Future<String> decrypt(String ciphertext) async {
    final parts = ciphertext.split(':');
    if (parts.length != 2) {
      throw const FormatException('Invalid ciphertext format');
    }
    final key = await _loadOrCreateKey();
    final iv = enc.IV(Uint8List.fromList(_hexToBytes(parts[0])));
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    return encrypter.decrypt64(parts[1], iv: iv);
  }

  List<int> _hexToBytes(String hex) {
    final result = <int>[];
    for (var i = 0; i < hex.length; i += 2) {
      result.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    return result;
  }

  String _bytesToHex(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}

/// Deterministic test encryption (no secure storage).
class InMemoryEncryptionService implements EncryptionService {
  InMemoryEncryptionService({enc.Key? key})
      : _key = key ?? enc.Key.fromUtf8('0123456789abcdef0123456789abcdef');

  final enc.Key _key;

  @override
  Future<String> encrypt(String plaintext) async {
    final iv = enc.IV.fromUtf8('1234567890123456');
    final encrypter = enc.Encrypter(enc.AES(_key, mode: enc.AESMode.cbc));
    return encrypter.encrypt(plaintext, iv: iv).base64;
  }

  @override
  Future<String> decrypt(String ciphertext) async {
    final iv = enc.IV.fromUtf8('1234567890123456');
    final encrypter = enc.Encrypter(enc.AES(_key, mode: enc.AESMode.cbc));
    return encrypter.decrypt64(ciphertext, iv: iv);
  }
}
