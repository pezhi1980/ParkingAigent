# ROADMAP
## DK PARKING ENGINE — EXECUTION ROADMAP
## Denmark Legal Parking Distance App
## Version 8.0
## Status: Locked execution roadmap for Version 1
## Date: 2026-03-25

---

## 1. Document role

This roadmap is the execution control document for building Version 1 of the Denmark legal parking distance product.

This roadmap is written for a coding agent operating inside VS Code and for human review.

This document defines:

- what must be built
- in what order it must be built
- which files must exist before later work starts
- which deliverables are mandatory in each phase
- which validation gates must pass before the next phase opens
- which decisions are locked and may not be silently changed
- what the minimum release-ready Version 1 actually is

This roadmap is normative.

If implementation convenience conflicts with this roadmap, the roadmap wins unless the master specification or the legal-source update procedure formally changes the rule.

---

## 2. How this roadmap must be used

The coding agent must use this document as a step-by-step execution controller.

The agent must:

1. read `DK_PARKING_AGENT_MASTER_SPEC.md`
2. read this roadmap
3. read `RULES.md`
4. read `TASKLIST.md`
5. read `WHAT_DID_I_DO.md`
6. determine the active phase
7. verify that all prerequisites of the active phase are complete
8. perform only the next allowed task
9. record the work before and after the task
10. stop if a dependency, legal ambiguity, or validation failure appears

The agent must not jump ahead.

The agent must not start model work, AR work, SDK work, or app work before the legal and product foundation phase is closed.

The agent must not change legal thresholds, supported-rule meanings, decision-state semantics, or claim boundaries unless the formal legal update process is followed.

---

## 3. Project mission

Build an on-device Denmark parking assistant that can evaluate only supported Danish stopping and parking rules that are suitable for refusal-safe deterministic measurement.

Version 1 must:

- run the legal decision path on device
- rely on deterministic geometry, not generative inference
- use AR-based metric scaling
- use map priors only as priors, not as the final legal truth
- evaluate one active target vehicle at a time
- refuse when evidence is insufficient
- keep the agent or explainer outside the legal decision path
- produce structured, auditable outputs with version references
- avoid overclaiming
- stay inside a clearly disclosed support scope

---

## 4. Locked global decisions

The following decisions are locked for Version 1.

### 4.1 Platform order

Build order is:

1. iOS first
2. Android second only after iOS vertical-slice success and parity criteria are locked

### 4.2 Product architecture

The product must be split into:

- a deterministic on-device parking engine or SDK
- app-side capture, guidance, and user-confirmation flows
- a downloadable, versioned map-and-feature dataset
- a policy registry
- validation and observability tooling
- an optional agent or explainer layer outside the legal decision path

### 4.3 Legal decision path

The legal decision path must be:

- deterministic
- on-device
- refusal-safe
- version-auditable
- offline-capable after dataset activation
- isolated from generative language behavior

### 4.4 Agent boundary

The agent may explain results, guide retry, summarize the evaluated rule, and surface limitations.

The agent may not:

- compute legality from raw images
- replace geometry
- override refusal
- invent distances or legal references
- upgrade uncertainty into certainty
- hide scope limitations

### 4.5 Measurement backbone

AR-based metric ground-plane scale is mandatory.

Locked platform direction:

- iOS: ARKit
- Android: ARCore

### 4.6 Vision direction

Locked direction:

- on-device AR + ML hybrid perception
- target-vehicle detection and segmentation on device
- local ground-plane projection
- visually informed legal-boundary localization
- candidate matching using map priors + visual evidence
- uncertainty-aware refusal logic

### 4.7 Dataset direction

The active dataset must be:

- downloadable
- region-bounded
- versioned
- integrity-checked
- capable of offline use after activation
- structured so that features can be updated without shipping a full new app build

### 4.8 Packaging direction

The legal engine must be packaged as a standalone SDK-style module with platform bindings and a stable input-output contract.

### 4.9 Positive-result claim policy

Positive results may claim clearance only for supported rule families that were actually evaluated by the engine.

Positive results may never imply that all Danish parking conditions are satisfied.

### 4.10 Single active target rule

Each analysis attempt must evaluate exactly one active target vehicle.

Ambiguous multi-vehicle scenes must be disambiguated or refused.

### 4.11 Unsupported visible restriction sentinel

Version 1 must include a safety sentinel for visible but unsupported signs, markings, temporary controls, and private-condition boards.

### 4.12 Scope discipline

Version 1 must be built as a narrow, measurable, auditable product.

