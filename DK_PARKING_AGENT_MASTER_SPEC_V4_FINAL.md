# DK_PARKING_AGENT_MASTER_SPEC
## Denmark Legal Parking Distance Engine
## Version 4.0
## Status: Locked master specification for Version 1
## Date: 2026-03-25

---

## 1. Document role

This document is the highest-priority product, measurement, and safety specification for the Denmark legal parking distance engine.

This document defines:

- the legal question the system is allowed to answer
- the supported Version 1 rule families
- the exact geometric references that must be measured
- the mandatory refusal behavior when evidence is insufficient
- the mandatory boundary between the deterministic engine and any agent layer
- the output contract, confidence policy, privacy policy, and release-safety policy

This document is normative.

If another project document conflicts with this document, this document wins unless a newer formally locked legal-source update explicitly replaces part of it.

---

## 2. Normative language

The words **must**, **must not**, **should**, and **may** are normative in this document.

- **Must** means mandatory for implementation and release.
- **Must not** means prohibited.
- **Should** means expected default behavior unless a formally documented exception exists.
- **May** means allowed but not required.

---

## 3. Product identity

Version 1 is not a generic parking app.

Version 1 is a refusal-safe, on-device, rule-limited Denmark parking legality engine that evaluates only supported stopping and parking rules suitable for deterministic geometry.

The engine exists to answer one narrow legal-geometry question with controlled uncertainty.

The engine is not allowed to guess.

The engine is not allowed to imply support for rules it did not evaluate.

The engine is not allowed to present incomplete evidence as certainty.

---

## 4. Source hierarchy

The system must follow this source hierarchy in descending order:

1. Danish statutory law and official executive orders in force
2. Official Danish public-authority guidance and official municipal guidance
3. This master specification
4. The roadmap and subsystem strategy documents
5. Implementation details, tests, and UI wording

Informal articles, forum explanations, AI-generated summaries, or non-authoritative blogs must never be treated as controlling legal sources.

### 4.1 Legal-source basis locked for this specification

As of 2026-03-25 this specification is written against the project’s legal-source baseline, verified against the official consolidated Danish Road Traffic Act in force at the locked legal-source date.

The Version 1 legal baseline includes, at minimum, the official rules relevant to:

- pedestrian crossing distance restrictions
- cycle-path-exit distance restrictions
- intersection distance restrictions
- bus-stop restrictions
- directly prohibited placement surfaces
- driveway obstruction treatment
- statutory exceptions that can invalidate deterministic judgment

### 4.2 Legal-source governance rule

This specification does not authorize ad hoc legal interpretation.

If the law changes, the project must update:

- `LEGAL_SOURCE_REGISTER.md`
- `LEGAL_THRESHOLDS.md`
- `SCOPE_AND_LIMITATIONS.md`
- `CLAIMS_POLICY.md`
- this master specification where affected

No silent legal drift is allowed.

---

## 5. Product claim boundary

The product must not claim that it determines full parking legality under all Danish rules in all circumstances.

The product may only claim:

**The system evaluates supported Danish stopping and parking rules defined in this specification using on-device sensing, deterministic geometry, versioned map priors, and refusal-safe confidence logic.**

The product must not claim:

- that a result covers every possible Danish parking rule
- that a result overrides signs, temporary controls, local municipal restrictions, private contractual rules, or enforcement discretion
- that a result is final legal advice
- that a result is safe when evidence is materially incomplete
- that a positive result means there is no other parking restriction present

If the system does not explicitly evaluate a rule family, the product must not imply clearance for that rule family.

---

## 6. Supported primary question

The system is allowed to answer only this question:

**Does any part of the evaluated vehicle footprint violate a supported Danish stopping or parking rule by overlapping a prohibited legal zone or by being closer than the legal threshold to the correct protected legal boundary?**

The system is not measuring:

- the phone location
- the camera center
- the user position
- the vehicle center
- a map node center
- a road centerline
- a user tap point

The measured object is always the evaluated vehicle footprint in local ground-plane geometry.

---

## 7. Unsupported primary questions

The engine must not claim to answer the following broader questions:

