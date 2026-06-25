# MVP Stage 2 — Remove Voice/TTS & Low-data; Simplify Sensor Guard

**Started:** 2026-06-26  
**Branch:** `mvp-descope`  
**Baseline:** Stage 1 complete (`d87c5f1`)  
**Reference:** NG-Update-Design-Doc.md §7 Stage 2

---

## Log format

Each entry: **Command** → **Expectation** → **Result** (errors/problems noted)

---

## Phase R — Red (tests first)

| Action | Expectation | Result |
|--------|-------------|--------|
| Rewrite `sensor_guard_test.dart` | ok/unsteady only | OK |
| Update `capture_view_model_test.dart` | record proceeds when unsteady | OK |
| Replace `sync_evidence_use_case_test.dart` | single delegate test | OK |
| Trim `app_settings_repository_test.dart` | drop lowDataMode | OK |
| Update `settings_view_test.dart` | no low-data toggle | OK |
| Update `service_locator_test.dart` | drop VoicePrompt assert | OK |
| Update `fake_app_settings_repository.dart` | drop lowDataMode | OK |
| Update `capture_view_test.dart` | unsteady advisory, record enabled | OK |

---

## Phase G — Green (easy → hard)

| Action | Expectation | Result |
|--------|-------------|--------|
| Trim `app_settings_repository.dart` | remove lowDataMode | OK |
| Simplify `sync_evidence_use_case.dart` | syncPending only | OK |
| Simplify `guard_state.dart` | `{ ok, unsteady }` | OK |
| Rewrite `sensor_guard_service.dart` | accelerometer-only | OK |
| Delete `voice_prompt_service.dart` | file gone | OK |
| Trim `settings_view_model.dart` + `settings_view.dart` | no low-data toggle | OK |
| Strip voice from `capture_view_model.dart` + `capture_view.dart` | no TTS, canRecord=!busy | OK |
| Rewire `service_locator.dart` | no VoicePrompt DI | OK |
| Remove `flutter_tts` from `pubspec.yaml` | dep gone | OK |

---

## Phase V — Final gate

| Command | Expectation | Result |
|---------|-------------|--------|
| `rg "VoicePrompt\|voicePrompt\|flutter_tts\|lowDataMode" lib` (excl. l10n) | Zero hits | OK — l10n voice/low-data strings retained for Stage 3 |
| `flutter test --timeout 90s` | All green | OK — **107/107** |
| `flutter build apk --debug --target-platform android-arm64` | Compiles | OK |
| `git commit` | `stage-2: remove voice/low-data, simplify guard` | OK |

### Notes

- `guardObscured` l10n string reused for `unsteady` banner ("Excessive handling detected — hold steady.") — no ARB regeneration needed.
- `ConnectivityService` remains registered (unused until Stage 4 sync removal).
- Test count: 110 → 107 (removed 3 low-data/guard cases, added 0 net new).

---

## Stage 2 complete

- **Net surface:** no voice prompts, no low-data toggle, sensor guard is advisory-only (`ok` / `unsteady`), capture never blocked by guard state.
