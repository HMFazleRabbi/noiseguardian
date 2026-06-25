import 'dart:math';

/// IEC 61672-1 A-weighting in dB for frequency [frequencyHz].
double aWeightingDb(double frequencyHz) {
  if (frequencyHz <= 0) {
    return double.negativeInfinity;
  }
  const f1 = 20.598997;
  const f2 = 107.65265;
  const f3 = 737.86223;
  const f4 = 12194.217;

  final f2val = frequencyHz * frequencyHz;
  final numerator = f4 * f4 * f2val * f2val;
  final denominator = (f2val + f1 * f1) *
      sqrt((f2val + f2 * f2) * (f2val + f3 * f3)) *
      (f2val + f4 * f4);
  final ra = numerator / denominator;
  return 20 * log(ra) / ln10 + 2.0;
}

double aWeightingLinear(double frequencyHz) {
  return pow(10, aWeightingDb(frequencyHz) / 20).toDouble();
}

/// In-place radix-2 Cooley–Tukey FFT. [real] length must be a power of two.
void fftInPlace(List<double> real, List<double> imag) {
  final n = real.length;
  var j = 0;
  for (var i = 1; i < n; i++) {
    var bit = n >> 1;
    while (j & bit != 0) {
      j ^= bit;
      bit >>= 1;
    }
    j ^= bit;
    if (i < j) {
      final tempR = real[i];
      final tempI = imag[i];
      real[i] = real[j];
      imag[i] = imag[j];
      real[j] = tempR;
      imag[j] = tempI;
    }
  }

  for (var length = 2; length <= n; length <<= 1) {
    final angle = -2 * pi / length;
    final wLenR = cos(angle);
    final wLenI = sin(angle);
    for (var i = 0; i < n; i += length) {
      var wR = 1.0;
      var wI = 0.0;
      for (var k = 0; k < length ~/ 2; k++) {
        final uR = real[i + k];
        final uI = imag[i + k];
        final vR = real[i + k + length ~/ 2] * wR - imag[i + k + length ~/ 2] * wI;
        final vI = real[i + k + length ~/ 2] * wI + imag[i + k + length ~/ 2] * wR;
        real[i + k] = uR + vR;
        imag[i + k] = uI + vI;
        real[i + k + length ~/ 2] = uR - vR;
        imag[i + k + length ~/ 2] = uI - vI;
        final nextWR = wR * wLenR - wI * wLenI;
        wI = wR * wLenI + wI * wLenR;
        wR = nextWR;
      }
    }
  }
}

int nextPowerOfTwo(int value) {
  var n = 1;
  while (n < value) {
    n <<= 1;
  }
  return n;
}

void applyHann(List<double> samples) {
  final n = samples.length;
  if (n <= 1) {
    return;
  }
  for (var i = 0; i < n; i++) {
    final window = 0.5 * (1 - cos(2 * pi * i / (n - 1)));
    samples[i] *= window;
  }
}
