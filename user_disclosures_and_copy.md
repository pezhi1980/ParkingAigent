# USER DISCLOSURES AND COPY — DK PARKING ENGINE
## Version 1 — Phase 1 document
## Status: DONE
## Locked baseline date: 2026-04-03

---

## 1. Purpose

This document locks the controlled vocabulary and copy templates for all user-facing text in Version 1.

All implementation, UI, and copy work MUST reference this document.

No user-facing text may claim more than is allowed by `CLAIMS_POLICY.md`.
No user-facing text may contradict `DECISION_STATES.md` state semantics.
No user-facing text may suppress the limitations defined in `SCOPE_AND_LIMITATIONS.md`.

This document does not define final visual design or pixel-level layout.
It defines the required message content and constraints for each context.

---

## 2. Controlled vocabulary (locked)

The following terms are locked for internal and external use.

### 2.1 Decision state display names

| Internal State | Allowed display label | Notes |
|---|---|---|
| `ILLEGAL` | "Violation detected" | Do NOT use "illegal" as a display label. It implies broader legal advice. |
| `PROBABLY_ILLEGAL` | "Likely violation" | Must be paired with uncertainty qualifier. |
| `UNVERIFIABLE` | "Could not evaluate" | Must NOT be shown as an error. It is normal, correct behavior. |
| `PROBABLY_LEGAL` | "Likely compliant" | Must be paired with scope qualifier. |
| `LEGAL_WITH_BUFFER` | "Appears compliant" | Must NEVER say "safe to park" without qualification. |

### 2.2 Forbidden terms (must never appear in user-facing copy)
- "Safe to park here" (unqualified)
- "You are legally parked"
- "No fine risk"
- "Fully legal"
- "All parking rules satisfied"
- "Legal under Danish law" (unqualified — only allowed with explicit rule-family scope)
- "This overrides the sign"
- Any language implying the app is a legal authority

---

## 3. Per-state UI copy templates (locked)

These templates define what the UI MUST communicate for each state.
Final copy may adapt phrasing but MUST preserve the required information and MUST NOT remove required caveats.

### 3.1 LEGAL_WITH_BUFFER — "Appears compliant"

**Headline:** Appears compliant — [rule family name]

**Body (required information):**
"Based on the evaluated vehicle footprint and the measured distance/boundary, the vehicle appears to comply with the [rule family name] restriction. Measured margin: [X]m beyond the [threshold]m threshold.

This result applies only to the [rule family name] rule. Other restrictions — including signs, temporary controls, permits, and rules outside this app's scope — may still apply and are NOT evaluated here."

**Required footer:** Universal limitations notice (see section 6).

**Prohibited:** Any language implying full parking clearance.

---

### 3.2 PROBABLY_LEGAL — "Likely compliant"

**Headline:** Likely compliant — [rule family name]

**Body (required information):**
"Evidence suggests the vehicle is likely outside the [rule family name] restricted zone, but measurement confidence was not high enough for a strong positive result.

If in doubt, consider moving the vehicle or retrying with better framing.

This result applies only to the [rule family name] rule. Other restrictions may still apply."

**Required footer:** Universal limitations notice (see section 6).

---

### 3.3 PROBABLY_ILLEGAL — "Likely violation"

**Headline:** Likely violation — [rule family name]

**Body (required information):**
"Evidence suggests the vehicle may be violating the [rule family name] restriction. Confidence was not high enough for a definitive result, but you should consider moving the vehicle.

This result applies only to the [rule family name] rule."

**Required footer:** Universal limitations notice (see section 6).

**Prohibited:** Presenting this as definitive legal advice or a guarantee of enforcement.

---

### 3.4 ILLEGAL — "Violation detected"

**Headline:** Violation detected — [rule family name]

**Body (required information):**
"The evaluated vehicle footprint appears to violate the [rule family name] restriction. The vehicle should be moved.

This result is based on the evaluated evidence and applies only to the [rule family name] rule. Other restrictions may also apply."