The team must not silently expand from one supported rule family to many without formal scope lock, validation, and disclosure updates.

### 4.13 Vertical-slice discipline

Before broad system expansion, the project must complete one real end-to-end vertical slice on iOS for one region, one supported rule family, one capture flow, and one structured result path.

This milestone is mandatory.

---

## 5. Legal basis lock for Version 1

The roadmap assumes the legal-source basis locked on 2026-03-25 and verified against the official consolidated Danish Road Traffic Act source used by the project.

For Version 1 planning, the threshold and rule-family baseline includes at minimum:

- pedestrian-crossing related stopping/parking restriction with 5 metre boundary logic
- cycle-path-exit related stopping/parking restriction with 5 metre boundary logic
- intersection related stopping/parking restriction with 10 metre boundary logic
- bus-stop restriction using marked segment logic or 12 metre fallback from the sign when unmarked
- direct prohibited surfaces such as cycle path, footway, refuge, island, and similar directly forbidden placement surfaces
- driveway obstruction as advisory-first logic only in Version 1

The roadmap does not authorize the agent to reinterpret law.

The agent must lock formal legal-source references in the legal foundation documents before implementation starts.

---

## 6. Final Version 1 product target

Version 1 is an on-device mobile parking assistant for Denmark that evaluates only supported Danish stopping and parking rules that are suitable for refusal-safe measurement.

Version 1 must be able to return, within supported scope:

- rule family
- decision state
- measured distance or overlap
- legal threshold
- signed margin
- estimated total error
- confidence score
- protected boundary type
- target-selection information
- feature-candidate information
- capture quality
- refusal reason when applicable
- dataset version
- model version
- policy version
- limitations notice

Version 1 must not claim universal Denmark parking legality.

---

## 7. Version 1 scope lock

### 7.1 Fully supported in Version 1

Version 1 must fully support:

- intersection 10 metre evaluation
- pedestrian crossing 5 metre evaluation
- cycle-path exit 5 metre evaluation
- direct prohibited-surface detection where the prohibited surface is visually and geometrically supportable
- marked bus-stop evaluation
- unmarked bus-stop 12 metre evaluation where the sign and boundary are supportable
- deterministic refusal behavior
- offline dataset use after activation
- iOS implementation first

### 7.2 Advisory-first in Version 1

The following may exist but may not be promoted to hard legal certainty in Version 1:

- driveway obstruction
- property-access hindrance
- some curb-edge ambiguity cases
- weak-evidence edge placement near private entrances
- mixed or partially visible private-access situations

### 7.3 Explicitly outside hard legal-clear Version 1 unless separately implemented and validated

The following remain outside hard legal clearance unless separately added through formal scope extension:

- temporary restrictions
- police-controlled conditions
- construction-zone conditions
- event-based temporary traffic control
- permit-based parking rights
- payment/zone compliance
- loading-only rules
- local signage systems not yet supported by the sentinel/evaluator stack
- electric charging entitlement
- disabled-badge entitlement
- time-window exceptions
- vehicle-class-specific exemptions not explicitly modeled
- private contractual parking rules

### 7.4 Minimum launch scope

The minimum acceptable public launch scope is not “all supported rules in one day”.

The minimum acceptable launch scope is:

- one city or one tightly bounded region
- iOS
- downloadable region dataset
- one end-to-end supported result flow
- one stable retry flow
- one stable refusal flow
- one clear limitations surface
- version-auditable output

This does not weaken the master specification.

It defines the minimum credible launch unit.

---

## 8. Success criteria

The project succeeds only if all of the following are true:

1. the legal question answered by the engine is narrow and explicit
2. every supported rule family is backed by formal legal-source lock
3. the engine uses vehicle footprint geometry, not phone position
4. the engine uses the correct legal boundary for each rule family
5. map data is treated as prior evidence, not final truth
6. AR metric scale is stable enough for supported scenes
7. target selection is safe in multi-vehicle scenes
8. unsupported visible restrictions can trigger warning/refusal behavior
9. refusal happens before unsafe confidence
10. output states are clear and non-misleading
11. product copy does not overclaim
12. logs and versions are sufficient for audit and debugging
13. field validation demonstrates safe behavior near thresholds
14. unsupported cases are not silently shown as safe
15. the app can explain refusal in a way users understand

If any one of these is missing, the product is not release-ready.

---

## 9. Primary risks to design around

The roadmap must explicitly guard against these failure modes:

