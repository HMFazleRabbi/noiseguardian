# MVP Stage 3 — Remove l10n → English strings

**Started:** 2026-06-26  
**Branch:** `mvp-descope`  
**Baseline:** Stage 2 complete (`2b0fa8b`)  
**Reference:** NG-Update-Design-Doc.md §7 Stage 3

---

## Phase R — Red (tests first)

| Action | Expectation | Result |
|--------|-------------|--------|
| Populate `AppStrings` from `app_en.arb` | All used keys present | **PASS** — `lib/ui/core/strings.dart` |
| Update widget tests to drop l10n delegates | Tests compile without AppLocalizations | **PASS** |

---

## Phase G — Green (easy → hard)

| Step | Command / action | Expectation | Result |
|------|------------------|-------------|--------|
| 1 | Migrated UI: `app.dart`, shell, onboarding, capture, calibration, history, settings | No `AppLocalizations` imports | **PASS** |
| 2 | `SettingsViewModel` — removed `localeCode`, `setLocaleCode`, `AppLocaleNotifier` | English-only settings | **PASS** |
| 3 | `AppSettingsRepository` — removed locale persistence | Only `useMockDoe` remains | **PASS** |
| 4 | `service_locator.dart` — removed `AppLocaleNotifier` registration + async locale load | DI clean | **PASS** |
| 5 | Deleted `lib/core/locale/app_locale_notifier.dart`, `lib/l10n/*`, `l10n.yaml` | Files gone | **PASS** |
| 6 | `pubspec.yaml` — removed `flutter_localizations`, `generate: true`; kept `intl` for debug log | `flutter pub get` succeeds | **PASS** |
| 7 | Updated tests: capture, onboarding, history, calibration, settings, service_locator, app_settings fake/repo | No l10n in tests | **PASS** |
| 8 | Fix `capture_view.dart` missing `noise_class.dart` import for `displayName` extension | analyze 0 errors | **PASS** (found during analyze) |

### Problems encountered

| Issue | Fix |
|-------|-----|
| `capture_view.dart`: `displayName` undefined on `NoiseClass` | Added `import 'package:noise_guardian/domain/models/noise_class.dart';` (extension was previously in scope via transitive import) |
| PowerShell `&&` not valid | Use `;` as command separator |
| Test count 107 → 106 | Removed locale persistence unit test (expected) |

---

## Phase V — Reference sweep

| Command | Expectation | Result |
|---------|-------------|--------|
| `rg "AppLocalizations\|app_localizations\|AppLocaleNotifier\|localizationsDelegates" lib test` | Zero hits | **PASS** |

---

## Phase V — Final gate

| Gate | Command | Expectation | Result |
|------|---------|-------------|--------|
| Analyze | `flutter analyze` | 0 errors | **PASS** (29 info lints, pre-existing style) |
| Tests | `flutter test` | All green | **PASS** — **106 / 106** |
| Debug build | `flutter build apk --debug --target-platform android-arm64` | APK builds | **PASS** |

---

## Summary

- **Removed:** Bengali/English l10n stack, ARB files, `AppLocaleNotifier`, settings language selector, locale persistence
- **Added:** `AppStrings` English constants in `lib/ui/core/strings.dart`
- **Net surface:** English-only UI; `intl` retained for debug log timestamps only
