import 'package:noise_guardian/data/services/signing_service.dart';

class FakeSigningService implements SigningService {
  FakeSigningService({String? publicKeyHex})
      : publicKeyHex = publicKeyHex ?? ('a' * 128);

  final String publicKeyHex;
  String? lastSignedPayload;

  @override
  Future<String> exportPublicKeyHex() async => publicKeyHex;

  @override
  Future<void> generateOrLoadKey() async {}

  @override
  Future<String> sign(String payload) async {
    lastSignedPayload = payload;
    return 'deadbeef' * 16;
  }

  @override
  Future<bool> verify(
    String payload,
    String signatureHex,
    String publicKeyHex,
  ) async {
    return signatureHex == 'deadbeef' * 16 && payload == lastSignedPayload;
  }
}
