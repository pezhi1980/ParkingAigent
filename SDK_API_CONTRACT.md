# SDK API CONTRACT — DK PARKING ENGINE
## Version 1 — Phase 2 document
## Status: DONE
## Locked baseline date: 2026-04-03

---

## 1. Purpose

This document defines the stable public API contract for the DK Parking Engine SDK.

The SDK is the productized module that owns the legal decision path.

This contract defines:
- the SDK lifecycle (init, evaluate, teardown)
- the input contract (what the caller must provide)
- the output contract reference (see `OUTPUT_CONTRACT.md` for full field definitions)
- failure and refusal behavior
- versioning and compatibility obligations
- what the SDK guarantees and what it does not guarantee

Any change to a public API element requires a version bump per `VERSIONING_POLICY.md` and an update to this file.

---

## 2. SDK lifecycle

### 2.1 Initialization

The SDK MUST be initialized before any evaluation can proceed.

**Initialization inputs:**
- active region dataset bundle (loaded by the Dataset Subsystem)
- policy registry configuration (loaded by the Policy Registry)
- platform AR session handle (ARKit session reference on iOS)

**Initialization outputs:**
- `SDKInitResult` with one of:
  - `READY`: all required components loaded and validated
  - `NO_DATASET`: no active region dataset is available
  - `POLICY_VERSION_MISMATCH`: policy version incompatible with dataset
  - `AR_SESSION_UNAVAILABLE`: AR session could not be established
  - `INIT_FAILED_GENERAL`: unrecoverable initialization failure

**Initialization rules:**
- The SDK MUST NOT proceed to evaluation if `SDKInitResult` is not `READY`.
- The app MUST surface the appropriate user-facing message for each non-READY result.
- Re-initialization is allowed after resolving the blocking condition.

### 2.2 Evaluation

A single evaluation call processes one captured scene and returns one structured result.

**Evaluation inputs (see section 3 — Input Contract):**
- one camera frame (or frame sequence for stability)
- AR frame metadata (ground plane, metric transform)
- confirmed target vehicle identifier (from target selection)
- active region identifier

**Evaluation outputs:**
- one `ParkingEvaluationResult` per call (see `OUTPUT_CONTRACT.md`)

**Evaluation rules:**
- one evaluation call processes exactly one active target vehicle
- the SDK MUST NOT produce multiple legal results for multiple vehicles in one call
- the SDK MUST produce a result (including UNVERIFIABLE) for every evaluation call — it MUST NOT silently fail
- evaluation MUST complete entirely on-device — no network requests are made during evaluation

### 2.3 Teardown

The SDK MUST provide a teardown call that:
- releases AR session references
- flushes pending telemetry to local storage
- frees dataset caches

Teardown is required when the app moves to background or the user ends the parking check session.

---

## 3. Input contract

| Field | Type | Required | Description |
|---|---|---|---|
| `camera_frame` | Frame | REQUIRED | The current camera frame to evaluate |
| `ar_frame_metadata` | ARFrameMetadata | REQUIRED | Ground plane transform, metric scale validity indicator, plane stability score |
| `confirmed_target_id` | TargetID | REQUIRED | The identifier of the confirmed active target vehicle from target selection |
| `active_region_id` | RegionID | REQUIRED | The active region dataset region identifier |
| `capture_quality_indicators` | CaptureQuality | REQUIRED | Pre-computed capture quality scores (focus, brightness) from SS-01 |
| `evaluation_timestamp` | Timestamp | REQUIRED | Timestamp of the evaluation attempt (for telemetry and replay) |
| `policy_version` | VersionString | REQUIRED | The policy version currently loaded by the Policy Registry |

**Input contract rules:**
- All REQUIRED fields MUST be present. If any is missing, the SDK MUST return UNVERIFIABLE with `INSUFFICIENT_EVIDENCE_GENERAL`.
- The `ar_frame_metadata` validity indicator MUST be checked by the SDK before using metric geometry. If invalid, the SDK returns `AR_SCALE_UNTRUSTED`.
- The `confirmed_target_id` MUST reference a target that was confirmed by the user (or selected unambiguously by the target selection subsystem). The SDK MUST NOT silently re-select a different target.

---

## 4. Output contract reference

The full output contract is defined in `OUTPUT_CONTRACT.md`.

The SDK MUST produce a `ParkingEvaluationResult` that satisfies the OUTPUT_CONTRACT.md schema for every evaluation call.

The SDK MUST NOT produce partial results, null fields that are marked REQUIRED in OUTPUT_CONTRACT.md, or results without version references.

---

## 5. Failure and refusal behavior

### 5.1 Refusal is correct behavior

