# TASKLIST — DK PARKING ENGINE
## Live Execution Control System
## Version 4.0 — Aligned With Locked Master Spec v4 and Roadmap v8
## Date: 2026-03-25

---

# 1. PURPOSE

This file is the mandatory execution control system for the project.

It is not just a task list.

It is:

- execution tracker
- validation gate
- blocker registry
- anti-drift system
- audit trail for phased implementation

No meaningful work may proceed without being represented here.

---

# 2. CONTROLLING DOCUMENTS

The current controlling document set is:

- `DK_PARKING_AGENT_MASTER_SPEC_V4_FINAL.md`
- `ROADMAP_V8_FINAL.md`
- `RULES_V2_FINAL.md`
- `TASKLIST_V4_FINAL.md`
- `WHAT_DID_I_DO.md`

If older parallel files also exist, the versioned locked files above are controlling until a formal migration is recorded.

---

# 3. CORE EXECUTION RULE

```text
Before any meaningful action, TASKLIST_V4_FINAL.md must reflect the planned work, active phase, current blockers, and next valid step.
```

---

# 4. STATUS VALUES (STRICT)

Allowed values:

- TODO
- IN_PROGRESS
- BLOCKED
- DONE
- REFUSED

No other values are allowed.

---

# 5. CURRENT ACTIVE PHASE

Active phase: `PHASE 0 — LEGAL AND PRODUCT FOUNDATION`

The system MUST NOT move to the next phase unless:

- all required Phase 0 tasks are `DONE`
- Phase 0 validation passes
- Phase 0 checklist is complete
- no unresolved legal-source or threshold-traceability blocker remains

---

# 6. EXECUTION LOCK RULE (CRITICAL)

A task is NOT allowed to be marked as `DONE` unless:

- all required files are created
- the files are not empty
- content matches `DK_PARKING_AGENT_MASTER_SPEC_V4_FINAL.md`
- content matches `ROADMAP_V8_FINAL.md`
- no required section is missing
- no rule violation exists
- blockers are either resolved or explicitly not applicable

If any condition fails, the task MUST remain `IN_PROGRESS` or `BLOCKED`.

---

# 7. ATOMIC EXECUTION RULE

Tasks must be executed in atomic steps.

Each step MUST:

1. be represented here before execution if the plan or status changes
2. be recorded in `WHAT_DID_I_DO.md` before and after the meaningful step
3. keep the next action precise

Forbidden:

- multi-step silent execution
- hidden batch changes
- skipping blocker logging
- jumping to later phases while earlier dependencies remain unfinished

---

# 8. TASK TABLE

