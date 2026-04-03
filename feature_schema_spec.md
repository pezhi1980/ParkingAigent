# FEATURE SCHEMA SPEC — DK PARKING ENGINE
## Version 1 — Phase 3 document
## Status: DONE
## Locked baseline date: 2026-04-03

---

## 1. Purpose

This document defines the feature schema for all legal feature types used by the DK Parking Engine Version 1.

It specifies:
- feature type identifiers
- geometry types per feature family
- required and optional schema fields
- quality and confidence metadata fields
- how feature IDs are assigned and referenced

All dataset features MUST conform to this schema. All evaluator logic MUST treat these fields as the canonical representation of legal features.

---

## 2. Common fields (all feature types)

Every feature in the dataset MUST include these fields:

| Field | Type | Required | Description |
|---|---|---|---|
| `feature_id` | String | REQUIRED | Globally unique feature identifier within the region (e.g., `REG-DK-001-INT-00142`) |
| `feature_type` | FeatureTypeEnum | REQUIRED | One of the locked feature type values (see section 3) |
| `region_id` | String | REQUIRED | The region this feature belongs to |
| `geometry` | GeoJSON Geometry | REQUIRED | The geometry for this feature (type varies by feature_type — see sections 4–8) |
| `geometry_source` | String | REQUIRED | How this geometry was obtained (e.g., `official_road_registry`, `aerial_survey`, `manual_survey`) |
| `geometry_accuracy_class` | String | REQUIRED | One of: `HIGH` (< 0.5m error), `MEDIUM` (0.5–2m error), `LOW` (> 2m error) |
| `last_verified_date` | DateString (YYYY-MM-DD) | REQUIRED | Date this feature's geometry and attributes were last verified against official sources |
| `legal_source_ref` | String | REQUIRED | The legal source ID that makes this feature legally relevant (e.g., `DK-LAW-001`) |
| `candidate_confidence_score` | Float [0.0–1.0] | REQUIRED | Confidence that this feature is correctly positioned and typed; used in candidate matching |
| `is_active` | Boolean | REQUIRED | False if the feature has been retired or superseded |
| `notes` | String | OPTIONAL | Any feature-level notes for dataset maintainers |

---

## 3. Feature type enum (locked)

| Feature Type Value | Rule Family | Description |
|---|---|---|
| `PEDESTRIAN_CROSSING` | `pedestrian_crossing_5m` | A designated pedestrian crossing |
| `CYCLE_PATH_EXIT` | `cycle_path_exit_5m` | A location where a cycle path exits onto a road |
| `INTERSECTION` | `intersection_10m` | A road intersection (vejkryds) |
| `BUS_STOP` | `bus_stop_12m_fallback` / `bus_stop_marked_segment` | A designated bus stop |
| `PROHIBITED_SURFACE_ZONE` | `direct_prohibited_surfaces` | A zone of directly prohibited stopping/parking surface (cycle path, footway, refuge) |

No other feature types may be added to a V1 dataset bundle without a corresponding scope change.

---

## 4. PEDESTRIAN_CROSSING feature schema

Geometry type: `LineString` or `Polygon`

The geometry represents the **approach boundary** — the line or zone at which the 5m restriction begins (the nearside edge of the crossing).

| Field | Type | Required | Description |
|---|---|---|---|
| `crossing_type` | String | REQUIRED | One of: `zebra`, `signalised`, `unmarked_designated` |
| `approach_boundary` | GeoJSON LineString | REQUIRED | The legally relevant approach boundary line (nearside kerb line of the crossing) |
| `crossing_axis` | GeoJSON LineString | OPTIONAL | The axis of the crossing (for orientation reference) |
| `road_side` | String | OPTIONAL | Which side of the road this boundary is on: `left`, `right`, `both` |
| `has_tactile_paving` | Boolean | OPTIONAL | True if tactile paving is present |

---

## 5. CYCLE_PATH_EXIT feature schema

Geometry type: `LineString`

The geometry represents the **exit boundary line** — the line at which the cycle path exits onto the road surface, at which the 5m restriction begins.

| Field | Type | Required | Description |
|---|---|---|---|
| `exit_boundary` | GeoJSON LineString | REQUIRED | The legally relevant exit boundary (the road-side edge of the cycle-path exit) |
| `cycle_path_direction` | String | OPTIONAL | Direction of travel on the cycle path: `bidirectional`, `one_way` |
| `road_side` | String | OPTIONAL | Which side of the road: `left`, `right` |

---

## 6. INTERSECTION feature schema

Geometry type: `Point` or `Polygon`

The geometry represents the intersection centroid or bounding polygon. The evaluator uses the transverse edge of the intersecting road for the 10m measurement.

