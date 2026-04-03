# LEGAL THRESHOLDS — DK PARKING ENGINE
## Version 1 — Phase 0 foundation document
## Status: DONE
## Locked baseline date: 2026-03-25

## 1. Purpose
This document locks the numeric statutory thresholds and the exact boundary-reference concepts used by Version 1.
Legal thresholds are controlled legal constants.
They are NOT configurable user preferences.

## 2. Non-configurability statement (mandatory)
- Threshold values in this file MUST NOT be changed by UI, user settings, or remote policy toggles.
- Any threshold change requires formal legal-source update and change-control across all dependent documents.

## 3. Threshold table (Version 1 baseline)
Each threshold entry MUST include:
- numeric threshold
- owning rule family
- exact boundary reference concept
- controlling source traceability (Source ID + section/paragraph)

| Threshold ID | Rule Family | Numeric Threshold (m) | Boundary Reference Concept (normative) | Applies When | Controlling Source Traceability | Notes |
|---|---|---:|---|---|---|---|
| TH-CR-005M | pedestrian_crossing_5m | 5.0 | Shortest ground-plane distance from nearest legally relevant point of the evaluated vehicle footprint to the correct crossing approach boundary (rule-family specific) | Threshold-based crossing approach restriction cases | DK-LAW-001 § 29, stk. 1, nr. 1 | Must refuse if approach side/boundary is ambiguous |
| TH-CPX-005M | cycle_path_exit_5m | 5.0 | Shortest ground-plane distance from vehicle footprint to the legally relevant cycle-path-exit boundary (side selection depends on exit geometry) | Threshold-based cycle-path exit restriction cases | DK-LAW-001 § 29, stk. 1, nr. 1 | Must refuse if exit geometry cannot be resolved |
| TH-INT-010M | intersection_10m | 10.0 | Shortest ground-plane distance from vehicle footprint to the nearest legally relevant transverse edge (carriageway edge; or where legally relevant, the nearest relevant cycle-path edge where geometries merge) | Threshold-based intersection restriction cases | DK-LAW-001 § 29, stk. 1, nr. 2 | Must not substitute centerlines or map node centroids |
| TH-BS-012M | bus_stop_12m_fallback | 12.0 | Signed distance along curb/edge context: protected zone extends 12m on each side of the bus-stop sign when no marked segment exists and the sign is supportably localized | Unmarked bus-stop cases (fallback) | DK-LAW-001 § 29, stk. 2 | Marked segment takes precedence when present |

## 4. Non-threshold (overlap) legal constants
Some rule families are overlap-based rather than threshold-based.
They MUST be evaluated as overlap between the evaluated vehicle footprint and the prohibited legal zone.

| Constant ID | Rule Family | Constant Type | Boundary/Zone Concept | Controlling Source Traceability | Notes |
|---|---|---|---|---|---|
| OV-PS-001 | direct_prohibited_surfaces | overlap | Vehicle footprint overlap with directly prohibited surfaces (e.g., cycle path, footway, refuge, island/median-like protected structures) where within supported scope and safely localized | DK-LAW-001 § 28, stk. 3 | Must refuse if surface cannot be localized safely. Interpretation note: § 28, stk. 3 has an exception outside built-up areas for vehicles with permitted total weight ≤ 3,500 kg, and the first sentence does not apply to bicycles and two-wheeled mopeds. |
| BS-MARK-SEG | bus_stop_marked_segment | overlap/segment | Vehicle footprint overlap with the marked prohibited bus-stop segment where road marking defines extent | DK-LAW-001 § 29, stk. 2 (den afmærkede strækning + 12m fallback when not marked); DK-EO-001 (BEK 425) § 60 (T 61: can mark the bus-stop prohibition under § 29, stk. 2); DK-EO-001 (BEK 425) § 1, stk. 2 (minor deviations support only; does not lock start/continuity/gap semantics). Exact start-of-segment semantics and continuity/gap semantics for deriving the segment extent from markings remain NEEDS_LEGAL_REVIEW (not explicit in the currently locked official text). | Marking detection/localization required; do not treat segment-extent semantics as fully locked |

## 5. Advisory-first (not hard legal clearance)
Driveway obstruction is advisory-first in Version 1.
- No hard-legal threshold is locked here for driveway obstruction.
- Any future promotion to hard-supported requires formal scope update and validation.

## 6. V1 implementation resolution for BS-MARK-SEG unresolved semantics

The legal-source-level semantics for BS-MARK-SEG (exact start-of-segment and continuity/gap interpretation) remain `NEEDS_LEGAL_REVIEW` from the currently locked official text.

The V1 engine MUST implement the following safe resolution strategy. This strategy is locked and non-negotiable for Version 1:

### 6.1 Three-tier decision rule for bus-stop evaluation

| Condition | V1 Engine Behavior | Rationale |
|---|---|---|
| Marked segment (T 61) is clearly visible and extent is unambiguous (no gaps, clear start/end boundary visible) | Evaluate vehicle footprint overlap against the resolved marked segment boundary | T 61 presence is definitive; extent is directly observable without ambiguous semantic interpretation |
| Marked segment (T 61) is present but extent is ambiguous, partially visible, start unclear, or gaps exist | Fall back to TH-BS-012M (12m rule) applied from the supportably localized bus-stop sign | Conservative fallback; resolves segment-extent ambiguity safely without requiring legal-source resolution |
| No marking present AND bus-stop sign is supportably localized | Apply TH-BS-012M (12m rule) from the sign location | Explicit statutory fallback per DK-LAW-001 § 29, stk. 2 |
| No marking AND bus-stop sign is not supportably localized | Return UNVERIFIABLE with reason BOUNDARY_UNRESOLVED | Cannot evaluate safely |

### 6.2 What this resolution does NOT resolve

This V1 strategy does NOT resolve the underlying legal-source semantic question about how Danish law and road marking regulations define segment start, continuity, and gap behavior at the source level. That question remains `NEEDS_LEGAL_REVIEW`.

Formal legal-source resolution of BS-MARK-SEG segment-extent semantics is deferred to a post-Version-1 legal review. Any change to the resolution strategy requires:
- update to this section
- approval via the process defined in `legal_governance_strategy.md`
- log entry in `WHAT_DID_I_DO.md`
- update to `TASKLIST_V4_FINAL.md`

## 7. Traceability status
- The numeric baseline is locked by DK_PARKING_AGENT_MASTER_SPEC_V4_FINAL.md section 10.
- Official legal-source traceability is complete for all V1 evaluator thresholds:
	- Statutory threshold anchors for 5m/10m/12m are linked to DK-LAW-001.
	- BS-MARK-SEG segment-extent semantics remain NEEDS_LEGAL_REVIEW at source level; V1 behavior is governed by the safe three-tier resolution in section 6 above.
- Change-control statement: No threshold value in this file may be changed without formal legal-source update, cross-document update, and WHAT_DID_I_DO.md log entry.
