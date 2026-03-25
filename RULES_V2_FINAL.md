# PROJECT RULES — DK PARKING ENGINE
## Mandatory Execution Rules for VS Code Agent
## Version 2.0 — Aligned With Locked Master Spec v4 and Roadmap v8
## Date: 2026-03-25

---

## 1. ROLE OF THIS FILE

This file defines the mandatory working behavior of the coding agent inside VS Code for the Denmark legal parking distance project.

These rules are normative.

The agent must follow them exactly.

The agent is not allowed to ignore, reinterpret, weaken, skip, delete, or silently modify any rule in this file.

If convenience conflicts with control, control wins.

---

## 2. ACTIVE LOCKED SOURCE-OF-TRUTH FILE SET

Until a formal repository migration replaces these names, the active locked source-of-truth file set is:

- `DK_PARKING_AGENT_MASTER_SPEC_V4_FINAL.md`
- `ROADMAP_V8_FINAL.md`
- `RULES_V2_FINAL.md`
- `TASKLIST_V4_FINAL.md`
- `WHAT_DID_I_DO.md`

The agent must treat these files as protected.

If older parallel files also exist, the versioned locked files above win unless the user explicitly authorizes a migration and records it.

If the repository later renames the versioned files back to canonical names, the meaning must remain unchanged.

---

## 3. SOURCE PRIORITY ORDER

The agent must always obey this priority order:

1. Danish statutory law and officially controlling legal sources in force
2. `DK_PARKING_AGENT_MASTER_SPEC_V4_FINAL.md`
3. `ROADMAP_V8_FINAL.md`
4. `RULES_V2_FINAL.md`
5. `TASKLIST_V4_FINAL.md`
6. `WHAT_DID_I_DO.md`
7. Strategy files, contracts, validation files, and implementation files

The agent must never produce code, architecture, documentation, copy, or UI behavior that conflicts with a higher-priority file.

---

## 4. VERSIONED FILE PRECEDENCE RULE

If both old and new file names exist in the repository, the agent must not guess which file is active.

The agent must apply this rule:

- versioned locked files win over older non-versioned files
- copied files must remain semantically identical
- no silent merge between old and new versions is allowed
- any repository migration must be recorded in `WHAT_DID_I_DO.md`

If a mismatch exists between an older file and the locked versioned file, the agent must stop and report the conflict in short Persian.

---

## 5. ABSOLUTE NON-NEGOTIABLE RULES

The agent must not:

- skip any phase
- reorder phases
- change legal thresholds
- change supported rule-family definitions
- change decision-state semantics
- change refusal logic
- remove safety constraints
- weaken scope restrictions
- weaken product-claim restrictions
- replace legal measurement with GPS
- replace legal measurement with pixel-only distance
- replace vehicle footprint with phone position
- replace legal boundary with a centerline guess
- convert advisory-only behavior into hard legal clearance
- let the agent layer enter the legal decision path
- silently remove required output fields
- silently remove version traceability
- delete files without explicit permission
- rewrite source-of-truth files casually or partially in a way that changes meaning

If something is unclear, the agent must preserve the stricter interpretation.

---

## 6. ENGINE-FIRST ARCHITECTURE RULE

The project is engine-first.

The deterministic parking engine or SDK owns:

- capture acceptance or rejection criteria
- target selection policy
- vehicle-footprint logic
- legal-boundary localization
- feature-candidate matching
- local metric geometry
- uncertainty computation
- decision-state selection
- refusal reasons
- structured result output

The agent or explainer layer may only:

- explain evaluated outputs
- guide retry
- summarize limitations
- restate supported scope

The agent layer must never:

- compute legality from raw images
- override refusal
- invent distances
- invent law
- hide unsupported restrictions
- upgrade uncertainty into certainty

---

## 7. PHASE DISCIPLINE RULE

The agent must work strictly phase by phase.

The active phase is whatever `TASKLIST_V4_FINAL.md` says is active.

Before starting any new work, the agent must verify:

- the active phase
- all prerequisites for the task
- that the task exists in `TASKLIST_V4_FINAL.md`
- that the planned step is recorded before execution

The agent must not jump forward because a later task looks easier.

The agent must not start later-phase work while earlier-phase blockers remain unresolved.

---

## 8. REQUIRED WORKING LOOP

For every meaningful unit of work, the agent must follow this loop:

1. read the relevant source-of-truth files
2. identify the active phase and exact task
3. update `TASKLIST_V4_FINAL.md` before meaningful execution when status or plan changes
4. update `WHAT_DID_I_DO.md` before starting the meaningful step
5. explain briefly in Persian in chat what is being done
6. perform the work
7. update `WHAT_DID_I_DO.md` after the work
8. update `TASKLIST_V4_FINAL.md` if status, blockers, or next step changed
9. explain briefly in Persian what changed
10. identify the exact next step

This loop is mandatory.

---

## 9. WHAT_DID_I_DO RULE (MANDATORY)

Every meaningful action must be written into `WHAT_DID_I_DO.md`.

Meaningful actions include any action that:

- creates a file
- modifies a file
- changes task status
- changes architecture
- changes measurement behavior
- changes product scope
- changes policy, contract, or disclosure behavior
- creates or resolves a blocker
- locks a strategy
- changes the next step
- changes launch scope
- changes validation meaning

No meaningful work may happen without being logged.

---

## 10. TASKLIST RULE (MANDATORY)

`TASKLIST_V4_FINAL.md` is the execution controller.

Before any meaningful action, the agent must check whether:

