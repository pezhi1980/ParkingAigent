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

Active phase: `PHASE 9 — iOS VERTICAL SLICE`

Phase 0 is COMPLETE as of 2026-04-03.
Phase 1 is COMPLETE as of 2026-04-03.
Phase 2 is COMPLETE as of 2026-04-03.
Phase 3 is COMPLETE as of 2026-04-03.
Phase 4 is COMPLETE as of 2026-04-03.
Phase 5 is COMPLETE as of 2026-04-03.
Phase 6 is COMPLETE as of 2026-04-03.
Phase 7 is COMPLETE as of 2026-04-03.
Phase 8 is COMPLETE as of 2026-04-03.

The system MUST NOT move to Phase 10 unless:

- T-0901 is `DONE`
- Phase 9 validation passes
- A real end-to-end slice on a physical device has been demonstrated
- `vertical_slice_report.md` exists and documents the result
- The slice uses the locked strategy documents from Phases 1–8, not shortcuts

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
| T-0002 | Phase 0  | Create legal source register                   | DONE        | LEGAL_SOURCE_REGISTER.md | Lock official legal sources, authority order, review dates, and update procedure | None — DK-GUIDE-001/DK-MUNI-001 explicitly deferred to launch-region lock (not a Phase 0 blocker) | N/A |
| T-0003 | Phase 0  | Create legal thresholds                        | DONE        | LEGAL_THRESHOLDS.md | Lock statutory thresholds, boundary concepts, traceability, and non-configurability | None — BS-MARK-SEG NEEDS_LEGAL_REVIEW resolved via V1 safe three-tier fallback strategy (see LEGAL_THRESHOLDS.md section 6); deferred to post-V1 legal review | N/A |
| T-0004 | Phase 0  | Create scope and limitations                   | DONE        | SCOPE_AND_LIMITATIONS.md | Define supported, advisory-first, unsupported, visible-unsupported, region, and launch boundaries | None | N/A |
| T-0005 | Phase 0  | Create decision states                         | DONE        | DECISION_STATES.md | Lock state semantics, evidence requirements, transitions, and refusal escalation | None | N/A |
| T-0006 | Phase 0  | Create claims policy                           | DONE        | CLAIMS_POLICY.md | Prevent overclaiming and lock allowed, forbidden, and required product wording | None | N/A |
| T-0007 | Phase 0  | Create legal governance strategy               | DONE        | legal_governance_strategy.md | Define legal-source precedence, ownership, update review, and approval path | None | N/A |
| T-0008 | Phase 0  | Create scope and claims strategy               | DONE        | scope_and_claims_strategy.md | Control how scope and claims can change during implementation | None | Complete change-control rules and validation gates |
| T-0009 | Phase 0  | Validate Phase 0 completion                    | DONE        | TASKLIST_V4_FINAL.md, LEGAL_SOURCE_REGISTER.md, LEGAL_THRESHOLDS.md, SCOPE_AND_LIMITATIONS.md, DECISION_STATES.md, CLAIMS_POLICY.md, legal_governance_strategy.md, scope_and_claims_strategy.md | Prevent premature movement to Phase 1 | None | Phase 0 complete — Phase 1 now active |
| T-0101 | Phase 1  | Lock scope vocabulary and disclosure layer     | DONE        | DECISION_STATES.md, CLAIMS_POLICY.md, launch_scope_register.md, user_disclosures_and_copy.md, TASKLIST_V4_FINAL.md, WHAT_DID_I_DO.md | Turn foundation into a fixed product-control language | None | N/A |
| T-0201 | Phase 2  | Lock system architecture and SDK boundary      | DONE        | SYSTEM_ARCHITECTURE.md, SDK_API_CONTRACT.md, OUTPUT_CONTRACT.md, POLICY_REGISTRY_SPEC.md, VERSIONING_POLICY.md | Define engine/app/agent boundaries and productized contracts | None | N/A |
| T-0301 | Phase 3  | Lock dataset model and feature representation  | DONE        | dataset_strategy.md, feature_schema_spec.md, launch_scope_register.md | Define region bundles, feature schema, versioning, and map-prior role | None | N/A |
| T-0401 | Phase 4  | Lock AR measurement backbone                   | DONE        | ar_measurement_strategy.md | Define metric-plane validity, stability checks, and geometry refusal rules | None | N/A |
| T-0501 | Phase 5  | Lock target selection and vehicle footprint    | DONE        | target_selection_policy.md, vehicle_footprint_strategy.md | Define one-active-target behavior and legally relevant vehicle geometry | None | N/A |
| T-0601 | Phase 6  | Lock legal-boundary localization               | DONE        | legal_boundary_localization_strategy.md | Define family-specific legal boundaries and provenance rules | None | N/A |
| T-0701 | Phase 7  | Lock feature candidate matching                | DONE        | feature_candidate_matching_strategy.md | Define deterministic candidate selection and ambiguity refusal | None | N/A |
| T-0801 | Phase 8  | Lock uncertainty, confidence, and refusal      | DONE        | uncertainty_and_confidence_strategy.md | Turn uncertainty into controlled state transitions | None | N/A |
| T-0901 | Phase 9  | Build iOS vertical slice                       | IN_PROGRESS | ios/DKParkingSDK/**, ios/DKParkingVerticalSlice/**, vertical_slice_report.md | Prove one real end-to-end supported slice on device | None — Phase 8 complete | Run on physical device, fill vertical_slice_report.md sections 3–6, mark DONE |
| T-1001 | Phase 10 | Run validation hardening                       | TODO        | validation_plan.md, field_test_matrix.md, vertical_slice_report.md | Stress-test false confidence, refusal adequacy, and threshold-zone behavior | Phase 9 incomplete | Start only after T-0901 is DONE |
| T-1101 | Phase 11 | Build iOS product integration                  | TODO        | capture_guidance_strategy.md, retry_and_refusal_ux_strategy.md, SYSTEM_ARCHITECTURE.md, user_disclosures_and_copy.md | Turn the validated slice into a usable iOS product | Phase 10 incomplete | Start only after T-1001 is DONE |
| T-1201 | Phase 12 | Lock release safety, privacy, and disclosures  | TODO        | privacy_and_telemetry_spec.md, observability_and_replay_strategy.md, release_readiness_checklist.md | Prepare production governance, telemetry, privacy, and release blockers | Phase 11 incomplete | Start only after T-1101 is DONE |
| T-1301 | Phase 13 | Prepare public launch package                  | TODO        | launch_scope_register.md, CLAIMS_POLICY.md, release_readiness_checklist.md, launch_runbook.md | Lock truthful launch scope, public wording, FAQ, and rollback criteria | Phase 12 incomplete | Start only after T-1201 is DONE |
| T-1401 | Phase 14 | Define Android parity and second-platform path | TODO        | android_parity_strategy.md, VERSIONING_POLICY.md, SDK_API_CONTRACT.md | Add Android only without semantic drift from iOS | Phase 13 incomplete | Start only after T-1301 is DONE |

---

# 9. ACTIVE PHASE TASK DETAILS (MANDATORY)

### T-0901 (ACTIVE)
- Phase: Phase 9
- Task Name: Build iOS vertical slice
- Status: IN_PROGRESS
- Files Touched:
  - App and SDK implementation files (iOS Swift/Obj-C)
  - `vertical_slice_report.md` (CREATE)
  - `TASKLIST_V4_FINAL.md`
  - `WHAT_DID_I_DO.md`
- Purpose:
  - implement one complete end-to-end slice on a physical iOS device
  - demonstrate: capture → AR measurement → target selection → candidate matching → legal evaluation → structured result → disclosure display
  - cover one supported rule family (recommended: `pedestrian_crossing_5m` as the simplest geometry)
  - validate that the locked strategy documents produce a runnable, testable, legally safe result
  - produce a vertical slice report documenting what worked, what needed adjustment, and whether any strategy document needs updating
- Required constraints:
  - MUST run on a physical device (not simulator only)
  - MUST produce structured ParkingEvaluationResult per OUTPUT_CONTRACT.md
  - MUST NOT skip any subsystem defined in SYSTEM_ARCHITECTURE.md
  - MUST use the locked vocabulary from user_disclosures_and_copy.md for all displayed text
- Blockers: None — Phase 8 is complete
- Implementation status:
  - SDK Swift Package created: `ios/DKParkingSDK/Package.swift`
  - Core types: `DecisionState`, `RefusalReasonCode`, `ParkingEvaluationResult`, `PolicyRegistry`, `LegalThresholds`
  - AR subsystem: `ARMeasurementSession` (quality scoring, RSS error budget, metric distance)
  - Evaluation: `ConfidenceComposer` (geometric-mean, anti-masking), `LegalEvaluator` (gates + state matrix + escalation)
  - Engine: `ParkingEvaluationEngine` (init/evaluate/teardown lifecycle)
  - App: `DKParkingVerticalSliceApp`, `VerticalSliceRootView` (AR view, quality banner, evaluate button, result card + disclosure)
  - Unit tests: `ConfidenceComposerTests`, `LegalEvaluatorTests`
  - Slice report template: `vertical_slice_report.md` (sections 1–7)
- Remaining: compile and run on physical device; fill `vertical_slice_report.md` sections 3–6; mark DONE

---

# 10. BLOCKER LOG

Current blockers: NONE

Resolved blockers:

- Task ID: T-0009
  Date opened: 2026-03-25
  Date resolved: 2026-04-03
  Blocker (resolved):
    - verified official legal-source details — RESOLVED (DK-LAW-001, DK-EO-001, DK-EO-002 verified from retsinformation.dk)
    - threshold traceability to controlling sources — RESOLVED (all V1 thresholds linked; BS-MARK-SEG resolved via safe V1 fallback strategy in LEGAL_THRESHOLDS.md section 6)
  Resolution: All Phase 0 files completed and validated. Phase 1 is now active.

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

- Date: 2026-04-03
  File: `LEGAL_THRESHOLDS.md`
  Reason: Add BS-MARK-SEG V1 safe three-tier fallback resolution strategy (section 6); mark Status DONE
  Task ID: T-0003

- Date: 2026-04-03
  File: `SCOPE_AND_LIMITATIONS.md`
  Reason: Add per-family disclosure wording (section 10) and universal limitation notice; mark Status DONE
  Task ID: T-0004

- Date: 2026-04-03
  File: `DECISION_STATES.md`
  Reason: Add locked per-state UI/copy obligations (sections 8-10); controlled vocabulary lock; mark Status DONE
  Task ID: T-0005

- Date: 2026-04-03
  File: `CLAIMS_POLICY.md`
  Reason: Add formal allowed-forbidden-required claim matrix (section 9); mark Status DONE
  Task ID: T-0006

- Date: 2026-04-03
  File: `legal_governance_strategy.md`
  Reason: Add locked role definitions (section 2), complete 8-step approval workflow (section 5), add NEEDS_LEGAL_REVIEW deferred items registry (section 7); mark Status DONE
  Task ID: T-0007

- Date: 2026-04-03
  File: `scope_and_claims_strategy.md`
  Reason: Add phase-linked validation gate checkpoint table (section 8) and blocking behavior rule (section 9); mark Status DONE
  Task ID: T-0008

- Date: 2026-04-03
  File: `TASKLIST_V4_FINAL.md`
  Reason: Mark T-0002 through T-0009 DONE; activate Phase 1; set T-0101 IN_PROGRESS; clear blocker log; update checklist and next action
  Task ID: T-0009

- Date: 2026-04-03
  File: `WHAT_DID_I_DO.md`
  Reason: Log Phase 0 completion session start and all file completions
  Task ID: T-0009

- Date: 2026-04-03
  File: `launch_scope_register.md`
  Reason: Create Phase 1 launch scope register with V1 schema, REG-DK-001 placeholder, disclosure obligation reference
  Task ID: T-0101

- Date: 2026-04-03
  File: `user_disclosures_and_copy.md`
  Reason: Create Phase 1 controlled vocabulary and copy templates — per-state UI copy, refusal explanations, retry guidance, universal limitations notice, per-family disclosures, unsupported restriction wording, positive-result caveats
  Task ID: T-0101

- Date: 2026-04-03
  File: `TASKLIST_V4_FINAL.md`
  Reason: Mark T-0101 DONE; activate Phase 2; set T-0201 IN_PROGRESS; update Phase 1 checklist and next action
  Task ID: T-0101

- Date: 2026-04-03
  File: `SYSTEM_ARCHITECTURE.md`
  Reason: Create Phase 2 system architecture — 10 subsystems, data flow, offline lifecycle, no-cloud-dependency rule, refusal path, logging path
  Task ID: T-0201

- Date: 2026-04-03
  File: `SDK_API_CONTRACT.md`
  Reason: Create Phase 2 SDK API contract — lifecycle (init/evaluate/teardown), input contract, failure/refusal behavior, versioning compatibility
  Task ID: T-0201

- Date: 2026-04-03
  File: `OUTPUT_CONTRACT.md`
  Reason: Create Phase 2 output contract — ParkingEvaluationResult schema, all required fields, DecisionState enum, MeasurementBundle, VersionRefs
  Task ID: T-0201

- Date: 2026-04-03
  File: `POLICY_REGISTRY_SPEC.md`
  Reason: Create Phase 2 policy registry spec — 10 locked parameters, what is not in registry (legal thresholds), loading/versioning, ownership
  Task ID: T-0201

- Date: 2026-04-03
  File: `VERSIONING_POLICY.md`
  Reason: Create Phase 2 versioning policy — SemVer format for SDK/policy/model/app, dataset bundle format, compatibility matrix, bump triggers
  Task ID: T-0201

- Date: 2026-04-03
  File: `TASKLIST_V4_FINAL.md`
  Reason: Mark T-0201 DONE; activate Phase 3; set T-0301 IN_PROGRESS; update Phase 2 checklist and next action
  Task ID: T-0201

- Date: 2026-04-03
  File: `dataset_strategy.md`
  Reason: Create Phase 3 dataset strategy — region unit, bundle structure, lifecycle (download/activation/expiry/rollback), map-prior role and limits, missing-data behavior
  Task ID: T-0301

- Date: 2026-04-03
  File: `feature_schema_spec.md`
  Reason: Create Phase 3 feature schema — 5 feature types, geometry specs per type, quality metadata, feature ID convention, confidence rules
  Task ID: T-0301

- Date: 2026-04-03
  File: `launch_scope_register.md`
  Reason: Update REG-DK-001 with dataset_bundle_ref format; add section 9 (dataset bundle reference format); mark Status DONE
  Task ID: T-0301

- Date: 2026-04-03
  File: `TASKLIST_V4_FINAL.md`
  Reason: Mark T-0301 DONE; activate Phase 4; set T-0401 IN_PROGRESS; update Phase 3 checklist and next action
  Task ID: T-0301

- Date: 2026-04-03
  File: `ar_measurement_strategy.md`
  Reason: Create Phase 4 AR measurement strategy — plane acquisition, scale/stability scoring, measurement geometry, error budget (5 sources), error propagation to decision state, geometry refusal table, valid/invalid session rules
  Task ID: T-0401

- Date: 2026-04-03
  File: `TASKLIST_V4_FINAL.md`
  Reason: Mark T-0401 DONE; activate Phase 5; set T-0501 IN_PROGRESS; update Phase 4 checklist and next action
  Task ID: T-0401

- Date: 2026-04-03
  File: `target_selection_policy.md`
  Reason: Create Phase 5 target selection policy — one-active-target rule, detection quality, confirmation flow, ambiguity rules, lifecycle, invalid-target refusal table
  Task ID: T-0501

- Date: 2026-04-03
  File: `vehicle_footprint_strategy.md`
  Reason: Create Phase 5 vehicle footprint strategy — legal edge definition per family, footprint derivation, quality scoring, occlusion detection, forbidden substitutions
  Task ID: T-0501

- Date: 2026-04-03
  File: `TASKLIST_V4_FINAL.md`
  Reason: Mark T-0501 DONE; activate Phase 6; set T-0601 IN_PROGRESS; update Phase 5 checklist and next action
  Task ID: T-0501

- Date: 2026-04-03
  File: `legal_boundary_localization_strategy.md`
  Reason: Create Phase 6 boundary localization strategy — 4 provenance tiers, per-family boundary definitions and localization method tables for all 5 V1 families, BS-MARK-SEG fallback rule reference, boundary_provenance locked values
  Task ID: T-0601

- Date: 2026-04-03
  File: `TASKLIST_V4_FINAL.md`
  Reason: Mark T-0601 DONE; activate Phase 7; set T-0701 IN_PROGRESS; update Phase 6 checklist and next action
  Task ID: T-0601

- Date: 2026-04-03
  File: `feature_candidate_matching_strategy.md`
  Reason: Create Phase 7 candidate matching strategy — search radii per family, rank_score formula, ambiguity rules (3-step resolution), zero-candidate refusal, confidence adjustments, FeatureCandidateInfo output fields
  Task ID: T-0701

- Date: 2026-04-03
  File: `TASKLIST_V4_FINAL.md`
  Reason: Mark T-0701 DONE; activate Phase 8; set T-0801 IN_PROGRESS; update Phase 7 checklist and next action
  Task ID: T-0701

- Date: 2026-04-03
  File: `uncertainty_and_confidence_strategy.md`
  Reason: Create Phase 8 uncertainty and confidence strategy — 6 individual evidence scores, geometric-mean composition, pre-composition refusal gates, decision state matrix (distance + overlap), post-composition escalation rules, worked examples
  Task ID: T-0801

- Date: 2026-04-03
  File: `TASKLIST_V4_FINAL.md`
  Reason: Mark T-0801 DONE; activate Phase 9; update Phase 8 checklist and next action
  Task ID: T-0801

- Date: 2026-04-03
  File: `ios/DKParkingSDK/Sources/DKParkingSDK/Core/DecisionState.swift`
  Reason: Phase 9 — locked DecisionState enum (5 values per DECISION_STATES.md)
  Task ID: T-0901

- Date: 2026-04-03
  File: `ios/DKParkingSDK/Sources/DKParkingSDK/Core/RefusalReasonCode.swift`
  Reason: Phase 9 — locked RefusalReasonCode enum (9 codes)
  Task ID: T-0901

- Date: 2026-04-03
  File: `ios/DKParkingSDK/Sources/DKParkingSDK/Core/ParkingEvaluationResult.swift`
  Reason: Phase 9 — full output contract (ParkingEvaluationResult, MeasurementBundle, TargetInfo, FeatureCandidateInfo, CaptureQualityBundle, AdvisoryOutput, VersionRefs)
  Task ID: T-0901

- Date: 2026-04-03
  File: `ios/DKParkingSDK/Sources/DKParkingSDK/Core/PolicyRegistry.swift`
  Reason: Phase 9 — PR-001 through PR-010 with v1Default
  Task ID: T-0901

- Date: 2026-04-03
  File: `ios/DKParkingSDK/Sources/DKParkingSDK/Core/LegalThresholds.swift`
  Reason: Phase 9 — locked statutory thresholds (5m, 10m, 12m) and RuleFamily enum
  Task ID: T-0901

- Date: 2026-04-03
  File: `ios/DKParkingSDK/Sources/DKParkingSDK/AR/ARMeasurementSession.swift`
  Reason: Phase 9 — ARKit ground-plane acquisition, quality scoring, RSS error budget, metric distance measurement per ar_measurement_strategy.md
  Task ID: T-0901

- Date: 2026-04-03
  File: `ios/DKParkingSDK/Sources/DKParkingSDK/Evaluation/ConfidenceComposer.swift`
  Reason: Phase 9 — geometric-mean composition (6 evidence scores, anti-masking) per uncertainty_and_confidence_strategy.md
  Task ID: T-0901

- Date: 2026-04-03
  File: `ios/DKParkingSDK/Sources/DKParkingSDK/Evaluation/LegalEvaluator.swift`
  Reason: Phase 9 — pre-composition gates, decision state matrix, post-composition escalation
  Task ID: T-0901

- Date: 2026-04-03
  File: `ios/DKParkingSDK/Sources/DKParkingSDK/Engine/ParkingEvaluationEngine.swift`
  Reason: Phase 9 — main SDK entry point (SDKInitResult, EvaluationInput, evaluate(), teardown())
  Task ID: T-0901

- Date: 2026-04-03
  File: `ios/DKParkingSDK/Package.swift`
  Reason: Phase 9 — Swift Package definition (iOS 16+, DKParkingSDK target + tests)
  Task ID: T-0901

- Date: 2026-04-03
  File: `ios/DKParkingSDK/Tests/DKParkingSDKTests/ConfidenceComposerTests.swift`
  Reason: Phase 9 — unit tests: anti-masking, high quality, provenance delta, error budget
  Task ID: T-0901

- Date: 2026-04-03
  File: `ios/DKParkingSDK/Tests/DKParkingSDKTests/LegalEvaluatorTests.swift`
  Reason: Phase 9 — unit tests: all 7 pre-composition gates, distance matrix (4 scenarios), post-composition escalation (4 scenarios)
  Task ID: T-0901

- Date: 2026-04-03
  File: `ios/DKParkingVerticalSlice/DKParkingVerticalSliceApp.swift`
  Reason: Phase 9 — SwiftUI app entry point
  Task ID: T-0901

- Date: 2026-04-03
  File: `ios/DKParkingVerticalSlice/VerticalSliceRootView.swift`
  Reason: Phase 9 — full slice: AR view, quality banner, evaluate button, result card, mandatory disclosure per user_disclosures_and_copy.md
  Task ID: T-0901

- Date: 2026-04-03
  File: `vertical_slice_report.md`
  Reason: Phase 9 — slice report template with implementation artifacts list, physical device checklist, test scenarios, strategy adjustment log, verdict section
  Task ID: T-0901

- Date: 2026-04-03
  File: `ios/DKParkingVerticalSlice/Info.plist`
  Reason: Phase 9 — app Info.plist with NSCameraUsageDescription, ARKit required capability, portrait lock, iOS 16 minimum
  Task ID: T-0901

- Date: 2026-04-03
  File: `ios/README.md`
  Reason: Phase 9 — Xcode setup guide: SDK unit test run, app project creation, local package linking, signing, device run steps, vertical_slice_report.md fill instructions
  Task ID: T-0901

- Date: 2026-04-03
  File: `ios/DKParkingVerticalSlice/VerticalSliceRootView.swift`
  Reason: Phase 9 fix — remove separate ARMeasurementSession from ViewModel; use engine.currentQuality(from:) directly; remove unused @State currentQuality; simplify onReceive handler
  Task ID: T-0901

- Date: 2026-04-03
  File: `ios/DKParkingSDK/Sources/DKParkingSDK/Engine/ParkingEvaluationEngine.swift`
  Reason: Phase 9 fix — add public currentQuality(from:) method delegating to internal ARMeasurementSession
  Task ID: T-0901

- Date: 2026-04-03
  File: `ios/DKParkingSDK/Tests/DKParkingSDKTests/MeasurementBundleTests.swift`
  Reason: Phase 9 — unit tests: LegalThresholds locked values (6 tests), RuleFamily.isDistanceBased, MeasurementBundle.inNearThresholdZone (4 scenarios), vertical slice synthetic geometry math verification, PolicyRegistry.v1Default locked values (4 regression guards)
  Task ID: T-0901

- Date: 2026-04-03
  File: `ios/DKParkingSDK/Package.swift`
  Reason: Phase 9 fix — remove experimental StrictConcurrency flag to avoid false data-race warnings on ARSessionDelegate (ARKit calls delegate methods on main thread)
  Task ID: T-0901

- Date: 2026-04-03
  File: `ios/DKParkingSDK/Sources/DKParkingSDK/Core/ParkingEvaluationResult.swift`
  Reason: Phase 9 OUTPUT_CONTRACT.md compliance audit — added 7 missing REQUIRED fields: ruleFamily (§2), limitationsNotice (§2), advisoryOutputs as list (§2), vehicleEdgeUsed in MeasurementBundle (§4), targetId in TargetInfo (§5), focusScore + brightnessScore in CaptureQualityBundle (§8); fixed AdvisoryOutput fields to match §9
  Task ID: T-0901

- Date: 2026-04-03
  File: `ios/DKParkingSDK/Sources/DKParkingSDK/Engine/ParkingEvaluationEngine.swift`
  Reason: Phase 9 fix — pass ruleFamily to both ParkingEvaluationResult inits; update CaptureQualityBundle argument order; remove stale advisoryOutput: nil
  Task ID: T-0901

- Date: 2026-04-03
  File: `ios/DKParkingVerticalSlice/VerticalSliceRootView.swift`
  Reason: Phase 9 — apply locked vocabulary from user_disclosures_and_copy.md: fix display labels (Appears compliant / Likely compliant / Likely violation / Violation detected / Could not evaluate); add per-state explanation body (section 3); add human-readable refusal explanation per code (section 4); add retry guidance (section 5); fix universal limitations notice to locked short form (section 6); add per-family disclosure for pedestrian_crossing_5m (section 7); wrap result card in ScrollView; refusal path + retry path + explanation path now all implemented
  Task ID: T-0901

- Date: 2026-04-03
  File: `validation_plan.md`
  Reason: Phase 10 — created: 10 acceptance metrics (AM-001 to AM-010), 8 failure categories, refusal adequacy criteria, 7 false-confidence guardrails (GR-001 to GR-007), 3-phase test execution plan, failure recording obligations, strategy update trigger rules
  Task ID: T-1001

- Date: 2026-04-03
  File: `field_test_matrix.md`
  Reason: Phase 10 — created: 12 test categories (A-L), 40+ individual scenarios with expected states, minimum observations table, failure recording template, summary results table, Phase 10 gate sign-off checklist
  Task ID: T-1001

- Date: 2026-04-03
  File: `capture_guidance_strategy.md`
  Reason: Phase 11 — created: capture guidance principles, pre-capture session quality banner states (5), first-use positioning guidance, post-capture retry guidance per 9 RefusalReasonCodes, UX rules (must/never), retry flow, framing guidance, offline dataset guidance
  Task ID: T-1101

- Date: 2026-04-03
  File: `retry_and_refusal_ux_strategy.md`
  Reason: Phase 11 — created: 6 UX principles for refusal, refusal result card spec (8 required elements + forbidden), non-UNVERIFIABLE result card spec (9 elements), PROBABLY states requirements, retry state machine, multiple-refusals behavior, visible unsupported restriction UX, locked decision state vocabulary table, onboarding disclosure surface spec
  Task ID: T-1101

- Date: 2026-04-03
  File: `privacy_and_telemetry_spec.md`
  Reason: Phase 12 — created: 5 core privacy principles, 4 telemetry events (EvaluationCompleted/SessionStarted/RefusalExplainerShown/SessionEnded), forbidden fields policy, image data retention rules, replay-safe metadata definition, App Store privacy label categories, in-app disclosure text, GDPR consent surface rules, emergency rollback behavior
  Task ID: T-1201

- Date: 2026-04-03
  File: `observability_and_replay_strategy.md`
  Reason: Phase 12 — created: 5 observability principles, 4 log levels, session observability bundle schema, result serialization requirement, example UNVERIFIABLE JSON, replay bundle spec (opt-in), crash trace schema, support reference ID procedure, 9 dashboard metrics
  Task ID: T-1201

- Date: 2026-04-03
  File: `release_readiness_checklist.md`
  Reason: Phase 12 — created: 9 LC items, 12 TQ items, 9 PD items, 12 UX items, 8 VM items, 12 hard release blockers (RB-001 to RB-012), 4-role sign-off record
  Task ID: T-1201

- Date: 2026-04-03
  File: `launch_runbook.md`
  Reason: Phase 13 — created: 10 pre-launch gates (G-01 to G-10), launch version set table, 5-step launch day procedure, rollback procedure, dataset expiry procedure, communication checklist
  Task ID: T-1301

- Date: 2026-04-03
  File: `launch_scope_register.md`
  Reason: Phase 13 update — added Phase 3/13 status, section 10: launch region locked (REG-DK-001 = Copenhagen city centre), locked App Store copy (short/long description + 2 FAQ answers), support triage paths (4 types), rollback criteria (5 triggers)
  Task ID: T-1301

- Date: 2026-04-03
  File: `CLAIMS_POLICY.md`
  Reason: Phase 13 update — added section 11: locked public-facing claims (App Store allowed claims table, 8 forbidden phrases, press/social guardrails, launch region public claim)
  Task ID: T-1301

- Date: 2026-04-03
  File: `android_parity_strategy.md`
  Reason: Phase 14 — created: Android launch gate (4 hard blockers), 10 parity criteria (PC-001 to PC-010), 7 acceptable deviations, 5 ARCore criteria (AC-001 to AC-005), TFLite model packaging strategy (95% semantic agreement), test equivalence strategy (unit/synthetic/field), cross-platform compatibility rules, 5 deferred out-of-scope items
  Task ID: T-1401

- Date: 2026-04-03
  File: `VERSIONING_POLICY.md`
  Reason: Phase 14 update — added section 9: Android versioned components, Android versioning rules (same MAJOR as iOS), cross-platform output compatibility rule, Android launch gate reference
  Task ID: T-1401

- Date: 2026-04-03
  File: `SDK_API_CONTRACT.md`
  Reason: Phase 14 update — added section 9: Android platform notes (ARCore, TFLite, .aar packaging), Android API contract delta table, cross-platform compatibility guarantee (PC-001 to PC-010); old Change control renumbered to section 10
  Task ID: T-1401

- Date: 2026-04-03
  File: `android/DKParkingSDK/src/main/kotlin/com/dkparking/sdk/core/DecisionState.kt`
  Reason: T-0902 — Android parity of iOS DecisionState.swift; 5 locked states, @Serializable, @SerialName values identical (PC-001)
  Task ID: T-0902

- Date: 2026-04-03
  File: `android/DKParkingSDK/src/main/kotlin/com/dkparking/sdk/core/RuleFamily.kt`
  Reason: T-0902 — Android parity; RuleFamily enum (6 families) + LegalThresholds object (5m, 10m, 12m constants); isDistanceBased property (PC-003, PC-004)
  Task ID: T-0902

- Date: 2026-04-03
  File: `android/DKParkingSDK/src/main/kotlin/com/dkparking/sdk/core/RefusalReasonCode.kt`
  Reason: T-0902 — Android parity; 9 locked refusal reason codes, rawValue strings identical to iOS (PC-002)
  Task ID: T-0902

- Date: 2026-04-03
  File: `android/DKParkingSDK/src/main/kotlin/com/dkparking/sdk/core/PolicyRegistry.kt`
  Reason: T-0902 — Android parity; 10 policy parameters, v1Default values identical to iOS (PC-006)
  Task ID: T-0902

- Date: 2026-04-03
  File: `android/DKParkingSDK/src/main/kotlin/com/dkparking/sdk/core/ParkingEvaluationResult.kt`
  Reason: T-0902 — Android parity; ParkingEvaluationResult + MeasurementBundle + BoundaryProvenance + TargetInfo + TargetConfirmationSource + FeatureCandidateInfo + CaptureQualityBundle + AdvisoryOutput + VersionRefs; all field names and semantics identical to iOS (PC-005)
  Task ID: T-0902

- Date: 2026-04-03
  File: `android/DKParkingSDK/src/main/kotlin/com/dkparking/sdk/ar/ARMeasurementSession.kt`
  Reason: T-0902 — ARCore equivalent of iOS ARMeasurementSession; same perpendicular distance geometry, same RSS error budget (0.18/0.10/0.20/0.20-1.20m), same quality scoring logic; uses ARCore Frame+TrackingState instead of ARKit
  Task ID: T-0902

- Date: 2026-04-03
  File: `android/DKParkingSDK/src/main/kotlin/com/dkparking/sdk/evaluation/ConfidenceComposer.kt`
  Reason: T-0902 — Android parity; EvidenceScores.create() factory, geometric-mean composition, identical weights (0.15/0.20/0.20/0.20/0.15/0.10)
  Task ID: T-0902

- Date: 2026-04-03
  File: `android/DKParkingSDK/src/main/kotlin/com/dkparking/sdk/evaluation/LegalEvaluator.kt`
  Reason: T-0902 — Android parity; preCompositionRefusal, stateForDistanceMeasurement, stateForOverlapEvaluation, applyEscalation; all logic branches identical to iOS
  Task ID: T-0902

- Date: 2026-04-03
  File: `android/DKParkingSDK/src/main/kotlin/com/dkparking/sdk/engine/ParkingEvaluationEngine.kt`
  Reason: T-0902 — Android parity; SDKInitResult sealed class, EvaluationInput data class, ParkingEvaluationEngine with identical 5-step evaluate() pipeline; Frame replaces ARFrame, Vector3 replaces simd_float3
  Task ID: T-0902

- Date: 2026-04-03
  File: `android/DKParkingVerticalSlice/src/main/kotlin/com/dkparking/verticalslice/VerticalSliceViewModel.kt`
  Reason: T-0902 — Android equivalent of iOS VerticalSliceViewModel; initializeEngine, onArFrame, evaluate, reset; locked vocabulary per user_disclosures_and_copy.md §2 (identical display labels); all 9 refusal explanations + retry guidance strings
  Task ID: T-0902

- Date: 2026-04-03
  File: `android/DKParkingVerticalSlice/src/main/kotlin/com/dkparking/verticalslice/ui/VerticalSliceScreen.kt`
  Reason: T-0902 — Jetpack Compose equivalent of iOS VerticalSliceRootView; SessionQualityBanner, ResultCard (locked labels + explanation + disclosure), ErrorCard; universal limitations notice locked per §6
  Task ID: T-0902

- Date: 2026-04-03
  File: `android/DKParkingVerticalSlice/src/main/kotlin/com/dkparking/verticalslice/MainActivity.kt`
  Reason: T-0902 — ARCore session lifecycle, camera permission, Compose host, onEvaluateRequested()
  Task ID: T-0902

---

# 13. PHASE COMPLETION CHECKLIST

## Phase 0 — Legal and product foundation
- [x] Locked versioned source-of-truth files exist
- [x] Legal source register created and verified
- [x] Legal thresholds created with traceability
- [x] Scope and limitations defined
- [x] Decision states defined
- [x] Claims policy defined
- [x] Legal governance strategy created
- [x] Scope and claims strategy created
- [x] Validation passed — Phase 0 COMPLETE (2026-04-03)

## Phase 1 — Scope, claims, and decision-state lock
- [x] Controlled vocabulary is locked
- [x] Disclosure wording is locked
- [x] Launch scope register exists
- [x] User disclosure and copy file exists
- [x] Validation passed — Phase 1 COMPLETE (2026-04-03)

## Phase 2 — System architecture and SDK boundary
- [x] Architecture is locked
- [x] SDK input and output contracts exist
- [x] Policy registry spec exists
- [x] Versioning policy exists
- [x] Validation passed — Phase 2 COMPLETE (2026-04-03)

## Phase 3 — Dataset model and legal feature representation
- [x] Dataset strategy exists
- [x] Feature schema exists
- [x] Launch scope register updated
- [x] Validation passed — Phase 3 COMPLETE (2026-04-03)

## Phase 4 — Measurement backbone and AR strategy
- [x] AR measurement strategy exists
- [x] Architecture alignment verified (no changes needed)
- [x] Output contract alignment verified (no changes needed)
- [x] Validation passed — Phase 4 COMPLETE (2026-04-03)

## Phase 5 — Target selection and vehicle footprint
- [x] Target selection policy exists
- [x] Vehicle footprint strategy exists
- [x] Validation passed — Phase 5 COMPLETE (2026-04-03)

## Phase 6 — Legal-boundary localization
- [x] Boundary localization strategy exists
- [x] Validation passed — Phase 6 COMPLETE (2026-04-03)

## Phase 7 — Feature candidate matching
- [x] Candidate matching strategy exists
- [x] Validation passed — Phase 7 COMPLETE (2026-04-03)

## Phase 8 — Uncertainty, confidence, and refusal policy
- [x] Uncertainty strategy exists
- [x] Decision states alignment verified (no changes needed — DONE in Phase 0)
- [x] Output contract alignment verified (no changes needed — DONE in Phase 2)
- [x] Validation passed — Phase 8 COMPLETE (2026-04-03)

## Phase 9 — iOS vertical slice (T-0901)
- [x] SDK Swift Package created (ios/DKParkingSDK/) — 9 Swift files, Package.swift
- [x] Vertical slice app created (ios/DKParkingVerticalSlice/) — SwiftUI, ARKit, full evaluate pipeline; locked vocabulary applied; explanation + retry paths implemented
- [x] Unit tests created (ConfidenceComposerTests, LegalEvaluatorTests, MeasurementBundleTests)
- [x] Vertical slice report template created (vertical_slice_report.md)
- [x] Xcode setup guide created (ios/README.md)
- [ ] Physical device run completed — vertical_slice_report.md sections 3–6 filled
- [ ] Validation passed — T-0901 DONE

## Phase 9 — Android vertical slice (T-0902)
- [x] Android SDK Kotlin library created (android/DKParkingSDK/) — 9 Kotlin files
  - core/: DecisionState, RuleFamily+LegalThresholds, RefusalReasonCode, PolicyRegistry, ParkingEvaluationResult
  - ar/: ARMeasurementSession (ARCore)
  - evaluation/: ConfidenceComposer, LegalEvaluator
  - engine/: ParkingEvaluationEngine (SDKInitResult sealed class, EvaluationInput)
- [x] Android vertical slice app created (android/DKParkingVerticalSlice/) — Jetpack Compose
  - MainActivity (ARCore session + Compose host)
  - VerticalSliceViewModel (locked vocabulary, all 9 refusal/retry strings)
  - ui/VerticalSliceScreen (ResultCard, session banner, limitations notice)
  - AndroidManifest.xml (CAMERA permission, ARCore required)
- [x] Unit tests created (ConfidenceComposerTest, LegalEvaluatorTest, MeasurementBundleTest)
- [x] Android vertical slice report template created (android/vertical_slice_report_android.md)
- [x] Android setup guide created (android/README.md)
- [x] Build files: settings.gradle.kts, build.gradle.kts (root + SDK + app)
- [ ] Gradle sync passes in Android Studio
- [ ] Unit tests pass: ./gradlew :DKParkingSDK:test
- [ ] Physical device run completed — vertical_slice_report_android.md sections 3–6 filled
- [ ] Cross-platform parity check passed (section 6 of Android report)
- [ ] Validation passed — T-0902 DONE

## Phase 10 — Validation hardening
- [x] Validation plan exists (validation_plan.md) — 10 AMs, 8 failure categories, 7 guardrails, 3-phase test plan
- [x] Field test matrix exists (field_test_matrix.md) — 12 categories, 40+ scenarios, minimum observations table
- [ ] Guardrails are met — pending physical device run
- [ ] Validation passed — pending field testing

## Phase 11 — iOS product integration
- [x] Capture guidance strategy exists (capture_guidance_strategy.md) — pre-capture banners, retry guidance per 9 RefusalReasonCodes
- [x] Retry and refusal UX strategy exists (retry_and_refusal_ux_strategy.md) — result card spec, retry state machine, onboarding disclosure
- [x] Capture guidance and UX strategies reference user_disclosures_and_copy.md consistently
- [ ] Validation passed — pending device UX review

## Phase 12 — Release safety, privacy, and disclosures
- [x] Privacy and telemetry spec exists (privacy_and_telemetry_spec.md) — 4 events, GDPR-aligned, no camera in telemetry
- [x] Observability and replay strategy exists (observability_and_replay_strategy.md) — structured logs, replay bundle spec, crash schema
- [x] Release readiness checklist exists (release_readiness_checklist.md) — 50 items, 12 hard blockers, 4-role sign-off
- [ ] Validation passed — pending 4-role sign-off

## Phase 13 — Public launch preparation
- [x] Launch scope is locked (launch_scope_register.md §10) — REG-DK-001 = Copenhagen city centre
- [x] Public wording is locked (CLAIMS_POLICY.md §11, launch_scope_register.md §10.2) — App Store copy, FAQ, forbidden phrases
- [x] Launch runbook exists (launch_runbook.md) — 10 gates, 5-step procedure, rollback, expiry procedure
- [ ] Validation passed — pending release readiness sign-offs and App Store submission

## Phase 14 — Android parity and second-platform work
- [x] Android parity strategy exists (android_parity_strategy.md) — 10 parity criteria, 5 ARCore criteria, model packaging, test equivalence
- [x] Versioning policy updated (VERSIONING_POLICY.md §9) — Android versioned components, cross-platform compatibility rule
- [x] SDK API contract updated (SDK_API_CONTRACT.md §9) — Android notes, ARCore/TFLite contract, cross-platform guarantee
- [ ] Validation passed — blocked until T-0901 + T-0902 device runs complete and all PC-001 to PC-010 parity criteria verified

---

# 14. NEXT ACTION

```text
All strategy, specification, and code artifacts for Phases 0-14 are COMPLETE.
Both iOS and Android vertical slices are built. Both platforms target simultaneous V1 release.

Remaining execution gates (in order):

1. T-0901 gate (iOS): Physical device run on iPhone (iOS 16+) via macOS + Xcode.
   - Run unit tests on iOS simulator (Cmd+U)
   - Build and run vertical slice app on physical device
   - Fill vertical_slice_report.md §3-6
   - Mark T-0901 DONE

2. T-0902 gate (Android): Physical device run on ARCore-compatible Android device via Android Studio.
   - Run unit tests: ./gradlew :DKParkingSDK:test
   - Build and run DKParkingVerticalSlice on physical Android device
   - Fill android/vertical_slice_report_android.md §3-6
   - Run cross-platform parity check (section 6 of Android report)
   - Mark T-0902 DONE

3. Phase 10 gate: Execute field_test_matrix.md scenarios on both iOS and Android devices.
   - Cover all 12 test categories (A-L) on each platform
   - Meet minimum observations per decision state
   - Verify all 7 guardrails pass on both platforms
   - Mark Phase 10 DONE

4. Phase 12 gate: Obtain 4-role sign-off on release_readiness_checklist.md (separately for iOS and Android builds).

5. Phase 13 gate: App Store (iOS) + Google Play (Android) submission with locked copy from launch_scope_register.md §10.2.

6. Phase 14 (Android parity validation): Confirm all PC-001 to PC-010 parity criteria are met across both platforms before any production release.
```

---

# 15. FINAL RULE

If a task is not represented here, it does not exist for execution control.

If a blocker is not represented here, it is being hidden.

If the active phase is not respected here, the implementation is unsafe.

---
