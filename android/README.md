# DK Parking Engine — Android Vertical Slice
## Phase 9 Android (T-0902)
## Parity: iOS vertical slice in ios/

---

## Prerequisites

- Android Studio Hedgehog (2023.1.1) or later
- Android device with ARCore support, API level 28+ (Android 9+)
- ARCore installed on device (Google Play Services for AR)
- USB debugging enabled on the test device

---

## Project structure

```
android/
  DKParkingSDK/              SDK library module (Kotlin)
    src/main/kotlin/com/dkparking/sdk/
      core/                  DecisionState, RuleFamily, LegalThresholds, RefusalReasonCode,
                             PolicyRegistry, ParkingEvaluationResult (all nested types)
      ar/                    ARMeasurementSession (ARCore equivalent of iOS ARKit session)
      evaluation/            ConfidenceComposer, LegalEvaluator
      engine/                ParkingEvaluationEngine (main SDK entry point)
    src/test/kotlin/         Unit tests (ConfidenceComposerTest, LegalEvaluatorTest, MeasurementBundleTest)

  DKParkingVerticalSlice/    Jetpack Compose app (vertical slice)
    src/main/
      kotlin/com/dkparking/verticalslice/
        MainActivity.kt      ARCore session + Compose host
        VerticalSliceViewModel.kt  Engine lifecycle, evaluate(), locked vocabulary
        ui/VerticalSliceScreen.kt  Compose UI (result card, session banner, limitations notice)
      AndroidManifest.xml    Camera permission, ARCore required

  build.gradle.kts           Root build file
  settings.gradle.kts        Module declarations
```

---

## Setup in Android Studio

1. Open Android Studio → **File > Open** → select `android/` folder
2. Wait for Gradle sync to complete
3. Connect an ARCore-compatible Android device via USB

---

## Run unit tests

In Android Studio: right-click `DKParkingSDK/src/test` → **Run Tests**

Or via terminal:
```
./gradlew :DKParkingSDK:test
```

Expected: all 3 test classes pass (ConfidenceComposerTest, LegalEvaluatorTest, MeasurementBundleTest)

---

## Run vertical slice on device

1. Select `DKParkingVerticalSlice` as the run configuration
2. Select your connected Android device
3. Click **Run** (green triangle)

Expected:
- App launches, requests camera permission
- ARCore session initializes
- "Move slowly to build AR tracking" banner visible
- After ~2s of good tracking: "AR ready — tap Evaluate" banner
- Tap **Evaluate** → result card appears with one of the 5 locked decision states
- UNVERIFIABLE path: refusal explanation + retry guidance shown

---

## Vertical slice report

After a successful device run, fill in `vertical_slice_report_android.md` sections 3–6.
T-0902 is not DONE until the physical device run is completed and logged.

---

## Parity with iOS

This Android SDK is the parity implementation of `ios/DKParkingSDK/`.

| iOS (Swift) | Android (Kotlin) |
|---|---|
| `DecisionState` enum | `DecisionState` enum |
| `RuleFamily` + `LegalThresholds` | `RuleFamily` + `LegalThresholds` |
| `RefusalReasonCode` enum | `RefusalReasonCode` enum |
| `PolicyRegistry` struct | `PolicyRegistry` data class |
| `ParkingEvaluationResult` | `ParkingEvaluationResult` |
| `ARMeasurementSession` (ARKit) | `ARMeasurementSession` (ARCore) |
| `ConfidenceComposer` | `ConfidenceComposer` |
| `LegalEvaluator` | `LegalEvaluator` |
| `ParkingEvaluationEngine` | `ParkingEvaluationEngine` |
| `VerticalSliceRootView` (SwiftUI) | `VerticalSliceScreen` (Compose) |
| `VerticalSliceViewModel` (iOS) | `VerticalSliceViewModel` (Android) |

Decision state semantics, refusal codes, legal thresholds, policy parameters, and
limitations notice text are identical between platforms (PC-001 to PC-010).

---

## STUB values — replace before release

| Field | Stub value | Required before release |
|---|---|---|
| `versionRefs.modelVersion` | `STUB-V1-android` | Replace with real TFLite model version |
| `versionRefs.datasetVersion` | `REG-DK-001-STUB` | Replace with first published dataset bundle |
| `EvaluationInput.*Point` | Hardcoded test vectors | Replace with real ARCore measurement |

---

## Known limitations of the vertical slice

- `vehicleFootprintEdgePoint` and `legalBoundaryLineStart/End` are hardcoded test vectors
- No real ML model: footprint and boundary detection require a real TFLite model
- The AR frame polling uses `session.update()` on button tap (not a real render loop)
- For production, attach an `ArSceneView` or `GLSurfaceView` with a frame listener