- “Is this car fully legal under all Danish parking law?”
- “Are there definitely no signs, time limits, permits, or exceptions that matter here?”
- “Will I certainly avoid a fine?”
- “Does this result overrule local enforcement?”
- “Is this location universally safe to park?”

The engine may only speak for the supported rule families it actually evaluated.

---

## 8. Agent boundary

### 8.1 Deterministic engine versus agent layer

The legal decision path must be deterministic and must run inside the parking engine or SDK.

Any agent, assistant, explainer, or LLM layer must be outside the legal decision path.

### 8.2 What the deterministic engine must own

The engine must own:

- sensor acceptance and refusal
- AR-based metric ground-plane calibration
- target selection safety state
- vehicle footprint estimation
- legal-boundary localization
- feature-candidate matching
- distance calculation
- overlap detection
- uncertainty estimation
- final state classification
- structured output generation

### 8.3 What the agent may do

An agent layer may only:

- explain the engine result in natural language
- guide the user to retry
- summarize which rule family was evaluated
- describe why the engine refused
- present limitations and safety notices
- translate structured output into human-readable help

### 8.4 What the agent may never do

An agent layer may never:

- infer legality from raw camera images on its own
- replace deterministic distance calculation
- override a refusal from the engine
- invent geometry, distances, or legal references
- upgrade `PROBABLY_*` or `UNVERIFIABLE` into certainty
- suppress limitations or supported-scope disclosures
- silently change which rule family was evaluated

This boundary is mandatory.

---

## 9. Version 1 scope policy

### 9.1 Fully supported in Version 1

Version 1 must support the following rule families when evidence is sufficient:

1. pedestrian crossing rule family
2. cycle-path-exit rule family
3. intersection rule family
4. direct prohibited-surface rule family
5. bus-stop rule family
6. refusal-safe handling for visible but unsupported restriction sources

### 9.2 Advisory-first in Version 1

Version 1 may provide advisory-first output, but not hard legal certainty, for:

- driveway obstruction
- property-access hindrance
- some private-access adjacency cases
- visually weak entrance/exit hindrance cases

### 9.3 Outside hard legal-clear Version 1 unless separately implemented

The following are outside hard legal clearance unless separately implemented and validated:

- permit rights
- payment compliance
- time-window restrictions
- loading-only restrictions
- temporary controls
- police or emergency instructions
- event or construction restrictions
- disabled-badge entitlement
- electric charging entitlement
- unsupported local signage schemes
- private contractual parking systems

### 9.4 Single active target rule

Each analysis attempt must evaluate exactly one active target vehicle.

Ambiguous multi-vehicle scenes must be disambiguated or refused.

### 9.5 Visible unsupported restriction sentinel

Version 1 must include a safety sentinel for visible but unsupported signs, markings, temporary controls, and private-condition boards.

If these appear relevant, the system must not imply clean legal clearance.

---

## 10. Version 1 legal threshold baseline

This specification locks the threshold baseline that later documents must formalize in `LEGAL_THRESHOLDS.md`.

### 10.1 Crossing rule family

The crossing rule family uses a 5 metre boundary logic relative to the legally relevant crossing approach boundary.

### 10.2 Cycle-path-exit rule family

The cycle-path-exit rule family uses a 5 metre boundary logic relative to the legally relevant exit boundary, with side selection depending on the exit geometry.

### 10.3 Intersection rule family

The intersection rule family uses a 10 metre boundary logic relative to the correct nearest transverse carriageway edge or, where relevant by law, the nearest relevant cycle-path edge where carriageway and cycle path merge into the intersection geometry.

### 10.4 Bus-stop rule family

The bus-stop rule family uses:

- the marked prohibited segment where road marking defines the protected extent, or
- a 12 metre boundary on each side of the stop sign where no such marking exists and the case is otherwise supportable

### 10.5 Direct prohibited-surface rule family

The direct prohibited-surface rule family uses overlap logic, not threshold logic, for surfaces where stopping or parking is directly prohibited by law.

### 10.6 Driveway obstruction in Version 1

Driveway obstruction is advisory-first in Version 1.

It must not be presented as a full hard-legal supported family unless separately promoted by formal scope update and validation.

### 10.7 Threshold authority rule

Legal threshold constants are not configurable product preferences.

