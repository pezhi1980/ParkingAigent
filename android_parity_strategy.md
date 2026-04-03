# ANDROID PARITY STRATEGY — DK PARKING ENGINE
## Version 1 — Phase 14 document
## Status: DONE
## Locked baseline date: 2026-04-03

---

## 1. Purpose

This document defines the criteria, constraints, and strategy for adding Android as a second platform for the DK Parking Engine, without changing decision-state semantics, boundary semantics, or claim behavior established in the iOS Version 1.

Android development proceeds in parallel with iOS Version 1. Both platforms target simultaneous release.

---

## 2. Android launch gate

Android and iOS are developed in parallel (ROADMAP §7.1 scope change 2026-04-03). Both platforms must pass their respective gates before public release.

| Gate | Evidence required |
|---|---|
| Android vertical slice device run complete | `vertical_slice_report_android.md` §3–6 filled |
| Android field validation passed | `field_test_matrix_android.md` summary table complete |
| No active Android release blockers | `release_readiness_checklist.md` Android section checked |
| Cross-platform output equivalence verified | PC-007 synthetic geometry test passed for all 6 families |
| Cross-platform parity criteria met | All PC-001 through PC-010 verified |

---

## 3. Parity criteria (locked)

Android Version 1 MUST achieve parity with iOS Version 1 on the following:

| # | Criterion | Measurement |
|---|---|---|
| PC-001 | Same 5 decision states | `DecisionState` enum values identical |
| PC-002 | Same 9 refusal reason codes | `RefusalReasonCode` values identical |
| PC-003 | Same 6 supported rule families | `RuleFamily` enum values identical |
| PC-004 | Same locked legal thresholds | `LegalThresholds` values identical (5m, 10m, 12m, 0m) |
| PC-005 | Same `ParkingEvaluationResult` JSON schema | `OUTPUT_CONTRACT.md` compliance verified |
| PC-006 | Same policy parameters | `PolicyRegistry.v1Default` values identical |
| PC-007 | Cross-platform output equivalence on synthetic geometry | Same decision_state for identical input vectors |
| PC-008 | Same user-facing display labels | `user_disclosures_and_copy.md` §2.1 vocabulary |
| PC-009 | Same limitations notice text | `user_disclosures_and_copy.md` §6 locked text |
| PC-010 | Same per-family disclosure text | `user_disclosures_and_copy.md` §7 locked text |

---

## 4. Acceptable platform-specific deviations

The following differences between iOS and Android are acceptable and do not violate parity:

| Area | Acceptable deviation |
|---|---|
| AR framework | ARKit (iOS) vs. ARCore (Android) |
| AR quality scores | Different score distributions due to different AR framework implementations |
| Model packaging | Core ML (iOS) vs. TensorFlow Lite (Android); MAJOR version must match |
| UI framework | SwiftUI (iOS) vs. Jetpack Compose (Android) |
| Session quality thresholds | May be tuned per platform after validation, as a MINOR policy version bump |
| Error budget components | Platform-specific RSS components if ARCore measurement differs from ARKit |
| Minimum OS version | iOS 16+ vs. Android 9+ (API level 28+) |

---

## 5. ARCore acceptance criteria

ARCore is the Android equivalent of ARKit. Before Android can proceed, ARCore must meet:

| # | Criterion | Acceptance threshold |
|---|---|---|
| AC-001 | Metric scale accuracy | ARCore metric scale error ≤ ARKit metric scale error × 1.5 (on equivalent scenes) |
| AC-002 | Ground plane stability | ARCore plane stability score ≥ 0.70 achievable in outdoor scenes within 5 seconds |
| AC-003 | Perpendicular distance measurement | Measured distance error ≤ 0.25m (1σ) for distances 1–10m in good conditions |
| AC-004 | Low-light behavior | ARCore degrades gracefully and quality score drops below threshold — no false-positive scale |
| AC-005 | Multi-surface disambiguation | ARCore correctly identifies the ground plane in scenes with vertical surfaces nearby |

---

## 6. Model packaging strategy for Android

The on-device ML model(s) (vehicle footprint, boundary detection) must be packaged for Android using TensorFlow Lite:

1. iOS model (Core ML `.mlmodelc`) is the canonical source.
2. For Android, the model is converted to TFLite (`.tflite`) using the official CoreML-to-TFLite converter or re-trained with equivalent architecture.
3. The Android model MUST achieve ≥ 95% semantic agreement with the iOS model on the parity test dataset.
4. If agreement is < 95%, the Android model version is bumped and re-validated before release.
5. Model version format: `model-v1.0.0-android` (platform suffix added for Android-specific builds).

---

## 7. Test equivalence strategy

Android parity testing must cover:

### 7.1 Unit test equivalence
- All 3 iOS unit test suites must have Android equivalents:
  - `ConfidenceComposerTest` (Kotlin/JUnit)
  - `LegalEvaluatorTest` (Kotlin/JUnit)
  - `MeasurementBundleTest` (Kotlin/JUnit)
- All 7 guardrails from `validation_plan.md` must pass on Android.

### 7.2 Cross-platform synthetic geometry test
- For each of the 6 supported rule families, inject identical synthetic geometry vectors into both iOS and Android SDKs.
- Verify `decision_state` is identical for all 6 families.
- Verify `refusal_reasons` are identical for refusal scenarios.
- This test must pass 100% before Android release.

### 7.3 Field test equivalence
- Run at minimum 50% of `field_test_matrix.md` scenarios on Android device.
- All Category D (poor AR) and H (unsupported restrictions) scenarios must be retested on Android.
- Results recorded in a separate `field_test_matrix_android.md` file.

---

## 8. Cross-platform output compatibility rules

Per `VERSIONING_POLICY.md` §9.3:

1. `decision_state` and `refusal_reasons` MUST be semantically identical for identical geometry on both platforms.
2. `captureQuality` scores MAY differ between platforms (ARKit vs. ARCore).
3. `versionRefs.sdkVersion` MAJOR MUST match between platforms.
4. `versionRefs.policyVersion`, `versionRefs.datasetVersion`, and `versionRefs.legalSourceBaselineDate` are shared and MUST be identical.
5. The JSON schema of `ParkingEvaluationResult` MUST be identical between platforms (same field names, same types).

---

## 9. What Android work is explicitly out of scope for Version 1 parity

The following are NOT required for Android Version 1 parity and are deferred:

| Deferred item | Reason |
|---|---|
| New rule families not in iOS V1 | Parity requires same families first |
| New regions not in iOS V1 | Android uses the same REG-DK-001 dataset |
| Android-specific UI features beyond iOS V1 | Parity baseline first, Android-native UX enhancements in V1.1 |
| Android Watch / tablet optimization | Post-parity |
| Offline dataset sync (Android-specific) | Same dataset lifecycle as iOS — no Android-specific additions |

---

## 10. Change control

Any change to parity criteria, ARCore acceptance thresholds, or cross-platform compatibility rules requires:
1. Update to this file.
2. Update to `VERSIONING_POLICY.md` §9.
3. Update to `SDK_API_CONTRACT.md` §8.
4. Entry in `WHAT_DID_I_DO.md`.
5. Update to `TASKLIST_V4_FINAL.md`.