| ID     | Phase    | Task Name                                      | Status      | Files Touched | Purpose | Blockers | Next Step |
|--------|----------|------------------------------------------------|-------------|---------------|---------|----------|-----------|
| T-0001 | Phase 0  | Lock versioned source-of-truth file set        | DONE        | DK_PARKING_AGENT_MASTER_SPEC_V4_FINAL.md, ROADMAP_V8_FINAL.md, RULES_V2_FINAL.md, TASKLIST_V4_FINAL.md, WHAT_DID_I_DO.md | Establish the active locked control files | None | Keep all future work aligned to the versioned locked files |
| T-0002 | Phase 0  | Create legal source register                   | IN_PROGRESS | LEGAL_SOURCE_REGISTER.md | Lock official legal sources, authority order, review dates, and update procedure | Verified official fields still incomplete | Complete required source entries and hierarchy fields |
| T-0003 | Phase 0  | Create legal thresholds                        | IN_PROGRESS | LEGAL_THRESHOLDS.md | Lock statutory thresholds, boundary concepts, traceability, and non-configurability | Threshold-to-source traceability incomplete | Link each V1 threshold to controlling legal sources |
| T-0004 | Phase 0  | Create scope and limitations                   | IN_PROGRESS | SCOPE_AND_LIMITATIONS.md | Define supported, advisory-first, unsupported, visible-unsupported, region, and launch boundaries | Scope wording not yet fully locked to launch scope language | Complete supported/advisory/unsupported matrix and disclosure wording |
| T-0005 | Phase 0  | Create decision states                         | IN_PROGRESS | DECISION_STATES.md | Lock state semantics, evidence requirements, transitions, and refusal escalation | State copy and UI obligations not yet fully linked | Complete per-state semantics and transition rules |
| T-0006 | Phase 0  | Create claims policy                           | IN_PROGRESS | CLAIMS_POLICY.md | Prevent overclaiming and lock allowed, forbidden, and required product wording | Positive-result and refusal caveat wording still incomplete | Complete claim matrix and mandatory caveats |
| T-0007 | Phase 0  | Create legal governance strategy               | IN_PROGRESS | legal_governance_strategy.md | Define legal-source precedence, ownership, update review, and approval path | Governance review procedure not yet fully specified | Complete locked-date and change-approval workflow |
| T-0008 | Phase 0  | Create scope and claims strategy               | IN_PROGRESS | scope_and_claims_strategy.md | Control how scope and claims can change during implementation | Scope-entry and claim-change gates not yet fully specified | Complete change-control rules and validation gates |
| T-0009 | Phase 0  | Validate Phase 0 completion                    | BLOCKED     | TASKLIST_V4_FINAL.md, LEGAL_SOURCE_REGISTER.md, LEGAL_THRESHOLDS.md, SCOPE_AND_LIMITATIONS.md, DECISION_STATES.md, CLAIMS_POLICY.md, legal_governance_strategy.md, scope_and_claims_strategy.md | Prevent premature movement to Phase 1 | Missing verified legal-source details; thresholds lack complete traceability | Finish T-0002 and T-0003, then re-run Phase 0 validation |
| T-0101 | Phase 1  | Lock scope vocabulary and disclosure layer     | TODO        | DECISION_STATES.md, CLAIMS_POLICY.md, launch_scope_register.md, user_disclosures_and_copy.md, TASKLIST_V4_FINAL.md, WHAT_DID_I_DO.md | Turn foundation into a fixed product-control language | Phase 0 incomplete | Start only after T-0009 is DONE |
| T-0201 | Phase 2  | Lock system architecture and SDK boundary      | TODO        | SYSTEM_ARCHITECTURE.md, SDK_API_CONTRACT.md, OUTPUT_CONTRACT.md, POLICY_REGISTRY_SPEC.md, VERSIONING_POLICY.md | Define engine/app/agent boundaries and productized contracts | Phase 1 incomplete | Start only after T-0101 is DONE |
| T-0301 | Phase 3  | Lock dataset model and feature representation  | TODO        | dataset_strategy.md, feature_schema_spec.md, launch_scope_register.md | Define region bundles, feature schema, versioning, and map-prior role | Phase 2 incomplete | Start only after T-0201 is DONE |
| T-0401 | Phase 4  | Lock AR measurement backbone                   | TODO        | ar_measurement_strategy.md, SYSTEM_ARCHITECTURE.md, OUTPUT_CONTRACT.md | Define metric-plane validity, stability checks, and geometry refusal rules | Phase 3 incomplete | Start only after T-0301 is DONE |
| T-0501 | Phase 5  | Lock target selection and vehicle footprint    | TODO        | target_selection_policy.md, vehicle_footprint_strategy.md | Define one-active-target behavior and legally relevant vehicle geometry | Phase 4 incomplete | Start only after T-0401 is DONE |
| T-0601 | Phase 6  | Lock legal-boundary localization               | TODO        | legal_boundary_localization_strategy.md | Define family-specific legal boundaries and provenance rules | Phase 5 incomplete | Start only after T-0501 is DONE |
| T-0701 | Phase 7  | Lock feature candidate matching                | TODO        | feature_candidate_matching_strategy.md | Define deterministic candidate selection and ambiguity refusal | Phase 6 incomplete | Start only after T-0601 is DONE |
| T-0801 | Phase 8  | Lock uncertainty, confidence, and refusal      | TODO        | uncertainty_and_confidence_strategy.md, DECISION_STATES.md, OUTPUT_CONTRACT.md | Turn uncertainty into controlled state transitions | Phase 7 incomplete | Start only after T-0701 is DONE |
| T-0901 | Phase 9  | Build iOS vertical slice                       | TODO        | app and SDK implementation files, vertical_slice_report.md, TASKLIST_V4_FINAL.md, WHAT_DID_I_DO.md | Prove one real end-to-end supported slice on device | Phase 8 incomplete | Start only after T-0801 is DONE |
| T-1001 | Phase 10 | Run validation hardening                       | TODO        | validation_plan.md, field_test_matrix.md, vertical_slice_report.md | Stress-test false confidence, refusal adequacy, and threshold-zone behavior | Phase 9 incomplete | Start only after T-0901 is DONE |
| T-1101 | Phase 11 | Build iOS product integration                  | TODO        | capture_guidance_strategy.md, retry_and_refusal_ux_strategy.md, SYSTEM_ARCHITECTURE.md, user_disclosures_and_copy.md | Turn the validated slice into a usable iOS product | Phase 10 incomplete | Start only after T-1001 is DONE |
| T-1201 | Phase 12 | Lock release safety, privacy, and disclosures  | TODO        | privacy_and_telemetry_spec.md, observability_and_replay_strategy.md, release_readiness_checklist.md | Prepare production governance, telemetry, privacy, and release blockers | Phase 11 incomplete | Start only after T-1101 is DONE |
| T-1301 | Phase 13 | Prepare public launch package                  | TODO        | launch_scope_register.md, CLAIMS_POLICY.md, release_readiness_checklist.md, launch_runbook.md | Lock truthful launch scope, public wording, FAQ, and rollback criteria | Phase 12 incomplete | Start only after T-1201 is DONE |
| T-1401 | Phase 14 | Define Android parity and second-platform path | TODO        | android_parity_strategy.md, VERSIONING_POLICY.md, SDK_API_CONTRACT.md | Add Android only without semantic drift from iOS | Phase 13 incomplete | Start only after T-1301 is DONE |