1. wrong target vehicle selected
2. wrong feature candidate selected
3. wrong legal boundary localized
4. unstable or invalid metric plane
5. wrong vehicle edge used for measurement
6. unsupported visible restriction ignored
7. map/vision disagreement resolved unsafely
8. confidence score presented as certainty
9. generative layer leaking into legal decision path
10. positive result interpreted as full parking legality
11. public launch before field validation is strong enough
12. cross-platform parity drift after Android is added

Every phase must reduce one or more of these risks.

---

## 10. Dependency chain

The work must follow this dependency order:

1. legal and product foundation
2. scope/claims/decision-state lock
3. SDK boundary and output contract
4. dataset and feature representation strategy
5. AR and measurement strategy
6. target selection and vehicle footprint strategy
7. legal-boundary localization strategy
8. feature-candidate matching strategy
9. confidence and uncertainty strategy
10. iOS vertical slice
11. validation hardening
12. full iOS packaging
13. release documentation and disclosure
14. Android parity planning
15. Android build only after iOS sign-off

The agent must not invert this order.

---

## 11. Required repository file structure

The agent must build and maintain at least the following file structure over time.

### 11.1 Source-of-truth root files

- `DK_PARKING_AGENT_MASTER_SPEC.md`
- `ROADMAP.md`
- `RULES.md`
- `TASKLIST.md`
- `WHAT_DID_I_DO.md`

### 11.2 Foundation and legal governance files

- `LEGAL_SOURCE_REGISTER.md`
- `LEGAL_THRESHOLDS.md`
- `SCOPE_AND_LIMITATIONS.md`
- `DECISION_STATES.md`
- `CLAIMS_POLICY.md`
- `legal_governance_strategy.md`
- `scope_and_claims_strategy.md`

### 11.3 Core architecture and contract files

- `SYSTEM_ARCHITECTURE.md`
- `SDK_API_CONTRACT.md`
- `OUTPUT_CONTRACT.md`
- `POLICY_REGISTRY_SPEC.md`
- `VERSIONING_POLICY.md`

### 11.4 Perception and geometry strategy files

- `dataset_strategy.md`
- `feature_schema_spec.md`
- `ar_measurement_strategy.md`
- `vehicle_footprint_strategy.md`
- `target_selection_policy.md`
- `legal_boundary_localization_strategy.md`
- `feature_candidate_matching_strategy.md`
- `uncertainty_and_confidence_strategy.md`

### 11.5 App and UX files

- `capture_guidance_strategy.md`
- `retry_and_refusal_ux_strategy.md`
- `user_disclosures_and_copy.md`
- `supported_vs_unsupported_visual_signals.md`

### 11.6 Validation and release files

- `validation_plan.md`
- `field_test_matrix.md`
- `release_readiness_checklist.md`
- `privacy_and_telemetry_spec.md`
- `observability_and_replay_strategy.md`
- `launch_scope_register.md`

The roadmap may reference additional implementation files later, but the files above are the minimum document set the agent must create over time.

---

## 12. Phase structure

The project has 15 mandatory phases.

The agent must not merge, skip, or reorder them.

### Phase list

- Phase 0 — Legal and product foundation
- Phase 1 — Scope, claims, and decision-state lock
- Phase 2 — System architecture and SDK boundary
- Phase 3 — Dataset model and legal feature representation
- Phase 4 — Measurement backbone and AR strategy
- Phase 5 — Target selection and vehicle footprint
- Phase 6 — Legal-boundary localization
- Phase 7 — Feature candidate matching
- Phase 8 — Uncertainty, confidence, and refusal policy
- Phase 9 — iOS vertical slice
- Phase 10 — Validation hardening
- Phase 11 — iOS product integration
- Phase 12 — Release safety, privacy, and disclosures
- Phase 13 — Public launch preparation
- Phase 14 — Android parity criteria and second-platform work

---

## 13. Phase 0 — Legal and product foundation

### 13.1 Objective

Remove legal ambiguity and product-claim ambiguity before implementation begins.

### 13.2 Why this phase exists

Without this phase, later work will drift in thresholds, rule meanings, disclosures, and scope.

### 13.3 Required files

- `LEGAL_SOURCE_REGISTER.md`
- `LEGAL_THRESHOLDS.md`
- `SCOPE_AND_LIMITATIONS.md`
- `DECISION_STATES.md`
- `CLAIMS_POLICY.md`
- `legal_governance_strategy.md`
- `scope_and_claims_strategy.md`

### 13.4 Required actions in exact order

