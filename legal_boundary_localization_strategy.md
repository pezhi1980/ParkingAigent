# LEGAL BOUNDARY LOCALIZATION STRATEGY — DK PARKING ENGINE
## Version 1 — Phase 6 document
## Status: DONE
## Locked baseline date: 2026-04-03

---

## 1. Purpose

This document defines how legal boundaries are localized for each V1 supported rule family.

It governs:
- what the legal boundary reference point or line is for each family
- the localization tiers (visual detection, map-prior-assisted, map-prior-only)
- provenance rules: what evidence is required to localize each boundary type
- refusal conditions when a boundary cannot be safely localized
- the `boundary_provenance` field values used in `MeasurementBundle`

This document is normative. No boundary may be used in a legal measurement unless it meets the provenance requirements defined here.

---

## 2. Boundary provenance tiers (locked)

| Tier | Label (boundary_provenance value) | Description | Allowed result states |
|---|---|---|---|
| 1 | `visual_detection` | Boundary localized primarily from visual evidence in the captured frame (detected marking, kerb, sign) | All states including ILLEGAL and LEGAL_WITH_BUFFER |
| 2 | `map_prior_assisted` | Boundary localized from visual evidence WITH dataset feature as a prior to constrain the search | All states including ILLEGAL and LEGAL_WITH_BUFFER |
| 3 | `map_prior_only` | Boundary position taken entirely from dataset geometry; no visual confirmation | PROBABLY_ILLEGAL and PROBABLY_LEGAL at most; ILLEGAL and LEGAL_WITH_BUFFER MUST NOT be produced |
| 4 | `unresolved` | Boundary could not be localized | UNVERIFIABLE (BOUNDARY_UNRESOLVED) — no legal result |

A boundary MUST NOT be used at a lower-confidence tier if visual evidence is available.
A boundary MUST NOT be invented from road centerline, lane geometry, or inferred position.

---

## 3. Per-family boundary definitions and localization rules

### 3.1 PEDESTRIAN_CROSSING — 5m restriction

**Legal boundary reference:** The nearside approach boundary line — the line across the road at the point where the crossing begins (the nearside kerb edge of the crossing markings, or the stop line if present).

**Localization methods (ordered by preference):**

| Method | Tier | Visual evidence required |
|---|---|---|
| Detect crossing approach marking (zebra stripes, zig-zag markings, stop line) in the captured frame | 1 — `visual_detection` | Crossing markings visible in frame |
| Detect crossing edge from kerb texture / tactile paving, with dataset prior confirming location | 2 — `map_prior_assisted` | Kerb or paving edge visible; dataset feature within 5m |
| Use dataset feature approach_boundary directly (no visual confirmation) | 3 — `map_prior_only` | No marking/kerb visible but feature present |
| No feature found within search radius and no visual evidence | 4 — `unresolved` | UNVERIFIABLE |

**Refusal condition:** If no crossing marking, kerb edge, or dataset feature is found: `BOUNDARY_UNRESOLVED`.

---

### 3.2 CYCLE_PATH_EXIT — 5m restriction

**Legal boundary reference:** The exit boundary line — the road-side edge of the cycle path exit, where the cycle path meets the road surface.

**Localization methods (ordered by preference):**

| Method | Tier | Visual evidence required |
|---|---|---|
| Detect cycle path surface paint, edge marking, or surface texture change at exit | 1 — `visual_detection` | Cycle path exit edge visible in frame |
| Detect cycle path edge from surface material change with dataset prior | 2 — `map_prior_assisted` | Surface change visible; dataset feature within 5m |
| Use dataset feature exit_boundary directly | 3 — `map_prior_only` | No visual edge visible |
| No feature found | 4 — `unresolved` | UNVERIFIABLE |

**Refusal condition:** If cycle path exit cannot be localized and no dataset feature is within search radius: `BOUNDARY_UNRESOLVED`.

---

### 3.3 INTERSECTION — 10m restriction

**Legal boundary reference:** The transverse edge of the intersecting road — the line across the main road at the point where the side road begins (typically the projected kerb line of the minor road).

**Localization methods (ordered by preference):**

| Method | Tier | Visual evidence required |
|---|---|---|
| Detect kerb line of intersecting road visible in the captured frame | 1 — `visual_detection` | Kerb or road edge of side road visible |
| Detect road surface boundary with dataset intersection transverse edge as prior | 2 — `map_prior_assisted` | Road boundary visible; dataset intersection within 15m |
| Use dataset feature transverse_edges directly | 3 — `map_prior_only` | No kerb visible |
| No intersection feature found within search radius | 4 — `unresolved` | UNVERIFIABLE |

