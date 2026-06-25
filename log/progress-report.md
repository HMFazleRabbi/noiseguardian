# NoiseGuardian Progress Report

**Last updated:** 2026-06-25  
**Repository:** [github.com/HMFazleRabbi/noiseguardian](https://github.com/HMFazleRabbi/noiseguardian)  
**Package:** `gov.bd.doe.noise_guardian`  
**Design reference:** `NoiseGuardianDesignDoc.md` (parent workspace)

---

## Executive Summary

NoiseGuardian is a Flutter citizen-sensing app for capturing court-ready acoustic evidence of noise pollution in Dhaka. **Stage 1 (Foundation) is complete.** The app builds, runs on a physical Android device, passes all automated tests, and is under version control on GitHub.

---

## Completed Work

### Documentation (workspace)

| Artifact | Status |
|----------|--------|
| `NoiseGuardianOutline.md` | Done |
| `NG-Briefing.md` | Done |
| `NoiseGuardianDesignDoc.md` | Done — 7-stage TDD roadmap, architecture, JSON schema |
| `MOBILE_APP_AGENT_GUIDE.md` | Referenced for agent workflow |

### Stage 1 — Foundation (mobile app)

| Deliverable | Status |
|-------------|--------|
| Flutter project scaffold (`noise_guardian`) | Done |
| Layered `lib/` (data / domain / ui / router / di) | Done |
| `get_it` dependency injection | Done |
| `go_router` shell — Capture / History / Heatmap / Settings | Done |
| Material 3 theme (green environmental palette) | Done |
| Bengali + English localization (`app_en.arb`, `app_bn.arb`) | Done |
| Service stubs (`CalibrationService`, `SyncService`) | Done |
| Test fakes and harness | Done |
| Real-time debug file logging (`FileDebugLogService`) | Done |
| Settings live log viewer | Done |
| Global Flutter/platform error logging | Done |

### Quality Gates (Stage 1)

| Gate | Result |
|------|--------|
| `flutter analyze` | Clean |
| `flutter test` | **16 / 16 passing** |
| Physical device run (Samsung SM M315F, Android 12) | Verified |
| Release APK build | Not yet requested |

### Version Control

| Item | Detail |
|------|--------|
| Initial commit | `158059c` — Stage 1 foundation |
| Remote | `origin` → `https://github.com/HMFazleRabbi/noiseguardian.git` |
| Branch | `main` (synced with remote) |

---

## Issues Resolved

| Issue | Resolution |
|-------|------------|
| Red screen on device launch | Removed empty `MultiProvider` wrapper in `main.dart` |
| Gradle disk space exhaustion | Cleared Gradle caches; user freed ~17 GB |
| Debug connection drop on first launch | Second `flutter run` succeeded; app installs correctly |
| `MultiProvider` not caught by tests | Added `app_boot_test.dart`; tests now pump full app entry |

---

## Test Inventory

```
test/unit/app_router_test.dart          — 5 tests (4 routes + route constants)
test/unit/service_locator_test.dart     — 4 tests
test/unit/debug_log_service_test.dart   — 4 tests
test/widget/app_boot_test.dart          — 1 test
test/widget/scaffold_with_nav_bar_test.dart — 2 tests
```

---

## Debug Logging

- **File:** `noise_guardian_debug.log` (app documents directory on device)
- **Flush:** Every line written immediately for real-time tailing
- **In-app viewer:** Settings tab → live log + copy path / clear / refresh
- **Categories:** `bootstrap`, `router`, `navigation`, `ui`, `flutter`, `platform`, `settings`, `logger`

**Pull log from connected device:**

```powershell
adb exec-out run-as gov.bd.doe.noise_guardian cat app_flutter/noise_guardian_debug.log
```

---

## Seven-Stage Roadmap Status

| Stage | Name | Status |
|-------|------|--------|
| 1 | Foundation | **Complete** |
| 2 | Module A — Calibration | Not started |
| 3 | Modules B + C — Capture & Edge AI | Not started |
| 4 | Module D — Crypto & Evidence Packet | Not started |
| 5 | Module E — Offline Sync & Heatmap | Not started |
| 6 | UI/UX & Accessibility | Not started |
| 7 | Hardening & Release | Not started |

---

## Next Up — Stage 2 (Calibration)

**TDD tests to write first:**

1. `Cd = Lref - 20 * log10(Pmeasured / Pref)` against known fixtures
2. LAeq integration within **MAE ≤ 1.8 dB(A)** vs reference vectors
3. Cd persisted and applied to subsequent readings

**Deliverables:**

- `CalibrationService`, `LaeqService`, `CalibrationRepository`
- Pink-noise asset (`assets/sounds/pink_noise.wav`)
- Calibration wizard UI

---

## Dependencies (current)

| Package | Purpose |
|---------|---------|
| `go_router` | Declarative routing + shell navigation |
| `get_it` | Dependency injection |
| `provider` | Reserved for future ViewModels |
| `flutter_localizations` / `intl` | EN + BN i18n |
| `path_provider` | Debug log file path |

---

## Notes for Contributors

- Run all work from `noise_guardian/` directory
- Follow TDD: red → green → refactor per stage
- Read matching skill in `skills/skills/` before implementing (see design doc §6)
- Do not commit secrets, keystores, or `.env` files
- Parent workspace docs (`NoiseGuardianDesignDoc.md`, etc.) live one level above this repo

---

*This file is updated at the end of each completed stage.*
