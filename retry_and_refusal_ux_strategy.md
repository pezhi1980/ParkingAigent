# RETRY AND REFUSAL UX STRATEGY — DK PARKING ENGINE
## Version 1 — Phase 11 document
## Status: DONE
## Locked baseline date: 2026-04-03

---

## 1. Purpose

This document defines the user experience strategy for refusal and retry flows in the DK Parking Engine Version 1 iOS app.

A refusal (UNVERIFIABLE) is not a failure — it is correct behavior when evidence is insufficient. This document ensures that the app communicates refusal honestly and provides actionable, reason-specific retry guidance.

---

## 2. Core UX principles for refusal

1. **Refusal is correct behavior.** The app MUST NOT present UNVERIFIABLE as an error or failure.
2. **Refusal is never the user's fault.** Guidance must be framed as positioning advice, not blame.
3. **Every refusal has a reason.** The app MUST display a human-readable explanation for every RefusalReasonCode.
4. **Every refusal has a retry path.** The app MUST always provide a clear next action.
5. **Retry is not guaranteed to succeed.** The guidance must not promise a result — only describe the optimal approach.
6. **No forced result.** The app MUST NOT bypass refusal or downgrade to a guess. Refusal is always preferable to a forced legal determination.

---

## 3. Refusal result card specification

When `decision_state == UNVERIFIABLE`, the result card MUST show:

### 3.1 Required elements (locked)

| Element | Source | Example |
|---|---|---|
| State label | `user_disclosures_and_copy.md` §2.1 | "Could not evaluate" |
| State color | Neutral (gray) — never red | `.gray` |
| Explanation body | `user_disclosures_and_copy.md` §3.5 | "This is normal behavior when evidence is insufficient…" |
| Refusal reason code (machine) | `RefusalReasonCode.rawValue` | "AR_SCALE_UNTRUSTED" |
| Refusal explanation (human) | `user_disclosures_and_copy.md` §4 | "The AR metric scale could not be trusted…" |
| Retry guidance | `user_disclosures_and_copy.md` §5 | "Hold the camera at a downward angle…" |
| Universal limitations notice | `user_disclosures_and_copy.md` §6 | "This app evaluates only specific supported Danish…" |
| Reset / retry button | — | "Try again" |

### 3.2 Forbidden elements on UNVERIFIABLE card

- No red color for the state indicator.
- No text implying user error ("You must...", "You did not...", "Wrong angle").
- No text implying the engine failed ("Error", "The app failed to...").
- No legal recommendation ("You may park here").
- No confidence score display (confidence is not meaningful on a refusal).

---

## 4. Non-UNVERIFIABLE result card specification

When `decision_state != UNVERIFIABLE`, the result card MUST show:

### 4.1 Required elements (locked)

| Element | Source |
|---|---|
| State label (locked vocabulary) | `user_disclosures_and_copy.md` §2.1 |
| State color | Green (legalWithBuffer), yellow (probablyLegal), orange (probablyIllegal), red (illegal) |
| Explanation body | `user_disclosures_and_copy.md` §3.1–3.4 |
| Measurement details | measuredDistanceM, legalThresholdM, signedMarginM, totalEstimatedErrorM, confidenceScore |
| Boundary provenance | `boundaryProvenance.rawValue` |
| Near-threshold indicator | "Near-threshold: yes/no" when applicable |
| Universal limitations notice | `user_disclosures_and_copy.md` §6 |
| Per-family disclosure | `user_disclosures_and_copy.md` §7 |
| Evaluation ID (truncated) | `evaluationId.prefix(8)` for support reference |

### 4.2 PROBABLY states — additional requirements

For `probablyLegal` and `probablyIllegal`:
- The explanation body MUST include the uncertainty qualifier: "but measurement confidence was not high enough to make a definitive determination."
- The card MUST NOT present these states as definitive. No exclamation marks, no strong assertion language.
- The card SHOULD suggest retry or visual verification as an option.

---

## 5. Retry flow state machine

```
AR View (session initializing)
  → [session quality below threshold] → quality banner amber/gray
  → [session quality ready] → quality banner green, Evaluate button enabled
  → [user taps Evaluate]
      → [result: non-UNVERIFIABLE] → result card shown
          → [user taps Reset] → return to AR View
      → [result: UNVERIFIABLE] → refusal card shown with reason + retry guidance
          → [user taps Try again / Reset] → return to AR View
          → [user reads guidance, repositions, taps Evaluate again]
              → [new result produced]
```

---

## 6. Multiple refusals in sequence

If the user receives 3 or more consecutive UNVERIFIABLE results:

- The app SHOULD surface a more prominent guidance card that covers the most likely root causes.
- The guidance card MUST still not imply user error.
- Suggested text: "If the issue persists, try: (1) ensuring good lighting, (2) pointing the camera at the ground first, (3) verifying the crossing line is visible in the frame."

The app MUST NOT automatically change any evaluation parameters or lower quality thresholds in response to repeated refusals.

---

## 7. Visible unsupported restriction UX

When `unsupportedVisibleRestrictionFlag == true` and result is UNVERIFIABLE:

- The refusal explanation MUST explicitly mention the visible restriction.
- The app MUST NOT present the visible unsupported restriction as a minor advisory.
- Required text (locked): "A restriction sign or marking is visible that this version of the app does not evaluate. The engine cannot provide a result while an unevaluated restriction may affect clearance. Check all visible signs manually."
- No retry guidance for this case — the restriction is real and the user must act on it directly.

---

## 8. Decision state display vocabulary (locked)

Per `user_disclosures_and_copy.md` §2.1:

| DecisionState | Display label | Color |
|---|---|---|
| `legalWithBuffer` | "Appears compliant" | Green |
| `probablyLegal` | "Likely compliant" | Yellow |
| `probablyIllegal` | "Likely violation" | Orange |
| `illegal` | "Violation detected" | Red |
| `unverifiable` | "Could not evaluate" | Gray |

These labels are LOCKED. Do not use informal alternatives.

---

## 9. Onboarding disclosure surface

On first launch, before the AR session starts, the app MUST display a one-time acknowledgment screen containing:

1. What the app evaluates: "This app evaluates specific Danish stopping and parking rules using on-device AR measurement."
2. What the app does not evaluate: "It does not evaluate all parking rules. Other restrictions may apply."
3. Refusal behavior: "When evidence is insufficient, the app will decline to evaluate rather than guess."
4. Legal advice disclaimer: "This is not legal advice. Always check visible signs and markings."

The user MUST tap a confirmation button before reaching the AR evaluation view.

---

## 10. Change control

Any change to result card elements, retry flow, or refusal display vocabulary requires:
1. Update to this file.
2. Review of `user_disclosures_and_copy.md` for consistency.
3. Review of `CLAIMS_POLICY.md` for compliance.
4. Entry in `WHAT_DID_I_DO.md`.
5. Update to `TASKLIST_V4_FINAL.md`.