They are controlled legal constants and must not be changed by policy or UI.

---

## 11. Rule-family legal geometry definitions

This section defines the geometry the engine must use.

### 11.1 General legal geometry rule

For all supported threshold-based families, the measured quantity must be the shortest distance in local ground-plane metric geometry between:

- the nearest legally relevant point of the evaluated vehicle footprint, and
- the correct protected legal boundary for the active rule family

### 11.2 General overlap rule

For overlap-based families, the relevant quantity is whether any part of the evaluated vehicle footprint intersects the prohibited legal zone.

### 11.3 Vehicle reference rule

The measured vehicle reference must always be the evaluated footprint edge that is closest to the active protected boundary.

The system must not measure from:

- phone location
- camera origin
- vehicle center
- bumper center unless it is also the nearest legally relevant footprint point
- arbitrary user tap
- map centroid

### 11.4 Boundary reference rule

The protected legal boundary must be the rule-family-specific legal boundary.

The engine must not replace it with:

- road centerline
- lane centerline
- rough curb midpoint
- feature centroid
- guessed street node center

### 11.5 Local metric frame

All supported legal distances must be computed in a local metric frame derived from accepted on-device measurement.

Pixel distances alone are not legal distances.

### 11.6 Nearest-point principle

If a rule is threshold-based, the engine must use the shortest relevant point-to-boundary distance under the active rule-family geometry definition.

### 11.7 Boundary provenance requirement

The output must expose which boundary type was used and the provenance of that boundary.

---

## 12. Rule-family behavior by family

### 12.1 Pedestrian crossing family

The engine must determine whether any part of the evaluated vehicle footprint:

- overlaps the crossing itself where prohibited, or
- lies within the protected 5 metre approach distance relative to the correct crossing approach boundary

The engine must localize the crossing boundary actually relevant to the vehicle position.

If the crossing is partially visible and the approach side cannot be resolved safely, the engine must refuse.

### 12.2 Cycle-path-exit family

The engine must determine whether any part of the evaluated vehicle footprint:

- is placed in a directly prohibited position at the exit, or
- lies within the legally relevant 5 metre protection region relative to the exit boundary

The engine must account for whether the cycle path runs along the carriageway or is transverse to it where that affects the boundary concept.

If the exit geometry cannot be resolved with sufficient confidence, the engine must refuse.

### 12.3 Intersection family

The engine must determine whether any part of the evaluated vehicle footprint:

- lies inside the intersection prohibition zone, or
- lies within 10 metres of the legally relevant nearest transverse edge

If the relevant transverse edge cannot be localized safely, the engine must refuse.

The engine must not substitute road centerlines, map-node centers, or approximate crossing points for the legally relevant edge.

### 12.4 Bus-stop family

If a marked bus-stop prohibited segment is present and supportable, the engine must use the marked segment.

If no marking exists and the stop sign is supportable, the engine may evaluate the 12 metre boundary on each side of the sign.

If neither the marked segment nor sign location can be supportably localized, the engine must refuse.

### 12.5 Direct prohibited surfaces

For direct prohibited surfaces, the engine must determine whether any part of the vehicle footprint overlaps the prohibited surface.

Examples include cycle path, footway, refuge, island, median-like protected structures, and similar directly prohibited placement surfaces when they are within supported scope and can be localized safely.

### 12.6 Driveway obstruction advisory family

Version 1 may provide advisory risk output for driveway obstruction, but not hard legal certainty.

The engine must clearly label this as advisory-first.

---

## 13. Target vehicle selection policy

The engine must never silently switch between different vehicles in the same scene.

### 13.1 Single active target

Every analysis attempt must evaluate exactly one active target vehicle.

If no single active target can be established with sufficient confidence, the engine must return `UNVERIFIABLE`.

### 13.2 Allowed target-selection sources

The engine may establish the active target only from one or more of the following approved sources:

- explicit user target selection
- deterministic proximity and framing rules
- stable temporal target lock across the accepted capture window
- deterministic target-disambiguation logic documented in policy

### 13.3 Conservative Version 1 policy

Version 1 must use a conservative single-target policy:

