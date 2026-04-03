# SYSTEM ARCHITECTURE — DK PARKING ENGINE
## Version 1 — Phase 2 document
## Status: DONE
## Locked baseline date: 2026-04-03

---

## 1. Purpose

This document defines the authoritative system architecture for Version 1 of the DK Parking Engine.

It defines:
- all major subsystems and their boundaries
- the legal decision path and its isolation requirements
- the data flow from capture to structured result
- the offline lifecycle
- the subsystem interfaces at a boundary level

This document is normative. All implementation must conform to it.
Any change to subsystem boundaries requires updating this document, logging in `WHAT_DID_I_DO.md`, and updating `TASKLIST_V4_FINAL.md`.

---

## 2. Major subsystems

Version 1 consists of the following subsystems:

| Subsystem ID | Subsystem Name | Responsibility |
|---|---|---|
| SS-01 | Capture Subsystem | Accept or reject input frames; enforce capture quality gates before any data enters the evaluation path |
| SS-02 | AR Measurement Subsystem | Establish metric ground-plane scale using ARKit (iOS); validate plane stability; provide metric geometry to the evaluation path |
| SS-03 | Target Selection Subsystem | Identify and confirm the one active target vehicle; enforce single-active-target policy; provide confirmed vehicle footprint geometry |
| SS-04 | Dataset Subsystem | Load, version-check, and serve the regional feature dataset; enforce integrity; manage activation and expiry |
| SS-05 | Legal Evaluation Engine (core SDK) | Execute the deterministic parking rule evaluation; own the full legal decision path; produce structured result output |
| SS-06 | Policy Registry | Load and serve versioned policy configurations (refusal thresholds, confidence parameters, rule-family enable/disable flags) |
| SS-07 | Output Serializer | Package the structured result into the defined output contract format; attach version references |
| SS-08 | Agent / Explainer Layer | Explain evaluated outputs to the user; guide retry; summarize limitations; must NOT enter the legal decision path |
| SS-09 | App UI Layer | Present capture guidance, target confirmation, result display, retry/refusal UX, and limitations surfaces |
| SS-10 | Logging and Replay Subsystem | Record structured telemetry for observability, debugging, and field validation; must not affect the legal decision path |

---

## 3. Subsystem boundary rules (locked)

### 3.1 Legal decision path boundary

The **legal decision path** consists of SS-02, SS-03, SS-04, SS-05, SS-06, and SS-07.

The legal decision path MUST:
- run entirely on-device
- require no live network connection after dataset activation
- produce deterministic outputs for identical inputs
- be isolated from SS-08 (Agent layer)
- not allow the agent layer to modify, override, or re-enter any evaluation step

### 3.2 Agent layer boundary

SS-08 (Agent / Explainer Layer) may ONLY:
- receive the finalized structured result from SS-07
- explain the result to the user
- surface limitations
- guide retry

SS-08 MUST NOT:
- compute legality from raw images
- modify the decision state
- override a refusal
- inject distance values
- suppress required disclosures

### 3.3 Capture acceptance boundary

SS-01 (Capture Subsystem) is the gating boundary.

No data may proceed to the legal evaluation path unless SS-01 confirms:
- minimum image quality (focus, brightness)
- AR session is active and metric scale is initialized
- scene is within the active region dataset coverage

If any gate fails, SS-01 must return a pre-evaluation refusal with the appropriate reason code before SS-02 or SS-05 are invoked.

---

## 4. Data flow — capture to structured result

```
[Camera + ARKit sensors]
        |
        v
[SS-01: Capture Subsystem]
  → Quality gate check
  → AR session state check
  → Region coverage check
  → If gate fails → pre-evaluation UNVERIFIABLE (refusal reason)
        |
        v (gate passed)
[SS-02: AR Measurement Subsystem]
  → Ground-plane acquisition
  → Metric scale validation
  → Plane stability check
  → If invalid → UNVERIFIABLE (AR_SCALE_UNTRUSTED / PLANE_UNSTABLE)
        |
        v (valid metric frame)
[SS-03: Target Selection Subsystem]
  → Vehicle detection
  → Single-active-target policy enforcement
  → User confirmation trigger (if ambiguous)
  → Vehicle footprint geometry extraction
  → If ambiguous → UNVERIFIABLE (TARGET_AMBIGUOUS)
        |
        v (confirmed target + footprint)
[SS-04: Dataset Subsystem]  <—————————————————————
  → Load active region feature set                |
  → Integrity and version check                   |
  → If no active region → UNVERIFIABLE (NO_ACTIVE_DATASET_REGION)
        |
        v (feature candidates available)
[SS-05: Legal Evaluation Engine]
  → Feature candidate matching
  → Legal boundary localization
  → Distance / overlap measurement
  → Uncertainty and confidence computation
  → Decision state selection
  → Refusal if insufficient evidence
        |
  [SS-06: Policy Registry] (loaded at init; read during evaluation)
  → Provides: refusal thresholds, confidence parameters, rule-family flags
        |
        v (decision state + evidence bundle)
[SS-07: Output Serializer]
  → Attach version references (dataset, model, policy, app)
  → Package structured result per OUTPUT_CONTRACT.md
        |
        v
[SS-08: Agent / Explainer Layer]   [SS-09: App UI Layer]
  → Receives finalized result         → Renders result
  → Explains in natural language      → Shows limitations
  → Guides retry if UNVERIFIABLE      → Handles target confirmation UI
        |
        v
[SS-10: Logging and Replay Subsystem]
  → Records structured telemetry (async, must not block evaluation path)
```

