# DATASET STRATEGY — DK PARKING ENGINE
## Version 1 — Phase 3 document
## Status: DONE
## Locked baseline date: 2026-04-03

---

## 1. Purpose

This document defines the strategy for region datasets in Version 1.

It covers:
- what a region dataset is and what it contains
- the region unit and region bundle structure
- the download, activation, expiry, rollback, and update lifecycle
- the role of map priors in candidate generation
- the limits of map priors in final legal judgment
- missing-data behavior
- integrity and version requirements

---

## 2. What a region dataset is

A region dataset bundle is a versioned, on-device data package that contains:
- a structured set of legal feature candidates for a bounded geographic region
- geometry data for each feature candidate (coordinates, boundary shapes)
- feature type and quality metadata
- the applicable legal source baseline date
- version and integrity metadata

A region dataset bundle is NOT:
- a real-time map feed
- a cloud-connected service
- a source of final legal authority
- a substitute for on-device visual evidence

The dataset provides **candidate features** for the evaluation engine to use during candidate matching. The engine then uses visual evidence (camera + AR measurement) to confirm, refine, or reject each candidate before making any legal judgment.

---

## 3. Region unit definition

### 3.1 What defines a region
A region is a bounded geographic area that:
- is small enough to fit in a single downloadable bundle (target: ≤ 50 MB compressed)
- corresponds to one or more contiguous city districts or a full small city
- has uniform legal-source baseline date applicability

### 3.2 Region identifier
Each region has a unique `region_id` (e.g., `REG-DK-001`).
Region IDs are assigned in `launch_scope_register.md` and do not change once assigned.

### 3.3 Region boundary representation
Each region bundle declares its geographic bounding polygon.
The evaluation engine uses this polygon to determine whether the current location is within the active region.
If the location is outside all active region boundaries, the engine MUST return `NO_ACTIVE_DATASET_REGION`.

---

## 4. Region bundle structure

A region bundle is a signed, compressed archive containing:

```
REG-DK-001-2026.06.01-001/
  manifest.json          — bundle metadata (version, region_id, bounding polygon, legal_source_baseline_date, min_sdk_version, checksum table)
  features/
    intersections.geojson
    pedestrian_crossings.geojson
    cycle_path_exits.geojson
    bus_stops.geojson
    prohibited_surfaces.geojson
  region_boundary.geojson — the bounding polygon for this region
  integrity.sig           — digital signature for bundle verification
```

All feature files use the GeoJSON format. Feature schema is defined in `feature_schema_spec.md`.

---

## 5. Download, activation, and expiry lifecycle

### 5.1 Download
- The user initiates a dataset download for their desired region from within the app.
- The app downloads the bundle and verifies the bundle signature before storage.
- A failed signature check MUST discard the download entirely; it MUST NOT be partially activated.

### 5.2 Activation
- After successful signature verification, the Dataset Subsystem (SS-04) activates the bundle.
- Activation records: `region_id`, `bundle_version`, `activation_timestamp`, `legal_source_baseline_date`.
- A region is considered active from the moment of successful activation.

### 5.3 Expiry
- Each bundle declares a `valid_until` date in its manifest.
- `valid_until` is computed as: `activation_date` + `dataset_max_validity_days` (from `POLICY_REGISTRY_SPEC.md` PR-010, default 180 days).
- After `valid_until`, the bundle MUST be treated as expired.
- An expired bundle MUST NOT be used for evaluation. The engine MUST return `NO_ACTIVE_DATASET_REGION` until a new bundle is downloaded.
- The app MUST warn the user before expiry (recommended: 14 days before expiry).

### 5.4 Rollback
- If a newly downloaded bundle fails verification, SS-04 MUST revert to the last valid active bundle (if not expired) or refuse.
- Rollback events MUST be logged in telemetry.

### 5.5 Updates
- When a new bundle version is available for an active region, the app SHOULD notify the user.
- A new bundle is not automatically activated without user action.
- After a new bundle is activated, the previous bundle may be deleted.

---

## 6. Role of map priors in candidate generation (locked rule)