- if only one plausible parked vehicle is present in the evaluation zone, that vehicle may be selected automatically
- if more than one plausible vehicle is present, the app must require explicit user confirmation or very clear deterministic disambiguation
- if two vehicles remain materially plausible after disambiguation, the engine must refuse

### 13.4 Auto-selection limits

Automatic target selection is allowed only if all of the following are true:

- one vehicle is materially more central or intentionally framed than others
- one vehicle has a clearly visible risk-side edge
- one vehicle is materially more compatible with the relevant candidate feature
- one vehicle maintains stable identity over the accepted capture window
- no competing vehicle remains similarly plausible

### 13.5 Mandatory refusal cases

The engine must return `UNVERIFIABLE` if:

- two or more vehicles overlap materially in the analysis region
- the selected target identity changes during the accepted capture window
- the app cannot prove which vehicle the user intends to assess
- the nearest legal boundary could plausibly belong to more than one vehicle
- the chosen vehicle edge is too occluded for safe measurement

### 13.6 Required target output fields

The output contract must expose at minimum:

- `target_vehicle_id`
- `target_selection_mode`
- `target_selection_confidence`
- `target_disambiguation_required`
- `scene_vehicle_count_estimate`

---

## 14. Capture acceptance and refusal

### 14.1 Accepted capture principle

The engine may evaluate only accepted captures.

An accepted capture is a capture window that satisfies the minimum evidence requirements for the active analysis.

### 14.2 Mandatory acceptance checks

At minimum the engine must evaluate:

- sufficient lighting or feature visibility
- adequate focus
- adequate target-edge visibility
- adequate protected-boundary visibility or supportable provenance
- stable local metric plane
- stable temporal target identity
- no severe motion blur that destroys geometry trust
- no fatal obstruction of the critical scene region

### 14.3 Mandatory immediate refusal cases

The engine must refuse if any of the following are true:

- metric scale cannot be trusted
- the target vehicle cannot be isolated
- the protected legal boundary cannot be localized or supported safely
- two or more rule-family candidates remain materially unresolved
- a visible unsupported restriction source creates unresolved risk
- the app is offline without the required active dataset region
- the result would require unsupported legal interpretation

### 14.4 Capture quality classification

The output must expose a structured capture-quality classification that is sufficient for retry guidance.

### 14.5 Retry guidance rule

Each refusal reason must map to a retry class such as:

- move closer
- change angle
- show the target edge
- include the boundary area
- confirm the target vehicle
- improve light/steadiness
- update or download region dataset

---

## 15. Dataset and feature priors

### 15.1 Dataset role

The dataset provides candidate legal features and region-scoped prior information.

It does not by itself prove the final legal state.

### 15.2 Dataset requirements

The active dataset must be:

- downloadable
- versioned
- integrity-checked
- region-bounded
- auditable
- usable offline after activation

### 15.3 Candidate-generation role

The engine may use the dataset to generate candidate crossings, intersections, cycle-path exits, bus stops, and other supported features near the target.

### 15.4 Dataset limitation rule

The engine must not output a final hard legal state using map priors alone when visual or measurement evidence is materially insufficient.

### 15.5 Dataset mismatch handling

If map evidence and visual evidence materially disagree, the engine must downgrade or refuse according to confidence policy.

---

## 16. Legal-boundary localization policy

### 16.1 Boundary localization sources

The engine may localize the active legal boundary from a controlled combination of:

- visual scene evidence
- accepted AR geometry
- versioned dataset priors
- deterministic rule-family logic

### 16.2 Boundary localization must be family-specific

The engine must know which boundary type it is localizing.

It must not use one generic “danger zone line” for all rules.

### 16.3 Mandatory boundary provenance

The output must indicate:

- boundary type
- boundary source mix
- boundary confidence
- whether the boundary was fully visible, partially visible, or inferred with constrained support

### 16.4 Refusal on unresolved boundary ambiguity

If the active legal boundary remains materially ambiguous after candidate resolution, the engine must refuse.

---

## 17. AR and local geometry policy

### 17.1 AR requirement

AR-based local metric geometry is mandatory for supported distance evaluation.

### 17.2 Metric-plane rule

The engine must establish a local ground-plane metric frame before performing threshold-based measurement.