---

## 5. Dataset loading path

1. User downloads region dataset bundle for the active launch region.
2. SS-04 verifies the bundle integrity (checksum/signature).
3. SS-04 verifies the bundle version against the current policy version.
4. SS-04 activates the bundle and records the activation timestamp.
5. The bundle is stored on-device and remains available offline after activation.
6. Dataset expiry: if the bundle exceeds the maximum validity period (defined in VERSIONING_POLICY.md), SS-04 MUST refuse to use it and return `NO_ACTIVE_DATASET_REGION` until a fresh bundle is downloaded.
7. Rollback: if a new bundle fails integrity check, SS-04 MUST revert to the last valid bundle (if within validity period) or refuse.

---

## 6. Policy loading path

1. Policy registry (SS-06) is loaded at SDK initialization.
2. The policy configuration is versioned and bundled with the app or downloaded as a controlled update.
3. SS-06 exposes read-only parameters to SS-05 during evaluation.
4. SS-06 does not expose legal thresholds as configurable values. Legal constants are locked in the evaluator logic per `LEGAL_THRESHOLDS.md`.
5. A policy version mismatch between the policy registry and the active dataset bundle MUST produce a structured warning in the output (not a silent mismatch).

---

## 7. Offline lifecycle

After dataset activation:
- the full legal evaluation path (SS-01 through SS-07) operates without any live network dependency
- the agent layer (SS-08) may optionally use on-device language model capabilities; it MUST NOT require network access to produce required disclosures
- telemetry (SS-10) is queued locally and uploaded when connectivity is available; telemetry failure MUST NOT block evaluation

---

## 8. Refusal path

Refusal (UNVERIFIABLE) may be generated at multiple points in the pipeline:

| Point | Refusal Trigger | Reason Codes |
|---|---|---|
| SS-01 (Capture) | Quality gate failure | INSUFFICIENT_LIGHT_OR_FOCUS |
| SS-01 (Capture) | No active region | NO_ACTIVE_DATASET_REGION |
| SS-02 (AR) | Metric scale invalid | AR_SCALE_UNTRUSTED |
| SS-02 (AR) | Plane unstable | PLANE_UNSTABLE |
| SS-03 (Target) | Target ambiguous | TARGET_AMBIGUOUS |
| SS-03 (Target) | Target edge occluded | TARGET_EDGE_OCCLUDED |
| SS-05 (Engine) | Boundary unresolved | BOUNDARY_UNRESOLVED |
| SS-05 (Engine) | Feature candidate ambiguous | FEATURE_CANDIDATE_AMBIGUOUS |
| SS-05 (Engine) | Visible unsupported restriction | VISIBLE_UNSUPPORTED_RESTRICTION |
| SS-05 (Engine) | Insufficient evidence | INSUFFICIENT_EVIDENCE_GENERAL |
| SS-05 (Engine) | Unsupported rule context | UNSUPPORTED_RULE_CONTEXT |

All refusals produce a structured UNVERIFIABLE result via SS-07 with the appropriate reason code.

---

## 9. Explanation path

1. SS-07 outputs the finalized structured result.
2. SS-08 receives the structured result as input.
3. SS-08 maps the decision state and refusal reason to explanation text using the locked vocabulary in `user_disclosures_and_copy.md`.
4. SS-09 renders the explanation with the required limitations notices.
5. SS-08 and SS-09 must not alter the decision state or evidence fields of the structured result.

---

## 10. Logging and replay path

1. SS-10 records a structured telemetry event for every evaluation attempt.
2. The telemetry record includes: decision state, refusal reasons (if any), version references, capture quality indicators, anonymized geometry metadata (no raw images by default — see `privacy_and_telemetry_spec.md` Phase 12).
3. Telemetry is stored locally and uploaded asynchronously.
4. Telemetry records must be sufficient to replay the evaluation conditions for debugging.
5. Telemetry MUST NOT store raw images without explicit user consent (Phase 12).
6. Telemetry upload MUST NOT block or delay the evaluation path.

---

## 11. iOS platform bindings (Version 1)

- AR measurement backbone: ARKit (iOS)
- On-device ML inference (target detection, segmentation): Core ML / Vision framework
- Dataset storage: on-device file system with integrity verification
- SDK packaging: Swift/Obj-C module with stable public API (defined in `SDK_API_CONTRACT.md`)

---

## 12. No hidden cloud dependency rule (mandatory)

The legal decision path (SS-01 through SS-07) MUST NOT:
- require a network request to evaluate a scene
- call any remote API as part of the evaluation
- depend on a remote confidence scorer, remote model, or remote legal-lookup service
- cache map data that requires live refresh during the evaluation session

After dataset activation, the product MUST be able to produce a structured result (including UNVERIFIABLE) with no network connectivity.

---

## 13. Change control

Any change to subsystem boundaries, data flow, or the offline lifecycle requires:
1. Update to this document.
2. Entry in `WHAT_DID_I_DO.md`.
3. Review of `SDK_API_CONTRACT.md` and `OUTPUT_CONTRACT.md` for consistency.
4. Update to `TASKLIST_V4_FINAL.md` if a new task or blocker arises.
