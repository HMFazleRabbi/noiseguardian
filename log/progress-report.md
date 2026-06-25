# NoiseGuardian Progress Report

**Last updated:** 2026-06-26  
**Repository:** [github.com/HMFazleRabbi/noiseguardian](https://github.com/HMFazleRabbi/noiseguardian)  
**Package:** `gov.bd.doe.noise_guardian`  
**Design reference:** `NoiseGuardianDesignDoc.md` (parent workspace)

---

## Executive Summary

NoiseGuardian is a Flutter citizen-sensing app for capturing court-ready acoustic evidence of noise pollution in Dhaka. **Original Stages 1–6 are complete.** The project is now executing the **MVP descope** roadmap ([NG-Update-Design-Doc.md](../NG-Update-Design-Doc.md) §7). **MVP Stages 1–3 are complete** on branch `mvp-descope`.

---

## MVP Descope Progress (NG-Update-Design-Doc.md)

| MVP Stage | Scope | Status |
|-----------|-------|--------|
| 1 | Safety harness + remove Heatmap | **Complete** |
| 2 | Remove Voice/TTS + Low-data; simplify Sensor Guard | **Complete** |
| 3 | Remove l10n → English strings | **Complete** |
| 4 | Remove Sync/Queue → ReportRepository | Not started |
| 5 | Slim crypto + SHA-256 packet + local export | Not started |
| 6 | YAMNet edge AI + release hardening | Not started |

### MVP Stage 3 — Remove l10n → English strings

| Deliverable | Status |
|-------------|--------|
| Populate `lib/ui/core/strings.dart` from `app_en.arb` (used keys) | Done |
| Replace all `AppLocalizations` call-sites with `AppStrings` | Done |
| Delete l10n config, ARB files, generated localizations | Done |
| Remove `AppLocaleNotifier`, locale selector, locale persistence | Done |
| Drop `flutter_localizations` from pubspec | Done |

**Quality gates (MVP Stage 3):** `flutter analyze` 0 errors · **106 / 106 tests** · debug APK (arm64) builds

See [log/mvp-stage-3-dev-log.md](mvp-stage-3-dev-log.md).

---

### MVP Stage 2 — Remove Voice/TTS & Low-data; Simplify Sensor Guard

| Deliverable | Status |
|-------------|--------|
| Delete `VoicePromptService` + remove `flutter_tts` dep | Done |
| Remove low-data Wi-Fi gate from settings + `SyncEvidenceUseCase` | Done |
| `GuardState` simplified to `{ ok, unsteady }` | Done |
| Accelerometer-only sensor guard (advisory, never blocks capture) | Done |
| Capture record button enabled even when `unsteady` | Done |

**Quality gates (MVP Stage 2):** `flutter analyze` 0 errors · **107 / 107 tests** · debug APK (arm64) builds

---

### MVP Stage 1 — Safety Harness & Heatmap Removal

| Deliverable | Status |
|-------------|--------|
| Branch `mvp-descope`, tag `baseline-stage6` @ `df8799d` | Done |
| Boot smoke test (capture → history → settings tabs) | Done |
| `lib/ui/core/strings.dart` scaffold | Done |
| Heatmap feature removed (UI, service, model, DI, route) | Done |
| 3-tab shell: capture / history / settings | Done |

**Quality gates (MVP Stage 1):** `flutter analyze` 0 errors · **110 / 110 tests** · debug APK (arm64) builds

**Commits:** `f0d87ce` harness · `24c23e6` remove heatmap

See [log/mvp-stage-1-dev-log.md](mvp-stage-1-dev-log.md).

---

## Completed Work (Original Roadmap)

### Stage 6 — UI/UX & Accessibility

| Deliverable | Status |
|-------------|--------|
| PDPO 2025 onboarding + consent redirect | Done |
| Full Bengali/English ARB strings | Done |
| `VoicePromptService` (flutter_tts) on guard changes + capture complete | Done |
| Low-data mode (WiFi-only sync gate) | Done |
| `PdfExportService` + history/settings export | Done |
| `LocalMockDoeSyncService` (`#DOE-DHK-YYYYMMDD-####`) | Done |
| `HeatmapMapView` offline Dhaka marker map | Done |
| `AppLocaleNotifier` + settings locale EN/BN | Done |
| `SettingsViewModel` wired UI | Done |
| LAeq color meter vs zone threshold | Done |

### Stage 5 — Module E: Offline Sync & Heatmap

| Deliverable | Status |
|-------------|--------|
| `QueueStatus`, `QueuedEvidence`, `SyncReceipt`, `HeatmapCell` models | Done |
| `BackoffPolicy` (1s→2s→4s→8s… cap 5 min) | Done |
| `EvidenceQueueRepository` (AES-256 encrypted sqflite + in-memory) | Done |
| `HttpSyncService` POST `/api/v1/evidence`, receipt on 201, backoff on 5xx | Done |
| `HeatmapAggregationService` (obfuscated coords only) | Done |
| `SyncEvidenceUseCase` | Done |
| `HistoryViewModel` + `HistoryView` (status chips, receipt, Sync) | Done |
| `HeatmapViewModel` + `HeatmapView` (read-only cell grid) | Done |
| Capture flow enqueues packet after build | Done |

### Stages 1–4

See prior stage logs (`log/stage-1-dev-log.md` … `log/stage-5-dev-log.md`).

### Quality Gates (Stage 6)

| Gate | Result |
|------|--------|
| `flutter analyze` | Info lints only (0 errors) |
| `flutter test` | **114 / 114 passing** |

---

## Test Inventory (Stage 6 additions)

```
test/unit/consent_repository_test.dart         — 3 tests
test/unit/app_settings_repository_test.dart    — 4 tests
test/unit/local_mock_doe_sync_service_test.dart — 3 tests
test/unit/pdf_export_service_test.dart         — 1 test
test/unit/sync_evidence_use_case_test.dart     — 2 tests
test/widget/onboarding_view_test.dart          — 2 tests
test/widget/settings_view_test.dart            — 1 test
(+ extended capture/history/router/service_locator tests)
```

---

## Seven-Stage Roadmap Status

| Stage | Name | Status |
|-------|------|--------|
| 1 | Foundation | **Complete** |
| 2 | Module A — Calibration | **Complete** |
| 3 | Modules B + C — Capture & Edge AI | **Complete** |
| 4 | Module D — Crypto & Evidence Packet | **Complete** |
| 5 | Module E — Offline Sync & Heatmap | **Complete** |
| 6 | UI/UX & Accessibility | **Complete** |
| 7 | Hardening & Release | Not started |

---

## Next Up — MVP Stage 4 (Remove Sync/Queue → ReportRepository)

**Deliverables:**

- Replace encrypted queue + sync with local `ReportRepository`
- Rename history → reports
- Remove HTTP sync, mock DoE, connectivity gate

---

## Next Up — MVP Stage 3 — superseded

**Deliverables:**

- RFC 3161 TSA / NTP timestamp integration
- `server_signature_ecdsa` countersignature verification
- Production DoE portal URL + TLS hardening
- Release signing, store metadata, penetration test fixes

---

## Dependencies (current)

| Package | Purpose |
|---------|---------|
| `sqflite` | Encrypted offline evidence queue |
| `http` | DoE REST sync |
| `connectivity_plus` | Network status (Stage 4 removal candidate) |
| `pdf`, `printing` | Evidence PDF export |
| `crypto` | SHA-256 hashing |
| `pointycastle` | ECDSA secp256k1 signing |
| `encrypt` | AES-256 encryption |
| `geolocator` | Device GPS |
| `flutter_secure_storage` | Key storage (Android Keystore) |
| `sensors_plus` | Accelerometer/gyroscope guard |
| `record` | 44.1 kHz PCM capture |
| `shared_preferences` | Cd, consent, settings |
| `go_router`, `get_it`, `provider` | Routing, DI, ViewModels |

---

*This file is updated at the end of each completed stage.*
