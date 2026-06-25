# NoiseGuardian Progress Report

**Last updated:** 2026-06-26  
**Repository:** [github.com/HMFazleRabbi/noiseguardian](https://github.com/HMFazleRabbi/noiseguardian)  
**Package:** `gov.bd.doe.noise_guardian`  
**Design reference:** `NoiseGuardianDesignDoc.md` (parent workspace)

---

## Executive Summary

NoiseGuardian is a Flutter citizen-sensing app for capturing court-ready acoustic evidence of noise pollution in Dhaka. **Stages 1–6 are complete.** The app builds, runs on a physical Android device, passes all automated tests, and is under version control on GitHub.

---

## Completed Work

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

## Next Up — Stage 7 (Hardening & Release)

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
| `connectivity_plus` | Low-data WiFi gate |
| `flutter_tts` | Voice-guided capture |
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