---

# 9. ACTIVE PHASE TASK DETAILS (MANDATORY)

### T-0002
- Phase: Phase 0
- Task Name: Create legal source register
- Status: IN_PROGRESS
- Files Touched:
  - `LEGAL_SOURCE_REGISTER.md`
- Purpose:
  - lock controlling legal sources for Version 1
  - define source authority order
  - define review dates and update procedure
- Required minimum content:
  - source title
  - source type
  - issuing authority
  - status in force
  - access path
  - relevance to supported rule families
  - hierarchy rank
  - review date
  - update procedure
- Current blocker detail:
  - verified official fields are still incomplete
- Next Step:
  - complete the required source-entry fields using official controlling sources only

### T-0003
- Phase: Phase 0
- Task Name: Create legal thresholds
- Status: IN_PROGRESS
- Files Touched:
  - `LEGAL_THRESHOLDS.md`
- Purpose:
  - lock the V1 statutory thresholds
  - lock the exact rule-family ownership of each threshold
  - lock the boundary-reference concept
  - declare that legal constants are not configurable
- Required minimum content:
  - numeric thresholds
  - owning rule family
  - exact boundary reference concept
  - controlling source traceability
  - change-control statement
  - non-configurability statement
- Current blocker detail:
  - threshold-to-source traceability is not yet complete
- Next Step:
  - add controlling-source links for each V1 threshold and verify family ownership

### T-0004
- Phase: Phase 0
- Task Name: Create scope and limitations
- Status: IN_PROGRESS
- Files Touched:
  - `SCOPE_AND_LIMITATIONS.md`
- Purpose:
  - define what Version 1 supports
  - define advisory-first families
  - define unsupported families
  - define visible-but-unsupported policy
  - define launch limits and region limits
- Required minimum content:
  - supported rules
  - advisory-only rules
  - unsupported rules
  - visible-unsupported disclosure behavior
  - region limits
  - launch limits
  - rule-family disclosure wording
- Next Step:
  - complete the support matrix and align it with launch-scope wording

### T-0005
- Phase: Phase 0
- Task Name: Create decision states
- Status: IN_PROGRESS
- Files Touched:
  - `DECISION_STATES.md`
- Purpose:
  - lock allowed result states and meanings
  - define evidence thresholds and state transitions
  - define escalation into refusal
- Required minimum content:
  - state names
  - meaning
  - evidence level
  - user-facing copy guidance
  - transitions
  - refusal escalation
- Next Step:
  - finish exact semantics for `ILLEGAL`, `PROBABLY_ILLEGAL`, `UNVERIFIABLE`, `PROBABLY_LEGAL`, and `LEGAL_WITH_BUFFER`

### T-0006
- Phase: Phase 0
- Task Name: Create claims policy
- Status: IN_PROGRESS
- Files Touched:
  - `CLAIMS_POLICY.md`
- Purpose:
  - prevent the product from claiming more than it supports
  - define mandatory caveats and disclosure obligations
