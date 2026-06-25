import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:noise_guardian/data/services/key_store.dart';
import 'package:pointycastle/export.dart';

const String _ecdsaPrivateKeyStorageKey = 'ecdsa_secp256k1_private_hex';

/// ECDSA signing abstraction (secp256k1).
abstract class SigningService {
  Future<void> generateOrLoadKey();
  Future<String> sign(String payload);
  Future<bool> verify(String payload, String signatureHex, String publicKeyHex);
  Future<String> exportPublicKeyHex();
}

class EcdsaSigningService implements SigningService {
  EcdsaSigningService({required KeyStore keyStore}) : _keyStore = keyStore;

  final KeyStore _keyStore;
  ECPrivateKey? _privateKey;
  ECPublicKey? _publicKey;

  @override
  Future<void> generateOrLoadKey() async {
    final stored = await _keyStore.read(_ecdsaPrivateKeyStorageKey);
    if (stored != null && stored.isNotEmpty) {
      _privateKey = _decodePrivateKey(stored);
      _publicKey = _derivePublicKey(_privateKey!);
      return;
    }

    final domain = ECCurve_secp256k1();
    final secureRandom = FortunaRandom();
    final seed = Uint8List(32);
    final random = Random.secure();
    for (var i = 0; i < seed.length; i++) {
      seed[i] = random.nextInt(256);
    }
    secureRandom.seed(KeyParameter(seed));

    final keyGen = ECKeyGenerator()
      ..init(ParametersWithRandom(ECKeyGeneratorParameters(domain), secureRandom));
    final pair = keyGen.generateKeyPair();
    _privateKey = pair.privateKey as ECPrivateKey;
    _publicKey = pair.publicKey as ECPublicKey;

    await _keyStore.write(
      _ecdsaPrivateKeyStorageKey,
      _encodePrivateKey(_privateKey!),
    );
  }

  @override
  Future<String> sign(String payload) async {
    await generateOrLoadKey();
    final signer = ECDSASigner(SHA256Digest(), HMac(SHA256Digest(), 64))
      ..init(true, PrivateKeyParameter<ECPrivateKey>(_privateKey!));
    final sig = signer.generateSignature(utf8.encode(payload)) as ECSignature;
    return _encodeSignature(sig);
  }

  @override
  Future<bool> verify(
    String payload,
    String signatureHex,
    String publicKeyHex,
  ) async {
    final publicKey = _decodePublicKey(publicKeyHex);
    final signature = _decodeSignature(signatureHex);
    final signer = ECDSASigner(SHA256Digest(), HMac(SHA256Digest(), 64))
      ..init(false, PublicKeyParameter<ECPublicKey>(publicKey));
    return signer.verifySignature(utf8.encode(payload), signature);
  }

  @override
  Future<String> exportPublicKeyHex() async {
    await generateOrLoadKey();
    return _encodePublicKey(_publicKey!);
  }

  ECPublicKey _derivePublicKey(ECPrivateKey privateKey) {
    final q = privateKey.parameters!.G * privateKey.d!;
    return ECPublicKey(q, privateKey.parameters);
  }

  String _encodePrivateKey(ECPrivateKey key) {
    return key.d!.toRadixString(16).padLeft(64, '0');
  }

  ECPrivateKey _decodePrivateKey(String hex) {
    final domain = ECCurve_secp256k1();
    return ECPrivateKey(BigInt.parse(hex, radix: 16), domain);
  }

  String _encodePublicKey(ECPublicKey key) {
    final x = key.Q!.x!.toBigInteger()!.toRadixString(16).padLeft(64, '0');
    final y = key.Q!.y!.toBigInteger()!.toRadixString(16).padLeft(64, '0');
    return '$x$y';
  }

  ECPublicKey _decodePublicKey(String hex) {
    final domain = ECCurve_secp256k1();
    final x = BigInt.parse(hex.substring(0, 64), radix: 16);
    final y = BigInt.parse(hex.substring(64), radix: 16);
    final q = domain.curve.createPoint(x, y);
    return ECPublicKey(q, domain);
  }

  String _encodeSignature(ECSignature sig) {
    final r = sig.r.toRadixString(16).padLeft(64, '0');
    final s = sig.s.toRadixString(16).padLeft(64, '0');
    return '$r$s';
  }

  ECSignature _decodeSignature(String hex) {
    final r = BigInt.parse(hex.substring(0, 64), radix: 16);
    final s = BigInt.parse(hex.substring(64), radix: 16);
    return ECSignature(r, s);
  }
}
