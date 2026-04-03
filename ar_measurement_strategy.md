# AR MEASUREMENT STRATEGY — DK PARKING ENGINE
## Version 1 — Phase 4 document
## Status: DONE
## Locked baseline date: 2026-04-03

---

## 1. Purpose

This document defines the AR measurement backbone for Version 1.

It governs:
- how metric ground-plane acquisition works and when it is valid
- plane stability scoring and minimum thresholds
- metric scale validity scoring and minimum thresholds
- the measurement geometry: how the distance from vehicle footprint edge to legal boundary is derived
- the measurement error budget: its components and propagation
- geometry refusal rules: when measurement MUST NOT proceed
- what counts as a valid vs. invalid AR measurement session

This document is normative. All measurement implementation MUST conform to it.

---

## 2. Non-negotiable measurement constraints (locked)

These constraints are absolute and may not be relaxed by any policy parameter or future implementation shortcut:

1. **Metric plane only**: Distance measurement MUST use ARKit metric plane geometry. GPS coordinates MUST NOT be used as the primary distance measurement source. Pixel-only distance estimation MUST NOT be used.

2. **Legal footprint edge, not phone position**: The vehicle position reference used in distance computation MUST be the legal vehicle footprint edge (the edge of the vehicle closest to the boundary being evaluated), not the phone position.

3. **Error budget tracked**: The total estimated measurement error budget MUST be computed and recorded in the output (`total_estimated_error_m` in `MeasurementBundle`).

4. **Geometry refusal is mandatory**: When plane validity or metric scale validity falls below minimum thresholds, evaluation MUST be refused (UNVERIFIABLE). There is no fallback measurement path using inferior geometry.

5. **No legal boundary from centerline guess**: The legal boundary MUST be derived from a localizable physical reference (detected road marking, detected sign, dataset feature with visual confirmation), not inferred from a road centerline alone.

---

## 3. Ground-plane acquisition (ARKit, iOS Version 1)

### 3.1 Plane detection requirements
- ARKit horizontal plane detection is used to establish the ground plane.
- The detected plane MUST cover the area between the vehicle and the legal boundary being measured.
- If the plane does not cover the required measurement corridor, the engine MUST use a conservative plane extent estimate and add the corresponding uncertainty to the error budget.

### 3.2 Plane stability scoring
Plane stability is scored on [0.0–1.0] and reflects:
- Consistency of the plane transform across recent frames (low variance = high stability)
- AR tracking quality reported by ARKit (`.normal` = higher score; `.limited` = lower score)
- Duration of continuous plane tracking without interruption

Minimum plane stability score to proceed: **0.70** (configurable via `POLICY_REGISTRY_SPEC.md` PR-006).
Below this threshold: return UNVERIFIABLE with `PLANE_UNSTABLE`.

### 3.3 Metric scale validity scoring
Metric scale validity is scored on [0.0–1.0] and reflects:
- ARKit world-tracking confidence (`.high` = 1.0; `.medium` = 0.6; `.low` = 0.2)
- World-origin stability (time since world origin reset)
- Presence of visual features in the AR session sufficient for accurate scale

Minimum metric scale validity score to proceed: **0.75** (configurable via `POLICY_REGISTRY_SPEC.md` PR-007).
Below this threshold: return UNVERIFIABLE with `AR_SCALE_UNTRUSTED`.

---

## 4. Measurement geometry

### 4.1 Overview
The measurement computes the perpendicular distance from the **nearest relevant edge of the vehicle footprint** to the **legal boundary reference line**.

For distance-based rules (5m, 10m, 12m):
```
measured_distance_m = distance(vehicle_footprint_nearest_edge, legal_boundary_line)
```

For overlap-based rules (direct prohibited surfaces):
```
overlap_detected = intersects(vehicle_footprint_polygon, prohibited_surface_polygon)
```

### 4.2 Vehicle footprint nearest edge projection
The vehicle footprint is projected onto the AR ground plane.
The nearest edge to the legal boundary is identified.
The measurement is taken from the nearest point on that edge to the nearest point on the legal boundary line projected onto the same plane.

### 4.3 Legal boundary projection
The legal boundary reference (crossing approach line, transverse edge of intersection, bus-stop sign position, marked segment extent) is projected onto the AR ground plane from the dataset feature geometry plus any visual confirmation offset.

### 4.4 Signed margin
```
signed_margin_m = measured_distance_m - legal_threshold_m
```
- Positive: vehicle is beyond the threshold (potential clearance)
- Negative: vehicle is within the threshold (potential violation)

---

## 5. Measurement error budget

### 5.1 Error sources and their contributions (Version 1 estimates)

