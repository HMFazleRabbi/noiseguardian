# Stage 5 Development Log — Module E: Offline Sync & Heatmap

**Started:** 2026-06-25  
**Completed:** 2026-06-25  
**Goal:** Encrypted evidence queue, HTTP sync with backoff, heatmap aggregation, History/Heatmap UI  
**TDD gate:** `flutter analyze` (info only) + `flutter test` **93/93 green**

---

## Stage 4 Verification (pre-flight)

| Step | Command | Expectation | Result |
|------|---------|-------------|--------|
| Test | `flutter test` | 73/73 pass | **PASS** (Stage 4 baseline) |

---

## Stage 5 Work Log

### 1. Add dependencies

| Command | Expectation | Result |
|---------|-------------|--------|
| `flutter pub add sqflite http path` | Resolve packages | **PASS** |
| `flutter pub add --dev sqflite_common_ffi` | Dev FFI for optional desktop DB smoke | **PASS** |

### 2. TDD — write failing tests first

| File | Tests |
|------|-------|
| `test/unit/backoff_policy_test.dart` | exponential schedule, 5 min cap, maxAttempts |
| `test/unit/evidence_queue_repository_test.dart` | encrypt at rest, status transitions |
| `test/unit/sync_service_test.dart` | MockClient 201/4xx/5xx, successRate |
| `test/unit/heatmap_aggregation_test.dart` | obfuscated coords only |
| `test/unit/history_view_model_test.dart` | load + sync refresh |
| `test/unit/heatmap_view_model_test.dart` | synced packets aggregation |
| `test/widget/history_view_test.dart` | status chips, receipt, Sync button |
| `test/widget/heatmap_view_test.dart` | cell grid |
| `test/unit/service_locator_test.dart` | extended Stage 5 registrations |
| `test/fakes/fake_evidence_queue_repository.dart` | queue fake |

### 3. Implementation

| Component | Path |
|-----------|------|
| `QueueStatus`, `SyncReceipt`, `SyncSummary`, `HeatmapCell` | `lib/domain/models/` |
| `QueuedEvidence` | `lib/data/models/queued_evidence.dart` |
| `BackoffPolicy` | `lib/core/net/backoff_policy.dart` |
| `EvidenceQueueRepository` (+ in-memory + sqflite) | `lib/data/repositories/evidence_queue_repository.dart` |
| `HttpSyncService`, `DisabledSyncService` | `lib/data/services/http_sync_service.dart`, `sync_service.dart` |
| `HeatmapAggregationService` | `lib/data/services/heatmap_aggregation_service.dart` |
| `SyncEvidenceUseCase` | `lib/domain/use_cases/sync_evidence_use_case.dart` |
| `HistoryViewModel`, `HeatmapViewModel` | `lib/ui/features/history/`, `heatmap/` |
| `HistoryView`, `HeatmapView` | replaced placeholders with list/grid UI |
| Capture enqueue after packet build | `CaptureViewModel` |
| DI + router providers | `service_locator.dart`, `app_router.dart` |

### 4. Quality gate

| Command | Expectation | Result |
|---------|-------------|--------|
| `flutter analyze` | 0 errors/warnings (info OK) | **PASS** — 23 info lints |
| `flutter test` | All green | **PASS** — 93/93 |

### 5. Device run (SM M315F)

| Command | Expectation | Result |
|---------|-------------|--------|
| `flutter build apk --debug -d R58N66P4RBP` | APK builds with sqflite | **PASS** (~27 s Gradle) |
| `adb install -r build/app/outputs/flutter-apk/app-debug.apk` | Installs on R58N66P4RBP | **PASS** |

**Manual verification:** Capture → packet enqueued (debug log `queue_id`) → History tab shows pending row with status chip → Sync button present (sync disabled with empty `kDoePortalBaseUrl` returns zero attempted) → Heatmap empty until synced rows exist.

### Errors / fixes

| Issue | Fix |
|-------|-----|
| Router/widget tests failed — `HistoryViewModel` not registered | Always register default `InMemoryEvidenceQueueRepository` in DI |
| Duplicate repo implementations (String vs int IDs) | Consolidated to single `evidence_queue_repository.dart` with int IDs |
| `unnecessary_non_null_assertion` in CaptureViewModel | Removed redundant `!` after null promotion |
| 5xx retry incremented attempts before retry check | Reordered to check `shouldRetry` before `incrementAttempts` |

---

## Deferred to Stage 6

- `PdfExportService`
- Full BN/EN ARB strings for History/Heatmap
- Real map widget for heatmap
- Low-data / Wi-Fi-only sync toggle

## Deferred to Stage 7

- RFC 3161 TSA / NTP timestamp
- `server_signature_ecdsa` countersignature verification
