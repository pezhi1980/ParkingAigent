# VERTICAL SLICE REPORT — ANDROID
## DK Parking Engine — Phase 9 Android (T-0902)
## Rule family: pedestrian_crossing_5m

---

## 1. Purpose

This report documents the outcome of the Android vertical slice run for the DK Parking Engine.
It is the Android equivalent of `vertical_slice_report.md` (iOS).

T-0902 is NOT DONE until sections 3–6 are filled by a human running the app on a physical Android device.

---

## 2. Prerequisites checklist (complete before device run)

- [ ] Android device: ARCore-compatible, API 28+
- [ ] ARCore installed (Google Play Services for AR)
- [ ] USB debugging enabled
- [ ] Android Studio Hedgehog+ opened with `android/` project
- [ ] Gradle sync successful (no build errors)
- [ ] Unit tests passed: `./gradlew :DKParkingSDK:test`

---

## 3. Unit test run record

**Date run:** _____________
**Device / emulator:** _____________
**Android version:** _____________

| Test class | Result | Notes |
|---|---|---|
| `ConfidenceComposerTest` | PASS / FAIL | |
| `LegalEvaluatorTest` | PASS / FAIL | |
| `MeasurementBundleTest` | PASS / FAIL | |

**All tests pass?** YES / NO

**If any FAIL — describe:**
_____________

---

## 4. Physical device run record

**Date run:** _____________
**Device model:** _____________
**Android version:** _____________
**ARCore version:** _____________
**App build version:** 1.0 (versionCode 1)

### 4.1 App launch

| Check | Result |
|---|---|
| App installs and launches without crash | YES / NO |
| Camera permission dialog shown | YES / NO |
| Permission granted — camera preview begins | YES / NO |
| ARCore session initializes | YES / NO |

### 4.2 Session quality banner

| Banner state observed | YES / NO |
|---|---|
| "Move slowly to build AR tracking" shown on first launch | YES / NO |
| "AR ready — tap Evaluate" shown after ~2–3 seconds | YES / NO |
| Banner updates correctly when camera is moved away | YES / NO |

### 4.3 Evaluate button

| Check | Result |
|---|---|
| Button disabled while AR quality is poor | YES / NO |
| Button enabled once AR is ready | YES / NO |
| Button tap triggers evaluation | YES / NO |

### 4.4 Result card

| Check | Result | Observed value |
|---|---|---|
| Decision state displayed | YES / NO | (label text) |
| One of 5 locked labels shown | YES / NO | (which label) |
| Explanation body shown | YES / NO | |
| Per-family disclosure shown | YES / NO | |
| Limitations notice shown | YES / NO | |

### 4.5 UNVERIFIABLE / refusal path

| Check | Result |
|---|---|
| UNVERIFIABLE shown when AR quality is poor | YES / NO |
| Refusal explanation shown | YES / NO |
| Retry guidance shown | YES / NO |
| "Evaluate again" button shown and works | YES / NO |

---

## 5. Example result JSON

Paste a full `ParkingEvaluationResult` JSON from a device run here (from Logcat):

```json
{
  "_placeholder": "Replace with actual result JSON from Logcat after device run"
}
```

---

## 6. Cross-platform parity check (vs iOS result)

Run equivalent evaluation on both iOS and Android with the same hardcoded stub geometry vectors and compare:

| Field | iOS result | Android result | Match? |
|---|---|---|---|
| `decisionState` | | | YES / NO |
| `refusalReasons` (if UNVERIFIABLE) | | | YES / NO |
| `ruleFamily` | | | YES / NO |
| `measurement.signedMarginM` | | | YES / NO |
| `versionRefs.policyVersion` | | | YES / NO |
| `versionRefs.legalSourceBaselineDate` | | | YES / NO |
| `limitationsNotice` | | | YES / NO |

**All fields match?** YES / NO

**If any mismatch — describe and escalate (PC-007 failure):**
_____________

---

## 7. T-0902 sign-off

T-0902 is DONE when:
- [ ] Unit tests all pass (section 3)
- [ ] Physical device run complete (section 4)
- [ ] Example result JSON logged (section 5)
- [ ] Cross-platform parity check passed (section 6 — all YES)

**Sign-off date:** _____________
**Signed off by:** _____________
