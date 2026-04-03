# VERSIONING POLICY — DK PARKING ENGINE
## Version 1 — Phase 2 document
## Status: DONE
## Locked baseline date: 2026-04-03

---

## 1. Purpose

This document defines the versioning scheme for all versioned components in the DK Parking Engine product.

It governs:
- version number formats
- what triggers a version bump for each component
- compatibility rules between components
- how version references appear in outputs

---

## 2. Versioned components

| Component | Version ID in output | Version format | Controlled by |
|---|---|---|---|
| Region Dataset Bundle | `dataset_version` | `REGION_ID-YYYY.MM.DD-NNN` | Dataset Subsystem / Engineering Owner |
| On-device ML Model(s) | `model_version` | `model-vMAJOR.MINOR.PATCH` | Engineering Owner |
| Policy Registry | `policy_version` | `policy-vMAJOR.MINOR.PATCH` | Engineering Owner + Product Owner |
| SDK (Legal Evaluation Engine) | `sdk_version` | `sdk-vMAJOR.MINOR.PATCH` | Engineering Owner |
| App (iOS) | `app_version` | `app-vMAJOR.MINOR.PATCH` | Release Authority |
| Legal Source Baseline | `legal_source_baseline_date` | `YYYY-MM-DD` | Legal Source Owner |

---

## 3. Version format rules

### 3.1 SemVer-style components (model, policy, SDK, app)

Format: `component-vMAJOR.MINOR.PATCH`

| Segment | Increment when |
|---|---|
| MAJOR | Breaking change: removes or changes the meaning of a mandatory output field, changes the decision state vocabulary, changes the SDK input contract in a non-backward-compatible way, or changes the legal evaluation logic in a way that may produce different results for identical inputs |
| MINOR | Backward-compatible addition: adds new optional output fields, adds new advisory families, adds new refusal reason codes, or adjusts policy registry parameters with validation evidence |
| PATCH | Bug fix: corrects an implementation error without changing the contract or evaluation logic; includes documentation fixes |

### 3.2 Dataset bundle version

Format: `REGION_ID-YYYY.MM.DD-NNN`

- `REGION_ID`: the region identifier (e.g., `REG-DK-001`)
- `YYYY.MM.DD`: the publication date of the bundle
- `NNN`: a three-digit sequence number for same-day revisions (starting at `001`)

Example: `REG-DK-001-2026.06.01-001`

### 3.3 Legal source baseline date

Format: `YYYY-MM-DD`

This date represents the locked legal-source baseline used for this release.
It is updated only when a legal-source update has been reviewed, approved, and propagated per `legal_governance_strategy.md`.

---

## 4. Compatibility matrix rules (locked)

| SDK version | Dataset version | Policy version | Compatibility rule |
|---|---|---|---|
| sdk-v1.x.x | Any REG-DK-001-2026.x dataset with `min_sdk = sdk-v1.0.0` | policy-v1.x.x | Compatible if MAJOR matches across SDK and policy |
| sdk-v2.x.x | Any dataset with `min_sdk = sdk-v2.0.0` | policy-v2.x.x | New MAJOR — requires migration |

**Compatibility enforcement:**
- The dataset bundle MUST declare a `min_sdk_version` field.
- The SDK MUST refuse to initialize if its version is lower than `min_sdk_version` of the active dataset bundle.
- The policy registry MUST declare a `compatible_sdk_major` field.
- The SDK MUST refuse to initialize if the policy MAJOR version does not match the SDK MAJOR version.

---

## 5. What triggers a version bump

### 5.1 SDK MAJOR bump triggers
- Removing or renaming any field in the `ParkingEvaluationResult` output contract
- Changing the semantic meaning of any `DecisionState` enum value
- Changing the SDK initialization lifecycle in a non-backward-compatible way
- Changing the legal evaluation logic in a way that produces different results for identical inputs (including threshold changes from a legal-source update)

