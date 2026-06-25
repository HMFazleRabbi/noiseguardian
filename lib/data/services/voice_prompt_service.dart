import 'package:flutter_tts/flutter_tts.dart';

/// Voice-guided capture prompts (design doc §12.3).
abstract class VoicePromptService {
  Future<void> speak(String text);
  Future<void> stop();
  Future<void> dispose();
}

/// No-op for tests and when TTS is unavailable.
class NoopVoicePromptService implements VoicePromptService {
  const NoopVoicePromptService();

  @override
  Future<void> dispose() async {}

  @override
  Future<void> speak(String text) async {}

  @override
  Future<void> stop() async {}
}

/// Production TTS via flutter_tts.
class FlutterTtsVoicePromptService implements VoicePromptService {
  FlutterTtsVoicePromptService({FlutterTts? tts}) : _tts = tts ?? FlutterTts();

  final FlutterTts _tts;
  bool _initialized = false;

  Future<void> _ensureInit() async {
    if (_initialized) {
      return;
    }
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    _initialized = true;
  }

  @override
  Future<void> speak(String text) async {
    if (text.isEmpty) {
      return;
    }
    await _ensureInit();
    await _tts.stop();
    await _tts.speak(text);
  }

  @override
  Future<void> stop() async {
    await _tts.stop();
  }

  @override
  Future<void> dispose() async {
    await _tts.stop();
  }
}