### 17.3 Invalid geometry prohibition

The engine must not compute a final distance from:

- raw pixels only
- apparent size only
- GPS distance only
- compass-only heading assumptions
- hand-waved planar assumptions without stability checks

### 17.4 Stability rule

The engine must check plane stability across the accepted capture window.

If stability is insufficient, the engine must refuse or downgrade according to policy.

### 17.5 Projection rule

Vehicle footprint points and legal-boundary points used in distance calculation must be represented in the same accepted local metric frame.

### 17.6 Geometry output fields

The output must expose enough geometry metadata to support debugging, including at minimum:

- local metric-frame validity
- AR stability summary
- projection validity summary

---

## 18. Vehicle footprint policy

### 18.1 Footprint concept

The evaluated vehicle footprint is the on-ground occupied outline or supported occupied extent of the target vehicle that matters for the active rule family.

### 18.2 Footprint representation

The engine may use a polygon, oriented box with conservative refinement, or another documented shape representation, but it must preserve the legally relevant nearest-edge behavior.

### 18.3 Risk-side edge rule

For threshold rules, the measured footprint edge must be the nearest legally relevant edge to the active protected boundary.

### 18.4 Occlusion policy

If the risk-side edge is materially occluded and cannot be conservatively localized with sufficient confidence, the engine must refuse.

### 18.5 Conservative-edge policy

Where uncertainty remains but a conservative supported bound is possible, the engine may downgrade state but must not present certainty beyond the uncertainty budget.

---

## 19. Feature candidate matching policy

### 19.1 Candidate-generation principle

The engine may consider multiple candidate features near the target, but must converge on one active candidate or refuse.

### 19.2 Candidate-ranking signals

Candidate ranking may use:

- proximity in accepted metric geometry
- visual alignment with the scene
- dataset priors
- boundary compatibility
- temporal stability across the capture window
- rule-family compatibility with visible scene evidence

### 19.3 Forbidden candidate behavior

The engine must not:

- silently switch candidates late in the pipeline
- force a single candidate when two remain materially plausible
- ignore visible evidence that materially contradicts the candidate

### 19.4 Candidate ambiguity refusal

If multiple candidates remain materially plausible after deterministic ranking, the engine must return `UNVERIFIABLE`.

### 19.5 Candidate output fields

The output must include:

- `feature_candidate_id`
- `feature_candidate_type`
- `feature_candidate_confidence`
- `candidate_resolution_mode`

---

## 20. Uncertainty and confidence policy

### 20.1 Core rule

Confidence must be an evidence-based output of the deterministic pipeline.

It must not be a stylistic number.

### 20.2 Mandatory uncertainty components

At minimum the engine must account for:

- AR scale uncertainty
- plane-fit uncertainty
- target-edge uncertainty
- boundary-localization uncertainty
- candidate-feature uncertainty
- projection uncertainty
- temporal instability
- dataset uncertainty where relevant

### 20.3 Total-error budget

The engine must compute or conservatively estimate `estimated_total_error_m` for supported threshold-based evaluations.

### 20.4 Confidence-state relationship

Decision state must be selected from evidence + margin + uncertainty.

A small raw margin near threshold is not sufficient for certainty.

### 20.5 Mandatory near-threshold downgrade rule

If the measured margin is too small relative to total uncertainty, the engine must downgrade the result or refuse.

### 20.6 Confidence score meaning

The confidence score must reflect confidence in the structured result inside supported scope.

It must not imply confidence about unsupported rule families.

### 20.7 Uncertainty output fields

The output must expose:

- `estimated_total_error_m`
- `confidence_score`
- `uncertainty_components_summary`

---

## 21. Supported decision states

The product must implement the following user-visible decision states.

### 21.1 `ILLEGAL`

Use only when the supported evidence and uncertainty model justify strong confidence that the evaluated footprint violates the active supported rule family.

### 21.2 `PROBABLY_ILLEGAL`

Use when evidence points toward violation but uncertainty is too high for the strongest state.

### 21.3 `UNVERIFIABLE`

Use when the engine cannot safely determine the result inside supported scope.

This is correct behavior.

### 21.4 `PROBABLY_LEGAL`

