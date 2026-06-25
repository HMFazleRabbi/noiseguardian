# MVP Stage 1 — Safety Harness & Heatmap Removal

**Started:** 2026-06-26  
**Branch:** `mvp-descope`  
**Baseline tag:** `baseline-stage6` @ `df8799d`  
**Reference:** NG-Update-Design-Doc.md §7 Stage 1

---

## Log format

Each entry: **Command** → **Expectation** → **Result** (errors/problems noted)

---

## Phase A — Safety Harness

### A1. Git anchor

| Command | Expectation | Result |
|---------|-------------|--------|
| `git checkout -b mvp-descope` | New branch from clean `df8799d` | OK — branch created |
| `git tag baseline-stage6` | Tag at HEAD for rollback | OK |

### A2. Additive scaffold

| Item | Expectation | Result |
|------|-------------|--------|
| `lib/ui/core/strings.dart` | Empty `AppStrings` namespace | OK |
| `test/widget/app_boot_test.dart` | Tap capture → history → settings | OK (114 tests) |

### A3. Baseline gate

| Command | Expectation | Result |
|---------|-------------|--------|
| `flutter analyze` | 0 errors | OK — 34 info lints only (`prefer_initializing_formals`) |
| `flutter test --timeout 90s` | 114/114 green | OK |
| `flutter build apk --debug` | Compiles | **Partial** — default multi-ABI fails: `PathNotFoundException` copying `libsqlite3.so` for `armeabi-v7a` (sqflite native hooks on Windows). **Workaround:** `flutter build apk --debug --target-platform android-arm64` succeeds |
| `git commit` | `stage-1: harness + baseline tag` | OK |

---

## Phase B/C — Heatmap removal

*(To be filled during implementation)*

---

## Phase D — Final gate

*(To be filled after heatmap removal)*
