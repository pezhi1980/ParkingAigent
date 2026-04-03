# CAPTURE GUIDANCE STRATEGY — DK PARKING ENGINE
## Version 1 — Phase 11 document
## Status: DONE
## Locked baseline date: 2026-04-03

---

## 1. Purpose

This document defines how the app guides users to capture scenes that produce valid, evaluable results.

Capture guidance is a UX subsystem. Its job is to reduce UNVERIFIABLE outcomes caused by controllable user behavior — without implying that all refusals are user errors.

---

## 2. Capture guidance principles

1. **Guide, do not blame.** Guidance text must never imply the user is doing something wrong. It must always frame guidance as "here is how to get the best result."
2. **Guidance is advisory.** The user may ignore guidance. The engine must still produce a correct result (including refusal) regardless.
3. **Guidance is reason-specific.** Generic guidance ("hold the phone better") is not acceptable. Each refusal reason code has specific guidance.
4. **Guidance must not overclaim.** Guidance text must not imply that following it guarantees a legal determination.
5. **Guidance is not a substitute for refusal.** If the scene is still insufficient after guidance, the engine must still refuse.

---

## 3. Pre-capture guidance

Pre-capture guidance appears before the user taps Evaluate. It is shown in the AR session quality banner.

### 3.1 Session quality states and guidance text

| State | Condition | Banner text |
|---|---|---|
| Initializing | < 2 seconds since session start | "Starting AR session — please wait" |
| Plane not found | No horizontal plane detected | "Point the camera downward at the ground near the vehicle" |
| Scale low | metricScaleScore < 0.75 | "Hold steady — establishing metric scale" |
| Plane unstable | planeStabilityScore < 0.70 | "Move slowly to improve plane stability" |
| Ready | Both scores ≥ thresholds | "Ready — tap Evaluate when positioned" |

### 3.2 Pre-capture positioning guidance

The following guidance should be surfaced as an onboarding overlay on first use:

1. Stand beside the vehicle, slightly behind the relevant boundary side.
2. Point the camera downward at approximately 30–45° angle to the ground.
3. Ensure the vehicle's legally relevant side (nearest to the crossing or boundary) is fully visible.
4. Ensure the pedestrian crossing or legal boundary marking is also visible in the frame.
5. Hold steady for 2–3 seconds before evaluating.

---

## 4. Post-capture retry guidance (by refusal reason)

Post-capture retry guidance appears inside the result card when `decision_state == UNVERIFIABLE`.

Per `user_disclosures_and_copy.md` §5. These are the locked retry guidance strings per reason code:

| RefusalReasonCode | Retry guidance |
|---|---|
| `arScaleUntrusted` | "Hold the camera at a downward angle toward the ground. Wait for the AR session banner to turn green before evaluating." |
| `planeUnstable` | "Move the camera slowly across the ground surface to establish a stable ground plane, then evaluate again." |
| `targetEdgeOccluded` | "Reposition so the full side of the vehicle nearest the boundary is visible and unobstructed." |
| `targetAmbiguous` | "Move closer to the specific vehicle you want to evaluate." |
| `boundaryUnresolved` | "Include the pedestrian crossing or boundary marking in the frame alongside the vehicle." |
| `featureCandidateAmbiguous` | "Move so only one pedestrian crossing or legal boundary feature is prominent in the scene." |
| `visibleUnsupportedRestriction` | "A restriction sign is visible that this version of the app cannot evaluate. Check all visible signs manually." |
| `noActiveDatasetRegion` | "This location may be outside the supported region. Check that you are in a supported area." |
| `insufficientEvidenceGeneral` | "Try moving to a different angle with the crossing and vehicle clearly visible. Ensure the AR session is stable." |

---

## 5. Capture guidance UX rules

### 5.1 What must always be visible

- The AR session quality banner MUST be visible whenever the AR view is active.
- The banner MUST change color based on session state: gray (initializing), amber (degraded), green (ready).
- The Evaluate button MUST be disabled when the session is not ready.

### 5.2 What must never happen

- The Evaluate button MUST NOT be tappable when session quality is below threshold.
- The app MUST NOT auto-evaluate without user intent.
- The app MUST NOT dismiss the result card automatically — the user must explicitly reset.
- Guidance text MUST NOT include words like "error", "failed", "wrong" in reference to user actions.

### 5.3 Retry flow

1. UNVERIFIABLE result card is shown with refusal explanation and retry guidance.
2. User reads guidance.
3. User taps "Reset" (or equivalent).
4. App returns to AR view with session quality banner visible.
5. User repositions per guidance.
6. User taps Evaluate again.

---

## 6. Framing guidance for legal boundary visibility

When the legal boundary (pedestrian crossing marking) is not visible in the frame, the app should surface:

"Include the pedestrian crossing line in the frame along with the vehicle side nearest to it. Both must be visible for an accurate evaluation."

This guidance is triggered when `boundaryProvenance == mapPriorOnly` or `boundaryProvenance == mapPriorAssisted` and the result is UNVERIFIABLE with `boundaryUnresolved`.

---

## 7. Offline dataset guidance

If `SDKInitResult == noActiveDatasetRegion`:

"No supported dataset is available for this location. Supported regions are listed in the app. Ensure you are connected to internet to download the latest dataset bundle."

If `SDKInitResult == datasetExpired`:

"The dataset for this region has expired. Please update the app or connect to internet to download the latest dataset bundle."

---

## 8. Change control

Any change to guidance text, session quality thresholds, or retry flow requires:
1. Update to this file.
2. Review of `user_disclosures_and_copy.md` for consistency.
3. Entry in `WHAT_DID_I_DO.md`.
4. Update to `TASKLIST_V4_FINAL.md`.