The SDK MUST return UNVERIFIABLE (with structured reason code) rather than forcing a legal determination when evidence is insufficient.

Refusal MUST NOT be treated as an SDK error by the caller.

### 5.2 SDK errors vs. refusals

| Condition | SDK response |
|---|---|
| Evidence insufficient for safe evaluation | `ParkingEvaluationResult` with `decision_state = UNVERIFIABLE` and appropriate `refusal_reason` |
| Missing required input field | `ParkingEvaluationResult` with `decision_state = UNVERIFIABLE` and `refusal_reason = INSUFFICIENT_EVIDENCE_GENERAL` |
| SDK not initialized | `SDKError.NOT_INITIALIZED` (exception / error result — distinct from ParkingEvaluationResult) |
| Unrecoverable internal error | `SDKError.INTERNAL_ERROR` with error code — the caller MUST treat this as a session-level failure and re-initialize |

### 5.3 No silent failures

The SDK MUST NOT:
- return a null result
- return a result without a decision state
- swallow errors silently
- produce a positive legal result from a failed evaluation

---

## 6. Agent layer boundary (re-stated for SDK consumers)

The SDK (SS-05 + SS-06 + SS-07) is the legal decision path owner.

The caller (app + agent layer) MUST NOT:
- modify the `decision_state` field of the returned result
- suppress or alter `refusal_reason` codes
- infer legal conclusions from raw SDK internals
- bypass the evaluation call and compute legality from image data directly

The agent/explainer layer receives the finalized `ParkingEvaluationResult` as a read-only input for explanation purposes only.

---

## 7. Versioning and compatibility

The SDK is versioned per `VERSIONING_POLICY.md`.

**Backward compatibility obligations:**
- Minor SDK version increments MUST NOT remove mandatory output fields.
- Minor SDK version increments MUST NOT change the semantic meaning of decision states.
- Major SDK version increments may change the API contract; migration guidance is required.

**Version mismatch behavior:**
- If the app ships an SDK version that is incompatible with the loaded dataset bundle version, the SDK MUST refuse to initialize with `POLICY_VERSION_MISMATCH`.
- The app MUST surface a user-visible update prompt in this case.

---

## 8. Platform-specific notes (Version 1 — iOS)

- The SDK is packaged as a Swift module (XCFramework or Swift Package).
- ARKit session management is the responsibility of the app; the SDK receives the session handle at init.
- On-device ML model inference (target detection, segmentation) is invoked by the SDK via Core ML.
- The SDK MUST NOT request camera permissions directly — the app manages permissions and passes frames to the SDK.

---

## 9. Platform-specific notes (Version 2 — Android, Phase 14)

Android and iOS are developed in parallel (ROADMAP §7.1 scope change 2026-04-03). The following applies to the Android SDK:

- The Android SDK is packaged as an Android Library (`.aar`) or Maven artifact.
- ARCore session management is the responsibility of the app; the SDK receives the ARCore session handle at init.
- On-device ML model inference is invoked via TensorFlow Lite (`.tflite` model).
- The SDK MUST NOT request camera permissions directly — the app manages permissions.
- The Android SDK MUST implement the same `SDKInitResult`, `EvaluationInput`, and `ParkingEvaluationResult` contracts as the iOS SDK, with platform-idiomatic naming (camelCase Kotlin).
- The Android SDK JSON output schema MUST be byte-for-byte compatible with the iOS SDK JSON output schema for equivalent inputs.

### 9.1 Android API contract changes from iOS

| Contract area | iOS | Android |
|---|---|---|
| AR framework | ARKit (`ARFrame`, `ARPlaneAnchor`) | ARCore (`Frame`, `Plane`) |
| ML runtime | Core ML | TensorFlow Lite |
| Packaging | Swift Package / XCFramework | Android Library (.aar) |
| Minimum OS | iOS 16+ | Android 9+ (API 28+) |
| Concurrency | Swift async / MainActor | Kotlin Coroutines / Main thread |

### 9.2 Cross-platform compatibility guarantee

The Android SDK MUST satisfy all parity criteria defined in `android_parity_strategy.md` §3 (PC-001 through PC-010) before public release. Any violation of these criteria is a release blocker for Android.

---

## 10. Change control

Any change to:
- the input contract
- the initialization lifecycle
- the failure/refusal behavior contract
- the versioning and compatibility obligations

requires:
1. Update to this document.
2. Entry in `WHAT_DID_I_DO.md`.
3. Review of `OUTPUT_CONTRACT.md` and `SYSTEM_ARCHITECTURE.md` for consistency.
4. Version bump per `VERSIONING_POLICY.md`.
5. Update to `TASKLIST_V4_FINAL.md` if a new task or blocker arises.