- Required minimum content:
  - approved claims
  - prohibited claims
  - required limitations
  - positive-result caveat
  - negative-result caveat
  - refusal copy obligations
- Next Step:
  - complete the allowed-forbidden-required claim matrix

### T-0007
- Phase: Phase 0
- Task Name: Create legal governance strategy
- Status: IN_PROGRESS
- Files Touched:
  - `legal_governance_strategy.md`
- Purpose:
  - define how legal-source updates are reviewed, approved, locked, and propagated
- Required minimum content:
  - owner roles
  - source precedence
  - update trigger conditions
  - locked-date policy
  - review path
  - approval path
  - downstream update rules
- Next Step:
  - complete the locked-date and approval workflow

### T-0008
- Phase: Phase 0
- Task Name: Create scope and claims strategy
- Status: IN_PROGRESS
- Files Touched:
  - `scope_and_claims_strategy.md`
- Purpose:
  - control how scope changes, claim changes, and launch-scope changes can be proposed and validated
- Required minimum content:
  - scope entry rule
  - scope expansion rule
  - claim wording gate
  - required validation before support claims
  - launch-scope update rule
  - refusal for unsupported-visible conditions
- Next Step:
  - complete scope-entry and claim-change control rules

### T-0009
- Phase: Phase 0
- Task Name: Validate Phase 0 completion
- Status: BLOCKED
- Files Touched:
  - `TASKLIST_V4_FINAL.md`
  - `LEGAL_SOURCE_REGISTER.md`
  - `LEGAL_THRESHOLDS.md`
  - `SCOPE_AND_LIMITATIONS.md`
  - `DECISION_STATES.md`
  - `CLAIMS_POLICY.md`
  - `legal_governance_strategy.md`
  - `scope_and_claims_strategy.md`
- Purpose:
  - prevent movement to Phase 1 before legal, scope, threshold, and claim ambiguity are removed
- Blockers:
  - `LEGAL_SOURCE_REGISTER.md` lacks fully verified official-source details
  - `LEGAL_THRESHOLDS.md` lacks complete threshold traceability to controlling sources
- Next Step:
  - complete T-0002 and T-0003, then re-run Phase 0 validation

---

# 10. BLOCKER LOG

Current blockers:

- Task ID: T-0009
  Date: 2026-03-25
  Blocker:
    - verified official legal-source details are incomplete
    - threshold traceability to controlling sources is incomplete
  Impact:
    - Phase 0 cannot be validated
    - Phase 1 must not start
  Required Resolution:
    - complete REQUIRED fields in `LEGAL_SOURCE_REGISTER.md`
    - link each V1 threshold in `LEGAL_THRESHOLDS.md` to controlling legal sources
  Temporary Action:
    - keep Phase 0 active
    - do not proceed to later phases

---

# 11. FILE CREATION OR LOCK LOG

- Date: 2026-03-25
  File: `DK_PARKING_AGENT_MASTER_SPEC_V4_FINAL.md`
  Reason: Lock updated master specification
  Task ID: T-0001

- Date: 2026-03-25
  File: `ROADMAP_V8_FINAL.md`
  Reason: Lock updated execution roadmap
  Task ID: T-0001

- Date: 2026-03-25
  File: `RULES_V2_FINAL.md`
  Reason: Align execution rules with locked master specification and roadmap
  Task ID: T-0001

- Date: 2026-03-25
  File: `TASKLIST_V4_FINAL.md`
  Reason: Align execution control with locked master specification and roadmap
  Task ID: T-0001

- Date: 2026-03-25
  File: `LEGAL_SOURCE_REGISTER.md`
  Reason: Create Phase 0 legal source register (skeleton; official-source fields TBD)
  Task ID: T-0002

- Date: 2026-03-25
  File: `LEGAL_THRESHOLDS.md`
  Reason: Create Phase 0 legal thresholds baseline (skeleton; traceability TBD)
  Task ID: T-0003

- Date: 2026-03-25
  File: `SCOPE_AND_LIMITATIONS.md`
  Reason: Create Phase 0 scope and limitations definition (skeleton)
  Task ID: T-0004

- Date: 2026-03-25
  File: `DECISION_STATES.md`
  Reason: Create Phase 0 decision-state semantics (skeleton aligned to master spec)
  Task ID: T-0005

