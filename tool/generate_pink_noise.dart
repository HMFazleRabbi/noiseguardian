import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

/// Generates `assets/sounds/pink_noise.wav` for calibration reference playback.
void main() {
  const sampleRate = 44100;
  const durationSeconds = 3;
  const amplitude = 0.15;

  final sampleCount = sampleRate * durationSeconds;
  final samples = _generatePinkNoise(sampleCount, amplitude);
  final bytes = _encodeWav(samples, sampleRate);

  final file = File('assets/sounds/pink_noise.wav');
  file.parent.createSync(recursive: true);
  file.writeAsBytesSync(bytes);
  stdout.writeln('Wrote ${file.path} (${bytes.length} bytes)');
}

List<double> _generatePinkNoise(int count, double amplitude) {
  final random = Random(42);
  final output = List<double>.filled(count, 0);
  var b0 = 0.0;
  var b1 = 0.0;
  var b2 = 0.0;
  var b3 = 0.0;
  var b4 = 0.0;
  var b5 = 0.0;
  var b6 = 0.0;

  for (var i = 0; i < count; i++) {
    final white = random.nextDouble() * 2 - 1;
    b0 = 0.99886 * b0 + white * 0.0555179;
    b1 = 0.99332 * b1 + white * 0.0750759;
    b2 = 0.96900 * b2 + white * 0.1538520;
    b3 = 0.86650 * b3 + white * 0.3104856;
    b4 = 0.55000 * b4 + white * 0.5329522;
    b5 = -0.7616 * b5 - white * 0.0168980;
    final pink = b0 + b1 + b2 + b3 + b4 + b5 + b6 + white * 0.5362;
    b6 = white * 0.115926;
    output[i] = pink * amplitude;
  }
  return output;
}

Uint8List _encodeWav(List<double> samples, int sampleRate) {
  final pcm = Int16List(samples.length);
  for (var i = 0; i < samples.length; i++) {
    final clamped = samples[i].clamp(-1.0, 1.0);
    pcm[i] = (clamped * 32767).round();
  }

  final byteRate = sampleRate * 2;
  final dataSize = pcm.lengthInBytes;
  final buffer = ByteData(44 + dataSize);

  void writeString(int offset, String value) {
    for (var i = 0; i < value.length; i++) {
      buffer.setUint8(offset + i, value.codeUnitAt(i));
    }
  }

  writeString(0, 'RIFF');
  buffer.setUint32(4, 36 + dataSize, Endian.little);
  writeString(8, 'WAVE');
  writeString(12, 'fmt ');
  buffer.setUint32(16, 16, Endian.little);
  buffer.setUint16(20, 1, Endian.little);
  buffer.setUint16(22, 1, Endian.little);
  buffer.setUint32(24, sampleRate, Endian.little);
  buffer.setUint32(28, byteRate, Endian.little);
  buffer.setUint16(32, 2, Endian.little);
  buffer.setUint16(34, 16, Endian.little);
  writeString(36, 'data');
  buffer.setUint32(40, dataSize, Endian.little);

  final bytes = buffer.buffer.asUint8List();
  final result = Uint8List(44 + dataSize);
  result.setRange(0, 44, bytes);
  result.setRange(44, 44 + dataSize, pcm.buffer.asUint8List());
  return result;
}
