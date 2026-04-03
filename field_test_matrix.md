# FIELD TEST MATRIX — DK PARKING ENGINE
## Version 1 — Phase 10 document
## Status: DONE
## Locked baseline date: 2026-04-03

---

## 1. Purpose

This document defines the complete field test matrix for Phase 10 validation.

Each scenario must be executed on a physical iPhone (iOS 16+) with the vertical slice app.
Results must be recorded in the Result column and cross-referenced to `validation_plan.md` acceptance metrics.

---

## 2. Test scenario registry

### Category A — Nominal distance (clearly legal)

| ID | Scene description | Vehicle position | Expected state | Result | Eval ID |
|---|---|---|---|---|---|
| A-001 | Pedestrian crossing, clear daytime, vehicle 7m from boundary | 7.0m from crossing | LEGAL_WITH_BUFFER | — | — |
| A-002 | Pedestrian crossing, vehicle 6m from boundary, high-quality AR | 6.0m | LEGAL_WITH_BUFFER | — | — |
| A-003 | Pedestrian crossing, vehicle 5.5m from boundary, visualDetection | 5.5m | LEGAL_WITH_BUFFER or PROBABLY_LEGAL | — | — |

### Category B — Near-threshold (within downgrade zone)

| ID | Scene description | Vehicle position | Expected state | Result | Eval ID |
|---|---|---|---|---|---|
| B-001 | Pedestrian crossing, vehicle 5.1m — inside error+margin band | ~5.1m | PROBABLY_LEGAL | — | — |
| B-002 | Pedestrian crossing, vehicle exactly 5.0m (at threshold) | 5.0m | PROBABLY_LEGAL or PROBABLY_ILLEGAL | — | — |
| B-003 | Pedestrian crossing, vehicle 4.9m — just over threshold | 4.9m | PROBABLY_ILLEGAL | — | — |
| B-004 | Pedestrian crossing, vehicle 4.5m — inside error band from violation side | 4.5m | PROBABLY_ILLEGAL | — | — |

### Category C — Nominal violation (clearly illegal)

| ID | Scene description | Vehicle position | Expected state | Result | Eval ID |
|---|---|---|---|---|---|
| C-001 | Pedestrian crossing, vehicle 3m from boundary, clear AR | 3.0m | ILLEGAL | — | — |
| C-002 | Pedestrian crossing, vehicle 2m from boundary | 2.0m | ILLEGAL | — | — |
| C-003 | Pedestrian crossing, vehicle 1m from boundary | 1.0m | ILLEGAL | — | — |

### Category D — Poor AR conditions (should refuse)

| ID | Scene description | Condition | Expected state | Result | Eval ID |
|---|---|---|---|---|---|
| D-001 | Fast camera movement during evaluation | Excessive motion | UNVERIFIABLE / AR_SCALE_UNTRUSTED | — | — |
| D-002 | Evaluation immediately after app launch (< 2s) | Initializing | UNVERIFIABLE / AR_SCALE_UNTRUSTED | — | — |
| D-003 | No horizontal plane detected before evaluation | No plane | UNVERIFIABLE / PLANE_UNSTABLE | — | — |
| D-004 | Very low light conditions (indoors, night) | Low features | UNVERIFIABLE / AR_SCALE_UNTRUSTED | — | — |

### Category E — Partial occlusion

| ID | Scene description | Condition | Expected state | Result | Eval ID |
|---|---|---|---|---|---|
| E-001 | Vehicle partially behind post, footprintQuality < 0.40 | Occluded edge | UNVERIFIABLE / TARGET_EDGE_OCCLUDED | — | — |
| E-002 | Vehicle partially behind another vehicle | Occluded | UNVERIFIABLE / TARGET_EDGE_OCCLUDED | — | — |

### Category F — Multiple nearby vehicles

| ID | Scene description | Condition | Expected state | Result | Eval ID |
|---|---|---|---|---|---|
| F-001 | Two vehicles at similar distance — target is the closer one | Target confirmed | Correct state for closer vehicle | — | — |
| F-002 | Two vehicles at very different distances — evaluate farther one | Target confirmed | Correct state for target vehicle | — | — |

### Category G — Multiple nearby legal features

| ID | Scene description | Condition | Expected state | Result | Eval ID |
|---|---|---|---|---|---|
| G-001 | Two pedestrian crossings visible, evaluate against nearest | Correct candidate | State based on nearest crossing | — | — |
| G-002 | Pedestrian crossing + intersection visible simultaneously | Correct candidate | State based on selected family | — | — |

### Category H — Visible unsupported restrictions