1. Create `LEGAL_SOURCE_REGISTER.md`
2. Lock source authority order
3. Record the official source documents used
4. Create `LEGAL_THRESHOLDS.md`
5. Lock all statutory thresholds relevant to V1
6. Create `SCOPE_AND_LIMITATIONS.md`
7. Mark every rule family as supported, advisory-first, or unsupported
8. Create `DECISION_STATES.md`
9. Define state semantics, transitions, and UI obligations
10. Create `CLAIMS_POLICY.md`
11. Define allowed, forbidden, and required claims
12. Create `legal_governance_strategy.md`
13. Define how law updates are reviewed and approved
14. Create `scope_and_claims_strategy.md`
15. Define how scope changes must be proposed and validated
16. Validate consistency across all files
17. Mark Phase 0 complete only after consistency is proven

### 13.5 Mandatory content requirements

`LEGAL_SOURCE_REGISTER.md` must include:

- source title
- source type
- issuing authority
- status in force
- access path
- relevance to supported rule families
- hierarchy rank
- review date
- update procedure

`LEGAL_THRESHOLDS.md` must include:

- numeric thresholds
- rule-family ownership
- exact boundary reference concept
- change-control statement
- non-configurability of legal constants

`SCOPE_AND_LIMITATIONS.md` must include:

- supported rules
- unsupported rules
- advisory-only rules
- visible-but-unsupported policy
- region limits
- launch limits
- rule-family disclosure wording

`DECISION_STATES.md` must include:

- state names
- meaning
- required evidence level
- user-facing copy guidance
- transitions
- escalation to refusal

`CLAIMS_POLICY.md` must include:

- approved product claims
- prohibited claims
- required limitations
- positive-result caveat
- negative-result caveat
- refusal copy obligations

### 13.6 Validation gate

Phase 0 is complete only if:

- no legal threshold is missing
- no scope ambiguity remains for V1
- no decision state is undefined
- no product claim can be interpreted as full legal advice
- all legal references are traceable

### 13.7 Phase 0 done definition

The project can now say exactly:

- what legal question is answered
- what rules are in scope
- which thresholds apply
- what outputs mean
- what the product may and may not claim

If this cannot be stated in one page clearly, Phase 0 is not done.

---

## 14. Phase 1 — Scope, claims, and decision-state lock

### 14.1 Objective

Operationalize the foundation into a fixed product-control layer that later phases must obey.

### 14.2 Required files

- update `TASKLIST.md`
- update `WHAT_DID_I_DO.md`
- refine `DECISION_STATES.md`
- refine `CLAIMS_POLICY.md`
- create `launch_scope_register.md`
- create `user_disclosures_and_copy.md`

### 14.3 Required actions

1. Define launch-scope register structure
2. Define per-rule-family disclosure wording
3. Define required limitation notice templates
4. Define refusal explanation templates
5. Define positive-result wording restrictions
6. Define unsupported-visible-restriction wording
7. Link all user-facing wording to decision states
8. Lock the vocabulary that implementation must use

### 14.4 Validation gate

This phase passes only if a reviewer can look at each state and know:

- what the engine means
- what the UI must say
- what the app must never imply

### 14.5 Done definition

All future code and copy can refer to one controlled vocabulary.

---

## 15. Phase 2 — System architecture and SDK boundary

### 15.1 Objective

Turn the product idea into a controlled system architecture with hard boundaries.

### 15.2 Required files

- `SYSTEM_ARCHITECTURE.md`
- `SDK_API_CONTRACT.md`
- `OUTPUT_CONTRACT.md`
- `POLICY_REGISTRY_SPEC.md`
- `VERSIONING_POLICY.md`

### 15.3 Required actions

1. Define major subsystems
2. Define engine/app/agent boundaries
3. Define data flow from capture to structured result
4. Define SDK lifecycle
5. Define input contract
6. Define output contract
7. Define policy registry ownership
8. Define versioning across dataset, model, policy, SDK, and app
9. Define failure behavior for missing components
10. Define offline lifecycle after dataset activation

### 15.4 Mandatory architecture constraints

The system architecture must show:

- legal decision path isolation
- capture acceptance boundary
- dataset loading path
- policy loading path
- measurement and evaluation path
- refusal path
- explanation path
- logging and replay path
- no hidden cloud dependency for the legal decision path

### 15.5 Validation gate

Phase 2 passes only if the app team can integrate the engine without guessing field meanings, state meanings, or retry behavior.

### 15.6 Done definition

The engine can now be treated as a productized module, not a loose collection of functions.

---

## 16. Phase 3 — Dataset model and legal feature representation

