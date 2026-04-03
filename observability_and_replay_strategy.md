# OBSERVABILITY AND REPLAY STRATEGY — DK PARKING ENGINE
## Version 1 — Phase 12 document
## Status: DONE
## Locked baseline date: 2026-04-03

---

## 1. Purpose

This document defines how the DK Parking Engine provides structured observability for debugging, quality monitoring, and (optionally) result replay — without compromising privacy or the on-device legal-decision boundary.

Observability must be sufficient to diagnose failures without pretending certainty.

---

## 2. Observability principles

1. **Structured over unstructured.** All observability output uses structured fields from `ParkingEvaluationResult` — not free-form logs or debug strings.
2. **No image data in observability output.** Camera frames, AR geometry, and point clouds are never part of any observability artifact.
3. **Every result is self-describing.** A `ParkingEvaluationResult` JSON contains all fields required to understand what happened, why, and under what conditions.
4. **Version refs on everything.** Every observability artifact includes SDK, policy, dataset, and model version refs.
5. **Replay must not re-evaluate.** A replay bundle is a read-only record of what happened. It must not be fed back into the engine as if it were a new evaluation.

---

## 3. Structured log levels

| Level | Usage |
|---|---|
| `INFO` | Session lifecycle (started, AR ready, evaluated, teardown) |
| `DEBUG` | Quality scores per frame, measurement details, error components (disabled in release builds by default) |
| `WARN` | Pre-composition gate fired, near-threshold zone entered, map-prior cap applied |
| `ERROR` | SDK not initialized when evaluate() called, measurement session returned nil, unexpected state |

All log events MUST include:
- `timestamp_utc`
- `session_id`
- `evaluation_id` (if in context of an evaluation)
- `sdk_version`

---

## 4. Session observability bundle

For every evaluation session (from `initialize()` to `teardown()`), the SDK maintains an in-memory session observability bundle:

```json
{
  "session_id": "UUID",
  "session_started_at": "ISO8601",
  "session_ended_at": "ISO8601",
  "sdk_version": "1.0.0",
  "policy_version": "PR-V1-001",
  "dataset_version": "REG-DK-001-2026.06.01-001",
  "dataset_region_id": "REG-DK-001",
  "model_version": "STUB-V1",
  "evaluation_count": 3,
  "refusal_count": 1,
  "quality_samples": [
    { "t": 0.0, "plane": 0.0, "scale": 0.2, "valid": false },
    { "t": 2.1, "plane": 0.71, "scale": 0.88, "valid": true }
  ],
  "evaluations": [
    { "evaluation_id": "UUID", "decision_state": "LEGAL_WITH_BUFFER", "confidence_score": 0.86 },
    { "evaluation_id": "UUID", "decision_state": "UNVERIFIABLE", "refusal_reasons": ["AR_SCALE_UNTRUSTED"] }
  ]
}
```

This bundle is held in memory only. It is NOT persisted to disk unless the user has opted into replay logging.

---

## 5. Result serialization (required for all results)

Every `ParkingEvaluationResult` MUST be serializable to JSON. The JSON form is the canonical observability artifact.

The JSON MUST be producible from the Swift `Codable` synthesis on `ParkingEvaluationResult`.

The JSON MUST include all fields including `VersionRefs`, even for UNVERIFIABLE results.

Example UNVERIFIABLE result JSON structure:
```json
{
  "evaluationId": "UUID",
  "timestamp": "2026-04-03T21:00:00Z",
  "decisionState": "UNVERIFIABLE",
  "refusalReasons": ["AR_SCALE_UNTRUSTED"],
  "ruleFamily": "pedestrian_crossing_5m",
  "measurement": null,
  "targetInfo": null,
  "featureCandidate": null,
  "captureQuality": {
    "focusScore": 1.0,
    "brightnessScore": 1.0,
    "arPlaneStabilityScore": 0.50,
    "arMetricScaleValid": false,
    "arMetricScaleScore": 0.40
  },
  "advisoryOutputs": [],
  "unsupportedVisibleRestrictionFlag": false,
  "limitationsNotice": "This app evaluates only specific supported Danish stopping and parking rules...",
  "versionRefs": {
    "sdkVersion": "1.0.0",
    "policyVersion": "PR-V1-001",
    "datasetVersion": "REG-DK-001-2026.06.01-001",
    "datasetRegionId": "REG-DK-001",
    "modelVersion": "STUB-V1",
    "legalSourceBaselineDate": "2026-03-25"
  }
}
```

---

## 6. Replay metadata bundle (opt-in only)

When the user enables replay logging (explicit opt-in), the app MAY persist the following per evaluation:

**Allowed:**
- Full `ParkingEvaluationResult` JSON
- Session observability bundle (quality samples, evaluation list)
- Timestamp and session ID

**Forbidden:**
- Camera frames or video
- Raw AR geometry (point clouds, meshes, plane anchor transforms beyond scalar scores)
- GPS or location data
- Any user identifier

Replay bundles are stored locally in the app's documents directory under `replay_logs/`.

The user MUST be able to:
- View the list of stored replay bundles.
- Delete individual bundles.
- Delete all replay bundles.
- Export a bundle (as JSON) for support purposes.

---

## 7. Crash trace schema

Crash traces MUST NOT contain:
- Camera frames
- AR geometry
- User identifiers
- GPS data

Crash traces MUST contain:
- SDK version, policy version, dataset version
- Last known `decision_state` before crash (if available)
- Last known session quality scores
- Exception type and stack trace (symbolicated)
- OS version and device model (non-identifying)

---

## 8. Support reference ID

Every `ParkingEvaluationResult` contains `evaluationId` (UUID). The first 8 characters are shown in the UI as the support reference ID.

Support triage MUST use the `evaluationId` to correlate:
- The result state and refusal reasons
- The version refs (which SDK, policy, dataset, model produced the result)
- The session quality scores at the time of evaluation

The support team MUST NOT ask users to reproduce the exact scene — the `evaluationId` and version refs are sufficient for the majority of support cases.

---

## 9. Observability dashboard requirements (future)

For a production monitoring dashboard (Phase 12+), the following metrics MUST be derivable from telemetry:

| Metric | Source field |
|---|---|
| Daily evaluation count | `EvaluationCompleted.timestamp_utc` |
| Decision state distribution | `EvaluationCompleted.decision_state` |
| Refusal rate | `decision_state == UNVERIFIABLE` / total |
| Near-threshold rate | `EvaluationCompleted.in_near_threshold_zone` |
| Refusal reason distribution | `EvaluationCompleted.refusal_reasons` |
| Confidence score distribution | `EvaluationCompleted.confidence_score` |
| AR quality distribution | `arMetricScaleScore`, `arPlaneStabilityScore` |
| Dataset version distribution | `EvaluationCompleted.dataset_version` |
| SDK version distribution | `EvaluationCompleted.sdk_version` |

---

## 10. Change control

Any change to observability fields, replay bundle schema, or crash trace contents requires:
1. Update to this file.
2. Review of `privacy_and_telemetry_spec.md` for consistency.
3. Entry in `WHAT_DID_I_DO.md`.
4. Update to `release_readiness_checklist.md`.
