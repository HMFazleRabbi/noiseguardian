import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:noise_guardian/data/services/audio_purge_service.dart';

void main() {
  late AudioPurgeService purgeService;
  late Directory tempDir;

  setUp(() async {
    purgeService = const AudioPurgeService();
    tempDir = await Directory.systemTemp.createTemp('ng_purge_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('AudioPurgeService', () {
    test('deletes temp file when consent is false', () async {
      final file = File('${tempDir.path}/capture.wav');
      await file.writeAsString('fake audio data');

      final purged = await purgeService.purge(
        filePath: file.path,
        consentToRetain: false,
      );

      expect(purged, isTrue);
      expect(await file.exists(), isFalse);
    });

    test('retains file when consent is true', () async {
      final file = File('${tempDir.path}/capture.wav');
      await file.writeAsString('fake audio data');

      final purged = await purgeService.purge(
        filePath: file.path,
        consentToRetain: true,
      );

      expect(purged, isFalse);
      expect(await file.exists(), isTrue);
    });
  });
}
