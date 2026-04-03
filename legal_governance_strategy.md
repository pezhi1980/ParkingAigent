# LEGAL GOVERNANCE STRATEGY — DK PARKING ENGINE
## Version 1 — Phase 0 foundation document
## Status: DONE
## Locked baseline date: 2026-03-25

## 1. Purpose
Define how legal-source updates are detected, reviewed, approved, locked, and propagated across the project.
No silent legal drift is allowed.

## 2. Roles and ownership (locked role definitions — named assignments recorded separately)

### 2.1 Legal Source Owner
- Responsibility: Monitor Danish statutory law, executive orders, and official guidance relevant to supported rule families for changes. Verify official sources. Approve legal-source updates.
- Requirement: Must have access to retsinformation.dk and authoritative Danish legal sources.
- Named assignment: recorded in project team registry (not stored in this file to avoid stale names).

### 2.2 Engineering Owner
- Responsibility: Translate legal-source changes into implementation updates across threshold tables, evaluator logic, and SDK contracts. Confirm that implementation changes are traceable to legal-source decisions.
- Named assignment: recorded in project team registry.

### 2.3 Product Owner
- Responsibility: Ensure that legal-source changes are reflected in product scope, claims wording, disclosure texts, and release blockers. Approve scope changes that arise from legal-source updates.
- Named assignment: recorded in project team registry.

### 2.4 Release Authority
- Responsibility: Final approval before any release that follows a legal-source update. Must confirm that all downstream propagation steps are complete and no unresolved traceability gaps remain.
- Named assignment: recorded in project team registry.

### 2.5 Minimum quorum for legal-source change approval
A legal-source change affecting thresholds, scope, or claim semantics requires explicit sign-off from: Legal Source Owner AND Product Owner AND Engineering Owner.
A legal-source change affecting LEGAL_SOURCE_REGISTER.md only (access paths, review dates, TBD population) may be approved by Legal Source Owner alone.

## 3. Update triggers
A legal review MUST be triggered when any of the following occur:
- statutory law changes relevant to supported rule families
- executive orders/regulations affecting signs/markings change
- official guidance materially changes interpretation-relevant boundary concepts
- launch region changes (municipal guidance review)
- validation or field reports reveal ambiguity attributable to legal-source interpretation
- a NEEDS_LEGAL_REVIEW item is ready to be resolved

## 4. Locked-date policy
- Each release must reference a locked legal-source baseline date.
- The baseline date must be recorded in:
  - LEGAL_SOURCE_REGISTER.md
  - LEGAL_THRESHOLDS.md
  - DK_PARKING_AGENT_MASTER_SPEC_V4_FINAL.md (if it changes)
- The locked date may not be silently advanced. An advance requires a full review cycle.

## 5. Review and approval workflow (mandatory — step by step)

### Step 1 — Trigger detection
The Legal Source Owner detects or receives notice of a potential legal-source change.
Record the trigger event in WHAT_DID_I_DO.md with date and trigger description.

### Step 2 — Scope assessment
The Legal Source Owner determines which V1 threshold entries, rule families, or scope items are affected.
Create a blocker entry in TASKLIST_V4_FINAL.md for each affected item.

### Step 3 — Official source verification
Obtain the new official source from retsinformation.dk or the appropriate Danish public authority.
Do not use unofficial summaries, news articles, or secondary sources.

### Step 4 — Document updates
Update LEGAL_SOURCE_REGISTER.md with the new or corrected source entry.
Update LEGAL_THRESHOLDS.md for any changed threshold or traceability field.
Update SCOPE_AND_LIMITATIONS.md, DECISION_STATES.md, CLAIMS_POLICY.md as needed.

### Step 5 — Cross-check and consistency
Verify consistency across all affected documents.
Record the changes in WHAT_DID_I_DO.md with before/after summary.

### Step 6 — Approval
Obtain sign-off per section 2.5 quorum requirements.
Record approval in WHAT_DID_I_DO.md.

### Step 7 — Resolve blockers
Mark affected TASKLIST_V4_FINAL.md items as DONE or update their next steps.
Update locked baseline date if the change was substantive.

### Step 8 — Implementation follow-through
Engineering Owner ensures that any impacted implementation files are updated in the relevant implementation phase.

## 6. Downstream propagation rules
If a legal source change affects:
- thresholds → update LEGAL_THRESHOLDS.md and any evaluator specs
- scope meaning → update SCOPE_AND_LIMITATIONS.md
- claims/disclosures → update CLAIMS_POLICY.md and later copy files
- refusal logic semantics → update DECISION_STATES.md and later uncertainty strategy
- output contract fields → update OUTPUT_CONTRACT.md (Phase 2+)
- SDK behavior → update SDK_API_CONTRACT.md (Phase 2+)

## 7. NEEDS_LEGAL_REVIEW deferred items
Items currently deferred with NEEDS_LEGAL_REVIEW status:
- BS-MARK-SEG: exact start-of-segment semantics and continuity/gap semantics for bus-stop marked segment extent. V1 implementation uses safe three-tier fallback (see LEGAL_THRESHOLDS.md section 6). Resolution deferred to post-Version-1 legal review.

When any NEEDS_LEGAL_REVIEW item is ready for resolution, the full review and approval workflow (section 5) MUST be followed.

## 8. Auditability requirements
- Every change must be traceable to official controlling sources.
- Every change must be versioned and logged in WHAT_DID_I_DO.md.
- No silent meaning changes across versions.
- Audit trail: LEGAL_SOURCE_REGISTER.md + LEGAL_THRESHOLDS.md + WHAT_DID_I_DO.md entries form the legal audit chain.
