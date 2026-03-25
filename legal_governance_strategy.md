# LEGAL GOVERNANCE STRATEGY — DK PARKING ENGINE
## Version 1 — Phase 0 foundation document
## Status: IN_PROGRESS
## Locked baseline date: 2026-03-25

## 1. Purpose
Define how legal-source updates are detected, reviewed, approved, locked, and propagated across the project.
No silent legal drift is allowed.

## 2. Roles and ownership (to be finalized)
- Legal source owner: TBD (person/role)
- Engineering owner: TBD
- Product owner: TBD
- Release authority: TBD

## 3. Update triggers
A legal review MUST be triggered when any of the following occur:
- statutory law changes relevant to supported rule families
- executive orders/regulations affecting signs/markings change
- official guidance materially changes interpretation-relevant boundary concepts
- launch region changes (municipal guidance review)
- validation or field reports reveal ambiguity attributable to legal-source interpretation

## 4. Locked-date policy
- Each release must reference a locked legal-source baseline date.
- The baseline date must be recorded in:
  - LEGAL_SOURCE_REGISTER.md
  - LEGAL_THRESHOLDS.md
  - DK_PARKING_AGENT_MASTER_SPEC_V4_FINAL.md (if it changes)

## 5. Review and approval workflow (minimum)
1. Record the trigger and scope in WHAT_DID_I_DO.md.
2. Update LEGAL_SOURCE_REGISTER.md with verified official-source details.
3. Update LEGAL_THRESHOLDS.md traceability fields.
4. Update any impacted scope/claims/decision-state documents.
5. Update TASKLIST_V4_FINAL.md blockers and next steps.
6. Require explicit approval (legal + product + engineering) before marking Phase 0/Phase gate as DONE.

## 6. Downstream propagation rules
If a legal source change affects:
- thresholds → update LEGAL_THRESHOLDS.md and any evaluator specs
- scope meaning → update SCOPE_AND_LIMITATIONS.md
- claims/disclosures → update CLAIMS_POLICY.md and later copy files
- refusal logic semantics → update DECISION_STATES.md and later uncertainty strategy

## 7. Auditability requirements
- Every change must be traceable to official controlling sources.
- Every change must be versioned and logged.
- No silent meaning changes across versions.

## 8. Current status
This strategy is incomplete until owner roles and approval checkpoints are explicitly assigned.