### 16.1 Objective

Define how map and legal features are represented, versioned, downloaded, and used safely.

### 16.2 Required files

- `dataset_strategy.md`
- `feature_schema_spec.md`
- update `launch_scope_register.md`

### 16.3 Required actions

1. Define region unit
2. Define feature IDs and schema
3. Define geometry types per feature family
4. Define confidence/quality metadata for dataset features
5. Define version and integrity checks
6. Define download, activation, expiry, and rollback behavior
7. Define update semantics for region bundles
8. Define missing-data behavior
9. Define map-prior role in candidate generation
10. Define map-prior limits in final legal judgment

### 16.4 Mandatory constraints

The dataset model must support at minimum:

- intersections
- crossing-related features
- cycle-path-exit features
- bus-stop features
- directly prohibited-surface metadata when available
- region scoping
- dataset version traceability

### 16.5 Validation gate

Phase 3 passes only if a candidate feature set can be generated deterministically from region data without pretending that map data alone is legally sufficient.

### 16.6 Done definition

The project now knows what “feature candidate” means and how it reaches the device.

---

## 17. Phase 4 — Measurement backbone and AR strategy

### 17.1 Objective

Define how metric scale and local geometry are established on device.

### 17.2 Required files

- `ar_measurement_strategy.md`
- update `SYSTEM_ARCHITECTURE.md`
- update `OUTPUT_CONTRACT.md`

### 17.3 Required actions

1. Define accepted sensor prerequisites
2. Define ground-plane acquisition rules
3. Define metric-scale validity checks
4. Define plane-stability thresholds
5. Define when capture must be rejected
6. Define projection model to local ground plane
7. Define measurement reference frame
8. Define temporal-stability checks
9. Define fallback/refusal cases
10. Define AR observability fields

### 17.4 Mandatory constraints

This phase must explicitly reject:

- pixel-only distance as legal distance
- GPS-only distance as legal distance
- phone-center reference as legal reference
- unverified plane assumptions

### 17.5 Validation gate

Phase 4 passes only if the system can say when AR scale is trustworthy enough and when it must refuse.

### 17.6 Done definition

Metric geometry on device is now a controlled subsystem, not an assumption.

---

## 18. Phase 5 — Target selection and vehicle footprint

### 18.1 Objective

Define which vehicle is being evaluated and how the legally relevant vehicle footprint is represented.

### 18.2 Required files

- `target_selection_policy.md`
- `vehicle_footprint_strategy.md`

### 18.3 Required actions

1. Define single-active-target policy
2. Define user-confirmation triggers
3. Define automatic-target-selection limits
4. Define identity stability requirements across frames
5. Define target refusal cases
6. Define footprint representation
7. Define risk-side edge concept
8. Define edge-quality scoring
9. Define partial occlusion handling
10. Define footprint uncertainty contribution

### 18.4 Mandatory constraints

This phase must ensure:

- no silent switching between vehicles
- no measurement from phone position
- no measurement from vehicle center
- no unsafe use of hallucinated vehicle edges

### 18.5 Validation gate

Phase 5 passes only if ambiguous scenes deterministically lead to user confirmation or refusal.

### 18.6 Done definition

The project now knows what exact vehicle geometry it is measuring and when it cannot know.

---

## 19. Phase 6 — Legal-boundary localization

### 19.1 Objective

Define how the legally relevant boundary is localized for each supported rule family.

### 19.2 Required files

- `legal_boundary_localization_strategy.md`

### 19.3 Required actions

1. Define boundary type per rule family
2. Define boundary localization sources
3. Define visual evidence requirements
4. Define map-assisted boundary inference limits
5. Define per-rule-family boundary confidence
6. Define partial visibility handling
7. Define candidate-side disambiguation rules
8. Define refusal rules for weak boundary evidence
9. Define output fields for boundary provenance

### 19.4 Mandatory constraints

The strategy must support at minimum:

- crossing approach boundary
- cycle-path-exit boundary
- intersection boundary from the correct transverse edge concept
- bus-stop marked segment boundary
- bus-stop unmarked sign-based 12 metre fallback
- direct prohibited-surface overlap boundary

### 19.5 Validation gate

Phase 6 passes only if the system can state which boundary it used and why that boundary is legally relevant.

### 19.6 Done definition

The system now knows what it is measuring against.

---

## 20. Phase 7 — Feature candidate matching

### 20.1 Objective

Define how the system chooses the correct candidate feature near the target vehicle.

### 20.2 Required files

- `feature_candidate_matching_strategy.md`

