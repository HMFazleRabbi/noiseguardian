# MVP Stage 5 — Slim Crypto (SHA-256 only) + Local Export

**Started:** 2026-06-26  
**Branch:** `mvp-descope`  
**Baseline:** Stage 4 complete (`dd588f6`)  
**Reference:** NG-Update-Design-Doc.md §7 Stage 5

---

## Phase 0 — Baseline

| Action | Expectation | Result |
|--------|-------------|--------|
| `git status` | Clean on `mvp-descope` @ `dd588f6` | **PASS** |

---

## Phase G — Green (easy → hard)

| Step | Command / action | Expectation | Result |
|------|------------------|-------------|--------|
| 1 | Add `share_plus` + `JsonExportService`; Reports UI share JSON/PDF | Export/share wired | **PASS** |
| 2 | Simplify `TimestampService` — drop `nowToken` | ISO-8601 only | **PASS** |
| 3 | Drop GPS obfuscation from `gps_math`, packet metadata | `lat`/`lon`/`gps_hash` only | **PASS** |
| 4 | Slim `EvidencePacket` security to `hash_sha256`; update build use case | No ECDSA fields | **PASS** |
| 5 | Delete signing/encryption/keystore + deps; bump version `2.0.0-mvp` | Crypto stack gone | **PASS** |

### Problems encountered

| Issue | Fix |
|-------|-----|
| `share_plus ^12.0.1` conflict with `geolocator` (win32) | Bumped to `share_plus: ^13.1.0` |
| `ViolationType.wireName` undefined in build use case | Added `import violation_result.dart` for extension |
| `flutter pub get` failed first attempt | Resolved after share_plus version bump |

---

## Phase V — Reference sweep

| Command | Expectation | Result |
|---------|-------------|--------|
| `rg "pointycastle\|encrypt\|secure_storage\|signature_ecdsa" lib` | Zero hits | **PASS** |
| `evidence_packet_test` guard | No obfuscation/token/signature in JSON; tamper hash mismatch | **PASS** |

---

## Phase V — Final gate

| Gate | Command | Expectation | Result |
|------|---------|-------------|--------|
| Analyze | `flutter analyze` | 0 errors | **PASS** (info lints only) |
| Tests | `flutter test` | All green | **PASS** — **88 / 88** |
| Debug build | `flutter build apk --debug --target-platform android-arm64` | APK builds | **PASS** |

---

## Summary

- **Added:** `JsonExportService`, Share JSON/PDF on Reports tab, `share_plus` dep
- **Slimmed:** Evidence packet to metrics + metadata + SHA-256 only; app version `2.0.0-mvp`
- **Removed:** ECDSA signing, AES encryption, keystore, GPS obfuscation, `timestamp_token`, deps `pointycastle`/`encrypt`/`flutter_secure_storage`
