# LAUNCH SCOPE REGISTER — DK PARKING ENGINE
## Version 1 — Phase 1 document (updated Phase 3)
## Status: DONE
## Locked baseline date: 2026-04-03

---

## 1. Purpose

This register defines the authorized public launch scope for Version 1.

It tracks:
- which regions are authorized for active use
- which supported rule families are active per region
- which dataset bundle is referenced per region
- which disclosure obligations apply per region
- the launch status of each region entry

No region may be activated for public use unless it appears here with status `ACTIVE`.

---

## 2. Launch entry schema

Each launch entry MUST contain:

| Field | Required | Meaning |
|---|---|---|
| `region_id` | REQUIRED | Unique identifier for the launch region |
| `region_name` | REQUIRED | Human-readable region name |
| `region_type` | REQUIRED | One of: `city`, `district`, `bounded_area` |
| `platform` | REQUIRED | `iOS` (Version 1 only) |
| `launch_status` | REQUIRED | One of: `NOT_YET_LAUNCHED`, `ACTIVE`, `RETIRED` |
| `supported_families` | REQUIRED | List of supported rule families active in this region (subset of V1 supported families) |
| `dataset_bundle_ref` | REQUIRED | Reference to the versioned dataset bundle for this region |
| `disclosure_obligation_ref` | REQUIRED | Reference to applicable disclosure wording (see section 4) |
| `legal_source_baseline_date` | REQUIRED | The legal-source baseline date in force for this region entry |
| `activation_date` | REQUIRED when ACTIVE | Date the region was activated for public use |
| `retirement_date` | REQUIRED when RETIRED | Date the region was retired |
| `notes` | OPTIONAL | Any region-specific operational notes |

---

## 3. Launch region entries

### 3.1 Entry table

| region_id | region_name | region_type | platform | launch_status | supported_families | dataset_bundle_ref | disclosure_obligation_ref | legal_source_baseline_date | activation_date | notes |
|---|---|---|---|---|---|---|---|---|---|---|
| REG-DK-001 | TBD — First launch region (to be locked at Phase 3 dataset assembly) | TBD | iOS | NOT_YET_LAUNCHED | pedestrian_crossing_5m, cycle_path_exit_5m, intersection_10m, direct_prohibited_surfaces, bus_stop_12m_fallback, bus_stop_marked_segment | Format: REG-DK-001-YYYY.MM.DD-NNN (see section 9) — specific version assigned at first bundle publication | DISC-V1-UNIVERSAL | 2026-03-25 | TBD | First launch region; exact name and boundaries locked when dataset assembly begins; bundle format defined in dataset_strategy.md |

### 3.2 First launch region selection criteria

The first launch region (REG-DK-001) MUST satisfy:

- geographically bounded (one city or tightly defined area)
- a region dataset bundle can be assembled that covers the supported families
- field validation is feasible within the region
- the region can be served without requiring unsupported rule families
- iOS only at launch

Region selection MUST be recorded in this file and in `WHAT_DID_I_DO.md` when locked.

---

## 4. Disclosure obligations per region

### 4.1 DISC-V1-UNIVERSAL

Applies to: all Version 1 launch regions.

This disclosure obligation references the full universal limitations notice from `SCOPE_AND_LIMITATIONS.md` section 10.8 and `user_disclosures_and_copy.md`.

Every result shown to a user in any active region MUST include (or link to):

1. The per-family disclosure wording for the evaluated rule family (from `SCOPE_AND_LIMITATIONS.md` section 10 and `user_disclosures_and_copy.md`).
2. The universal limitations notice (from `SCOPE_AND_LIMITATIONS.md` section 10.8 and `user_disclosures_and_copy.md`).
3. The dataset version, model version, and policy version in the structured result output.

---

## 5. Launch status transition rules

| Transition | Allowed when |
|---|---|
| `NOT_YET_LAUNCHED` → `ACTIVE` | Region dataset is validated, field testing is complete (Phase 10), release readiness checklist is passed, and the Product Owner approves activation |
| `ACTIVE` → `RETIRED` | Dataset is expired or withdrawn, a critical legal-source change requires re-validation, or a safety issue is identified; Release Authority must approve retirement |
| `RETIRED` → `ACTIVE` | All relevant blockers are resolved, re-validation is complete, and release readiness checklist passes again |

No unauthorized status transitions are allowed.
Every transition must be recorded in `WHAT_DID_I_DO.md`.

---

## 6. Supported families reference (Version 1)

The following families are defined as supported for Version 1.
A launch entry may include any subset of these, but MUST NOT add unsupported families.

| Family ID | Rule Family | Threshold / Evaluation Type |
|---|---|---|
| `pedestrian_crossing_5m` | Pedestrian crossing 5m restriction | 5m distance from crossing approach boundary |
| `cycle_path_exit_5m` | Cycle-path exit 5m restriction | 5m distance from exit boundary |
| `intersection_10m` | Intersection 10m restriction | 10m distance from transverse edge |
| `direct_prohibited_surfaces` | Direct prohibited-surface overlap | Overlap evaluation |
| `bus_stop_marked_segment` | Bus-stop marked segment | Marked segment overlap (with 12m fallback on ambiguity) |
| `bus_stop_12m_fallback` | Bus-stop 12m fallback (unmarked) | 12m from sign |

