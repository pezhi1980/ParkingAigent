# TARGET SELECTION POLICY — DK PARKING ENGINE
## Version 1 — Phase 5 document
## Status: DONE
## Locked baseline date: 2026-04-03

---

## 1. Purpose

This document defines the target selection policy for Version 1.

It governs:
- the one-active-target rule
- how target vehicles are detected and tracked
- how the user confirms the active target
- what constitutes target ambiguity and how it is handled
- target lifecycle within an evaluation session
- what makes a target invalid for evaluation

---

## 2. One-active-target rule (locked, non-negotiable)

**Only one vehicle may be evaluated per evaluation call.**

The engine MUST NOT:
- evaluate multiple vehicles simultaneously
- produce a legal result that covers more than one vehicle
- silently select a default vehicle without visual confirmation when ambiguity exists

This rule is absolute. It cannot be relaxed by policy parameters.

---

## 3. Target detection

Target detection is performed by the on-device ML model (Vision/CoreML on iOS).

### 3.1 Detection outputs
For each frame, the detection model produces:
- a list of vehicle bounding boxes with class confidence scores
- a vehicle instance mask (or segmentation polygon) for each detection
- a depth estimate per detection (from AR depth or stereo depth assistance)

### 3.2 Detection quality requirements
A vehicle detection is considered usable if:
- class confidence ≥ 0.60
- the vehicle instance mask covers the legally relevant edge (front or rear or near-side)
- the bounding box is not clipped by the frame edge on the measured side

If no detection meets these requirements: return UNVERIFIABLE with `BOUNDARY_UNRESOLVED` (no usable target).

---

## 4. Target confirmation flow

### 4.1 Auto-select (unambiguous case)
If exactly one vehicle is detected in the frame with sufficient confidence AND it is the visually dominant vehicle (largest masked area, or clearly closest to the boundary being evaluated):
- the target is auto-selected as `target_confirmation_source = auto_selected_unambiguous`
- no user interaction is required
- the selection is recorded in the output (`TargetInfo.target_confirmation_source`)

### 4.2 User confirmation (ambiguous case)
If more than one vehicle is detected with sufficient confidence, OR the dominant vehicle is not clearly distinguishable:
- the app UI MUST show a target selection prompt
- the user MUST explicitly tap or confirm the intended vehicle
- only after user confirmation does the target become active
- `target_confirmation_source = user_confirmed`

### 4.3 No valid target detected
If no vehicle is detected with sufficient confidence:
- return UNVERIFIABLE with `TARGET_AMBIGUOUS` (or `INSUFFICIENT_EVIDENCE_GENERAL` if the scene contains no recognizable vehicles)
- provide retry guidance: "Frame the vehicle you want to evaluate and make sure it is fully visible"

---

## 5. Target ambiguity rules

| Condition | Required Behavior |
|---|---|
| Exactly one vehicle, high confidence, dominant | Auto-select, proceed |
| Exactly one vehicle, low confidence | User confirmation required |
| Multiple vehicles, one clearly dominant | Auto-select dominant vehicle, but app may offer re-selection |
| Multiple vehicles, no clear dominant | User confirmation required — do NOT auto-select |
| Zero usable vehicle detections | UNVERIFIABLE — do not proceed |

**Ambiguity MUST result in user confirmation or refusal. It MUST NOT result in guessing.**

---

## 6. Active target lifecycle

### 6.1 Target lock
Once a target is confirmed (auto or user), it becomes the **active target** for the evaluation session.
The active target is locked for the duration of a single evaluation call.

### 6.2 Target invalidation
The active target MUST be invalidated (and re-confirmation triggered) when:
- the user explicitly requests to change target
- the target vehicle has left the frame between confirmation and capture
- the AR session has reset since target confirmation
- the target detection confidence has fallen below 0.40 between confirmation and evaluation

When invalidated, the session returns to the target detection step.

### 6.3 One-call scope
The active target is scoped to one evaluation call only.
A new evaluation call starts a new target selection cycle.

---

## 7. Invalid target conditions (MUST refuse)

| Invalid Condition | Refusal Reason Code |
|---|---|
| Target edge used for measurement is partially occluded and edge quality below PR-008 threshold | `TARGET_EDGE_OCCLUDED` |
| Target confidence dropped below 0.40 after confirmation | `TARGET_AMBIGUOUS` |
| Target vehicle left the frame after confirmation | `TARGET_AMBIGUOUS` |
| Multiple vehicles overlap the target detection region and cannot be separated | `TARGET_AMBIGUOUS` |

---

## 8. Change control

Any change to:
- the one-active-target rule
- detection quality thresholds
- the auto-select vs. user-confirmation boundary
- target lifecycle rules

requires:
1. Update to this document.
2. Entry in `WHAT_DID_I_DO.md`.
3. Review of `vehicle_footprint_strategy.md` and `OUTPUT_CONTRACT.md` (`TargetInfo`) for consistency.
4. Engineering + Product Owner approval for changes affecting user confirmation behavior.
5. Update to `TASKLIST_V4_FINAL.md` if a new task or blocker arises.