- Date: 2026-03-25
  File: `CLAIMS_POLICY.md`
  Reason: Create Phase 0 claims policy (skeleton aligned to master spec)
  Task ID: T-0006

- Date: 2026-03-25
  File: `legal_governance_strategy.md`
  Reason: Create Phase 0 legal governance strategy (skeleton)
  Task ID: T-0007

- Date: 2026-03-25
  File: `scope_and_claims_strategy.md`
  Reason: Create Phase 0 scope and claims change-control strategy (skeleton)
  Task ID: T-0008

---

# 12. FILE MODIFICATION LOG

Current entries:
- Date: 2026-03-25
  File: `TASKLIST_V4_FINAL.md`
  Reason: Update next action and log Phase 0 foundation file creation
  Task ID: T-0002..T-0009

- Date: 2026-03-25
  File: `WHAT_DID_I_DO.md`
  Reason: Initialize mandatory work log and record Phase 0 work
  Task ID: T-0002..T-0009

---

# 13. PHASE COMPLETION CHECKLIST

## Phase 0 — Legal and product foundation
- [x] Locked versioned source-of-truth files exist
- [ ] Legal source register created and verified
- [ ] Legal thresholds created with traceability
- [ ] Scope and limitations defined
- [ ] Decision states defined
- [ ] Claims policy defined
- [ ] Legal governance strategy created
- [ ] Scope and claims strategy created
- [ ] Validation passed

## Phase 1 — Scope, claims, and decision-state lock
- [ ] Controlled vocabulary is locked
- [ ] Disclosure wording is locked
- [ ] Launch scope register exists
- [ ] User disclosure and copy file exists
- [ ] Validation passed

## Phase 2 — System architecture and SDK boundary
- [ ] Architecture is locked
- [ ] SDK input and output contracts exist
- [ ] Policy registry spec exists
- [ ] Versioning policy exists
- [ ] Validation passed

## Phase 3 — Dataset model and legal feature representation
- [ ] Dataset strategy exists
- [ ] Feature schema exists
- [ ] Launch scope register updated
- [ ] Validation passed

## Phase 4 — Measurement backbone and AR strategy
- [ ] AR measurement strategy exists
- [ ] Architecture updated
- [ ] Output contract updated
- [ ] Validation passed

## Phase 5 — Target selection and vehicle footprint
- [ ] Target selection policy exists
- [ ] Vehicle footprint strategy exists
- [ ] Validation passed

## Phase 6 — Legal-boundary localization
- [ ] Boundary localization strategy exists
- [ ] Validation passed

## Phase 7 — Feature candidate matching
- [ ] Candidate matching strategy exists
- [ ] Validation passed

## Phase 8 — Uncertainty, confidence, and refusal policy
- [ ] Uncertainty strategy exists
- [ ] Decision states updated
- [ ] Output contract updated
- [ ] Validation passed

## Phase 9 — iOS vertical slice
- [ ] One true end-to-end slice exists
- [ ] Vertical slice report exists
- [ ] Validation passed

## Phase 10 — Validation hardening
- [ ] Validation plan exists
- [ ] Field test matrix exists
- [ ] Guardrails are met
- [ ] Validation passed

## Phase 11 — iOS product integration
- [ ] Capture guidance strategy exists
- [ ] Retry and refusal UX strategy exists
- [ ] Updated architecture and copy files exist
- [ ] Validation passed

## Phase 12 — Release safety, privacy, and disclosures
- [ ] Privacy and telemetry spec exists
- [ ] Observability and replay strategy exists
- [ ] Release readiness checklist exists
- [ ] Validation passed

## Phase 13 — Public launch preparation
- [ ] Launch scope is locked
- [ ] Public wording is locked
- [ ] Launch runbook exists
- [ ] Validation passed

## Phase 14 — Android parity and second-platform work
- [ ] Android parity strategy exists
- [ ] Versioning policy updated
- [ ] SDK API contract updated
- [ ] Validation passed

---

# 14. NEXT ACTION

```text
Create the missing Phase 0 foundation files (non-empty skeletons) in the mandated order, then complete the REQUIRED fields in LEGAL_SOURCE_REGISTER.md and complete threshold traceability in LEGAL_THRESHOLDS.md, then re-run T-0009.
```

---

# 15. FINAL RULE

If a task is not represented here, it does not exist for execution control.

If a blocker is not represented here, it is being hidden.

If the active phase is not respected here, the implementation is unsafe.

---
