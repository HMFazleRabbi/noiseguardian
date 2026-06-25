import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:noise_guardian/data/services/debug_log_service.dart';

void main() {
  group('FileDebugLogService', () {
    late Directory tempDir;
    late FileDebugLogService logger;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('ng_log_test_');
      logger = FileDebugLogService(logDirectory: tempDir);
      await logger.init();
    });

    tearDown(() async {
      await logger.dispose();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('writes log lines to file and flushes immediately', () async {
      await logger.info('test', 'hello world', data: {'value': 1});

      final file = File('${tempDir.path}/noise_guardian_debug.log');
      expect(await file.exists(), isTrue);

      final content = await file.readAsString();
      expect(content, contains('[INFO] [test] hello world'));
      expect(content, contains('"value":1'));
    });

    test('readTail returns recent lines', () async {
      await logger.debug('test', 'line-a');
      await logger.warn('test', 'line-b');

      final tail = await logger.readTail(lines: 10);
      expect(tail.length, greaterThanOrEqualTo(2));
      expect(tail.last, contains('line-b'));
    });

    test('lineStream emits each written line', () async {
      final lines = <String>[];
      final sub = logger.lineStream.listen(lines.add);

      await logger.info('stream', 'live update');
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(lines.any((line) => line.contains('live update')), isTrue);
      await sub.cancel();
    });

    test('clear resets log content', () async {
      await logger.info('test', 'to be cleared');
      await logger.clear();

      final tail = await logger.readTail();
      expect(tail.any((line) => line.contains('to be cleared')), isFalse);
      expect(tail.any((line) => line.contains('Debug log cleared')), isTrue);
    });

    test('handles concurrent writes without losing lines', () async {
      await Future.wait([
        logger.info('test', 'concurrent-a'),
        logger.info('test', 'concurrent-b'),
        logger.info('test', 'concurrent-c'),
        logger.warn('test', 'concurrent-d'),
      ]);

      final file = File('${tempDir.path}/noise_guardian_debug.log');
      final content = await file.readAsString();
      expect(content, contains('concurrent-a'));
      expect(content, contains('concurrent-b'));
      expect(content, contains('concurrent-c'));
      expect(content, contains('concurrent-d'));
    });
  });
}