Map priors (the pre-built dataset features) play a **candidate generation** role only.

### 6.1 What map priors MAY do
- Provide candidate feature locations for candidate matching
- Narrow the search radius for candidate selection
- Provide geometry estimates that guide boundary localization
- Carry feature type and quality metadata that inform confidence scoring

### 6.2 What map priors MUST NOT do
- Serve as the sole basis for a positive legal result (`LEGAL_WITH_BUFFER` or `PROBABLY_LEGAL`)
- Override or suppress visual evidence
- Allow a legal determination to be made when visual evidence is insufficient
- Provide the exact legal boundary geometry used in the final measurement without visual confirmation support

### 6.3 The map-prior confidence rule
A candidate sourced from map priors carries a `candidate_confidence_score` reflecting the geometric accuracy and freshness of the map data.
If the `candidate_confidence_score` is below the threshold defined in `POLICY_REGISTRY_SPEC.md` (PR-002), the candidate MUST be flagged as map-prior-only and the result MUST be downgraded (at minimum to `PROBABLY_LEGAL` or `PROBABLY_ILLEGAL`).

A result of `LEGAL_WITH_BUFFER` or `ILLEGAL` MUST NOT be produced from map-prior-only geometry without visual confirmation supporting the boundary location.

---

## 7. Missing-data behavior (mandatory)

### 7.1 No active region
If no region bundle is active for the current location:
- Engine returns UNVERIFIABLE with `NO_ACTIVE_DATASET_REGION`

### 7.2 Feature type missing from dataset
If the dataset contains no features of the required type within the search radius:
- Engine returns UNVERIFIABLE with `BOUNDARY_UNRESOLVED` (no candidate found)
- The engine MUST NOT attempt to extrapolate features from incomplete data

### 7.3 Feature geometry quality too low
If the best available candidate for a required type has `candidate_confidence_score` below the minimum threshold:
- The candidate is used with a map-prior-only confidence flag
- The result is downgraded accordingly (never ILLEGAL or LEGAL_WITH_BUFFER from map-prior-only geometry alone)

### 7.4 Expired bundle
If the active bundle has expired:
- Engine returns UNVERIFIABLE with `NO_ACTIVE_DATASET_REGION` (expired)
- The app MUST surface a "please update your region data" message

---

## 8. Dataset version traceability

Every evaluation result MUST include:
- `dataset_version`: the bundle version string (e.g., `REG-DK-001-2026.06.01-001`)
- `dataset_region_id`: the region identifier
- `legal_source_baseline_date`: the legal baseline date from the bundle manifest

This ensures that any result can be traced to the exact dataset state that was active at evaluation time.

---

## 9. Dataset content and quality obligations

### 9.1 Accuracy obligation
Dataset features MUST be sourced from authoritative data (official road geometry data, official Danish traffic infrastructure databases where available, or high-accuracy survey data).
User-contributed geometry is NOT permitted in Version 1.

### 9.2 Coverage obligation
For a region to be launch-eligible, the dataset MUST cover:
- all intersections with streets in the region
- all designated pedestrian crossings
- all cycle-path exits onto roads
- all marked bus stops (signs + markings where available)
- directly prohibited surfaces (cycle paths, footways) where geometry data is available

Coverage gaps MUST be declared in the region manifest as `known_coverage_gaps`.
A region with critical coverage gaps MUST NOT be activated for public launch until gaps are addressed or the engine handles them via UNVERIFIABLE/missing-data behavior.

### 9.3 Staleness obligation
All feature geometry MUST be verified against official sources within 12 months before bundle publication.
The bundle's `legal_source_baseline_date` MUST reflect the verification date.

---

## 10. Change control

Any change to the dataset structure, lifecycle rules, or map-prior limits requires:
1. Update to this document.
2. Entry in `WHAT_DID_I_DO.md`.
3. Review of `feature_schema_spec.md` and `VERSIONING_POLICY.md` for consistency.
4. Engineering Owner approval.
5. Update to `TASKLIST_V4_FINAL.md` if a new task or blocker arises.