**Required footer:** Universal limitations notice (see section 6).

**Prohibited:** Predicting enforcement outcomes. Do not say "you will receive a fine."

---

### 3.5 UNVERIFIABLE — "Could not evaluate"

**Headline:** Could not evaluate

**Body (required information):**
"The system could not safely evaluate this scene. This is normal behavior when evidence is insufficient — it is not an error.

Reason: [human-readable refusal reason from section 4 below]

[Retry guidance from section 5 below, if applicable]"

**Required footer:** Universal limitations notice (see section 6).

**Prohibited:**
- Implying the parking is safe because the system could not evaluate.
- Implying this is always the user's fault.

---

## 4. Refusal explanation templates (per refusal reason)

Each `UNVERIFIABLE` result carries a machine-readable refusal reason code. The UI MUST display a human-readable explanation. Locked templates:

| Refusal Reason Code | Human-Readable Explanation |
|---|---|
| `NO_ACTIVE_DATASET_REGION` | "No active map data is available for this location. You may need to download the region dataset." |
| `AR_SCALE_UNTRUSTED` | "The app could not establish reliable metric scale for this scene. Move to a flatter, better-lit surface and try again." |
| `PLANE_UNSTABLE` | "The ground plane could not be stabilized. Try holding the phone more steadily and ensuring the ground is clearly visible." |
| `TARGET_AMBIGUOUS` | "More than one vehicle was detected near the frame. Please frame only the vehicle you want to evaluate and confirm the target." |
| `TARGET_EDGE_OCCLUDED` | "Part of the vehicle's edge relevant to this measurement is not visible. Try repositioning to see the full side of the vehicle." |
| `BOUNDARY_UNRESOLVED` | "The relevant legal boundary could not be clearly identified in this scene. Try to include the crossing, cycle path, intersection edge, or bus-stop sign in the frame." |
| `FEATURE_CANDIDATE_AMBIGUOUS` | "Multiple nearby features matched the scene. The system could not safely select which one to evaluate. Try repositioning to make the relevant feature clearer." |
| `VISIBLE_UNSUPPORTED_RESTRICTION` | "A sign or marking visible in the scene is not supported by this app's evaluation scope. The system cannot confirm compliance with that restriction." |
| `INSUFFICIENT_LIGHT_OR_FOCUS` | "The image quality was not sufficient for safe evaluation. Move to better lighting or ensure the camera is focused, then try again." |
| `UNSUPPORTED_RULE_CONTEXT` | "The parking context here is not within the supported evaluation scope of this app." |
| `INSUFFICIENT_EVIDENCE_GENERAL` | "There was not enough evidence to evaluate safely. Try repositioning and retrying." |

---

## 5. Retry guidance templates

When a retry path exists, the UI MUST include retry guidance. Locked templates:

| Retry Context | Retry Guidance Text |
|---|---|
| Poor plane or scale | "For a better result: hold your phone at a slight downward angle so the ground is clearly visible. Move slowly and wait for the AR indicator to stabilize before capturing." |
| Occluded target edge | "For a better result: move to a position where you can clearly see the full side of the vehicle closest to the relevant boundary." |
| Ambiguous target | "For a better result: move closer to the specific vehicle you want to evaluate, or use the target selection confirmation to confirm which vehicle." |
| Boundary not visible | "For a better result: reposition so the relevant feature (crossing, cycle path, intersection, or bus-stop sign) is clearly visible in the frame alongside the vehicle." |
| Poor light | "For a better result: move to a better-lit position or wait for better light conditions." |
| Unsupported restriction visible | "This app cannot evaluate the restriction visible in the scene. Check the app's supported scope for what it can and cannot evaluate." |
| General | "For a better result: try repositioning for a clearer view of the vehicle and the relevant boundary, then capture again." |

---

## 6. Universal limitations notice (mandatory for ALL results)

This notice MUST appear on every user-visible result screen, regardless of state.

