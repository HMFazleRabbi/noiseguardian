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
| Update sensor_guard_test.dart | ok/unsteady only | Pending |
| Update capture_view_model_test.dart | record proceeds when unsteady | Pending |
| Update sync_evidence_use_case_test.dart | drop low-data gate group | Pending |
| Update app_settings_repository_test.dart | drop lowDataMode tests | Pending |
| Update settings_view_test.dart | drop low-data toggle | Pending |
| Update service_locator_test.dart | drop VoicePrompt assert | Pending |
| Update fake_app_settings_repository.dart | drop lowDataMode | Pending |

---

## Phase G — Green (easy → hard)

*(To be filled during implementation)*

---

## Phase V — Verify & commit

*(To be filled after gate)*
