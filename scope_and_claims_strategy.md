# SCOPE AND CLAIMS STRATEGY — DK PARKING ENGINE
## Version 1 — Phase 0 foundation document
## Status: IN_PROGRESS
## Locked baseline date: 2026-03-25

## 1. Purpose
Control how scope and claims can change during implementation.
Prevent accidental expansion and prevent claims from outrunning validation.

## 2. Scope entry rule (mandatory)
A rule family may be considered "supported" ONLY if:
- it is explicitly listed as supported in SCOPE_AND_LIMITATIONS.md, AND
- thresholds/boundary definitions are locked and traceable in LEGAL_THRESHOLDS.md, AND
- decision-state semantics for that family are compatible with DECISION_STATES.md, AND
- output contract supports provenance fields for the family, AND
- validation criteria exist and are met.

## 3. Advisory-first rule (mandatory)
Advisory-first families must:
- be explicitly labeled "advisory" in outputs and UX
- be prohibited from producing hard-legal positive clearance states
- be prohibited from marketing claims implying legal certainty

## 4. Scope expansion rule (mandatory)
Any scope expansion (new family, new region, promotion of advisory to supported) requires:
1. Add proposal entry to WHAT_DID_I_DO.md.
2. Update SCOPE_AND_LIMITATIONS.md with explicit changes.
3. Update LEGAL_SOURCE_REGISTER.md and LEGAL_THRESHOLDS.md as needed.
4. Update CLAIMS_POLICY.md to ensure claims remain truthful.
5. Add validation plan updates (later phases).
6. Update TASKLIST_V4_FINAL.md with new tasks and blockers.
7. Do not release until validation gates are satisfied.

## 5. Claim wording gate (mandatory)
Claims can only be strengthened (e.g., from "probably" to "with buffer") if:
- validation demonstrates low false confidence near thresholds
- refusal behavior is adequate
- visible-unsupported sentinel behavior is present and tested
- version traceability is complete

## 6. Launch-scope update rule
The public launch region and supported slice must remain bounded.
Changing the launch region requires:
- updating launch-scope documents (Phase 1+)
- revisiting municipal guidance entries in LEGAL_SOURCE_REGISTER.md

## 7. Visible unsupported restriction rule
If visible unsupported restrictions are detected/suspected:
- the product must not imply clean clearance
- claims must remain conservative

## 8. Current status
This strategy is incomplete until the validation gate checkpoints are tied to later-phase validation documents and release blockers.