### 20.3 Required actions

1. Define candidate-generation radius
2. Define ranking signals
3. Define map/vision consistency checks
4. Define temporal-stability use
5. Define tie-breaking rules
6. Define candidate-switch refusal rules
7. Define multi-feature ambiguity handling
8. Define output provenance fields

### 20.4 Mandatory constraints

Candidate matching must never:

- silently jump between plausible features
- use a feature that conflicts materially with visible evidence
- force a single candidate when two remain plausible

### 20.5 Validation gate

Phase 7 passes only if the engine can say exactly which candidate feature was evaluated and why alternatives were rejected or refused.

### 20.6 Done definition

Feature selection becomes auditable.

---

## 21. Phase 8 — Uncertainty, confidence, and refusal policy

### 21.1 Objective

Turn all uncertainty sources into controlled state transitions and refusal logic.

### 21.2 Required files

- `uncertainty_and_confidence_strategy.md`
- update `DECISION_STATES.md`
- update `OUTPUT_CONTRACT.md`

### 21.3 Required actions

1. Enumerate all uncertainty sources
2. Define total-error budget composition
3. Define confidence score meaning
4. Define decision-state thresholds
5. Define refusal triggers
6. Define near-threshold downgrade policy
7. Define map/perception disagreement handling
8. Define unstable-capture handling
9. Define confidence observability fields

### 21.4 Mandatory uncertainty sources

The strategy must consider at minimum:

- AR scale uncertainty
- plane-fit uncertainty
- vehicle-edge uncertainty
- legal-boundary uncertainty
- feature-candidate uncertainty
- projection uncertainty
- temporal instability
- dataset uncertainty where relevant

### 21.5 Validation gate

Phase 8 passes only if the engine can justify every result state using evidence plus uncertainty rather than intuition.

### 21.6 Done definition

The project now knows when it should answer, downgrade, or refuse.

---

## 22. Phase 9 — iOS vertical slice

### 22.1 Objective

Build one true end-to-end iOS slice before broad expansion.

### 22.2 Mandatory slice scope

The slice must include:

- one bounded region
- one supported rule family
- one active-target flow
- one dataset bundle
- one AR measurement path
- one structured result path
- one refusal path
- one retry path
- one explanation path

### 22.3 Required files

- implementation files under app and SDK directories
- update `WHAT_DID_I_DO.md`
- update `TASKLIST.md`
- create `vertical_slice_report.md`

### 22.4 Required actions

1. Implement dataset load
2. Implement capture acceptance
3. Implement target selection
4. Implement local geometry
5. Implement one rule-family evaluation
6. Implement structured result serialization
7. Implement refusal serialization
8. Implement app-side result rendering
9. Implement retry and guidance loop
10. Record observed failures and gaps

### 22.5 Validation gate

Phase 9 passes only if a reviewer can run the slice on device and observe:

- at least one successful supported evaluation
- at least one correct refusal
- stable state output
- traceable versions
- no hidden cloud dependency in the legal path

### 22.6 Done definition

The product is no longer theoretical.

---

## 23. Phase 10 — Validation hardening

### 23.1 Objective

Prove that the system behaves safely and honestly outside the best demo path.

### 23.2 Required files

- `validation_plan.md`
- `field_test_matrix.md`
- update `vertical_slice_report.md`

### 23.3 Required test categories

- near-threshold scenes
- night scenes
- rain or poor-visibility scenes
- partial occlusion
- multiple nearby vehicles
- multiple nearby legal features
- map drift
- unstable AR
- partially visible boundaries
- visible unsupported signs or markings
- bus-stop marked and unmarked cases
- false-target temptation cases

### 23.4 Required actions

1. Define acceptance metrics
2. Define failure categories
3. Define refusal adequacy criteria
4. Define false-confidence guardrail metrics
5. Run controlled tests
6. Record failures
7. Update strategies if needed
8. Repeat until the guardrails are met

### 23.5 Validation gate

Phase 10 passes only if false confidence near thresholds is acceptably controlled and refusal behavior is demonstrably safer than forced output.

### 23.6 Done definition

The system is now stress-tested against realistic failure modes.

---

## 24. Phase 11 — iOS product integration

### 24.1 Objective

Turn the validated slice into a coherent Version 1 iOS product.

### 24.2 Required files

- `capture_guidance_strategy.md`
- `retry_and_refusal_ux_strategy.md`
- update `SYSTEM_ARCHITECTURE.md`
- update `user_disclosures_and_copy.md`

### 24.3 Required actions

