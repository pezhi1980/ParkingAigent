# DECISION STATES — DK PARKING ENGINE
## Version 1 — Phase 0 foundation document
## Status: DONE
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

## 8. UI and copy obligations (locked per state)

This section locks the mandatory copy obligations for each state. Final UI wording is defined in `user_disclosures_and_copy.md` (Phase 1), but the obligations below are normative and may not be violated.

### 8.1 ILLEGAL
- UI MUST communicate: strong evidence of violation of the evaluated supported rule
- UI MUST include limitations notice (only supported rule evaluated)
- UI MUST NOT say: "you will get a fine" or imply certainty beyond supported scope
- Retry guidance: not applicable for this state, but a re-evaluate option is allowed

### 8.2 PROBABLY_ILLEGAL
- UI MUST communicate: likely violation, but with higher uncertainty than ILLEGAL
- UI MUST communicate: user should consider moving the vehicle as a safe precaution
- UI MUST include limitations notice
- UI MUST NOT present as definitive legal advice

### 8.3 UNVERIFIABLE
- UI MUST communicate: the system could not safely evaluate — this is normal and correct behavior
- UI MUST provide the structured refusal reason in human-readable form (e.g., "target vehicle could not be clearly identified", "the boundary was not visible enough")
- UI MUST provide retry guidance when a retry path exists
- UI MUST NOT imply this is a user error
- UI MUST NOT imply the parking is safe just because the system could not evaluate

### 8.4 PROBABLY_LEGAL
- UI MUST communicate: evidence suggests compliance for the evaluated rule, but confidence is not high enough for a strong positive result
- UI MUST include limitations notice
- UI MUST NOT present as full legal clearance
- UI MUST NOT suppress the information that other restrictions may apply

### 8.5 LEGAL_WITH_BUFFER
- UI MUST communicate: the evaluated footprint appears to comply with the specific evaluated rule, with a measurable margin
- UI MUST include limitations notice
- UI MUST include a statement that only the evaluated supported rule was checked
- UI MUST NOT use language implying universal parking legality (e.g., "safe to park here" without qualification)
- UI MUST reference the active dataset version and evaluation scope

## 9. Advisory-first families
Advisory-first outputs (e.g., driveway obstruction) must be labeled and must not share hard-legal certainty semantics unless formally promoted.
- UI MUST use the word "advisory" or equivalent
- UI MUST NOT show an advisory result using the same visual treatment as a hard-legal state
- Advisory outputs MUST NOT produce ILLEGAL or LEGAL_WITH_BUFFER states without formal scope promotion

## 10. Controlled vocabulary lock
The following terms are locked. Future code, UI, and copy MUST use these exact state names internally:
- `ILLEGAL`
- `PROBABLY_ILLEGAL`
- `UNVERIFIABLE`
- `PROBABLY_LEGAL`
- `LEGAL_WITH_BUFFER`

Any addition of states requires formal scope change, update to this file, WHAT_DID_I_DO.md log, and TASKLIST_V4_FINAL.md update.
