# VEHICLE FOOTPRINT STRATEGY — DK PARKING ENGINE
## Version 1 — Phase 5 document
## Status: DONE
## Locked baseline date: 2026-04-03

---

## 1. Purpose

This document defines how the legally relevant vehicle footprint geometry is derived and used in Version 1.

It governs:
- what "vehicle footprint" means in the legal evaluation context
- which vehicle edges are legally relevant for each rule family
- how the footprint is derived from the target detection
- how the footprint is projected onto the AR ground plane
- footprint quality scoring
- edge occlusion detection
- what the footprint is NOT (phone position, centroid, bounding box only)

---

## 2. Legal vehicle footprint definition (locked)

The **legal vehicle footprint** is the projected ground-plane outline of the confirmed target vehicle.

For legal distance measurement purposes, the relevant reference is the **outermost legally relevant edge** of the vehicle footprint — i.e., the edge of the vehicle body that is closest to the legal boundary being evaluated.

### 2.1 Non-negotiable constraints
- The measurement reference MUST be the vehicle footprint edge, NOT the phone/camera position.
- The measurement reference MUST be the vehicle footprint edge, NOT the vehicle centroid.
- The measurement reference MUST be the vehicle footprint edge, NOT the bounding box corner (bounding boxes overestimate vehicle extent in non-axis-aligned views).
- The footprint MUST be derived from the actual detected vehicle body geometry, not inferred from road lane position or parking bay geometry.

---

## 3. Legally relevant edge per rule family

| Rule Family | Relevant Edge | Reasoning |
|---|---|---|
| `pedestrian_crossing_5m` | The edge of the vehicle nearest to the crossing approach boundary (typically front or rear depending on parking orientation) | The statutory prohibition is based on vehicle position relative to the crossing |
| `cycle_path_exit_5m` | The edge nearest to the cycle-path exit boundary | Same principle |
| `intersection_10m` | The edge nearest to the intersection transverse edge | Same principle |
| `bus_stop_12m_fallback` / `bus_stop_marked_segment` | The edge nearest to the bus-stop boundary (sign or marking) | Same principle |
| `direct_prohibited_surfaces` | The full footprint polygon (overlap check — any overlap is a violation) | Overlap of any part of the vehicle with the prohibited surface |

---

## 4. Footprint derivation method

### 4.1 Input
- The confirmed vehicle instance mask from the target detection model
- The AR ground plane transform (from SS-02)
- The camera intrinsics

### 4.2 Steps
1. Project the vehicle instance mask boundary pixels onto the AR ground plane using the camera ray-plane intersection.
2. Compute the convex hull of the projected boundary points to obtain the ground-plane footprint polygon.
3. Identify the legally relevant edge as the side of the footprint polygon closest to the candidate legal boundary (from the dataset and boundary localization subsystem).
4. Extract the nearest point on that edge to the legal boundary line for the distance measurement.

### 4.3 Footprint simplification
The footprint polygon is simplified to a quadrilateral (4-corner bounding shape aligned to the vehicle axis) when:
- the detected mask has low confidence in boundary precision
- the vehicle is partially occluded

When simplified, the footprint edge used is the **closest** side of the quadrilateral to the boundary.
This is conservative (may slightly overestimate vehicle extent) and is intentionally safe.

---

## 5. Footprint quality scoring

The `footprint_quality_score` in `TargetInfo` (OUTPUT_CONTRACT.md) reflects:
- Instance mask confidence and boundary precision
- Extent of occlusion
- Consistency of the projected footprint across the AR frame

| Condition | Quality score range | Implication |
|---|---|---|
| Clear, unoccluded vehicle, high-confidence mask | 0.80–1.00 | Footprint suitable for ILLEGAL / LEGAL_WITH_BUFFER |
| Minor occlusion (< 20% of relevant edge) | 0.55–0.79 | Footprint suitable for PROBABLY_* states |
| Significant occlusion (> 20% of relevant edge) | 0.00–0.54 | `partial_occlusion_detected = true`; check against PR-008 threshold; may trigger `TARGET_EDGE_OCCLUDED` |

---

## 6. Edge occlusion detection

`partial_occlusion_detected` in `TargetInfo` is set to `true` when:
- the instance mask boundary on the legally relevant side is interrupted or has low confidence
- another detected object (another vehicle, post, wall) intersects the relevant edge region
- the relevant edge is at the frame boundary and clipped

When `partial_occlusion_detected = true`:
- Check `footprint_quality_score` against `POLICY_REGISTRY_SPEC.md` PR-008 threshold (default 0.40)
- If quality < PR-008: return UNVERIFIABLE with `TARGET_EDGE_OCCLUDED`
- If quality ≥ PR-008: proceed with degraded confidence (added to error budget), reflected in `confidence_score`

---

## 7. What the footprint is NOT

These substitutions are explicitly forbidden and must never appear in the implementation:

| Substitution | Why forbidden |
|---|---|
| Phone/camera GPS position | Phone position is not the vehicle legal boundary; GPS also lacks the metric precision required |
| Vehicle centroid | Centroid does not represent the legal vehicle edge |
| Raw bounding box corner | Bounding boxes are axis-aligned and overestimate vehicle extent at angles |
| Road lane centerline inferred position | Inferred position is not observed geometry |
| Parking bay geometry | Parking bay geometry defines a permitted space, not the vehicle actual extent |

---

## 8. Change control

Any change to:
- the legally relevant edge selection per family
- the footprint derivation method
- quality score thresholds or occlusion detection rules

requires:
1. Update to this document.
2. Entry in `WHAT_DID_I_DO.md`.
3. Review of `ar_measurement_strategy.md` and `OUTPUT_CONTRACT.md` for consistency.
4. Engineering Owner approval.
5. Update to `TASKLIST_V4_FINAL.md` if a new task or blocker arises.
