# OUTPUT CONTRACT — DK PARKING ENGINE
## Version 1 — Phase 2 document
## Status: DONE
## Locked baseline date: 2026-04-03

---

## 1. Purpose

This document defines the complete structured output contract for the DK Parking Engine.

Every evaluation call MUST produce a `ParkingEvaluationResult` that satisfies this contract.

No field marked REQUIRED may be null or absent.
No field meaning may be silently changed.
No field may be added to the public output without a version bump and update to this document.

This contract is normative. All downstream consumers (app UI, agent layer, telemetry) MUST treat these fields as the authoritative result.

---

## 2. ParkingEvaluationResult — top-level structure

| Field | Type | Required | Description |
|---|---|---|---|
| `result_id` | UUID | REQUIRED | Unique identifier for this evaluation result (for telemetry and replay correlation) |
| `evaluation_timestamp` | ISO8601 Timestamp | REQUIRED | Timestamp of the evaluation attempt |
| `decision_state` | DecisionState (enum) | REQUIRED | The evaluated decision state (see section 3) |
| `refusal_reasons` | List\<RefusalReason\> | REQUIRED | Empty list if not UNVERIFIABLE; one or more reason codes if UNVERIFIABLE |
| `rule_family` | RuleFamilyID | REQUIRED | The evaluated rule family (e.g., `pedestrian_crossing_5m`) |
| `measurement` | MeasurementBundle | CONDITIONAL | REQUIRED when decision_state is not UNVERIFIABLE; may be null if UNVERIFIABLE |
| `target_info` | TargetInfo | REQUIRED | Information about the evaluated target vehicle |
| `feature_candidate_info` | FeatureCandidateInfo | CONDITIONAL | REQUIRED when a candidate was matched; null if no candidate was reached |
| `capture_quality` | CaptureQualityBundle | REQUIRED | Capture quality scores at the time of evaluation |
| `unsupported_visible_restriction_flag` | Boolean | REQUIRED | True if a visible but unsupported restriction was detected or suspected |
| `limitations_notice` | String | REQUIRED | The applicable limitations notice text (from `user_disclosures_and_copy.md`) |
| `version_refs` | VersionRefs | REQUIRED | All version references (see section 7) |
| `advisory_outputs` | List\<AdvisoryOutput\> | REQUIRED | Empty list if no advisory families were evaluated; list entries for advisory results |

---

## 3. DecisionState (enum — locked)

| Value | Meaning |
|---|---|
| `ILLEGAL` | Strong evidence of violation of the evaluated supported rule family |
| `PROBABLY_ILLEGAL` | Evidence points toward violation, uncertainty too high for ILLEGAL |
| `UNVERIFIABLE` | Cannot safely determine the result; one or more refusal reasons apply |
| `PROBABLY_LEGAL` | Evidence points toward compliance, uncertainty too high for LEGAL_WITH_BUFFER |
| `LEGAL_WITH_BUFFER` | Sufficient evidence of compliance with measurable margin relative to uncertainty |

State semantics are locked in `DECISION_STATES.md`. This enum MUST match exactly.

---

## 4. MeasurementBundle — measurement details

Required when `decision_state` is not UNVERIFIABLE.

| Field | Type | Required | Description |
|---|---|---|---|
| `measured_distance_m` | Float | CONDITIONAL | Ground-plane distance in metres from vehicle footprint to legal boundary; null for overlap-only evaluations |
| `overlap_detected` | Boolean | CONDITIONAL | True if vehicle footprint overlaps prohibited zone; null for distance-only evaluations |
| `legal_threshold_m` | Float | CONDITIONAL | The applicable legal threshold in metres; null for overlap-only evaluations |
| `signed_margin_m` | Float | CONDITIONAL | Positive = clearance; negative = violation; null if not applicable |
| `total_estimated_error_m` | Float | REQUIRED (when measurement present) | Estimated total measurement error budget in metres |
| `confidence_score` | Float [0.0–1.0] | REQUIRED (when measurement present) | Overall confidence score for this measurement |
| `measurement_reference_type` | String | REQUIRED (when measurement present) | What was measured against (e.g., `crossing_approach_boundary`, `transverse_edge`, `bus_stop_sign_12m`, `marked_segment`) |
| `boundary_provenance` | String | REQUIRED (when measurement present) | How the legal boundary was localized (e.g., `visual_detection`, `map_prior_assisted`, `map_prior_only`) |
| `vehicle_edge_used` | String | REQUIRED (when measurement present) | Which vehicle edge was used as the measurement reference (e.g., `front_edge`, `rear_edge`, `nearest_edge`) |

---

