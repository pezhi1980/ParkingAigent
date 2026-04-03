# FEATURE CANDIDATE MATCHING STRATEGY — DK PARKING ENGINE
## Version 1 — Phase 7 document
## Status: DONE
## Locked baseline date: 2026-04-03

---

## 1. Purpose

This document defines how the engine selects a candidate feature from the dataset for each evaluation.

It governs:
- the candidate search radius per family
- candidate ranking and selection rules
- what happens when multiple candidates qualify (ambiguity)
- what happens when zero candidates qualify
- candidate confidence score computation
- the determinism requirement

---

## 2. Determinism requirement (locked, non-negotiable)

For identical inputs (same vehicle position, same AR frame, same dataset version, same policy version), the candidate matching MUST produce the same result.

The matching algorithm MUST NOT use random tie-breaking, non-deterministic sorting, or any input that varies across runs for the same scene.

If a tie cannot be resolved deterministically, the result MUST be ambiguity refusal — not an arbitrary pick.

---

## 3. Candidate search

### 3.1 Search center
The search center is the **projected vehicle footprint centroid** on the AR ground plane.

### 3.2 Search radius per family

| Rule Family | Primary search radius | Extended radius (if zero candidates at primary) |
|---|---|---|
| `pedestrian_crossing_5m` | 15m | 25m (once; if still zero → refusal) |
| `cycle_path_exit_5m` | 15m | 25m (once) |
| `intersection_10m` | 25m | 40m (once) |
| `bus_stop_12m_fallback` / `bus_stop_marked_segment` | 25m | 40m (once) |
| `direct_prohibited_surfaces` | 10m | 15m (once) |

Maximum search radius is also bounded by `POLICY_REGISTRY_SPEC.md` PR-009 (`max_candidate_search_radius_m`, default 50m).

### 3.3 Candidate eligibility filter
A feature is eligible as a candidate if:
- `feature_type` matches the required family type
- `is_active = true`
- the feature geometry is within the search radius
- `candidate_confidence_score` > 0.0 (zero-confidence features are not eligible)

---

## 4. Candidate ranking (within eligible set)

Candidates are ranked by a composite score:

```
rank_score = (0.60 × candidate_confidence_score) + (0.40 × proximity_score)
```

Where:
- `candidate_confidence_score` is the dataset feature quality score from `feature_schema_spec.md`
- `proximity_score = 1.0 - (distance_to_vehicle_centroid / search_radius)` (normalized, clamped to [0.0, 1.0])

The candidate with the **highest `rank_score`** is selected as the primary candidate.

---

## 5. Ambiguity rules

### 5.1 Ambiguity definition
Ambiguity exists when two or more candidates have `rank_score` values within **0.10** of the top-ranked candidate's score.

### 5.2 Ambiguity resolution attempts (ordered)
1. **Visual disambiguation**: If the boundary localization subsystem can visually confirm which candidate's feature is present in the frame (e.g., only one crossing is visible), select the visually confirmed candidate. Record `alternative_candidates_rejected` count in `FeatureCandidateInfo`.
2. **Confidence tiebreak**: If one candidate has `candidate_confidence_score` ≥ 0.20 higher than the other, select the higher-confidence candidate.
3. **Proximity tiebreak**: If candidates are equidistant within 0.5m and confidence is equal, select the nearer candidate.

### 5.3 Unresolvable ambiguity → mandatory refusal
If none of the above resolve the ambiguity:
- return UNVERIFIABLE with `FEATURE_CANDIDATE_AMBIGUOUS`
- record `alternative_candidates_rejected = 0` (no selection was made)

The engine MUST NOT guess when ambiguity is unresolvable.

---

## 6. Zero candidates → mandatory refusal

If zero eligible candidates are found within the extended search radius:
- return UNVERIFIABLE with `BOUNDARY_UNRESOLVED`
- do not attempt any further fallback (no hardcoded distances, no centerline inference)

---

## 7. Candidate confidence score computation

The `candidate_confidence_score` stored in the dataset is the baseline. During matching, it may be adjusted:

| Adjustment | Condition | Effect |
|---|---|---|
| Visual confirmation boost | Boundary localization confirms the feature visually (tier 1 or 2) | +0.10 (cap at 1.0) |
| Staleness penalty | `last_verified_date` > 12 months before evaluation | −0.10 |
| LOW accuracy class penalty | `geometry_accuracy_class = LOW` | −0.20 (if not already reflected in dataset score) |
| Extended radius penalty | Candidate found only at extended radius, not primary | −0.05 |

The adjusted score is stored as `FeatureCandidateInfo.candidate_confidence_score` in the output.

---

## 8. FeatureCandidateInfo output fields

The matching step populates `FeatureCandidateInfo` in the output:

| Field | Value |
|---|---|
| `candidate_feature_id` | The selected dataset feature ID |
| `candidate_feature_type` | The feature type enum value |
| `candidate_selection_basis` | One of: `nearest_map_feature`, `visual_confirmation_assisted`, `visual_confirmation_primary` |
| `alternative_candidates_rejected` | Count of other eligible candidates not selected |
| `candidate_confidence_score` | The adjusted candidate confidence score |

---

## 9. Multi-family evaluation sessions

Each evaluation call targets one rule family at a time.
If the user or app requests evaluation of multiple families in the same scene, each family is evaluated as a separate call with its own candidate matching cycle.
Results for different families MUST NOT share candidate state.

---

## 10. Change control

Any change to:
- search radii
- ranking formula or weights
- ambiguity thresholds
- confidence adjustment rules

requires:
1. Update to this document.
2. Entry in `WHAT_DID_I_DO.md`.
3. Review of `legal_boundary_localization_strategy.md` and `OUTPUT_CONTRACT.md` for consistency.
4. Engineering Owner approval; validation evidence required for threshold changes.
5. Policy registry update if PR-009 is adjusted.
6. Update to `TASKLIST_V4_FINAL.md` if a new task or blocker arises.
