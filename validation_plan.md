# VALIDATION PLAN — DK PARKING ENGINE
## Version 1 — Phase 10 document
## Status: DONE
## Locked baseline date: 2026-04-03

---

## 1. Purpose

This document defines the structured validation plan for the DK Parking Engine Version 1.

Validation must prove that the system behaves safely and honestly outside the best demo path — especially near legal thresholds, under poor AR conditions, and when unsupported restrictions are present.

This plan is normative for Phase 10. All field testing must follow the categories, acceptance metrics, and failure criteria defined here.

---

## 2. Acceptance metrics

A Version 1 system passes validation only if all of the following are true:

| # | Metric | Threshold |
|---|---|---|
| AM-001 | Refusal rate in near-threshold zone (±0.30m + error budget) | ≥ 80% of scenes produce PROBABLY_LEGAL or PROBABLY_ILLEGAL, not a hard state |
| AM-002 | False-confidence rate: LEGAL_WITH_BUFFER when measured margin < 0.50m | ≤ 5% of tested scenes |
| AM-003 | Refusal rate when AR session is poor (scale < 0.75 or plane < 0.70) | 100% — zero false positives tolerated |
| AM-004 | Correct refusal when visible unsupported restriction present | 100% — UNVERIFIABLE with VISIBLE_UNSUPPORTED_RESTRICTION always |
| AM-005 | Correct refusal when vehicle edge is occluded and footprint score < 0.40 | 100% |
| AM-006 | Limitations notice visible on every result (all states) | 100% |
| AM-007 | Version references present in every serialized result | 100% |
| AM-008 | Per-family disclosure visible when decision state is not UNVERIFIABLE | 100% |
| AM-009 | Retry guidance visible for every UNVERIFIABLE result | 100% |
| AM-010 | No result claims universal parking legality (C-007 forbidden) | 100% |

---

## 3. Failure categories

| Category | Code | Description |
|---|---|---|
| False confidence | FC | System produces LEGAL_WITH_BUFFER or PROBABLY_LEGAL when ground truth is a violation or the evidence is insufficient |
| Missing refusal | MR | System produces a non-UNVERIFIABLE result when a pre-composition gate should have fired |
| Wrong state direction | WSD | System produces LEGAL state when ground truth is ILLEGAL, or vice versa, without near-threshold explanation |
| Disclosure failure | DF | Limitations notice, per-family disclosure, or refusal explanation absent from UI |
| Version trace failure | VTF | Result serialized without complete VersionRefs |
| Overclaim | OC | Any user-facing text violates CLAIMS_POLICY.md (C-007 through C-013) |
| Unsafe escalation failure | UEF | Visible unsupported restriction detected but positive result not escalated to UNVERIFIABLE |
| Measurement error | ME | Measured distance differs from ground-truth by more than totalEstimatedErrorM |

---

## 4. Refusal adequacy criteria

Refusal is adequate when ALL of the following hold:

1. The RefusalReasonCode is present and correctly identifies the root cause.
2. The human-readable refusal explanation is displayed in the UI.
3. Retry guidance is displayed and is actionable for the specific reason code.
4. The result is NOT presented as a parking recommendation.
5. The user is NOT implied to have made an error — refusal is presented as correct behavior.

Refusal is NOT adequate if:
- The reason code is `insufficientEvidenceGeneral` when a more specific code applies.
- Retry guidance is missing or generic when a specific guidance exists.
- The UNVERIFIABLE state is presented in red or as a "failure" UI pattern.

---

## 5. False-confidence guardrail metrics

The following guardrails MUST be verified in controlled tests:

| Guardrail | Test method | Pass criterion |
|---|---|---|
| GR-001: Near-threshold downgrade | Place vehicle at exactly threshold distance (5.00m). Evaluate with varying error budgets. | No LEGAL_WITH_BUFFER produced when margin < nearThresholdDowngradeMarginM (0.30m) + error |
| GR-002: Low confidence floor | Inject artificially low evidence scores. | UNVERIFIABLE returned when confidence < 0.30 |
| GR-003: Map-prior-only cap | Use mapPriorOnly provenance with strong geometry. | LEGAL_WITH_BUFFER never returned; capped at PROBABLY_LEGAL |
| GR-004: Unsupported restriction | Evaluate with unsupportedVisibleRestrictionFlag = true on positive state. | UNVERIFIABLE with VISIBLE_UNSUPPORTED_RESTRICTION always |
| GR-005: AR scale failure | Evaluate with metricScaleScore < 0.75. | AR_SCALE_UNTRUSTED refusal always |
| GR-006: Plane instability | Evaluate with planeStabilityScore < 0.70. | PLANE_UNSTABLE refusal always |
| GR-007: Excessive error budget | Evaluate with totalEstimatedErrorM > 2.0. | Measurement returns nil; INSUFFICIENT_EVIDENCE_GENERAL refusal |

---

## 6. Test execution phases

### Phase 10a — Controlled indoor tests (simulator + synthetic geometry)
- Run all unit tests: ConfidenceComposerTests, LegalEvaluatorTests, MeasurementBundleTests
- Verify all 7 guardrails (GR-001 through GR-007) in isolation
- Expected: 100% pass

### Phase 10b — Vertical slice device tests (physical iPhone, pedestrian crossings)
- Run field_test_matrix.md scenarios
- Must cover all test categories from ROADMAP §23.3
- Minimum: 3 LEGAL_WITH_BUFFER, 3 ILLEGAL, 3 PROBABLY_LEGAL, 3 PROBABLY_ILLEGAL, 3 UNVERIFIABLE observations

### Phase 10c — Adversarial tests
- Deliberately poor AR conditions (fast movement, low light, covered camera)
- Deliberately ambiguous geometry (two nearby crossings)
- Deliberately visible unsupported signs (time-limited parking signs)
- Expected: all adversarial inputs produce UNVERIFIABLE, never a hard legal state

---

## 7. Failure recording obligations

Every field test failure MUST be recorded with:

1. Test scenario ID (from field_test_matrix.md)
2. Observed `decision_state`
3. Expected `decision_state` or expected refusal
4. Failure category code (FC, MR, WSD, DF, VTF, OC, UEF, ME)
5. `evaluationId` from the serialized result
6. Full `ParkingEvaluationResult` JSON if available
7. Remediation: strategy document that needs updating, or code change required

---

## 8. Strategy update trigger

If any of the following failure categories appear in > 2% of tests, the corresponding strategy document MUST be updated before Phase 10 can pass:

| Failure category | Strategy document to update |
|---|---|
| FC, WSD | `uncertainty_and_confidence_strategy.md` |
| MR, GR-001 to GR-007 | `uncertainty_and_confidence_strategy.md` |
| ME | `ar_measurement_strategy.md` |
| UEF | `uncertainty_and_confidence_strategy.md`, `CLAIMS_POLICY.md` |
| OC | `user_disclosures_and_copy.md`, `CLAIMS_POLICY.md` |

---

## 9. Phase 10 validation gate

Phase 10 passes only when:
- All 10 acceptance metrics (AM-001 through AM-010) are met.
- All 7 guardrails (GR-001 through GR-007) pass in controlled tests.
- No failure category appears in > 2% of field tests.
- `vertical_slice_report.md` §5 (failures and gaps) is filled.
- No strategy document update is outstanding.

---

## 10. Change control

Any change to acceptance metrics, failure categories, or guardrail thresholds requires:
1. Update to this file.
2. Entry in `WHAT_DID_I_DO.md`.
3. Update to `TASKLIST_V4_FINAL.md`.
