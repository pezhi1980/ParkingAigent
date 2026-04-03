# UNCERTAINTY AND CONFIDENCE STRATEGY — DK PARKING ENGINE
## Version 1 — Phase 8 document
## Status: DONE
## Locked baseline date: 2026-04-03

---

## 1. Purpose

This document defines how uncertainty is measured, composed, and translated into decision states and refusal for Version 1.

It governs:
- the individual evidence quality scores and their sources
- how scores are composed into the overall `confidence_score`
- how `confidence_score` + `signed_margin_m` + error budget determine the reachable decision state
- the near-threshold zone behavior
- all refusal escalation rules
- the refusal-first principle

This document is the authoritative gate document for the evaluation path. A reader should be able to look at any combination of inputs and derive the exact decision state.

---

## 2. Refusal-first principle (locked, non-negotiable)

When evidence is insufficient to safely determine the result, the engine MUST refuse (UNVERIFIABLE) rather than:
- guessing
- silently downgrading to a lower-confidence state
- averaging conflicting signals
- using prior expectations as a substitute for missing evidence

Refusal is **correct behavior**, not a failure. The UI and agent layer MUST communicate it as such.

---

## 3. Individual evidence quality scores

These scores are computed before the confidence composition step:

| Score | Source | Range | Description |
|---|---|---|---|
| `ar_plane_stability_score` | AR Measurement (SS-02) | [0.0–1.0] | Ground-plane stability (from `ar_measurement_strategy.md`) |
| `ar_metric_scale_score` | AR Measurement (SS-02) | [0.0–1.0] | Metric scale validity (from `ar_measurement_strategy.md`) |
| `footprint_quality_score` | Target Selection (SS-03) | [0.0–1.0] | Vehicle footprint edge quality (from `vehicle_footprint_strategy.md`) |
| `candidate_confidence_score` | Candidate Matching (SS-05) | [0.0–1.0] | Dataset feature quality + visual confirmation (from `feature_candidate_matching_strategy.md`) |
| `boundary_localization_score` | Boundary Localization (SS-05) | [0.0–1.0] | Derived from provenance tier: visual_detection=0.90, map_prior_assisted=0.70, map_prior_only=0.50 |
| `measurement_error_budget_score` | AR Measurement (SS-02) | [0.0–1.0] | Derived from `total_estimated_error_m`: score = max(0, 1.0 - (total_estimated_error_m / 2.0)) |

---

## 4. Confidence score composition

The overall `confidence_score` is a weighted geometric mean of the individual scores:

```
confidence_score = (
  ar_plane_stability_score ^ 0.15  ×
  ar_metric_scale_score    ^ 0.20  ×
  footprint_quality_score  ^ 0.20  ×
  candidate_confidence_score ^ 0.20 ×
  boundary_localization_score ^ 0.15 ×
  measurement_error_budget_score ^ 0.10
) ^ (1 / 1.00)
```

(Sum of exponents = 1.00; geometric mean weighted by exponents.)

**Critical property:** A single score of 0.0 drives `confidence_score` to 0.0, ensuring that a complete failure in any dimension cannot be hidden by high scores elsewhere.

The `confidence_score` is stored in `MeasurementBundle.confidence_score` in the output.

---

## 5. Pre-composition refusal gates (MUST be checked before composition)

These gates are checked BEFORE computing the confidence score.
If any gate fails, the evaluation returns UNVERIFIABLE immediately — the composition step is skipped.

| Gate | Failure condition | Refusal reason |
|---|---|---|
| AR metric scale validity | `ar_metric_scale_valid = false` OR `ar_metric_scale_score` < PR-007 threshold | `AR_SCALE_UNTRUSTED` |
| AR plane stability | `ar_plane_stability_score` < PR-006 threshold | `PLANE_UNSTABLE` |
| Target edge quality | `partial_occlusion_detected = true` AND `footprint_quality_score` < PR-008 threshold | `TARGET_EDGE_OCCLUDED` |
| Candidate found | Zero eligible candidates after extended search | `BOUNDARY_UNRESOLVED` |
| Candidate ambiguity | Unresolvable ambiguity in candidate matching | `FEATURE_CANDIDATE_AMBIGUOUS` |
| Unsupported restriction | `unsupported_visible_restriction_flag = true` AND restriction materially affects result | `VISIBLE_UNSUPPORTED_RESTRICTION` |
| Measurement error absolute cap | `total_estimated_error_m` > 2.0m | `INSUFFICIENT_EVIDENCE_GENERAL` |

---

## 6. Decision state transition rules (post-composition)

After the confidence score is computed and all pre-composition gates pass, the decision state is determined by:

### Step 1: Near-threshold zone check
```
in_near_threshold_zone = (|signed_margin_m| < total_estimated_error_m + 0.30)
```
(The 0.30m value is PR-004 from `POLICY_REGISTRY_SPEC.md`.)

### Step 2: State selection matrix

| `signed_margin_m` | `in_near_threshold_zone` | `confidence_score` | Decision State |
|---|---|---|---|
| strongly positive (≥ threshold) | false | ≥ PR-002 (0.80) | `LEGAL_WITH_BUFFER` |
| positive | true (near threshold) | any | `PROBABLY_LEGAL` |
| positive | false | < PR-002 | `PROBABLY_LEGAL` |
| negative | true (near threshold) | any | `PROBABLY_ILLEGAL` |
| negative | false | ≥ PR-003 (0.80) | `ILLEGAL` |
| negative | false | < PR-003 | `PROBABLY_ILLEGAL` |
| cannot compute | — | — | `UNVERIFIABLE` (`INSUFFICIENT_EVIDENCE_GENERAL`) |

