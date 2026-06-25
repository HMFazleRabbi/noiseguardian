import 'dart:math';
import 'dart:typed_data';

import 'package:noise_guardian/core/audio/a_weighting.dart';
import 'package:noise_guardian/domain/models/audio_features.dart';

const int _fftSize = 2048;
const int _hopSize = 1024;
const int _melBands = 40;

/// Decodes 16-bit PCM WAV bytes to normalized samples in [-1, 1].
List<double> decodePcm16Wav(Uint8List bytes) {
  if (bytes.length < 44) {
    throw ArgumentError('WAV data too short');
  }
  final dataOffset = _findDataChunkOffset(bytes);
  final sampleCount = (bytes.length - dataOffset) ~/ 2;
  final result = List<double>.filled(sampleCount, 0);
  final data = ByteData.sublistView(bytes, dataOffset);
  for (var i = 0; i < sampleCount; i++) {
    result[i] = data.getInt16(i * 2, Endian.little) / 32768.0;
  }
  return result;
}

int _findDataChunkOffset(Uint8List bytes) {
  for (var i = 12; i < bytes.length - 8; i++) {
    if (bytes[i] == 0x64 &&
        bytes[i + 1] == 0x61 &&
        bytes[i + 2] == 0x74 &&
        bytes[i + 3] == 0x61) {
      return i + 8;
    }
  }
  return 44;
}

/// Extracts [AudioFeatures] from PCM samples at [sampleRateHz].
AudioFeatures extractAudioFeatures({
  required List<double> samples,
  required int sampleRateHz,
}) {
  final frames = _stftFrames(samples);
  if (frames.isEmpty) {
    return _zeroFeatures();
  }

  final magnitudes = frames.map(_magnitudeSpectrum).toList(growable: false);
  final powerSpectra = magnitudes
      .map((m) => m.map((v) => v * v).toList(growable: false))
      .toList(growable: false);

  final melFrames = magnitudes.map((m) => _toMel(m, sampleRateHz)).toList();
  final logMel = melFrames
      .map((frame) => frame.map((v) => log(max(v, 1e-10))).toList())
      .toList();
  final mfccFrames = logMel.map(_dct2).toList();

  final mfccMeans = _columnMeans(mfccFrames, AudioFeatures.mfccCount);
  final deltas = _deltaFrames(mfccFrames);
  final deltaMeans = _columnMeans(deltas, AudioFeatures.mfccCount);
  final deltaDeltas = _deltaFrames(deltas);
  final deltaDeltaMeans = _columnMeans(deltaDeltas, AudioFeatures.mfccCount);

  final centroid = _mean(
    magnitudes.map((m) => _spectralCentroid(m, sampleRateHz)).toList(),
  );
  final rolloff = _mean(
    magnitudes.map((m) => _spectralRolloff95(m, sampleRateHz)).toList(),
  );
  final flux = _meanSpectralFlux(magnitudes);
  final zcr = _zeroCrossingRate(samples);
  final lowFreq = _lowFrequencyEnergyRatio(powerSpectra, sampleRateHz);
  final impulsive = _impulsiveness(samples);

  return AudioFeatures(
    mfccMeans: mfccMeans,
    deltaMeans: deltaMeans,
    deltaDeltaMeans: deltaDeltaMeans,
    spectralCentroid: centroid,
    spectralRolloff95: rolloff,
    spectralFlux: flux,
    zeroCrossingRate: zcr,
    lowFreqEnergyRatio: lowFreq,
    impulsiveness: impulsive,
  );
}

AudioFeatures _zeroFeatures() {
  return AudioFeatures(
    mfccMeans: List<double>.filled(AudioFeatures.mfccCount, 0),
    deltaMeans: List<double>.filled(AudioFeatures.mfccCount, 0),
    deltaDeltaMeans: List<double>.filled(AudioFeatures.mfccCount, 0),
    spectralCentroid: 0,
    spectralRolloff95: 0,
    spectralFlux: 0,
    zeroCrossingRate: 0,
    lowFreqEnergyRatio: 0,
    impulsiveness: 0,
  );
}

List<List<double>> _stftFrames(List<double> samples) {
  final frames = <List<double>>[];
  for (var start = 0; start + _fftSize <= samples.length; start += _hopSize) {
    final frame = List<double>.from(samples.sublist(start, start + _fftSize));
    applyHann(frame);
    frames.add(frame);
  }
  return frames;
}

List<double> _magnitudeSpectrum(List<double> frame) {
  final real = List<double>.from(frame);
  final imag = List<double>.filled(frame.length, 0);
  fftInPlace(real, imag);
  final half = frame.length ~/ 2;
  return List<double>.generate(
    half,
    (i) => sqrt(real[i] * real[i] + imag[i] * imag[i]) / frame.length,
  );
}

List<double> _toMel(List<double> magnitudes, int sampleRateHz) {
  final melFilters = _melFilterbank(sampleRateHz, magnitudes.length);
  return List<double>.generate(_melBands, (band) {
    var energy = 0.0;
    for (var bin = 0; bin < magnitudes.length; bin++) {
      energy += magnitudes[bin] * melFilters[band][bin];
    }
    return energy;
  });
}

