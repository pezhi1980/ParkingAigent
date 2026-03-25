# DECISION STATES — DK PARKING ENGINE
## Version 1 — Phase 0 foundation document
## Status: IN_PROGRESS
## Locked baseline date: 2026-03-25

## 1. Purpose
This document defines the allowed decision-state vocabulary, what each state means, minimum evidence expectations, and mandatory transitions/refusal escalation semantics.

## 2. Allowed user-visible decision states (locked)
- `ILLEGAL`
- `PROBABLY_ILLEGAL`
- `UNVERIFIABLE`
- `PROBABLY_LEGAL`
- `LEGAL_WITH_BUFFER`

No other user-visible legal states are allowed in Version 1 without formal change control.

## 3. Core semantic rules
- The engine MUST NOT force a decision when evidence is insufficient.
- `UNVERIFIABLE` is correct behavior.
- Positive states apply ONLY to the evaluated supported rule family/families.
- Near-threshold results MUST downgrade or refuse based on total uncertainty.

## 4. State definitions
### 4.1 ILLEGAL
Meaning: Strong supported evidence + uncertainty model justify high confidence that the evaluated vehicle footprint violates the active supported rule family.
Minimum expectations:
- one active target vehicle resolved
- one candidate feature resolved
- correct protected boundary localized
- local metric frame valid
- signed margin/overlap indicates violation with adequate confidence

### 4.2 PROBABLY_ILLEGAL
Meaning: Evidence points toward violation, but uncertainty is too high for `ILLEGAL`.
Typical causes:
- near-threshold with moderate uncertainty
- partial boundary visibility
- edge localization uncertainty

### 4.3 UNVERIFIABLE
Meaning: The engine cannot safely determine the result inside supported scope.
Examples (non-exhaustive):
- target ambiguous
- boundary unresolved
- feature candidate ambiguous
- local metric frame invalid/unstable
- visible unsupported restriction materially affects clearance
- scene outside active dataset region

### 4.4 PROBABLY_LEGAL
Meaning: Evidence points toward compliance for the active supported family, but uncertainty is too high for `LEGAL_WITH_BUFFER`.
Typical causes:
- positive margin but small relative to total error
- incomplete boundary visibility

### 4.5 LEGAL_WITH_BUFFER
Meaning: The system has sufficient evidence that the evaluated footprint is outside the active threshold or prohibited zone with enough margin relative to uncertainty.
Constraints:
- MUST NOT imply universal Denmark parking legality.
- MUST include limitations notice.

## 5. Mandatory refusal relationship
- `UNVERIFIABLE` must be used when the pipeline cannot satisfy the prerequisites for safe evaluation.
- The engine MUST surface structured refusal reasons and retry guidance codes.

## 6. Minimum refusal reason taxonomy (locked minimum)
The engine must expose at least:
- `NO_ACTIVE_DATASET_REGION`
- `AR_SCALE_UNTRUSTED`
- `PLANE_UNSTABLE`
- `TARGET_AMBIGUOUS`
- `TARGET_EDGE_OCCLUDED`
- `BOUNDARY_UNRESOLVED`
- `FEATURE_CANDIDATE_AMBIGUOUS`
- `VISIBLE_UNSUPPORTED_RESTRICTION`
- `INSUFFICIENT_LIGHT_OR_FOCUS`
- `UNSUPPORTED_RULE_CONTEXT`
- `INSUFFICIENT_EVIDENCE_GENERAL`

## 7. Minimum semantic state machine (mandatory)
The engine MUST follow the semantic ordering:
1. If outside supported scope → `UNVERIFIABLE`
2. If target unresolved → `UNVERIFIABLE`
3. If boundary unresolved → `UNVERIFIABLE`
4. If feature candidate unresolved → `UNVERIFIABLE`
5. If visible unsupported restriction materially affects clearance → downgrade or `UNVERIFIABLE`
6. If geometry invalid → `UNVERIFIABLE`
7. If margin/overlap + uncertainty strongly indicates violation → `ILLEGAL`
8. If likely violation but not strong enough → `PROBABLY_ILLEGAL`
9. If strong clearance with buffer vs uncertainty → `LEGAL_WITH_BUFFER`
10. If likely clearance but not strong enough → `PROBABLY_LEGAL`
11. Otherwise → `UNVERIFIABLE`

## 8. UI and copy obligations (Phase 0 minimum)
This file does not define final UI copy, but it locks these obligations:
- Every state shown to the user MUST include a limitations notice.
- `UNVERIFIABLE` MUST be presented as normal/safe behavior.
- The product MUST NOT imply that positive states override signs or other restrictions.

## 9. Advisory-first families
Advisory-first outputs (e.g., driveway obstruction) must be labeled and must not share hard-legal certainty semantics unless formally promoted.