1. Build pre-capture guidance
2. Build target confirmation UI
3. Build guidance for framing the relevant boundary
4. Build retry flows by refusal reason
5. Build result rendering by decision state
6. Build visible-unsupported-restriction surfaces
7. Build limitations surfaces
8. Build offline dataset lifecycle UI

### 24.4 Validation gate

Phase 11 passes only if users can understand:

- what was evaluated
- what was not evaluated
- why a refusal happened
- what retry action is appropriate

### 24.5 Done definition

The system becomes a usable app, not just an engine demo.

---

## 25. Phase 12 — Release safety, privacy, and disclosures

### 25.1 Objective

Ensure the product can be publicly shipped without misleading users or violating privacy commitments.

### 25.2 Required files

- `privacy_and_telemetry_spec.md`
- `observability_and_replay_strategy.md`
- `release_readiness_checklist.md`

### 25.3 Required actions

1. Define telemetry minimum set
2. Define what image data may or may not be retained
3. Define replay-safe metadata
4. Define user disclosures
5. Define privacy consent surface if applicable
6. Define crash/failure trace schema
7. Define release blockers
8. Define emergency rollback behavior for dataset/policy/model versions

### 25.4 Mandatory privacy rules

The release design must preserve:

- no hidden cloud legal-decision dependency
- no unnecessary frame retention by default
- structured metadata preferred over raw image retention
- clear disclosure when any image or measurement artifact is stored
- version traceability for support and audit

### 25.5 Validation gate

Phase 12 passes only if privacy, telemetry, support, and legal-copy reviewers can all sign off on the same behavior description.

### 25.6 Done definition

The product is now governable in production.

---

## 26. Phase 13 — Public launch preparation

### 26.1 Objective

Prepare the minimum public launch unit and public-facing claims.

### 26.2 Required files

- update `launch_scope_register.md`
- update `CLAIMS_POLICY.md`
- update `release_readiness_checklist.md`
- create `launch_runbook.md`

### 26.3 Required actions

1. Lock launch region
2. Lock launch copy
3. Lock app-store wording
4. Lock FAQ wording
5. Lock in-app limitations wording
6. Lock support triage paths
7. Lock release version set
8. Lock rollback criteria

### 26.4 Validation gate

Phase 13 passes only if no public-facing text implies universal Denmark parking legality.

### 26.5 Done definition

A truthful, limited, supportable launch package exists.

---

## 27. Phase 14 — Android parity criteria and second-platform work

### 27.1 Objective

Only after iOS sign-off, define how Android may be added without semantic drift.

### 27.2 Required files

- `android_parity_strategy.md`
- update `VERSIONING_POLICY.md`
- update `SDK_API_CONTRACT.md`

### 27.3 Required actions

1. Define parity criteria
2. Define acceptable platform-specific deviations
3. Define ARCore acceptance criteria
4. Define model packaging strategy for Android
5. Define test equivalence strategy
6. Define cross-platform output compatibility rules

### 27.4 Validation gate

Phase 14 passes only if Android can be added without changing decision-state semantics, boundary semantics, or claim behavior.

### 27.5 Done definition

Second-platform work is safe to begin.

---

## 28. Mandatory vertical-slice milestone

The project must not attempt “all rules, all regions, all flows” before this milestone is complete.

### 28.1 Vertical-slice required outcome

The slice must prove all of the following in one working path:

- region dataset activation
- single target selection
- stable AR plane
- boundary localization
- rule-family evaluation
- structured result output
- refusal output
- explanation path
- version traceability

### 28.2 Why this milestone is mandatory

Without this milestone, the project risks building isolated subsystems that do not compose into one safe product.

---

## 29. Mandatory output contract requirements

Regardless of phase, the final engine output must contain at minimum:

- `schema_version`
- `sdk_version`
- `policy_version`
- `dataset_version`
- `model_version`
- `analysis_id`
- `timestamp_utc`
- `region_id`
- `active_rule_family`
- `decision_state`
- `decision_reason_code`
- `target_selection_mode`
- `target_selection_confidence`
- `feature_candidate_id`
- `feature_candidate_type`
- `protected_boundary_type`
- `measured_distance_m` or `overlap_m`
- `legal_threshold_m` where relevant
- `signed_margin_m`
- `estimated_total_error_m`
- `confidence_score`
- `capture_quality`
- `limitations_notice`
- `unsupported_visible_restriction_flag`
- `refusal_reason` when applicable

The exact schema must be frozen in `OUTPUT_CONTRACT.md`.