Advisory-first families (`driveway_obstruction`) are NOT listed here.
Advisory-first families may be shown with advisory labeling but must not be included in launch entries as supported families.

---

## 9. Dataset bundle reference format

Dataset bundle references in this register use the format defined in `VERSIONING_POLICY.md` and `dataset_strategy.md`:

```
{region_id}-{YYYY.MM.DD}-{NNN}
```

- `region_id`: the region identifier (e.g., `REG-DK-001`)
- `YYYY.MM.DD`: bundle publication date
- `NNN`: three-digit sequence number for same-day revisions (starting at `001`)

Example: `REG-DK-001-2026.06.01-001`

The `dataset_bundle_ref` field in the launch entry table MUST be updated to a specific version string when the first bundle for that region is published.
Until then, the format string serves as the reference template.

---

## 7. Change control

Any change to this register (new region, status transition, family addition/removal) requires:
1. Entry in `WHAT_DID_I_DO.md` with date and reason.
2. Update to this file.
3. Update to `TASKLIST_V4_FINAL.md` if a new task or blocker is created.
4. Product Owner approval for ACTIVE status transitions.
5. Consistency check with `SCOPE_AND_LIMITATIONS.md`, `CLAIMS_POLICY.md`, and `user_disclosures_and_copy.md`.

---

## 8. Current status

- Phase 1: launch_scope_register.md created with Version 1 schema, first region entry placeholder (REG-DK-001), and disclosure obligation reference.
- Phase 3: Region selection criteria confirmed. REG-DK-001 = Copenhagen city centre (Indre By + Frederiksberg boundary) selected as pilot launch region. Dense pedestrian crossings, well-mapped road network, feasible field testing access.
- Phase 13: Launch region locked — see section 3.1 update below.
- Dataset bundle reference format confirmed: `REG-DK-001-YYYY.MM.DD-NNN`. Specific version assigned at first bundle publication.
- Status transitions to ACTIVE are blocked pending: field validation (Phase 10 gate), release readiness checklist sign-off (Phase 12), and Product Owner approval.

---

## 10. Phase 13 launch lock

### 10.1 Launch region (locked)

- **region_id:** REG-DK-001
- **region_name:** Copenhagen city centre — Indre By and adjacent districts
- **Approximate boundary:** Bounded by the lakes (Søerne) to the west, the harbour to the east, Nørrebro/Østerbro boundary to the north, and Amager Boulevard to the south
- **Launch status:** NOT_YET_LAUNCHED — pending Phase 10 validation and Phase 12 release readiness sign-off

### 10.2 Launch copy (locked)

**App Store short description (locked):**
"Evaluates specific Danish stopping and parking rules near pedestrian crossings, cycle-path exits, intersections, and bus stops using on-device AR measurement. Supported rules only. Not legal advice."

**App Store long description limitations paragraph (locked):**
"This app evaluates only specific supported Danish stopping and parking rules in covered regions. It does not evaluate all parking rules, signs, or time-limited restrictions. Results are not legal advice and do not guarantee you will not receive a fine. Always check visible signs and markings."

**In-app FAQ answer — "What does this app evaluate?" (locked):**
"The app evaluates specific Danish stopping and parking rules that are suitable for measurement — such as the 5-metre rule near pedestrian crossings. It does not evaluate all parking rules and cannot read time-limited signs, permits, or markings it cannot detect."

**In-app FAQ answer — "Is this legal advice?" (locked):**
"No. This app is a parking guidance tool only. It evaluates specific supported rules using on-device measurement. Results do not constitute legal advice and do not guarantee any enforcement outcome. Always follow all visible signs and road markings."

### 10.3 Support triage paths (locked)

| User complaint | Triage path |
|---|---|
| "App said I could park but I got a fine" | Log evaluation_id; check rule_family and limitation notices; confirm app showed per-family disclosure; escalate to legal review if disclosure was absent |
| "App always says Could not evaluate" | Confirm AR session quality prerequisites; check device iOS version; check dataset region coverage |
| "App gave wrong distance" | Log evaluation_id and version refs; check boundaryProvenance; check totalEstimatedErrorM; assess whether measurement is within stated error budget |
| "App doesn't cover my location" | Confirm region coverage; direct to supported region map |

### 10.4 Rollback criteria (locked)

The following trigger an emergency rollback (hotfix or forced update):

1. Any confirmed false-confidence result (LEGAL_WITH_BUFFER) where ground truth was a clear violation and the measurement was not within stated error budget.
2. Any missing-refusal on a visible unsupported restriction (UNVERIFIABLE not produced when it should be).
3. Any forbidden claim surfacing in production (C-007 through C-013 per CLAIMS_POLICY.md).
4. Dataset bundle expiry without a replacement bundle available (> 180 days, PR-010).
5. Any privacy violation: camera frames found in transmitted telemetry.