Use when evidence points toward compliance for the active supported family but uncertainty is too high for the strongest positive state.

### 21.5 `LEGAL_WITH_BUFFER`

Use only when the system has sufficient supported evidence that the evaluated footprint is outside the active threshold or zone with enough margin relative to uncertainty.

### 21.6 No forced-decision rule

The engine must not collapse `UNVERIFIABLE` into a positive or negative state merely for user convenience.

### 21.7 No universal-clearance rule

Even `LEGAL_WITH_BUFFER` means only that the evaluated supported family appears clear with buffer.

It does not mean all Danish parking conditions are satisfied.

---

## 22. Decision-state semantics

### 22.1 State selection rule

The final state must be derived from:

- active rule family
- selected feature candidate
- vehicle-footprint geometry
- legal-boundary geometry
- signed margin or overlap
- uncertainty budget
- visible unsupported restriction handling
- refusal policy

### 22.2 Signed margin semantics

For threshold-based families:

- negative signed margin indicates inside the forbidden threshold
- positive signed margin indicates outside the threshold
- near-zero margins must be evaluated relative to total uncertainty

For overlap-based families, overlap quantity replaces or supplements threshold margin.

### 22.3 Visible unsupported restriction impact

If a visible unsupported restriction source materially affects confidence in legal clearance, the state must be downgraded or refused rather than presented as clean positive clearance.

### 22.4 Advisory-family impact

Advisory-first families must not share the exact same certainty semantics as hard supported legal states unless separately promoted by formal scope update.

---

## 23. Input contract requirements

The SDK input contract must support at minimum:

- accepted camera frames or capture bundle reference
- active region identifier
- active dataset version reference
- device/AR session metadata
- optional explicit target selection from user
- app policy/config version reference
- timestamp and locale context as needed
- permissions and sensor-state summary
- any required map-prior context handle

The exact shape must be defined in `SDK_API_CONTRACT.md`.

The SDK must reject incomplete input required for a safe supported evaluation.

---

## 24. Output contract requirements

The engine output must be structured and deterministic.

### 24.1 Mandatory output fields

At minimum the output must contain:

- `schema_version`
- `analysis_id`
- `timestamp_utc`
- `sdk_version`
- `model_version`
- `dataset_version`
- `policy_version`
- `region_id`
- `active_rule_family`
- `decision_state`
- `decision_reason_code`
- `supported_scope_flag`
- `target_vehicle_id`
- `target_selection_mode`
- `target_selection_confidence`
- `scene_vehicle_count_estimate`
- `feature_candidate_id`
- `feature_candidate_type`
- `feature_candidate_confidence`
- `protected_boundary_type`
- `boundary_provenance`
- `capture_quality`
- `local_metric_frame_valid`
- `measured_distance_m` when relevant
- `overlap_m` when relevant
- `legal_threshold_m` when relevant
- `signed_margin_m` when relevant
- `estimated_total_error_m`
- `confidence_score`
- `unsupported_visible_restriction_flag`
- `limitations_notice`
- `refusal_reason` when applicable
- `retry_guidance_code` when applicable

### 24.2 Mandatory limitations notice rule

Every positive and negative user-visible result must include or map to a limitations notice indicating that only supported rule families were evaluated.

### 24.3 Version-traceability rule

The output must always be traceable to the exact dataset, policy, model, and SDK versions used for the decision.

### 24.4 Output compatibility rule

The meaning of existing output fields must not change silently across app versions or platforms.

---

## 25. Refusal reasons

The engine must expose structured refusal reasons.

At minimum the refusal taxonomy must cover:

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

The final taxonomy may be expanded, but not reduced below safe explainability.

---

## 26. Retry guidance mapping

Every refusal reason must map to one or more retry guidance codes that the app can present to the user.

At minimum the retry guidance set must support:

- show more of the target vehicle
- show more of the crossing/intersection/exit/bus-stop boundary
- confirm which vehicle is being checked
- move to a safer angle
- hold steady for AR stabilization
- improve lighting or reduce blur
- download/update region data
- retry later because the rule context is unsupported

---

## 27. Unsupported visible restriction sentinel

### 27.1 Sentinel role