---

## 30. Mandatory decision-state requirements

The product must implement and document at minimum these states:

- `ILLEGAL`
- `PROBABLY_ILLEGAL`
- `UNVERIFIABLE`
- `PROBABLY_LEGAL`
- `LEGAL_WITH_BUFFER`

No other user-visible legal states may be introduced without an explicit document update.

State semantics must be stable across platforms and app versions unless formally changed.

---

## 31. Mandatory visible-unsupported policy

If the system detects or reasonably suspects a visible but unsupported restriction source, the output must not imply safe clearance.

At minimum the system must be able to flag risk from:

- unsupported signs
- unsupported road markings
- temporary control devices
- private-condition boards
- atypical local restrictions that the engine does not evaluate

The exact behavior may be warning, downgrade, or refusal depending on evidence and policy, but silent clearance is forbidden.

---

## 32. Mandatory observability requirements

The engine and app must provide enough structured observability to debug failures without pretending certainty.

At minimum observability must capture:

- target selection path
- candidate ranking path
- boundary provenance
- AR stability summary
- uncertainty component summary
- refusal reason
- active versions
- whether visible unsupported restrictions were detected

---

## 33. Mandatory field-validation requirements

Before public launch, field validation must include:

- thresholds stressed from both sides
- multiple weather/light conditions
- multiple street layouts
- multiple device classes inside the supported platform set
- multi-vehicle scenes
- scenes with nearby misleading features
- scenes with unsupported visible restrictions
- user retry comprehension testing

The project must not use only curated easy scenes to claim readiness.

---

## 34. Release blockers

Public release is blocked if any one of the following is true:

1. legal thresholds are not formally locked
2. supported scope is ambiguous
3. positive-result claims remain too broad
4. decision states are not stable
5. output contract is not frozen
6. AR measurement acceptance is not defined
7. target-selection policy is not defined
8. boundary provenance is not exposed
9. uncertainty is not integrated into state selection
10. visible unsupported restrictions are not handled
11. refusal reasons are not user-readable
12. field validation is incomplete
13. privacy behavior is unclear
14. versioning is not traceable
15. launch region is not clearly bounded

If any blocker exists, the agent must not mark launch readiness as complete.

---

## 35. Change-control rules

The following items require formal change control and may not be casually edited:

- supported rule families
- legal thresholds
- decision-state vocabulary
- positive-result claim wording
- output contract core fields
- target-selection semantics
- visible-unsupported-restriction policy
- refusal policy
- launch region boundaries once publicly announced

Any such change must be reflected in:

- the master spec
- this roadmap where relevant
- the affected strategy files
- `TASKLIST.md`
- `WHAT_DID_I_DO.md`

---

## 36. What the coding agent must do at every phase

For every meaningful task the agent must:

1. announce the task briefly in Persian in chat
2. update `TASKLIST.md` before starting
3. update `WHAT_DID_I_DO.md` before and after the task
4. touch only the relevant files
5. preserve source-of-truth meaning
6. run the phase validation check mentally against this roadmap
7. refuse to advance if prerequisites are missing

If there is uncertainty, the stricter interpretation wins.

---

## 37. Minimum “done” sequence from 0 to 100

The shortest acceptable path from zero to a credible Version 1 is:

1. complete Phase 0
2. complete Phase 1
3. complete Phase 2
4. complete Phase 3
5. complete Phase 4
6. complete Phase 5
7. complete Phase 6
8. complete Phase 7
9. complete Phase 8
10. build the Phase 9 iOS vertical slice
11. harden with Phase 10 validation
12. integrate into product UX in Phase 11
13. complete release safety in Phase 12
14. prepare truthful launch in Phase 13
15. only then plan Android in Phase 14

Anything shorter than this is a prototype path, not a release path.

---

## 38. Final execution command to the VS Code agent

When operating on this project, the coding agent must behave as follows:

- never treat this as a generic AI app
- never treat GPS as the legal measurement source
- never treat the phone position as the vehicle reference
- never let the agent layer make legal decisions
- never broaden claims beyond supported rule families
- never skip refusal when evidence is insufficient
- never proceed to the next phase without passing the current gate
- always build the narrowest truthful Version 1 before expanding

This execution discipline is mandatory.

---

## 39. End state of this roadmap

This roadmap is complete only when it has produced:

- a legally grounded Version 1 scope
- a deterministic SDK boundary
- a validated iOS vertical slice
- a refusal-safe user experience
- truthful public launch materials
- a controlled path to Android

That is the required endpoint.