| Field | Type | Required | Description |
|---|---|---|---|
| `intersection_centroid` | GeoJSON Point | REQUIRED | The centroid of the intersection |
| `transverse_edges` | List\<GeoJSON LineString\> | REQUIRED | The transverse edge lines for each intersecting road arm (used as measurement reference); minimum 2 edges |
| `intersection_type` | String | REQUIRED | One of: `standard`, `roundabout`, `t_junction`, `y_junction` |
| `road_count` | Integer | REQUIRED | Number of roads meeting at this intersection |
| `has_traffic_signals` | Boolean | OPTIONAL | True if traffic signals are present |

---

## 7. BUS_STOP feature schema

Geometry type: `Point` (sign location) + optional `LineString` or `Polygon` (marking extent)

| Field | Type | Required | Description |
|---|---|---|---|
| `sign_location` | GeoJSON Point | REQUIRED | The location of the bus-stop sign post |
| `marking_extent` | GeoJSON LineString or Polygon | CONDITIONAL | The extent of the T 61 bus-stop road marking, if present and mappable; null if no marking |
| `has_marking` | Boolean | REQUIRED | True if a T 61 bus-stop road marking is present at this stop |
| `marking_confidence` | Float [0.0–1.0] | CONDITIONAL | Required if `has_marking = true`; confidence in the accuracy of the mapped marking extent |
| `marking_extent_status` | String | CONDITIONAL | Required if `has_marking = true`; one of: `FULLY_MAPPED`, `PARTIALLY_MAPPED`, `EXTENT_UNCERTAIN` |
| `bus_stop_id_ref` | String | OPTIONAL | Reference to the official bus stop registry ID if available |
| `road_side` | String | OPTIONAL | Which side of the road: `left`, `right` |

**Evaluator behavior rules for BUS_STOP features:**

These rules are locked per `LEGAL_THRESHOLDS.md` section 6:
- If `has_marking = true` AND `marking_extent_status = FULLY_MAPPED` AND `marking_confidence` meets the evaluation threshold: evaluate against `marking_extent`
- If `has_marking = true` AND (`marking_extent_status != FULLY_MAPPED` OR `marking_confidence` below threshold): fall back to 12m rule from `sign_location`
- If `has_marking = false`: apply 12m rule from `sign_location`
- If `sign_location` is not reliably localized: return UNVERIFIABLE (`BOUNDARY_UNRESOLVED`)

---

## 8. PROHIBITED_SURFACE_ZONE feature schema

Geometry type: `Polygon`

The geometry represents the extent of a directly prohibited parking/stopping surface.

| Field | Type | Required | Description |
|---|---|---|---|
| `surface_type` | String | REQUIRED | One of: `cycle_path`, `footway`, `refuge`, `median`, `protected_island` |
| `zone_polygon` | GeoJSON Polygon | REQUIRED | The boundary of the prohibited surface zone |
| `applicable_vehicle_classes` | List\<String\> | REQUIRED | Which vehicle classes are prohibited from this surface (for V1: `["all_except_bicycles_mopeds"]` for cycle paths; `["all"]` for footways/refuges) |
| `outside_built_up_area` | Boolean | OPTIONAL | True if this zone is outside a built-up area (relevant for § 28 stk. 3 exception for vehicles ≤ 3,500 kg) |

---

## 9. Feature ID assignment convention

Feature IDs follow this format:
`{region_id}-{type_code}-{five_digit_sequence}`

Type codes:
- `PC` — PEDESTRIAN_CROSSING
- `CPX` — CYCLE_PATH_EXIT
- `INT` — INTERSECTION
- `BS` — BUS_STOP
- `PS` — PROHIBITED_SURFACE_ZONE

Example: `REG-DK-001-INT-00142`

Feature IDs are immutable once assigned. A retired feature is flagged `is_active = false`; its ID is never reused.

---

## 10. Feature quality and candidate confidence rules

| `geometry_accuracy_class` | `candidate_confidence_score` cap | Implication for evaluation |
|---|---|---|
| `HIGH` | 1.0 | Candidate may support ILLEGAL or LEGAL_WITH_BUFFER with sufficient visual evidence |
| `MEDIUM` | 0.75 | Candidate may support PROBABLY_ILLEGAL or PROBABLY_LEGAL; ILLEGAL/LEGAL_WITH_BUFFER require stronger visual confirmation |
| `LOW` | 0.40 | Candidate is treated as map-prior-only hint; result MUST be downgraded to UNVERIFIABLE or PROBABLY_* |

The `candidate_confidence_score` in the dataset MUST be consistent with the `geometry_accuracy_class`.

---

## 11. Change control

Any change to the feature schema (adding fields, changing types, changing geometry conventions) requires:
1. Update to this document.
2. Entry in `WHAT_DID_I_DO.md`.
3. Review of `dataset_strategy.md` and `OUTPUT_CONTRACT.md` for consistency.
4. Engineering Owner approval.
5. Dataset bundle version bump per `VERSIONING_POLICY.md`.
6. Update to `TASKLIST_V4_FINAL.md` if a new task or blocker arises.
