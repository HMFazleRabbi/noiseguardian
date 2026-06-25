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

### B1. Red — tests first

| Action | Expectation | Result |
|--------|-------------|--------|
| Delete `heatmap_view_test.dart`, `heatmap_view_model_test.dart`, `heatmap_aggregation_test.dart` | 3 files gone | OK |
| Update `app_router_test.dart` | `/heatmap` → route not found; `shellRoutes` guard | OK |
| Update `scaffold_with_nav_bar_test.dart` | 3 nav destinations, no heatmap tap | OK |
| Update `service_locator_test.dart` | Remove heatmap registration asserts | OK |

### C1. Green — production (easy → hard)

| Action | Expectation | Result |
|--------|-------------|--------|
| Delete `lib/ui/features/heatmap/**`, `heatmap_aggregation_service.dart`, `heatmap_cell.dart` | 5 files gone | OK |
| Edit `scaffold_with_nav_bar.dart` | 3-tab nav | OK |
| Edit `app_routes.dart` | `shellRoutes = [capture, history, settings]` | OK |
| Edit `app_router.dart` | Remove heatmap branch | OK |
| Edit `service_locator.dart` | Remove heatmap DI (last) | OK |

---

## Phase D — Final gate

| Command | Expectation | Result |
|---------|-------------|--------|
| `rg "HeatmapView\|HeatmapViewModel\|HeatmapAggregationService\|HeatmapCell" lib test` | Zero hits | OK (l10n `navHeatmap` retained for Stage 3) |
| `flutter test --timeout 90s` | All green | OK — **110/110** |
| `flutter build apk --debug --target-platform android-arm64` | Compiles | OK |
| `git commit` | `stage-1: remove heatmap` | OK — `24c23e6` |

### Problems encountered

1. **Multi-ABI debug build fails on Windows** — `libsqlite3.so` missing for `armeabi-v7a` during native asset install. Workaround: `--target-platform android-arm64`.
2. **Prior monolithic descope** reverted because bulk deletion left dangling DI references; this stage's slice-by-slice approach avoided that.

---

## Stage 1 complete

- **Branch:** `mvp-descope`
- **Tags:** `baseline-stage6` (pre-descope), commits `f0d87ce` + `24c23e6`
- **Net surface:** 3-tab shell (capture / history / settings); sync, queue, crypto, l10n unchanged