**Refusal condition:** If no intersection feature is present and no kerb is visible: `BOUNDARY_UNRESOLVED`.
**Note:** For roundabouts, the transverse edge is the projected tangent of the roundabout entry kerb. See feature_schema_spec.md section 6.

---

### 3.4 BUS_STOP — 12m fallback / marked segment

**Legal boundary reference (marked segment case):** The extent of the T 61 bus-stop road marking.
**Legal boundary reference (12m fallback case):** The position of the bus-stop sign post.

**Localization methods — marked segment path:**

| Method | Tier | Visual evidence required |
|---|---|---|
| Detect T 61 marking extent in the captured frame (start and end lines visible) | 1 — `visual_detection` | Full marking extent visible |
| Detect partial T 61 marking with dataset marking_extent as extent estimate | 2 — `map_prior_assisted` | Partial marking visible; dataset marking_confidence ≥ threshold |
| Use dataset marking_extent directly (marking_extent_status = FULLY_MAPPED, confidence ≥ threshold) | 3 — `map_prior_only` | No marking visible |
| Marking ambiguous / extent uncertain → fall back to 12m rule | → see 12m fallback path | |

**Localization methods — 12m fallback path:**

| Method | Tier | Visual evidence required |
|---|---|---|
| Detect bus-stop sign in the captured frame (visual pole + sign head) | 1 — `visual_detection` | Sign visible in frame |
| Locate sign using dataset sign_location as prior | 2 — `map_prior_assisted` | Sign partially visible; dataset feature within 10m |
| Use dataset sign_location directly | 3 — `map_prior_only` | No sign visible; dataset feature present |
| No bus-stop feature found | 4 — `unresolved` | UNVERIFIABLE |

**BS-MARK-SEG fallback rule (from LEGAL_THRESHOLDS.md section 6):**
- Unambiguous marking extent visible → use marking extent boundary (tier 1 or 2)
- Marking present but extent ambiguous → fall back to 12m from sign
- No marking, sign present → 12m from sign
- No sign localized → UNVERIFIABLE

---

### 3.5 PROHIBITED_SURFACE_ZONE — overlap check

**Legal boundary reference:** The polygon boundary of the prohibited surface zone (cycle path, footway, refuge, median).

**Localization methods (ordered by preference):**

| Method | Tier | Visual evidence required |
|---|---|---|
| Detect prohibited surface type from visual surface texture/paint (blue cycle path, tactile footway) in frame | 1 — `visual_detection` | Surface type visible and distinguishable |
| Detect surface boundary with dataset prohibited zone polygon as prior | 2 — `map_prior_assisted` | Surface edge visible; dataset zone within 5m |
| Use dataset zone_polygon directly | 3 — `map_prior_only` | No surface visible; dataset zone present |
| No prohibited surface feature detected or found | 4 — `unresolved` | UNVERIFIABLE |

**Unsupported restriction check:** If a sign or marking is visible that indicates a prohibited surface not in the dataset, `unsupported_visible_restriction_flag = true` MUST be set.

---

## 4. General refusal rules (all families)

- If the localized boundary has `boundary_provenance = map_prior_only` AND the `candidate_confidence_score` of the dataset feature is below the engine's confidence floor for strong results: MUST NOT produce ILLEGAL or LEGAL_WITH_BUFFER.
- If the boundary position is uncertain by more than 2.0m (from dataset geometry_accuracy_class = LOW): treat as `map_prior_only` regardless of visual evidence.
- If a boundary cannot be projected onto the AR ground plane: `BOUNDARY_UNRESOLVED`.
- If multiple candidate boundaries are found and cannot be disambiguated: `FEATURE_CANDIDATE_AMBIGUOUS` (handled in Phase 7 — feature candidate matching).

---

## 5. boundary_provenance field values (locked for OUTPUT_CONTRACT.md)

These are the exact string values that MUST appear in `MeasurementBundle.boundary_provenance`:

- `visual_detection`
- `map_prior_assisted`
- `map_prior_only`
- (unresolved → no MeasurementBundle produced; result is UNVERIFIABLE)

---

## 6. Change control

Any change to boundary definitions, localization tiers, or provenance rules requires:
1. Update to this document.
2. Entry in `WHAT_DID_I_DO.md`.
3. Review of `feature_schema_spec.md`, `ar_measurement_strategy.md`, and `OUTPUT_CONTRACT.md` for consistency.
4. Engineering + Legal Source Owner approval for changes to per-family boundary definitions.
5. Update to `TASKLIST_V4_FINAL.md` if a new task or blocker arises.
