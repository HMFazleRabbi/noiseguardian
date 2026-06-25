# MVP Stage 4 — Remove Sync/Queue → ReportRepository

**Started:** 2026-06-26  
**Branch:** `mvp-descope`  
**Baseline:** Stage 3 complete (`ad00c86`)  
**Reference:** NG-Update-Design-Doc.md §7 Stage 4

---

## Phase 0 — Baseline

| Action | Expectation | Result |
|--------|-------------|--------|
| `git status` | Clean on `mvp-descope` @ `ad00c86` | **PASS** |

---

## Phase G — Green (easy → hard)

| Step | Command / action | Expectation | Result |
|------|------------------|-------------|--------|
| 1 | Add `SavedReport`, `ReportRepository` (in-memory + file), `report_repository_test.dart`, `FakeReportRepository` | save→get→list round-trip | **PASS** |
| 2 | Rewire `CaptureViewModel` → `ReportRepository.save()`; drop enqueue | Capture persists locally | **PASS** |
| 3 | Add `reports/` feature; route `/reports`; nav `nav_reports`; update strings | History replaced by Reports | **PASS** |
| 4 | Refactor `PdfExportService` to accept `EvidencePacket` | PDF export without queue model | **PASS** |
| 5 | Simplify settings (remove Mock DoE, export last report) | No sync UI | **PASS** |
| 6 | Delete sync/queue stack + tests/fakes + `tool/mock_doe_server.dart` | Files gone | **PASS** |
| 7 | Clean `service_locator.dart`; remove `http`, `sqflite`, `connectivity_plus`, shelf deps | `flutter pub get` OK | **PASS** |

### Problems encountered

| Issue | Fix |
|-------|-----|
| `service_locator_test` referenced deleted `SyncService` type | Removed assertion; guard via `ReportRepository` registration instead |
| Test count 106 → 88 | Removed 18 sync/queue/backoff tests; added 4 report tests (expected) |

---

## Phase V — Reference sweep

| Command | Expectation | Result |
|---------|-------------|--------|
| `rg "SyncService\|EvidenceQueue\|connectivity_plus\|http_sync" lib` | Zero hits | **PASS** |
| `app_router_test` | `/reports` present, `/history` 404 | **PASS** |

---

## Phase V — Final gate

| Gate | Command | Expectation | Result |
|------|---------|-------------|--------|
| Analyze | `flutter analyze` | 0 errors | **PASS** (23 info lints) |
| Tests | `flutter test` | All green | **PASS** — **88 / 88** |
| Debug build | `flutter build apk --debug --target-platform android-arm64` | APK builds | **PASS** |

---

## Summary

- **Added:** `ReportRepository` (local JSON via `path_provider`), `ReportsView`/`ReportsViewModel`, `/reports` route
- **Removed:** Encrypted queue, HTTP/mock sync, connectivity gate, queue status UI, Mock DoE settings, deps `http`, `sqflite`, `connectivity_plus`, `shelf`
- **Net surface:** Capture → local report save → Reports tab lists + PDF export; Settings exports last report
