# Stage 3 Development Log — Modules B + C: Capture and Edge AI

**Started:** 2026-06-25  
**Completed:** 2026-06-25  
**Goal:** SensorGuard, AudioCapture, FeatureExtractor, HeuristicClassifier, AudioPurge, Capture orchestration  
**TDD gate:** `flutter analyze` (info only) + `flutter test` **51/51 green**

---

## Stage 2 Verification (pre-flight)

| Step | Command | Expectation | Result |
|------|---------|-------------|--------|
| Test | `flutter test` | 35/35 pass | **PASS** (Stage 2 baseline) |

---

## Stage 3 Work Log

### 1. Add dependency

| Command | Expectation | Result |
|---------|-------------|--------|
| `flutter pub add sensors_plus` | Resolve package | **PASS** — sensors_plus 7.0.0 |

### 2. TDD — write failing tests first

| File | Tests |
|------|-------|
| `test/unit/sensor_guard_test.dart` | ok / muffled / pocketed / obscured profiles |
| `test/unit/feature_extractor_test.dart` | kFeatureLength, low-freq ratio, impulsiveness |
| `test/unit/tflite_classifier_test.dart` | heuristic maps fixtures to NoiseClass |
| `test/unit/audio_purge_test.dart` | purge invariant with/without consent |
| `test/unit/capture_view_model_test.dart` | guard blocks record; full flow |
| `test/widget/capture_view_test.dart` | muffled guard disables Record button |

### 3. Implementation

| Component | Path |
|-----------|------|
| Domain models | `lib/domain/models/guard_state.dart`, `noise_class.dart`, `audio_features.dart`, `classification_result.dart` |
| Feature math | `lib/core/audio/feature_math.dart` (STFT/MFCC/spectral + PCM decode) |
| Sensor guard | `lib/data/services/sensor_guard_service.dart` |
| Audio capture | `lib/data/services/audio_capture_service.dart` (`record` package) |
| Feature extractor | `lib/data/services/feature_extractor.dart` |
| Classifier | `lib/data/services/tflite_classifier.dart` (`HeuristicClassifier`) |
| Audio purge | `lib/data/services/audio_purge_service.dart` |
| Capture VM + UI | `lib/ui/features/capture/` |
| DI | `lib/di/service_locator.dart` |

### 4. Problems encountered and fixes

| Problem | Error / symptom | Fix |
|---------|-----------------|-----|
| `displayName` not found on `NoiseClass` | Compile error in `capture_view.dart` | Import `noise_class.dart` (extension `NoiseClassLabel`) |
| Router tests fail without DI | `type 'Null' is not a subtype of CaptureViewModel` | Call `configureDependencies(sensorGuardService: StubSensorGuardService())` in router/scaffold/boot tests |
| Widget test missing import | `CaptureViewModel` not found | Add view_model import in `capture_view_test.dart` |

### 5. Quality gate (final)

| Command | Expectation | Result |
|---------|-------------|--------|
| `flutter gen-l10n` | Generate capture/guard strings | **PASS** |
| `flutter test` | All green | **51/51 PASS** |
| `flutter analyze` | No errors/warnings | **PASS** — 4 info lints only (pre-existing initializing formals) |

### 7. Debug logger fix (device)

| Problem | `StreamSink is bound to a stream` on Android at startup |
| Fix | Replaced long-lived `IOSink` with serialized `File.writeAsString` append per line |


- `HeuristicClassifier` stands in for real TFLite model; F1 ≥ 0.87 gate deferred until `assets/models/` has trained weights.
- `kFeatureLength` = 45 (13 MFCC + 13 delta + 13 delta-delta + 6 scalars) — provisional.
- Device capture uses `record` at 44.1 kHz WAV; 15 s default duration in ViewModel.

---

*See `log/progress-report.md` for roadmap status.*
