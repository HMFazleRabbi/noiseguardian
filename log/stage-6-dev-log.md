# Stage 6 Development Log — UI/UX & Accessibility

**Started:** 2026-06-26  
**Completed:** 2026-06-26  
**Goal:** PDPO onboarding, BN/EN l10n, voice prompts, low-data sync gate, PDF export, mock DoE, heatmap map  
**TDD gate:** `flutter analyze` (info only) + `flutter test` **114/114 green**

---

## Stage 5 Verification (pre-flight)

| Step | Command | Expectation | Result |
|------|---------|-------------|--------|
| Test | `flutter test` | 93/93 pass | **PASS** (Stage 5 baseline) |

---

## Stage 6 Work Log

### 1. Add dependencies

| Package | Purpose |
|---------|---------|
| `flutter_tts` | Voice-guided capture prompts |
| `pdf`, `printing` | Evidence PDF export |
| `connectivity_plus` | Low-data WiFi-only gate |
| `shelf` (dev) | `tool/mock_doe_server.dart` |

### 2. TDD — write failing tests first

| File | Tests |
|------|-------|
| `test/unit/consent_repository_test.dart` | default, grant, revoke |
| `test/unit/app_settings_repository_test.dart` | mock DoE default, low-data, locale |
| `test/unit/local_mock_doe_sync_service_test.dart` | `#DOE-DHK-YYYYMMDD-####` receipt, invalid packet, success rate |
| `test/unit/pdf_export_service_test.dart` | non-empty `%PDF` bytes |
| `test/unit/sync_evidence_use_case_test.dart` | cellular blocked / WiFi allowed |
| `test/widget/onboarding_view_test.dart` | agree → capture, decline stays |
| `test/widget/settings_view_test.dart` | low-data toggle, locale BN labels |
| `test/widget/capture_view_test.dart` | extended: 48dp button |
| `test/widget/history_view_test.dart` | extended: mock DoE sync receipt |
| `test/unit/service_locator_test.dart` | extended: LocalMockDoe, SettingsViewModel |
| `test/unit/app_router_test.dart` | consent redirect |

### 3. Implementation

| Component | Path |
|-----------|------|
| `ConsentRepository`, `AppSettingsRepository` | `lib/data/repositories/` |
| `ConnectivityService` | `lib/data/services/connectivity_service.dart` |
| `LocalMockDoeSyncService` | `lib/data/services/local_mock_doe_sync_service.dart` |
| `PdfExportService`, `VoicePromptService` | `lib/data/services/` |
| `AppLocaleNotifier` | `lib/core/locale/app_locale_notifier.dart` |
| `OnboardingView` | `lib/ui/features/onboarding/views/` |
| `SettingsViewModel` + wired `SettingsView` | low-data, locale, mock DoE, PDF, debug log |
| `CaptureViewModel` | voice prompts + zone LAeq threshold meter |
| `HistoryViewModel.exportPdf` | per synced row |
| `HeatmapMapView` integrated in `HeatmapView` | offline Dhaka marker map |
| DI + router | `service_locator.dart`, `app_router.dart`, `app.dart` locale |
| Full BN/EN ARB strings | `lib/l10n/app_en.arb`, `app_bn.arb` |
| `tool/mock_doe_server.dart` | shelf dev server |

### 4. Quality gate

| Command | Expectation | Result |
|---------|-------------|--------|
| `flutter analyze` | 0 errors/warnings (info OK) | **PASS** — info lints only |
| `flutter test` | All green | **PASS** — 114/114 |

### Errors / fixes

| Issue | Fix |
|-------|-----|
| Duplicate `network_connectivity_service.dart` | Deleted; unified on `ConnectivityService` |
| ARB ICU apostrophe in onboarding intro | Escaped `Bangladesh''s` |
| `SettingsView` SwitchListTile without Material | Wrapped in `Material` |
| History list trailing overflow | Moved receipt/PDF to subtitle column |
| Receipt format | `#DOE-DHK-YYYYMMDD-####` prefix |

### 5. Device install (SM M315F)

| Step | Command | Expectation | Result |
|------|---------|-------------|--------|
| Build | `flutter build apk --debug` | APK produced | **PASS** |
| Install | `adb -s R58N66P4RBP install -r app-debug.apk` | Success on SM M315F | **PASS** |

Manual QA on device: onboarding → capture → History sync (mock `#DOE-DHK-*` receipt) → Heatmap cell — **airplane mode OK** (offline mock DoE requires no network).

---

## Deferred to Stage 7

- RFC 3161 TSA / NTP timestamp
- `server_signature_ecdsa` countersignature verification
- Production DoE portal URL configuration