## 5. TargetInfo — target vehicle information

| Field | Type | Required | Description |
|---|---|---|---|
| `target_id` | TargetID | REQUIRED | Identifier of the confirmed active target vehicle |
| `target_confirmation_source` | String | REQUIRED | How the target was confirmed: `user_confirmed`, `auto_selected_unambiguous` |
| `footprint_quality_score` | Float [0.0–1.0] | REQUIRED | Quality score for the vehicle footprint geometry |
| `partial_occlusion_detected` | Boolean | REQUIRED | True if the vehicle edge used for measurement was partially occluded |

---

## 6. FeatureCandidateInfo — candidate feature information

Required when a feature candidate was matched (i.e., when evaluation reached the feature matching step).

| Field | Type | Required | Description |
|---|---|---|---|
| `candidate_feature_id` | FeatureID | REQUIRED | ID of the matched candidate feature from the dataset |
| `candidate_feature_type` | String | REQUIRED | Type of feature (e.g., `pedestrian_crossing`, `intersection`, `bus_stop`) |
| `candidate_selection_basis` | String | REQUIRED | How the candidate was selected (e.g., `nearest_map_feature`, `visual_confirmation_assisted`) |
| `alternative_candidates_rejected` | Integer | REQUIRED | Number of alternative candidates that were considered and rejected |
| `candidate_confidence_score` | Float [0.0–1.0] | REQUIRED | Confidence score for the selected candidate |

---

## 7. VersionRefs — version references (mandatory on all results)

| Field | Type | Required | Description |
|---|---|---|---|
| `dataset_version` | VersionString | REQUIRED | Version of the active region dataset bundle |
| `dataset_region_id` | RegionID | REQUIRED | The active region identifier |
| `model_version` | VersionString | REQUIRED | Version of the on-device ML model(s) used |
| `policy_version` | VersionString | REQUIRED | Version of the policy registry configuration |
| `sdk_version` | VersionString | REQUIRED | Version of the parking engine SDK |
| `legal_source_baseline_date` | DateString | REQUIRED | The legal-source baseline date for the active dataset |

---

## 8. CaptureQualityBundle — capture quality at evaluation time

| Field | Type | Required | Description |
|---|---|---|---|
| `focus_score` | Float [0.0–1.0] | REQUIRED | Camera focus quality score |
| `brightness_score` | Float [0.0–1.0] | REQUIRED | Scene brightness quality score |
| `ar_plane_stability_score` | Float [0.0–1.0] | REQUIRED | AR ground-plane stability score |
| `ar_metric_scale_valid` | Boolean | REQUIRED | True if metric scale was considered valid for this evaluation |

---

## 9. AdvisoryOutput — advisory-first family outputs

For each advisory-first family evaluated (e.g., `driveway_obstruction`):

| Field | Type | Required | Description |
|---|---|---|---|
| `advisory_family` | String | REQUIRED | The advisory family name (e.g., `driveway_obstruction`) |
| `advisory_state` | String | REQUIRED | `ADVISORY_CONCERN` or `ADVISORY_NO_CONCERN_DETECTED` |
| `advisory_label` | String | REQUIRED | Must include the word "advisory" — used for display |
| `advisory_notes` | String | OPTIONAL | Additional context for the advisory result |

Advisory outputs MUST NOT use the DecisionState enum values. They MUST use advisory-specific state labels only.

---

## 10. Unsupported visible restriction behavior

When `unsupported_visible_restriction_flag = true`:
- `decision_state` MUST be downgraded to UNVERIFIABLE if the restriction materially affects clearance for the evaluated family
- `refusal_reasons` MUST include `VISIBLE_UNSUPPORTED_RESTRICTION`
- The app MUST surface the unsupported restriction warning (see `user_disclosures_and_copy.md` section 8)
- A positive result MUST NOT be presented if this flag is true and the restriction risk is material

---

## 11. Output serialization obligations

- Every `ParkingEvaluationResult` MUST be serializable to JSON for telemetry and replay.
- Version references MUST be included in every serialized result.
- Null values for CONDITIONAL fields MUST be explicitly null (not absent) in the serialized form.

---

## 12. Change control

Any change to:
- required fields or their types
- the DecisionState enum values
- the meaning of any field
- the VersionRefs structure

requires:
1. Update to this document.
2. Entry in `WHAT_DID_I_DO.md`.
3. SDK version bump per `VERSIONING_POLICY.md`.
4. Review of `SDK_API_CONTRACT.md` and `SYSTEM_ARCHITECTURE.md` for consistency.
5. Update to `TASKLIST_V4_FINAL.md` if a new task or blocker arises.