List<List<double>> _melFilterbank(int sampleRateHz, int fftBins) {
  final filters = List.generate(_melBands, (_) => List<double>.filled(fftBins, 0));
  final melMax = _hzToMel(sampleRateHz / 2);
  final melPoints = List<double>.generate(
    _melBands + 2,
    (i) => melMax * i / (_melBands + 1),
  );
  final hzPoints = melPoints.map(_melToHz).toList();
  final binPoints = hzPoints.map((hz) => (hz / sampleRateHz) * fftBins * 2).toList();

  for (var band = 0; band < _melBands; band++) {
    final left = binPoints[band];
    final center = binPoints[band + 1];
    final right = binPoints[band + 2];
    for (var bin = 0; bin < fftBins; bin++) {
      final b = bin.toDouble();
      if (b >= left && b <= center && center > left) {
        filters[band][bin] = (b - left) / (center - left);
      } else if (b > center && b <= right && right > center) {
        filters[band][bin] = (right - b) / (right - center);
      }
    }
  }
  return filters;
}

double _hzToMel(double hz) => 2595 * log(1 + hz / 700) / ln10;
double _melToHz(double mel) => 700 * (pow(10, mel / 2595) - 1);

List<double> _dct2(List<double> logMel) {
  final n = logMel.length;
  return List<double>.generate(AudioFeatures.mfccCount, (k) {
    var sum = 0.0;
    for (var i = 0; i < n; i++) {
      sum += logMel[i] * cos(pi * k * (i + 0.5) / n);
    }
    return sum;
  });
}

List<List<double>> _deltaFrames(List<List<double>> frames) {
  if (frames.length < 2) {
    return frames;
  }
  return List.generate(frames.length, (t) {
    final prev = frames[max(0, t - 1)];
    final next = frames[min(frames.length - 1, t + 1)];
    return List<double>.generate(prev.length, (i) => (next[i] - prev[i]) / 2);
  });
}

List<double> _columnMeans(List<List<double>> frames, int count) {
  if (frames.isEmpty) {
    return List<double>.filled(count, 0);
  }
  return List<double>.generate(count, (col) {
    var sum = 0.0;
    for (final frame in frames) {
      sum += frame[col];
    }
    return sum / frames.length;
  });
}

double _spectralCentroid(List<double> magnitudes, int sampleRateHz) {
  var weighted = 0.0;
  var total = 0.0;
  for (var i = 0; i < magnitudes.length; i++) {
    final freq = i * sampleRateHz / (_fftSize);
    weighted += freq * magnitudes[i];
    total += magnitudes[i];
  }
  return total == 0 ? 0 : weighted / total;
}

double _spectralRolloff95(List<double> magnitudes, int sampleRateHz) {
  final total = magnitudes.fold<double>(0, (a, b) => a + b);
  if (total == 0) {
    return 0;
  }
  var cumulative = 0.0;
  for (var i = 0; i < magnitudes.length; i++) {
    cumulative += magnitudes[i];
    if (cumulative >= 0.95 * total) {
      return i * sampleRateHz / _fftSize;
    }
  }
  return sampleRateHz / 2;
}

double _meanSpectralFlux(List<List<double>> magnitudes) {
  if (magnitudes.length < 2) {
    return 0;
  }
  var flux = 0.0;
  for (var t = 1; t < magnitudes.length; t++) {
    var frameFlux = 0.0;
    for (var i = 0; i < magnitudes[t].length; i++) {
      final diff = magnitudes[t][i] - magnitudes[t - 1][i];
      frameFlux += diff > 0 ? diff : 0;
    }
    flux += frameFlux;
  }
  return flux / (magnitudes.length - 1);
}

double _zeroCrossingRate(List<double> samples) {
  if (samples.length < 2) {
    return 0;
  }
  var crossings = 0;
  for (var i = 1; i < samples.length; i++) {
    if ((samples[i - 1] >= 0 && samples[i] < 0) ||
        (samples[i - 1] < 0 && samples[i] >= 0)) {
      crossings++;
    }
  }
  return crossings / samples.length;
}

double _lowFrequencyEnergyRatio(List<List<double>> powerSpectra, int sampleRateHz) {
  if (powerSpectra.isEmpty) {
    return 0;
  }
  var lowEnergy = 0.0;
  var totalEnergy = 0.0;
  for (final spectrum in powerSpectra) {
    for (var i = 0; i < spectrum.length; i++) {
      final freq = i * sampleRateHz / _fftSize;
      totalEnergy += spectrum[i];
      if (freq < 200) {
        lowEnergy += spectrum[i];
      }
    }
  }
  return totalEnergy == 0 ? 0 : lowEnergy / totalEnergy;
}

double _impulsiveness(List<double> samples) {
  if (samples.isEmpty) {
    return 0;
  }
  var peak = 0.0;
  var sumSquares = 0.0;
  for (final sample in samples) {
    final abs = sample.abs();
    if (abs > peak) {
      peak = abs;
    }
    sumSquares += sample * sample;
  }
  final rms = sqrt(sumSquares / samples.length);
  if (rms == 0) {
    return 0;
  }
  return peak / rms;
}

double _mean(List<double> values) {
  if (values.isEmpty) {
    return 0;
  }
  return values.reduce((a, b) => a + b) / values.length;
}

/// Generates a pure-tone PCM buffer for tests.
List<double> generateTone({
  required double frequencyHz,
  required int sampleRateHz,
  required double durationSeconds,
  double amplitude = 0.5,
}) {
  final count = (sampleRateHz * durationSeconds).round();
  final omega = 2 * pi * frequencyHz / sampleRateHz;
  return List<double>.generate(count, (i) => amplitude * sin(omega * i));
}

/// Generates impulsive transient samples for tests.
List<double> generateImpulsiveSamples({
  required int sampleRateHz,
  required double durationSeconds,
}) {
  final count = (sampleRateHz * durationSeconds).round();
  final samples = List<double>.filled(count, 0);
  for (var i = 1000; i < count; i += 2000) {
    samples[i] = 0.9;
    if (i + 1 < count) {
      samples[i + 1] = -0.8;
    }
  }
  return samples;
}