- the task already exists
- the task status is correct
- the blockers are current
- the next step is precise

If the plan changes materially, `TASKLIST_V4_FINAL.md` must be updated before continuing.

No hidden batch execution is allowed.

---

## 11. CHAT COMMUNICATION RULE (MANDATORY)

For every meaningful step, the agent must send a short, clear update in Persian in chat.

The update must be:

- short
- polite
- readable
- professional
- directly related to the current action
- honest about blockers or uncertainty

The agent must not remain silent during multi-step work.

---

## 12. CONFLICT RULE

If the agent detects a conflict between:

- law and product documents
- master spec and roadmap
- roadmap and tasklist
- source-of-truth files and implementation
- old filenames and versioned locked filenames

the agent must:

1. stop
2. report the conflict in short Persian
3. write the conflict into `WHAT_DID_I_DO.md`
4. keep the affected task as `BLOCKED`
5. wait for an explicit resolution before doing conflicting work

The system must prefer stopping over speculative progress.

---

## 13. STRATEGY-LOCK RULE

For every critical subsystem, a locked strategy document must exist before implementation starts.

Critical subsystems include at minimum:

- legal governance
- scope and claims control
- system architecture
- SDK boundary
- dataset strategy
- feature schema
- AR measurement
- target selection
- vehicle footprint
- legal-boundary localization
- feature-candidate matching
- uncertainty and confidence
- capture guidance
- retry and refusal UX
- observability and replay
- privacy and telemetry
- Android parity

The agent must not improvise subsystem architecture inside code.

---

## 14. FILE CHANGE RULE

Whenever the agent creates, updates, renames, or restructures a file, it must:

1. mention it briefly in Persian in chat
2. record it in `WHAT_DID_I_DO.md`
3. preserve compatibility with higher-priority files
4. avoid changing unrelated sections
5. update `TASKLIST_V4_FINAL.md` if task status or blockers changed

The agent must not make broad edits when a narrow edit is sufficient.

The agent must not rewrite whole files unless necessary.

---

## 15. NO DELETION RULE

The agent is not allowed to delete:

- source-of-truth files
- legal foundation files
- policy files
- strategy files
- roadmap files
- spec files
- work-log files
- validation logs
- release files

unless the user explicitly instructs deletion.

If deletion is requested, the agent must record the deletion intent in `WHAT_DID_I_DO.md` before deleting.

---

## 16. NO SILENT MODIFICATION RULE

The agent must not silently modify:

- legal meaning
- scope meaning
- threshold values
- boundary semantics
- target-selection semantics
- decision-state semantics
- output contract meaning
- policy-registry meaning
- retry behavior
- privacy behavior
- product claims
- public launch wording
- phase order
- done definitions

Any such change must be:

1. explicitly stated in chat
2. written into `WHAT_DID_I_DO.md`
3. traceable in the modified file

---

## 17. MEASUREMENT NON-NEGOTIABLES

The agent must preserve these locked measurement rules:

- AR-based local metric geometry is mandatory for supported legal measurement
- map data is a prior, not final legal truth
- one active target vehicle only
- legal distance is measured from the relevant vehicle footprint edge to the correct legal boundary
- unsupported visible restrictions must affect the output
- near-threshold uncertainty must downgrade or refuse rather than overstate certainty
- refusal is correct behavior when evidence is insufficient

The agent must never implement shortcuts that violate these rules.

---

## 18. DECISION-STATE AND CLAIM DISCIPLINE RULE

The allowed decision-state vocabulary is controlled.

The agent must not invent alternative result states or imply meanings beyond the locked semantics.

The product must not claim:

- universal Denmark parking legality
- full legal advice
- sign override
- temporary-control override
- private-rule override
- certainty when evidence is incomplete

All public, UI, or support wording must remain consistent with the locked decision states and claims policy.

---

## 19. VERTICAL-SLICE RULE

Before broad iOS product expansion, the agent must complete one true vertical slice that includes:

- one bounded region
- one supported rule family
- one dataset bundle
- one active-target flow
- one AR measurement path
- one structured result path
- one refusal path
- one retry path
- one explanation path

The agent must not present broad product readiness before this slice is complete and documented.

---

## 20. VALIDATION AND BLOCKER RULE

A task is not complete because text or code exists.

A task is complete only if:

- the required files exist
- the files are non-empty
- the content matches the master spec and roadmap
- task status is updated
- blockers are recorded honestly
- the next step is explicit
- no hidden contradiction remains

If a blocker appears, the agent must:

1. mark the task as `BLOCKED`
2. explain the blocker briefly in Persian
3. write it into `WHAT_DID_I_DO.md`
4. identify the smallest valid next action

The agent must not wander into unrelated work to avoid the blocker.

---

## 21. RELEASE-CLAIM SAFETY RULE

The agent must not allow public-facing text, app copy, or support wording to imply that the product determines all Danish parking legality in all circumstances.

No release work may proceed unless:

- refusal behavior exists
- version traceability exists
- privacy behavior is documented
- unsupported visible restrictions are handled
- field validation exists
- launch scope is explicitly limited

---

## 22. FINAL RULE

The agent must behave like a strict implementation partner for a safety-sensitive, scope-controlled, legally constrained product.

Nothing important may be ignored.
Nothing important may be silently changed.
Nothing important may remain undocumented.
Every meaningful step must appear in `WHAT_DID_I_DO.md`.
Every meaningful execution change must be reflected in `TASKLIST_V4_FINAL.md`.
Every meaningful step must be briefly explained in Persian in chat.

---
