# PRIVACY AND TELEMETRY SPEC — DK PARKING ENGINE
## Version 1 — Phase 12 document
## Status: DONE
## Locked baseline date: 2026-04-03

---

## 1. Purpose

This document defines what data the DK Parking Engine may collect, retain, transmit, and use in Version 1.

All telemetry design must comply with:
- GDPR (EU Regulation 2016/679) — applicable as Denmark is an EU member state
- Apple App Store privacy requirements (App Privacy nutrition label)
- The privacy principles in ROADMAP §25.4

---

## 2. Core privacy principles (locked)

1. **No hidden cloud legal-decision dependency.** All legal evaluations run entirely on-device. No camera frame, AR geometry, or partial result is sent to a server to complete a legal determination.
2. **No unnecessary frame retention by default.** Camera frames are processed in memory and not persisted to disk unless the user explicitly opts in to a debug or replay mode.
3. **Structured metadata preferred over raw image.** Telemetry events contain structured fields (distances, scores, reason codes, version refs) — not images or raw geometry.
4. **Clear disclosure when any artifact is stored.** If the user enables replay logging, the app must disclose what is stored and how to delete it.
5. **Version traceability for support and audit.** Every telemetry event must include VersionRefs (SDK, policy, dataset, model versions).

---

## 3. Telemetry minimum set

The following telemetry events are defined for Version 1. These are the MINIMUM required for support and audit.

### 3.1 EvaluationCompleted event

Emitted on every `ParkingEvaluationResult` — both non-UNVERIFIABLE and UNVERIFIABLE.

| Field | Type | Privacy level | Purpose |
|---|---|---|---|
| `event_type` | String = "evaluation_completed" | Public | Event identification |
| `evaluation_id` | UUID | Non-personal | Correlation ID |
| `timestamp_utc` | ISO8601 | Non-personal | Timing |
| `decision_state` | String | Non-personal | Result quality monitoring |
| `refusal_reasons` | [String] | Non-personal | Refusal pattern analysis |
| `rule_family` | String | Non-personal | Usage analytics |
| `confidence_score` | Float | Non-personal | Quality monitoring |
| `measured_distance_m` | Float (nullable) | Non-personal | Accuracy monitoring |
| `signed_margin_m` | Float (nullable) | Non-personal | Threshold distribution |
| `total_estimated_error_m` | Float (nullable) | Non-personal | Error budget monitoring |
| `boundary_provenance` | String | Non-personal | Provenance tier distribution |
| `ar_metric_scale_score` | Float | Non-personal | AR quality monitoring |
| `ar_plane_stability_score` | Float | Non-personal | AR quality monitoring |
| `in_near_threshold_zone` | Boolean | Non-personal | Near-threshold distribution |
| `sdk_version` | String | Non-personal | Version tracking |
| `policy_version` | String | Non-personal | Policy tracking |
| `dataset_version` | String | Non-personal | Dataset tracking |
| `dataset_region_id` | String | Non-personal | Region usage |
| `model_version` | String | Non-personal | Model tracking |
| `platform` | String = "ios" | Non-personal | Platform tracking |
| `os_version` | String | Non-personal | Compatibility monitoring |

**Forbidden fields in EvaluationCompleted:**
- No camera frame or image data
- No AR point cloud or mesh data
- No GPS coordinates
- No device identifier (IDFA, IDFV, serial)
- No user identifier

### 3.2 SessionStarted event

Emitted when the SDK is initialized and AR session starts.

| Field | Type | Privacy level |
|---|---|---|
| `event_type` | String = "session_started" | Public |
| `session_id` | UUID | Non-personal |
| `timestamp_utc` | ISO8601 | Non-personal |
| `sdk_version` | String | Non-personal |
| `policy_version` | String | Non-personal |
| `dataset_version` | String | Non-personal |
| `dataset_region_id` | String | Non-personal |
| `platform` | String | Non-personal |
| `os_version` | String | Non-personal |