**Short form (in-result):**
"This app evaluates only specific supported Danish stopping and parking rules. Other rules, signs, and restrictions may apply. This is not legal advice."

**Full form (accessible via 'more info' or limitations screen):**
"This app evaluates only specific supported Danish stopping and parking rules within the active region dataset. It does not evaluate all Danish parking rules and does not override signs, temporary controls, time-window restrictions, permits, payment obligations, or any other restriction outside its supported scope.

Refusal or an uncertain result is correct and safe behavior when evidence is insufficient.

Results are based on on-device sensing, versioned map data, and deterministic geometry. They are not legal advice and do not predict enforcement outcomes.

Dataset version: [dataset_version] | Policy version: [policy_version] | App version: [app_version]"

---

## 7. Per-family disclosure wording (locked — from SCOPE_AND_LIMITATIONS.md)

These are the per-family disclosure sentences required on results for each supported family.
They are reproduced here from `SCOPE_AND_LIMITATIONS.md` section 10 for copy-control purposes.

| Rule Family | Required Disclosure Sentence |
|---|---|
| `pedestrian_crossing_5m` | "This result evaluates only the 5-metre stopping/parking restriction near a pedestrian crossing. Other restrictions at this location may also apply." |
| `cycle_path_exit_5m` | "This result evaluates only the 5-metre stopping/parking restriction near a cycle-path exit. Other restrictions at this location may also apply." |
| `intersection_10m` | "This result evaluates only the 10-metre stopping/parking restriction near an intersection. Other restrictions at this location may also apply." |
| `direct_prohibited_surfaces` | "This result evaluates only whether the vehicle overlaps a directly prohibited surface within the supported detection scope. Other restrictions at this location may also apply." |
| `bus_stop_marked_segment` | "This result evaluates only the bus-stop restriction based on the localized marked segment (or 12-metre fallback where marking extent was unclear). Other restrictions at this location may also apply." |
| `bus_stop_12m_fallback` | "This result evaluates only the 12-metre bus-stop restriction measured from the localized bus-stop sign. Other restrictions at this location may also apply." |
| Advisory — `driveway_obstruction` | "This is an advisory indication only. The app cannot make a hard legal determination about driveway obstruction in Version 1." |

---

## 8. Unsupported visible restriction warning wording (mandatory)

When `unsupported_visible_restriction_flag = true` is set in the result, the UI MUST display:

**Warning (shown alongside or replacing a positive result):**
"A sign or marking visible in this scene is not supported by this app's evaluation scope. The app cannot confirm whether that restriction affects this location. Do not rely on this result for restrictions outside the supported scope."

This warning MUST NOT be suppressible by the user for the current evaluation session.
This warning MUST appear even if the evaluated supported rule shows a positive result.

---

## 9. Positive-result required caveats (mandatory)

Any positive result (`LEGAL_WITH_BUFFER` or `PROBABLY_LEGAL`) MUST include all of the following:

1. The evaluated rule family name.
2. The per-family disclosure sentence (section 7).
3. The universal limitations notice short form (section 6).
4. Dataset version and policy version references.
5. If `unsupported_visible_restriction_flag = true`: the unsupported restriction warning (section 8).

No positive result may be shown without all five items present.

---

## 10. Advisory-first labeling requirement

Any advisory-first result (e.g., driveway obstruction) MUST:
- Use the label "Advisory" visually prominently.
- NOT use the same visual treatment as hard-legal states.
- NOT produce a headline implying a hard legal finding.
- Include the advisory disclosure sentence from section 7.

---

## 11. Change control

Any change to this file requires:
1. Entry in `WHAT_DID_I_DO.md` with date and reason.
2. Consistency check with `DECISION_STATES.md`, `CLAIMS_POLICY.md`, and `SCOPE_AND_LIMITATIONS.md`.
3. Update to `TASKLIST_V4_FINAL.md` if a new blocker or task is created.
4. Product Owner approval for changes to mandatory caveats, prohibited terms, or state display names.
