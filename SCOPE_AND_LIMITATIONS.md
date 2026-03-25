# SCOPE AND LIMITATIONS — DK PARKING ENGINE
## Version 1 — Phase 0 foundation document
## Status: IN_PROGRESS
## Locked baseline date: 2026-03-25

## 1. Purpose
This document defines what Version 1 supports, what it treats as advisory-first, what it does not support, and the mandatory limitations disclosures.

## 2. Primary supported question (the ONLY allowed question)
Does any part of the evaluated vehicle footprint violate a supported Danish stopping or parking rule by:
- overlapping a prohibited legal zone, OR
- being closer than the legal threshold to the correct protected legal boundary?

## 3. What the system does NOT claim to do
Version 1 MUST NOT claim that it determines full parking legality under all Danish rules.
It does not override:
- signs or temporary controls
- permits, payments, or time-window rules
- local municipal restrictions outside supported scope
- private contractual rules
- enforcement discretion

## 4. Supported rule families (hard supported in Version 1)
Version 1 supports these rule families when evidence is sufficient:
1. pedestrian crossing distance/zone evaluation (5m logic)
2. cycle-path exit distance/zone evaluation (5m logic)
3. intersection distance/zone evaluation (10m logic)
4. direct prohibited-surface overlap evaluation (e.g., cycle path, footway, refuge/island) when safely localizable
5. bus-stop evaluation:
   - marked prohibited segment when marking defines extent
   - 12m fallback from bus-stop sign when unmarked and sign localization is supportable
6. visible-but-unsupported restriction sentinel (safety behavior)

## 5. Advisory-first families (NOT hard legal clearance in Version 1)
- driveway obstruction
- property-access hindrance

Advisory-first output MUST be clearly labeled and MUST NOT be promoted to hard legal certainty.

## 6. Explicitly unsupported (outside Version 1 hard legal clearance)
Version 1 does NOT support hard legal clearance for:
- permits and entitlement rules (disabled badge, EV charging entitlement, etc.)
- payment compliance
- time-window restrictions
- loading-only restrictions
- temporary controls, construction/event restrictions
- police/emergency instructions
- private contractual parking systems
- unsupported local signage schemes

## 7. Visible unsupported restriction sentinel (mandatory)
If the scene contains visible restriction sources that are not supported by the evaluator set (signs, markings, temporary controls, private boards), the system MUST NOT imply clean legal clearance.
The engine/app must:
- set `unsupported_visible_restriction_flag = true`, and
- downgrade a positive state or return `UNVERIFIABLE` when the risk materially affects clearance.

## 8. Region and launch limits
- Version 1 minimum credible launch: one bounded region (one city or tightly bounded area) on iOS.
- Outside the active region dataset, the engine MUST refuse with `NO_ACTIVE_DATASET_REGION`.

## 9. Mandatory limitations notice (for all results)
Every user-visible result MUST include (or map to) a limitations notice stating that:
- only the evaluated supported rule family/families are covered,
- other restrictions (signs, temporary controls, permits, private rules) may still apply,
- refusal is correct behavior when evidence is insufficient.

## 10. Scope change control (summary)
Any change in supported families, advisory-first status, or limitation language requires formal change control and updates across:
- CLAIMS_POLICY.md
- DECISION_STATES.md
- LEGAL_THRESHOLDS.md
- TASKLIST_V4_FINAL.md
- WHAT_DID_I_DO.md