| ID | Scene description | Condition | Expected state | Result | Eval ID |
|---|---|---|---|---|---|
| H-001 | Time-limited parking sign visible (e.g. P 1 time) | unsupportedVisibleRestrictionFlag=true | UNVERIFIABLE / VISIBLE_UNSUPPORTED_RESTRICTION | — | — |
| H-002 | No stopping zone sign visible (zone marking) | unsupportedVisibleRestrictionFlag=true | UNVERIFIABLE / VISIBLE_UNSUPPORTED_RESTRICTION | — | — |
| H-003 | Loading/unloading zone sign visible | unsupportedVisibleRestrictionFlag=true | UNVERIFIABLE / VISIBLE_UNSUPPORTED_RESTRICTION | — | — |

### Category I — Night / rain / low visibility

| ID | Scene description | Condition | Expected state | Result | Eval ID |
|---|---|---|---|---|---|
| I-001 | Night scene, street lighting only | Low brightness | UNVERIFIABLE or high-error result | — | — |
| I-002 | Rain, wet surface reflections | Unstable plane | UNVERIFIABLE / PLANE_UNSTABLE | — | — |
| I-003 | Overcast, poor contrast on boundary markings | Poor features | UNVERIFIABLE or PROBABLY_ state | — | — |

### Category J — Map drift / boundary localization

| ID | Scene description | Condition | Expected state | Result | Eval ID |
|---|---|---|---|---|---|
| J-001 | mapPriorOnly provenance, vehicle clearly legal | mapPriorOnly | PROBABLY_LEGAL (not LEGAL_WITH_BUFFER) | — | — |
| J-002 | mapPriorOnly provenance, vehicle clearly illegal | mapPriorOnly | PROBABLY_ILLEGAL (not ILLEGAL) | — | — |
| J-003 | Partially visible boundary (paint worn) | mapPriorAssisted | PROBABLY_ state expected, not hard state | — | — |

### Category K — Bus-stop cases

| ID | Scene description | Condition | Expected state | Result | Eval ID |
|---|---|---|---|---|---|
| K-001 | Bus stop with clear marking extent | busStopMarkedSegment | Evaluated against marked segment | — | — |
| K-002 | Bus stop without clear marking (sign only) | busStop12mFallback | 12m threshold applied | — | — |

### Category L — False-target temptation

| ID | Scene description | Condition | Expected state | Result | Eval ID |
|---|---|---|---|---|---|
| L-001 | Evaluating vehicle far from crossing but crossing is prominent in frame | Target confirmed | State based on actual vehicle, not visual prominence | — | — |
| L-002 | Two crossings in frame, vehicle near the further one | Correct target confirmed | State based on confirmed vehicle position | — | — |

---

## 3. Minimum coverage requirement

Before Phase 10 can pass, the following minimum observations must be recorded:

| Expected state | Minimum observations |
|---|---|
| LEGAL_WITH_BUFFER | 3 |
| PROBABLY_LEGAL | 3 |
| PROBABLY_ILLEGAL | 3 |
| ILLEGAL | 3 |
| UNVERIFIABLE | 5 (at least 3 different RefusalReasonCodes) |

---

## 4. Failure recording template

For each test that produces an unexpected result, fill in:

```
Test ID:
Scene description:
Expected state:
Observed state:
Observed RefusalReasonCode (if UNVERIFIABLE):
Failure category: [FC / MR / WSD / DF / VTF / OC / UEF / ME]
evaluationId:
measuredDistanceM:
signedMarginM:
totalEstimatedErrorM:
confidenceScore:
boundaryProvenance:
Notes:
Remediation:
```

---

## 5. Summary results table (to be filled after field testing)

| Category | Tested | Passed | Failed | Notes |
|---|---|---|---|---|
| A — Nominal legal | 0 | — | — | — |
| B — Near-threshold | 0 | — | — | — |
| C — Nominal illegal | 0 | — | — | — |
| D — Poor AR | 0 | — | — | — |
| E — Partial occlusion | 0 | — | — | — |
| F — Multiple vehicles | 0 | — | — | — |
| G — Multiple features | 0 | — | — | — |
| H — Unsupported restriction | 0 | — | — | — |
| I — Night/rain/low visibility | 0 | — | — | — |
| J — Map drift | 0 | — | — | — |
| K — Bus stop | 0 | — | — | — |
| L — False-target | 0 | — | — | — |

---

## 6. Phase 10 gate sign-off

- [ ] All required scenario categories covered
- [ ] Minimum observations per state achieved
- [ ] All failures recorded and categorized
- [ ] All failing guardrails remediated
- [ ] `validation_plan.md` acceptance metrics AM-001 through AM-010 verified
- [ ] `vertical_slice_report.md` §5 updated with field test summary
- [ ] Phase 10 DONE — date: TBD