The sentinel exists to prevent false reassurance when the camera sees restriction sources the engine does not yet evaluate fully.

### 27.2 Sentinel triggers

The sentinel must consider at minimum:

- parking signs not in the supported evaluator set
- road markings not in the supported evaluator set
- temporary controls
- cones or barriers suggesting temporary regulation
- private-condition boards
- visible municipal restrictions not yet in supported scope

### 27.3 Sentinel effect

When triggered, the sentinel may:

- add a warning
- downgrade a positive state
- force `UNVERIFIABLE`

The sentinel must not be ignored if it materially affects clearance.

### 27.4 Sentinel disclosure

The app must tell the user that an unsupported visible restriction may exist and therefore the engine did not provide clean clearance.

---

## 28. Privacy and data handling policy

### 28.1 On-device legal path

The legal decision path must run on device.

No hidden cloud dependency may be required for final legal-state classification in supported operation.

### 28.2 Data-minimization rule

The product should prefer structured metadata retention over raw frame retention wherever possible.

### 28.3 Image-retention rule

If images, thumbnails, or replay artifacts are retained for debugging or support, the product must disclose this clearly and govern it by explicit retention policy.

### 28.4 Version and telemetry traceability

The product must preserve enough structured telemetry to debug failures and support complaints while respecting data minimization.

### 28.5 Minimum telemetry fields

At minimum structured telemetry should support:

- analysis ID
- app version
- SDK version
- dataset version
- model version
- policy version
- decision state
- refusal reason
- capture-quality summary
- target/candidate/boundary confidence summaries
- unsupported-visible-restriction flag

---

## 29. Observability and replay policy

### 29.1 Observability goal

Observability must help answer:

- what the engine believed the target was
- what feature candidate it chose
- what boundary it used
- what uncertainty dominated the result
- why it answered, downgraded, or refused

### 29.2 Replay rule

If a replay system exists, replay artifacts must preserve version context and must not reinterpret past cases with new semantics unless clearly marked as retrospective analysis.

### 29.3 Debuggability requirement

A reviewer must be able to inspect a failed or disputed case and understand the reasoning path without relying on generative reconstruction.

---

## 30. User disclosure policy

The app must disclose, in user-facing copy, that:

- only supported rule families are evaluated
- visible unsupported restrictions may prevent clean clearance
- results are not universal legal advice
- refusal is normal when evidence is insufficient
- positive results apply only to the evaluated supported family or families
- local signs, temporary controls, permits, or other unsupported restrictions may still matter

These disclosures must appear in onboarding, help, result interpretation, and public marketing surfaces as appropriate.

---

## 31. Release-safety policy

### 31.1 No release without refusal

If the product cannot refuse safely, it must not be released.

### 31.2 No release with ambiguous claims

If product copy implies universal legality or overrules unsupported restrictions, release is blocked.

### 31.3 No release without version traceability

If support cannot identify the dataset/model/policy/SDK versions used in a case, release is blocked.

### 31.4 No release without field validation

If field validation does not include near-threshold and ambiguous real-world scenes, release is blocked.

### 31.5 No release without unsupported-visible-restriction handling

If visible unsupported restrictions can silently pass as clean legal clearance, release is blocked.

---

## 32. Validation requirements

Before public launch, validation must include at minimum:

- easy supported scenes
- near-threshold scenes on both sides
- night or low-light scenes
- rain or adverse visibility scenes
- partial occlusion scenes
- unstable AR scenes
- multiple-vehicle scenes
- multiple nearby-candidate scenes
- marked and unmarked bus-stop scenes
- direct prohibited-surface scenes
- scenes containing unsupported visible restrictions
- user retry comprehension checks

### 32.1 False-confidence guardrail

The project must optimize for low false confidence, not merely high answer rate.

### 32.2 Refusal adequacy guardrail

The project must measure whether refusal happened in scenes where confidence should not have been high.

### 32.3 Threshold-zone guardrail

The project must treat near-threshold scenes as first-class validation cases, not edge-case leftovers.

---

## 33. Non-negotiable engineering rules

The implementation must never:

