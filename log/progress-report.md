# NoiseGuardian Progress Report

**Last updated:** 2026-06-25  
**Repository:** [github.com/HMFazleRabbi/noiseguardian](https://github.com/HMFazleRabbi/noiseguardian)  
**Package:** `gov.bd.doe.noise_guardian`  
**Design reference:** `NoiseGuardianDesignDoc.md` (parent workspace)

---

## Executive Summary

NoiseGuardian is a Flutter citizen-sensing app for capturing court-ready acoustic evidence of noise pollution in Dhaka. **Stages 1–5 are complete.** The app builds, runs on a physical Android device, passes all automated tests, and is under version control on GitHub.

---

## Completed Work

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

### Stage 4 — Module D: Crypto & Evidence Packet

| Deliverable | Status |
|-------------|--------|
| `ZoneType`, `ViolationResult`, `EvidencePacket` models (canonical JSON) | Done |
| `ZoneThresholdService` (Residential 55/48 dB; Silent/Academic provisional) | Done |
| `ViolationEvaluator` (day/night/restricted-hour) | Done |
| `LocalTimestampService` (ISO-8601 + monotonic token) | Done |
| `GeolocatorGpsService` + GPS obfuscation/`gps_hash` | Done |
| `EcdsaSigningService` (secp256k1, secure storage) | Done |
| `AesEncryptionService` (AES-256 CBC, queue-at-rest ready) | Done |
| `BuildEvidencePacketUseCase` | Done |
| Capture flow logs evidence packet hash after recording | Done |

### Stage 3 — Modules B + C: Capture and Edge AI

| Deliverable | Status |
|-------------|--------|
| `SensorGuardService`, `AudioCaptureService`, `FeatureExtractor` | Done |
| `HeuristicClassifier`, `AudioPurgeService`, `CaptureViewModel` | Done |

### Stage 2 — Module A: Calibration

| Deliverable | Status |
|-------------|--------|
| `CalibrationService`, `LaeqService`, calibration wizard | Done |

### Stage 1 — Foundation

| Deliverable | Status |
|-------------|--------|
| Flutter scaffold, router shell, DI, theme, l10n, debug logging | Done |

### Quality Gates (Stage 5)

| Gate | Result |
|------|--------|
| `flutter analyze` | 23 info lints only |
| `flutter test` | **93 / 93 passing** |

---

## Test Inventory (Stage 5 additions)

```
test/unit/backoff_policy_test.dart           — 3 tests
test/unit/evidence_queue_repository_test.dart — 4 tests
test/unit/sync_service_test.dart             — 4 tests
test/unit/heatmap_aggregation_test.dart      — 3 tests
test/unit/history_view_model_test.dart       — 2 tests
test/unit/heatmap_view_model_test.dart       — 1 test
test/widget/history_view_test.dart           — 1 test
test/widget/heatmap_view_test.dart           — 1 test
(+ Stages 1–4 tests: 74 total across 22 files)
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
| 6 | UI/UX & Accessibility | Not started |
| 7 | Hardening & Release | Not started |

---

## Next Up — Stage 6 (UI/UX & Accessibility)

**Deliverables:**

- Onboarding + PDPO consent flow
- Full Bengali/English ARB strings
- Voice-guided capture prompts (`flutter_tts`)
- Low-data mode toggle
- `PdfExportService`
- Real map widget for heatmap

---

## Dependencies (current)

| Package | Purpose |
|---------|---------|
| `sqflite` | Encrypted offline evidence queue |
| `http` | DoE REST sync |
| `path` | SQLite DB path joining |
| `crypto` | SHA-256 hashing |
| `pointycastle` | ECDSA secp256k1 signing |
| `encrypt` | AES-256 encryption |
| `geolocator` | Device GPS |
| `flutter_secure_storage` | Key storage (Android Keystore) |
| `sensors_plus` | Accelerometer/gyroscope guard |
| `record` | 44.1 kHz PCM capture |
| `shared_preferences` | Cd + device install ID |
| `go_router`, `get_it`, `provider` | Routing, DI, ViewModels |

---

*This file is updated at the end of each completed stage.*