### 3.3 RefusalExplainerShown event

Emitted when the UNVERIFIABLE result card is shown to the user.

| Field | Type | Privacy level |
|---|---|---|
| `event_type` | String = "refusal_explainer_shown" | Public |
| `evaluation_id` | UUID | Non-personal |
| `refusal_reasons` | [String] | Non-personal |
| `timestamp_utc` | ISO8601 | Non-personal |

### 3.4 SessionEnded event

Emitted on teardown.

| Field | Type | Privacy level |
|---|---|---|
| `event_type` | String = "session_ended" | Public |
| `session_id` | UUID | Non-personal |
| `evaluation_count` | Integer | Non-personal |
| `refusal_count` | Integer | Non-personal |
| `timestamp_utc` | ISO8601 | Non-personal |

---

## 4. What image data may or may not be retained

| Data type | Default behavior | User opt-in allowed? | Notes |
|---|---|---|---|
| Camera frames (raw) | NOT retained | No | Processed in memory only |
| AR point cloud | NOT retained | No | Used for measurement only, discarded |
| AR plane anchors | NOT retained | No | Used for quality scoring only |
| Structured telemetry events | Batched locally, sent on wifi | Yes (opt-out) | No PII |
| Replay metadata bundle | NOT retained by default | Yes — explicit opt-in only | Must disclose to user |
| Crash traces | Retained locally, sent with consent | Yes (opt-in) | No camera data in traces |

---

## 5. Replay-safe metadata definition

A replay metadata bundle (for debugging and improvement, opt-in only) may contain:

**Allowed:**
- `ParkingEvaluationResult` JSON (all fields, no image data)
- Session quality scores over time (float array)
- AR ground plane stability score over time (float array)
- Measurement error components
- Refusal reason codes and timestamps
- SDK + policy + dataset + model version refs

**Forbidden in replay bundle:**
- Camera frames or video
- Raw AR geometry (point clouds, meshes)
- GPS coordinates
- Any field that could identify the user or device

---

## 6. User disclosures

### 6.1 App Store privacy nutrition label categories (Version 1)

| Data category | Collected? | Linked to identity? | Used for tracking? |
|---|---|---|---|
| Usage data (evaluation counts, session counts) | Yes | No | No |
| Diagnostics (crash reports) | Yes (opt-in) | No | No |
| Camera | Yes (on-device only, not sent) | No | No |
| Location | No | — | — |
| Identifiers | No | — | — |

### 6.2 In-app privacy disclosure (required on first launch)

"DK Parking collects anonymous usage statistics to improve the product. No camera images, location data, or personal identifiers are collected or transmitted. All parking evaluations run entirely on your device — your camera images never leave your phone."

---

## 7. Privacy consent surface

Version 1 does NOT require explicit consent for telemetry if:
- All telemetry events contain only non-personal data as defined above.
- The App Store privacy nutrition label is accurate and complete.
- The in-app first-launch disclosure is shown.

If any telemetry field is added that could be personal or linked to identity, a consent surface MUST be added before that telemetry is emitted.

---

## 8. Emergency rollback behavior

If a dataset, policy, or model version is found to contain an error that could produce unsafe results:

1. A forced app update is issued with a corrected version bundle.
2. The SDK MUST check `datasetMaxValidityDays` (PR-010 = 180 days) and refuse to evaluate with an expired dataset.
3. If a remote kill-switch is implemented in a future version, it MUST NOT affect the on-device legal decision path — it may only disable telemetry or surface an update prompt.
4. No legal evaluation result may be silently voided or altered after the fact by a remote signal.

---

## 9. Change control

Any change to telemetry fields, privacy levels, retention policies, or consent requirements requires:
1. Update to this file.
2. Update to App Store privacy nutrition label declaration.
3. Entry in `WHAT_DID_I_DO.md`.
4. Update to `release_readiness_checklist.md`.
5. Legal/privacy review before shipping.
