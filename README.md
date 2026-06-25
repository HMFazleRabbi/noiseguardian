# NoiseGuardian

Citizen-sensing mobile companion for capturing, verifying, and syncing **court-ready** acoustic evidence of noise pollution in Dhaka, Bangladesh.

**Status:** Stage 1 (Foundation) complete — 16/16 tests passing  
**Package ID:** `gov.bd.doe.noise_guardian`  
**Progress log:** [log/progress-report.md](log/progress-report.md)

---

## Overview

NoiseGuardian turns smartphones into verifiable environmental sensors. The app targets nocturnal piling, diesel generators, stone crushers, and related urban noise violations. Processing is **edge-heavy** and **privacy-by-design**: raw audio is purged after on-device feature extraction unless the user explicitly opts in.

Planned capabilities (see [7-stage roadmap](#development-roadmap)):

- MEMS microphone calibration (IEC 61672-1 Class 2 approach)
- On-device AI acoustic fingerprinting (TensorFlow Lite)
- Cryptographic Evidence Packets (SHA-256, ECDSA)
- Offline-first sync to the Department of Environment (DoE) portal
- Bengali + English UI with low-literacy / voice-guided flows

---

## Screenshots & Navigation

Bottom-navigation shell with four tabs:

| Tab | Route | Purpose |
|-----|-------|---------|
| Capture | `/capture` | Start acoustic measurement (Stage 2+) |
| History | `/history` | Evidence queue & receipts |
| Heatmap | `/heatmap` | Anonymized neighborhood noise map |
| Settings | `/settings` | Preferences + **live debug log viewer** |

---

## Tech Stack

| Layer | Choice |
|-------|--------|
| Framework | Flutter 3.x (Android + iOS) |
| Architecture | MVVM + Repository pattern |
| DI | `get_it` |
| Routing | `go_router` (`StatefulShellRoute`) |
| Localization | `flutter_localizations` — English + Bengali |
| Logging | `FileDebugLogService` — real-time flushed file log |

---

## Getting Started

### Prerequisites

```bash
flutter doctor -v
```

Requires Flutter SDK, Android SDK (and Xcode for iOS builds).

### Clone & run

```bash
git clone https://github.com/HMFazleRabbi/noiseguardian.git
cd noiseguardian
flutter pub get
flutter run
```

Pick a connected device or emulator when prompted, or target explicitly:

```bash
flutter devices
flutter run -d <device_id>
```

### Test & analyze

```bash
flutter analyze
flutter test
```

### Release build (Android)

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

---

## Project Structure

```
lib/
├── main.dart                 # App entry, logger init
├── app.dart                  # MaterialApp.router
├── di/                       # get_it service locator
├── router/                   # go_router config + nav observer
├── data/
│   ├── services/             # Calibration, sync, debug log
│   └── repositories/         # (Stage 2+)
├── domain/
│   ├── models/
│   └── use_cases/
├── ui/
│   ├── core/                 # Theme, shell, shared widgets
│   └── features/             # capture, history, heatmap, settings
└── l10n/                     # ARB files + generated localizations

test/
├── unit/
├── widget/
└── fakes/

log/
└── progress-report.md        # Stage-by-stage progress log
```

---

## Debug Logging

The app writes timestamped debug lines to `noise_guardian_debug.log` on the device (flushed after every line).

**In-app:** Settings tab → live log viewer, copy path, clear, refresh.

**From a connected phone via ADB:**

```bash
adb exec-out run-as gov.bd.doe.noise_guardian cat app_flutter/noise_guardian_debug.log
```

Log categories include `bootstrap`, `router`, `navigation`, `ui`, `flutter`, `platform`, and `settings`.

---

## Development Roadmap

Test-driven development (TDD): **red → green → refactor** per stage. Each stage gates on `flutter analyze` + `flutter test` before proceeding.

| Stage | Focus | Status |
|-------|-------|--------|
| 1 | Foundation — scaffold, routing, DI, l10n, debug logging | **Done** |
| 2 | Calibration — `Cd` correction, LAeq, pink-noise wizard | Planned |
| 3 | Capture & Edge AI — sensors, TFLite, raw-audio purge | Planned |
| 4 | Crypto & Evidence Packet — GPS, signing, violations | Planned |
| 5 | Offline Sync & Heatmap — SQLite queue, DoE REST API | Planned |
| 6 | UI/UX & Accessibility — consent, voice guide, low-data mode | Planned |
| 7 | Hardening & Release — integration tests, APK/AAB | Planned |

Detailed specs live in the parent workspace design doc (`NoiseGuardianDesignDoc.md`). See [log/progress-report.md](log/progress-report.md) for the latest completed work and next steps.

---

## Contributing

1. Work on a feature branch off `main`
2. Follow TDD — write failing tests first
3. Run `flutter analyze` and `flutter test` before committing
4. Update [log/progress-report.md](log/progress-report.md) when a stage is completed
5. Do **not** commit secrets, keystores, or API keys

---

## License

TBD — add license before public distribution.

---

## Links

- **Repository:** [github.com/HMFazleRabbi/noiseguardian](https://github.com/HMFazleRabbi/noiseguardian)
- **Progress report:** [log/progress-report.md](log/progress-report.md)