- replace legal geometry with GPS distance
- measure from phone position instead of vehicle footprint
- measure to a guessed generic boundary instead of the rule-specific legal boundary
- use the agent layer to compute legality
- hide `UNVERIFIABLE` behind forced decisions
- claim support for unimplemented rule families
- silently ignore visible unsupported restrictions
- silently change output semantics across versions or platforms

---

## 34. Formal change-control items

The following items require formal change control and may not be casually edited:

- supported rule-family list
- legal thresholds
- rule-family geometry definitions
- decision-state vocabulary
- refusal reason taxonomy
- output contract core fields
- positive-result claim semantics
- visible unsupported restriction policy
- advisory-first versus hard-supported family status

Any change must update all dependent documents.

---

## 35. Appendix A — Required minimum state machine

The result-state machine for supported hard-legal families must obey the following logic:

1. if the case is outside supported scope, return `UNVERIFIABLE`
2. if target is unresolved, return `UNVERIFIABLE`
3. if boundary is unresolved, return `UNVERIFIABLE`
4. if candidate feature is unresolved, return `UNVERIFIABLE`
5. if visible unsupported restriction materially affects clearance, downgrade or return `UNVERIFIABLE`
6. if geometry is invalid, return `UNVERIFIABLE`
7. if overlap or signed margin with uncertainty strongly indicates violation, return `ILLEGAL`
8. if overlap or signed margin indicates likely violation but not strong enough, return `PROBABLY_ILLEGAL`
9. if signed margin with uncertainty strongly indicates clearance inside supported family, return `LEGAL_WITH_BUFFER`
10. if signed margin indicates likely clearance but not strong enough, return `PROBABLY_LEGAL`
11. otherwise return `UNVERIFIABLE`

This logic is mandatory at the semantic level even if implementation details differ.

---

## 36. Appendix B — Minimum example output semantics

The exact schema belongs in `OUTPUT_CONTRACT.md`, but the semantic shape must be equivalent to the following:

```json
{
  "schema_version": "1.0.0",
  "analysis_id": "uuid",
  "timestamp_utc": "2026-03-25T12:00:00Z",
  "sdk_version": "1.0.0",
  "model_version": "v1-ios-a",
  "dataset_version": "cph-core-2026.03",
  "policy_version": "2026.03.25",
  "region_id": "dk-cph-core",
  "active_rule_family": "intersection_10m",
  "decision_state": "PROBABLY_ILLEGAL",
  "decision_reason_code": "NEGATIVE_MARGIN_WITH_MODERATE_UNCERTAINTY",
  "supported_scope_flag": true,
  "target_vehicle_id": "target-1",
  "target_selection_mode": "user_confirmed",
  "target_selection_confidence": 0.98,
  "scene_vehicle_count_estimate": 2,
  "feature_candidate_id": "intersection-123",
  "feature_candidate_type": "intersection",
  "feature_candidate_confidence": 0.91,
  "protected_boundary_type": "nearest_transverse_edge",
  "boundary_provenance": "visual_plus_dataset_plus_ar",
  "capture_quality": "acceptable_with_risk",
  "local_metric_frame_valid": true,
  "measured_distance_m": 8.7,
  "legal_threshold_m": 10.0,
  "signed_margin_m": -1.3,
  "estimated_total_error_m": 0.7,
  "confidence_score": 0.81,
  "unsupported_visible_restriction_flag": false,
  "limitations_notice": "Only supported Danish parking rules evaluated by the engine are covered.",
  "refusal_reason": null,
  "retry_guidance_code": null
}
```

This example is illustrative of semantics, not a permission to reduce the required contract.

---

## 37. Appendix C — What Version 1 is and is not

Version 1 is:

- narrow
- deterministic
- geometry-based
- refusal-safe
- on-device
- auditable
- scope-controlled

Version 1 is not:

- universal legal advice
- a sign-complete parking-law oracle
- a map-only distance checker
- a GPS-based legality detector
- a general computer-vision chatbot
- an excuse to suppress uncertainty

---

## 38. Final implementation command

Any implementation of this project must preserve the following truth:

**The engine may answer only when it can identify one target vehicle, one active legal feature, one correct protected boundary, and one trustworthy local metric frame inside supported scope. Otherwise it must refuse.**

That is the core of the product.