**Overlap-only evaluations (direct_prohibited_surfaces):**

| `overlap_detected` | `confidence_score` | Decision State |
|---|---|---|
| true | ≥ PR-003 | `ILLEGAL` |
| true | < PR-003 | `PROBABLY_ILLEGAL` |
| false | ≥ PR-002 | `LEGAL_WITH_BUFFER` |
| false | < PR-002 | `PROBABLY_LEGAL` |
| cannot compute | — | `UNVERIFIABLE` |

---

## 7. Post-composition refusal escalation rules

These rules are checked AFTER the state is selected. They may escalate a state to UNVERIFIABLE:

| Rule | Condition | Effect |
|---|---|---|
| Map-prior-only hard positive cap | `boundary_provenance = map_prior_only` AND state = `LEGAL_WITH_BUFFER` | Downgrade to `PROBABLY_LEGAL` (not UNVERIFIABLE; documented downgrade) |
| Map-prior-only hard negative cap | `boundary_provenance = map_prior_only` AND state = `ILLEGAL` | Downgrade to `PROBABLY_ILLEGAL` (documented downgrade) |
| Confidence floor near zero | `confidence_score` < 0.30 (regardless of margin) | Escalate to UNVERIFIABLE (`INSUFFICIENT_EVIDENCE_GENERAL`) |
| Positive result with unsupported restriction | `unsupported_visible_restriction_flag = true` AND `PR-005 = true` AND result is positive | Escalate to UNVERIFIABLE (`VISIBLE_UNSUPPORTED_RESTRICTION`) |

---

## 8. Uncertainty sources must not mask each other

The geometric mean composition (section 4) is specifically designed to prevent masking.

Implementation MUST NOT:
- use an arithmetic average of scores (allows high scores to mask a near-zero score)
- drop any individual score from the composition
- substitute a missing score with 1.0 (treat missing data as perfect data)
- cap `confidence_score` below what the composition produces (artificial inflation)

If a score cannot be computed (e.g., boundary localization was not attempted), the score for that dimension MUST be set to 0.0, which drives `confidence_score` to 0.0 and triggers the post-composition refusal escalation rule.

---

## 9. Confidence score and decision state in the output

- `MeasurementBundle.confidence_score`: the composed confidence score (section 4)
- `ParkingEvaluationResult.decision_state`: the final decision state after all rules (sections 5–7)
- `ParkingEvaluationResult.refusal_reasons`: list of reason codes if `decision_state = UNVERIFIABLE`

The output MUST reflect the actual decision state produced by this strategy. The agent layer and UI MUST NOT alter `decision_state` or `confidence_score`.

---

## 10. Worked examples

### Example A: Clear LEGAL_WITH_BUFFER
- `signed_margin_m = +1.8m`, threshold = 5m → vehicle is 6.8m from boundary
- `total_estimated_error_m = 0.35m`
- `|signed_margin_m| = 1.8m` >> `0.35 + 0.30 = 0.65m` → NOT in near-threshold zone
- All scores: plane=0.92, scale=0.88, footprint=0.85, candidate=0.80, boundary=0.90 (visual), error_budget=0.83
- `confidence_score` ≈ 0.86 ≥ PR-002 (0.80)
- Result: `LEGAL_WITH_BUFFER`

### Example B: Near-threshold → PROBABLY_LEGAL
- `signed_margin_m = +0.3m`, threshold = 5m → vehicle is 5.3m from boundary
- `total_estimated_error_m = 0.40m`
- `|0.3m|` < `0.40 + 0.30 = 0.70m` → IN near-threshold zone
- Result regardless of confidence: `PROBABLY_LEGAL`

### Example C: Map-prior-only ILLEGAL → downgraded
- `signed_margin_m = -1.5m` (clearly inside restricted zone)
- `confidence_score = 0.82`
- `boundary_provenance = map_prior_only`
- Post-composition rule: map-prior-only cap → downgrade from ILLEGAL to `PROBABLY_ILLEGAL`

### Example D: Low confidence → UNVERIFIABLE
- `signed_margin_m = +2.0m` (positive)
- `footprint_quality_score = 0.20` (heavily occluded edge)
- `confidence_score` ≈ 0.18 < 0.30 floor
- Post-composition rule: confidence floor near zero → UNVERIFIABLE (`INSUFFICIENT_EVIDENCE_GENERAL`)

---

## 11. Change control

Any change to:
- individual score definitions or their weights
- the confidence composition formula
- the decision state transition matrix
- the refusal gates or escalation rules
- the near-threshold margin (PR-004)
- the confidence floors (PR-002, PR-003)

requires:
1. Update to this document.
2. Entry in `WHAT_DID_I_DO.md`.
3. Review of `ar_measurement_strategy.md`, `POLICY_REGISTRY_SPEC.md`, `DECISION_STATES.md`, and `OUTPUT_CONTRACT.md` for consistency.
4. Engineering + Product Owner approval; validation evidence required for threshold changes.
5. Update to `TASKLIST_V4_FINAL.md` if a new task or blocker arises.