| Error Source | Estimated Contribution | Notes |
|---|---|---|
| ARKit metric scale error | ±0.10–0.25m | Depends on world-tracking quality and session duration |
| Ground-plane fit error | ±0.05–0.15m | Increases with slope, uneven surface, or limited plane coverage |
| Vehicle footprint edge localization error | ±0.10–0.30m | Depends on detection model quality and occlusion |
| Legal boundary localization error | ±0.10–0.40m | Depends on boundary source: visual detection (lower) vs. map-prior (higher) |
| Dataset feature position error | ±0.00–2.00m | Depends on `geometry_accuracy_class` (HIGH: <0.5m; MEDIUM: 0.5–2m; LOW: >2m) |

### 5.2 Total estimated error budget computation

```
total_estimated_error_m = sqrt(
  ar_scale_error² +
  plane_fit_error² +
  vehicle_edge_localization_error² +
  boundary_localization_error²
)
```

The dataset feature position error is folded into `boundary_localization_error` based on `geometry_accuracy_class`.

### 5.3 Error budget values MUST be recorded
`total_estimated_error_m` MUST be populated in the `MeasurementBundle` output for every non-UNVERIFIABLE result.

---

## 6. Error budget propagation to confidence and decision state

The error budget directly affects what decision state is reachable.

### 6.1 Near-threshold zone definition
A measurement is in the **near-threshold zone** when:
```
|signed_margin_m| < total_estimated_error_m + near_threshold_downgrade_margin_m
```
Where `near_threshold_downgrade_margin_m` = 0.30m (from `POLICY_REGISTRY_SPEC.md` PR-004).

### 6.2 Decision state reachability by margin/error

| Condition | Reachable States |
|---|---|
| `signed_margin_m` strongly positive AND outside near-threshold zone AND `confidence_score` ≥ floor | `LEGAL_WITH_BUFFER` |
| `signed_margin_m` positive but within near-threshold zone | `PROBABLY_LEGAL` at most |
| `signed_margin_m` negative AND outside near-threshold zone AND `confidence_score` ≥ floor | `ILLEGAL` |
| `signed_margin_m` negative but within near-threshold zone | `PROBABLY_ILLEGAL` at most |
| Cannot compute signed_margin_m reliably | `UNVERIFIABLE` |

No confidence manipulation may produce `LEGAL_WITH_BUFFER` or `ILLEGAL` from a near-threshold measurement.

---

## 7. Geometry refusal rules (mandatory)

The engine MUST refuse (UNVERIFIABLE) when any of the following conditions hold:

| Refusal Condition | Reason Code |
|---|---|
| `ar_metric_scale_valid = false` (score below PR-007 threshold) | `AR_SCALE_UNTRUSTED` |
| `ar_plane_stability_score` below PR-006 threshold | `PLANE_UNSTABLE` |
| The ground plane does not cover the measurement corridor and cannot be conservatively extended | `PLANE_UNSTABLE` |
| The legal boundary cannot be projected onto the ground plane within acceptable error | `BOUNDARY_UNRESOLVED` |
| The vehicle footprint edge used for measurement has `partial_occlusion_detected = true` AND edge quality score below PR-008 threshold | `TARGET_EDGE_OCCLUDED` |
| `total_estimated_error_m` exceeds 2.0m (absolute cap — no result is meaningful at this error) | `INSUFFICIENT_EVIDENCE_GENERAL` |

---

## 8. Valid vs. invalid AR measurement session

### 8.1 Valid session
An AR measurement session is valid when:
- ARKit world-tracking quality is `.normal` or `.limited` with metric scale validity ≥ PR-007 threshold
- A stable horizontal plane covering the measurement corridor has been detected (stability ≥ PR-006 threshold)
- The session has been active for at least 2 seconds (to allow AR initialization)
- No recent world origin reset has occurred within the last 1 second

### 8.2 Invalid session — mandatory behaviors
When the session is invalid:
- The capture subsystem (SS-01) MUST NOT forward frames to the evaluation path
- The app UI MUST show a stabilization indicator ("Hold still — establishing measurement")
- The app MUST NOT accept a user capture while the session is invalid

### 8.3 Session degradation during evaluation
If AR session quality degrades between capture and evaluation completion:
- The error budget is updated with degraded quality scores
- If scores fall below thresholds, the result is UNVERIFIABLE (not silently adjusted)

---

## 9. Platform binding (iOS Version 1)

- AR session: `ARWorldTrackingConfiguration` with `.gravity` alignment
- Plane detection: `ARPlaneDetection.horizontal`
- World tracking quality: accessed via `ARCamera.TrackingState`
- Frame rate: evaluation operates on the captured frame, not a live feed; capture is triggered on user action after session is valid

---

## 10. Change control

Any change to:
- measurement geometry (how distance is computed)
- error budget components or formula
- geometry refusal thresholds
- the near-threshold zone definition

requires:
1. Update to this document.
2. Entry in `WHAT_DID_I_DO.md`.
3. Review of `OUTPUT_CONTRACT.md` (`MeasurementBundle`) and `POLICY_REGISTRY_SPEC.md` for consistency.
4. If thresholds change: update `POLICY_REGISTRY_SPEC.md` and require validation evidence.
5. Update to `TASKLIST_V4_FINAL.md` if a new task or blocker arises.
