# POLICY REGISTRY SPEC — DK PARKING ENGINE
## Version 1 — Phase 2 document
## Status: DONE
## Locked baseline date: 2026-04-03

---

## 1. Purpose

This document defines the structure, ownership, and behavior of the Policy Registry (SS-06).

The Policy Registry provides versioned operational configuration to the Legal Evaluation Engine (SS-05).

It does NOT store legal thresholds. Legal thresholds are locked in `LEGAL_THRESHOLDS.md` and compiled into the evaluation engine. They are not configurable via the policy registry.

---

## 2. What the policy registry is and is not

### 2.1 The policy registry IS:
- a versioned, on-device configuration store
- a source of operational parameters that govern evaluation behavior (confidence thresholds, refusal sensitivities, rule-family enable/disable flags)
- updated via controlled releases (not via live remote push during an evaluation session)
- versioned and integrity-checked

### 2.2 The policy registry IS NOT:
- a store for legal thresholds (those are locked in LEGAL_THRESHOLDS.md)
- a mechanism for overriding legal constants at runtime
- a remote configuration endpoint that can change evaluation behavior without a controlled release
- accessible to the agent layer or the app UI directly

---

## 3. Policy registry contents (Version 1 locked parameter set)

| Parameter ID | Parameter Name | Type | Default | Description | Who may change it |
|---|---|---|---|---|---|
| PR-001 | `rule_family_enabled` | Map\<RuleFamilyID, Boolean\> | All V1 supported families: true | Enable/disable individual rule families for evaluation | Engineering + Product Owner, via controlled release |
| PR-002 | `confidence_floor_for_legal_with_buffer` | Float [0.0–1.0] | 0.80 | Minimum confidence score required to produce LEGAL_WITH_BUFFER | Engineering + Product Owner, via controlled release; requires validation evidence |
| PR-003 | `confidence_floor_for_illegal` | Float [0.0–1.0] | 0.80 | Minimum confidence score required to produce ILLEGAL | Engineering + Product Owner, via controlled release; requires validation evidence |
| PR-004 | `near_threshold_downgrade_margin_m` | Float | 0.30 | If the absolute signed margin is less than this value, the engine MUST downgrade from LEGAL_WITH_BUFFER to PROBABLY_LEGAL or from ILLEGAL to PROBABLY_ILLEGAL, regardless of confidence | Engineering only, via controlled release; requires validation evidence |
| PR-005 | `unsupported_restriction_auto_downgrade` | Boolean | true | If true, presence of visible unsupported restriction automatically downgrades a positive result to UNVERIFIABLE | Product Owner approval required to change |
| PR-006 | `plane_stability_minimum_score` | Float [0.0–1.0] | 0.70 | Minimum AR plane stability score required before evaluation proceeds | Engineering, via controlled release |
| PR-007 | `ar_scale_minimum_valid_threshold` | Float [0.0–1.0] | 0.75 | Minimum AR metric scale validity score required before evaluation proceeds | Engineering, via controlled release |
| PR-008 | `target_edge_occlusion_refusal_threshold` | Float [0.0–1.0] | 0.40 | If vehicle edge quality score falls below this, return TARGET_EDGE_OCCLUDED | Engineering, via controlled release |
| PR-009 | `max_candidate_search_radius_m` | Float | 50.0 | Maximum radius in metres for feature candidate search around the target vehicle | Engineering, via controlled release |
| PR-010 | `dataset_max_validity_days` | Integer | 180 | Maximum number of days a downloaded dataset bundle is considered valid | Product Owner + Engineering, via controlled release |

---

## 4. What is NOT in the policy registry

The following are NOT policy registry parameters and MUST NOT be moved there:

- `5m` pedestrian crossing threshold — locked in LEGAL_THRESHOLDS.md (TH-CR-005M)
- `5m` cycle-path exit threshold — locked in LEGAL_THRESHOLDS.md (TH-CPX-005M)
- `10m` intersection threshold — locked in LEGAL_THRESHOLDS.md (TH-INT-010M)
- `12m` bus-stop fallback threshold — locked in LEGAL_THRESHOLDS.md (TH-BS-012M)
- Decision state vocabulary — locked in DECISION_STATES.md
- Scope and limitations definitions — locked in SCOPE_AND_LIMITATIONS.md
- Claims policy — locked in CLAIMS_POLICY.md

These are legal constants and cannot be configured at runtime or via any registry.

---

## 5. Policy registry loading and versioning

- The policy registry is loaded at SDK initialization (SS-06 in SYSTEM_ARCHITECTURE.md).
- The registry file is versioned (see `VERSIONING_POLICY.md`).
- The registry file is bundled with the app release OR downloaded as a controlled update.
- The registry file MUST be integrity-checked before loading. A failed check MUST prevent SDK initialization.
- If the loaded policy version is incompatible with the active dataset bundle version, SDK initialization MUST fail with `POLICY_VERSION_MISMATCH`.

---

## 6. Policy registry ownership

| Role | Responsibility |
|---|---|
| Engineering Owner | Owns parameter values and their implementation correctness |
| Product Owner | Approves changes to parameters that affect product behavior visible to users (PR-005, PR-002, PR-003) |
| Release Authority | Approves any policy registry release |

Changes to policy registry parameters that affect confidence thresholds (PR-002, PR-003) or refusal behavior (PR-005, PR-008) REQUIRE validation evidence before release.

---

## 7. Change control

Any change to a policy registry parameter (adding, removing, or modifying a parameter) requires:
1. Update to this document.
2. Entry in `WHAT_DID_I_DO.md` with before/after values and rationale.
3. Policy version bump per `VERSIONING_POLICY.md`.
4. Validation evidence for changes to confidence thresholds or refusal behavior.
5. Product Owner approval for changes to PR-002, PR-003, PR-005.
6. Update to `TASKLIST_V4_FINAL.md` if a new task or blocker arises.

No parameter may be silently changed between releases.
