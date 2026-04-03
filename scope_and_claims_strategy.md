# SCOPE AND CLAIMS STRATEGY — DK PARKING ENGINE
## Version 1 — Phase 0 foundation document
## Status: DONE
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

## 8. Validation gate checkpoints (phase-linked)

The following checkpoints govern when scope may advance, when claims may strengthen, and when release may proceed. Each checkpoint references the phase where evidence is produced.

| Checkpoint ID | Gate Condition | Blocking Phase | Passes When |
|---|---|---|---|
| VG-001 | Scope entry gate | Before Phase 2 implementation | LEGAL_THRESHOLDS.md and SCOPE_AND_LIMITATIONS.md are complete and consistent for all V1 families |
| VG-002 | SDK and output contract gate | Before Phase 9 (vertical slice) | OUTPUT_CONTRACT.md includes provenance fields for all V1 families |
| VG-003 | Dataset gate | Before Phase 9 | dataset_strategy.md + feature_schema_spec.md exist and cover all V1 families |
| VG-004 | Pre-slice claim gate | Before public testing | At least one supported family result path produces correct structured output with limitations notice and version reference |
| VG-005 | Near-threshold validation gate | Before claim strengthening | Phase 10 field test matrix demonstrates false-confidence rate is acceptably controlled near thresholds for each supported family |
| VG-006 | Refusal adequacy gate | Before claim strengthening | Phase 10 demonstrates UNVERIFIABLE is returned in all expected failure conditions |
| VG-007 | Unsupported restriction gate | Before public release | Visible-unsupported sentinel behavior is tested and demonstrated for at least one unsupported visible restriction type |
| VG-008 | Version traceability gate | Before public release | Every user-visible result includes dataset version, model version, and policy version in the output |
| VG-009 | Launch scope lock gate | Before public launch | launch_scope_register.md (Phase 1+) is complete, bounded, and consistent with SCOPE_AND_LIMITATIONS.md and CLAIMS_POLICY.md |
| VG-010 | Advisory-to-supported promotion gate | Before promoting advisory family | Dedicated validation plan section exists; Phase 10 guardrails met for the promoted family; CLAIMS_POLICY.md updated |

## 9. Blocking behavior
If any validation gate checkpoint is not met, the associated phase or release step MUST remain blocked.
A checkpoint may not be bypassed by convenience, schedule pressure, or partial evidence.
Any bypass attempt must be recorded as a REFUSED action in WHAT_DID_I_DO.md.
