# Stage 4 Development Log — Module D: Crypto, Violation, Evidence Packet

**Started:** 2026-06-25  
**Completed:** 2026-06-25  
**Goal:** ZoneThreshold, ViolationEvaluator, EvidencePacket, GPS, Signing, Encryption, BuildEvidencePacketUseCase  
**TDD gate:** `flutter analyze` (info only) + `flutter test` **73/73 green**

---

## Stage 3 Verification (pre-flight)

| Step | Command | Expectation | Result |
|------|---------|-------------|--------|
| Test | `flutter test` | 52/52 pass | **PASS** (Stage 3 baseline) |

---

## Stage 4 Work Log

### 1. Add dependencies

| Command | Expectation | Result |
|---------|-------------|--------|
| `flutter pub add crypto pointycastle encrypt geolocator flutter_secure_storage` | Resolve 5 packages | **PASS** |
| AndroidManifest `ACCESS_FINE_LOCATION` + `ACCESS_COARSE_LOCATION` | Permissions added | **PASS** |

### 2. TDD — write failing tests first

| File | Tests |
|------|-------|
| `test/unit/zone_threshold_test.dart` | day/night limits per zone |
| `test/unit/violation_evaluator_test.dart` | day/night/restricted-hour violations |
| `test/unit/evidence_packet_test.dart` | JSON round-trip, canonical payload, hash |
| `test/unit/crypto_test.dart` | SHA-256, ECDSA sign/verify, AES round-trip |
| `test/unit/gps_math_test.dart` | obfuscation + gps_hash |
| `test/unit/build_evidence_packet_test.dart` | use case assembly + signature verify |
| `test/unit/service_locator_test.dart` | extended for Stage 4 registrations |
| `test/fakes/fake_gps_service.dart` | GPS stub |
| `test/fakes/fake_signing_service.dart` | signing stub |
| `test/fakes/fake_key_store.dart` | in-memory secure storage |
| `test/fakes/fake_timestamp_service.dart` | fixed ISO/token |

### 3. Implementation

| Component | Path |
|-----------|------|
| ZoneType, ViolationResult, EvidencePacket | `lib/domain/models/` |
| Canonical JSON, GPS math | `lib/core/crypto/` |
| ZoneThresholdService | `lib/data/services/zone_threshold_service.dart` |
| ViolationEvaluator | `lib/data/services/violation_evaluator.dart` |
| TimestampService (local) | `lib/data/services/timestamp_service.dart` |
| GpsService + GeolocatorGpsService | `lib/data/services/gps_service.dart`, `geolocator_gps_service.dart` |
| KeyStore | `lib/data/services/key_store.dart` |
| EcdsaSigningService (secp256k1) | `lib/data/services/signing_service.dart` |
| AesEncryptionService | `lib/data/services/encryption_service.dart` |
| BuildEvidencePacketUseCase | `lib/domain/use_cases/build_evidence_packet_use_case.dart` |
| DI wiring | `lib/di/service_locator.dart` |
| Capture debug trigger | `CaptureViewModel` builds packet after capture |

### 4. Quality gate

| Command | Expectation | Result |
|---------|-------------|--------|
| `flutter analyze` | 0 errors/warnings (info OK) | **PASS** — 13 info lints |
| `flutter test` | All green | **PASS** — 73/73 |

### 5. Device run (SM M315F)

| Command | Expectation | Result |
|---------|-------------|--------|
| `flutter build apk --debug -d R58N66P4RBP` | APK builds with location permissions | **PASS** (~6 min Gradle) |
| `adb install -r build/app/outputs/flutter-apk/app-debug.apk` | Installs on R58N66P4RBP | **PASS** |

**Manual verification:** Open Capture tab → complete a recording → check debug log for `evidence` / `Packet built` with `hash_sha256` and obfuscated GPS. Grant location permission when prompted on first packet build.

### Errors / fixes

| Issue | Fix |
|-------|-----|
| `ViolationType.wireName` not in scope | Import `violation_result.dart` in use case |
| `DebugLogService.log` does not exist | Use `info()` with Map data |
| `fake_signing_service` const string multiply | Non-const default via constructor initializer |
| Unused imports (analyze warnings) | Removed from signing/encryption/service_locator_test |

---

## Deferred to Stage 5

- RFC 3161 TSA timestamp token + NTP
- `server_signature_ecdsa` countersignature
- Encrypted SQLite evidence queue (`EvidenceQueueRepository`)
- Full History/submit UI wiring