### 5.2 SDK MINOR bump triggers
- Adding new optional output fields to `ParkingEvaluationResult`
- Adding new refusal reason codes (non-breaking — callers that don't handle the new code fall through to `INSUFFICIENT_EVIDENCE_GENERAL` display)
- Adding support for a new rule family evaluator
- Updating on-device ML model (if the model change does not affect the output contract)

### 5.3 SDK PATCH bump triggers
- Fixing a calculation bug that was producing incorrect distances (requires validation evidence and release notes)
- Fixing a crash or stability issue
- Updating documentation or copy strings in the SDK bundle

### 5.4 Dataset bundle version bump triggers
- Adding new features to the region dataset
- Correcting feature positions or metadata
- Updating the legal-source baseline date for the region
- Expiring or retiring specific features

### 5.5 Policy version bump triggers
- Any change to a policy registry parameter value
- Adding or removing a policy parameter
- Changing the `compatible_sdk_major` field

### 5.6 Legal source baseline date update triggers
- A new controlling legal source is locked per `legal_governance_strategy.md`
- A NEEDS_LEGAL_REVIEW item is resolved and changes threshold or scope

---

## 6. Version references in output (mandatory)

Every `ParkingEvaluationResult` MUST include the full `VersionRefs` bundle (see `OUTPUT_CONTRACT.md` section 7).

The version references MUST reflect the actual components active at evaluation time.
Version references MUST NOT be hardcoded or defaulted to stale values.

---

## 7. Version traceability audit requirement

For every public release, the following MUST be traceable:
- which SDK version was shipped
- which policy version was bundled
- which dataset bundle version was active at launch
- which legal source baseline date applies
- which model version was shipped

This traceability MUST be preserved in release notes and in `WHAT_DID_I_DO.md`.

---

## 8. Change control

Any change to the versioning scheme (adding a new component, changing the format, changing compatibility rules) requires:
1. Update to this document.
2. Entry in `WHAT_DID_I_DO.md`.
3. Review of `SDK_API_CONTRACT.md`, `OUTPUT_CONTRACT.md`, and `POLICY_REGISTRY_SPEC.md` for consistency.
4. Update to `TASKLIST_V4_FINAL.md` if a new task or blocker arises.

---

## 9. Phase 14 — Android platform versioning addendum

### 9.1 Additional versioned component (Android)

| Component | Version ID in output | Version format | Controlled by |
|---|---|---|---|
| SDK (Android) | `sdk_version` | `sdk-vMAJOR.MINOR.PATCH` | Engineering Owner |
| App (Android) | `app_version` | `app-vMAJOR.MINOR.PATCH` | Release Authority |

### 9.2 Android versioning rules

- The Android SDK MUST use the same MAJOR version as the iOS SDK when both platforms are in production simultaneously.
- MAJOR version increments MUST be applied to both platforms simultaneously or the older-platform SDK must be retired.
- The policy version, dataset version, and legal source baseline date are SHARED between iOS and Android — they are platform-independent.
- The model version MAY differ between platforms (e.g., `model-v1.0.0-ios` vs `model-v1.0.0-android`) if the model is compiled separately, but the MAJOR version MUST match.

### 9.3 Cross-platform output compatibility rule

- A `ParkingEvaluationResult` produced by the iOS SDK and one produced by the Android SDK for identical inputs MUST produce semantically identical results (same `decision_state`, same `refusal_reasons`) when using the same policy version and dataset version.
- Platform-specific differences in `captureQuality` scores (due to ARKit vs. ARCore differences) are acceptable and expected.
- Any divergence in legal decision output between platforms for identical geometry MUST trigger a MAJOR version bump on the diverging platform.

### 9.4 Android launch gate

Android and iOS are developed in parallel (ROADMAP §7.1 scope change 2026-04-03). The Android SDK version MUST NOT be released until:
- Android vertical slice device run is complete (`vertical_slice_report_android.md` §3–6 filled).
- `android_parity_strategy.md` parity criteria PC-001 through PC-010 are all met.
- Cross-platform output equivalence is verified for all 6 supported rule families (PC-007).
- `release_readiness_checklist.md` Android section is completed.
- ARCore acceptance criteria AC-001 through AC-005 pass.
