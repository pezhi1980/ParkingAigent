# LEGAL SOURCE REGISTER — DK PARKING ENGINE
## Version 1 — Phase 0 foundation document
## Status: IN_PROGRESS (Phase 0 controlling-source set verified; optional guidance/municipal entries pending)
## Locked baseline date: 2026-03-25

## 1. Purpose
This document locks the official controlling legal sources used by Version 1.
It provides the authority order, review cadence, and the update procedure.

This register is required before any implementation that depends on legal thresholds or rule-family meaning.

## 2. Source hierarchy (authority order)
1. Danish statutory law and official executive orders in force
2. Official Danish public-authority guidance and official municipal guidance
3. DK_PARKING_AGENT_MASTER_SPEC_V4_FINAL.md
4. ROADMAP_V8_FINAL.md
5. RULES_V2_FINAL.md
6. TASKLIST_V4_FINAL.md
7. Implementation files

## 3. Locked legal-source baseline policy
- Baseline date: 2026-03-25
- The project must not allow silent legal drift.
- If any controlling source changes (or if interpretation-relevant guidance changes), the project must follow the update procedure in section 6.

## 4. Source entries (REQUIRED FIELDS)
Each entry MUST include:
- source title
- source type
- issuing authority
- status in force
- access path
- relevance to supported rule families
- hierarchy rank
- review date
- update procedure

### 4.1 Register table
| Source ID | Source Title | Source Type | Issuing Authority | Status In Force | Access Path | Relevance to Supported Rule Families | Hierarchy Rank | Review Date | Update Procedure | Notes |
|---|---|---|---|---|---|---|---:|---|---|---|
| DK-LAW-001 | Bekendtgørelse af færdselsloven (Danish Road Traffic Act, Consolidated) — LBK nr 118 af 12/01/2026 | Statutory law | Transportministeriet | GÆLDENDE (retsinformation.dk display) | https://retsinformation.dk/eli/lta/2026/118 ; PDF: https://www.retsinformation.dk/api/pdf/254826 | All supported V1 families (crossing, cycle-path exit, intersection, bus-stop, direct prohibited surfaces, driveway advisory) | 1 | 2026-03-25 | See section 6 | Used for § 28, § 29, and § 95 traceability in Phase 0 |
| DK-EO-001 | BEK nr 425 af 13/04/2023, Transportministeriet — Bekendtgørelse om vejafmærkning | Executive order (Bekendtgørelse) | Transportministeriet | GÆLDENDE (retsinformation.dk display) | https://www.retsinformation.dk/eli/lta/2023/425 ; PDF: https://www.retsinformation.dk/api/pdf/235801 | Road marking / segment-definition semantics referenced under Færdselsloven § 95; supports bus-stop marked-segment interpretation via T 61 meaning (and limited “minor deviation” support via § 1, stk. 2) | 1 | 2026-03-29 | See section 6 | Verified controlling “vejafmærkning” instrument; predecessor BEK nr 2511 af 09/12/2021 is HISTORISK |
| DK-EO-002 | BEK nr 426 af 13/04/2023, Transportministeriet — Bekendtgørelse om anvendelse af vejafmærkning | Executive order (Bekendtgørelse) | Transportministeriet | GÆLDENDE (retsinformation.dk display) | https://www.retsinformation.dk/eli/lta/2023/426 ; PDF: https://www.retsinformation.dk/api/pdf/235802 | Application/use of road markings; needed to interpret when markings define extent (segment-definition) | 1 | 2026-03-29 | See section 6 | Supplementary to DK-EO-001 for “anvendelse” semantics |
| DK-EO-003 | BEK nr 2511 af 09/12/2021, Transportministeriet — Bekendtgørelse om vejafmærkning (predecessor) | Executive order (Bekendtgørelse) | Transportministeriet | HISTORISK (retsinformation.dk display) | https://www.retsinformation.dk/eli/lta/2021/2511 ; PDF: https://www.retsinformation.dk/api/pdf/227643 | Historical predecessor only; must not be treated as controlling while BEK 425 is in force | 1 | 2026-03-29 | See section 6 | Predecessor to DK-EO-001; kept for audit/traceability only |
| DK-GUIDE-001 | Official public-authority guidance (national) | Guidance | TBD | TBD | TBD | Clarifies boundary concepts where law delegates to guidance (if any) | 2 | TBD | See section 6 | Optional; must be official |
| DK-MUNI-001 | Municipal guidance for launch region | Municipal guidance | TBD | TBD | TBD | Launch-region operational notes; must not override statutory law | 2 | TBD | See section 6 | Only for launch region |

## 5. Review cadence
- Minimum review cadence: at least once per release, and whenever a legal change trigger occurs.
- If the launch region changes, municipal guidance entries must be reviewed and updated.

## 6. Legal-source update procedure (no silent drift)
When a change is suspected or confirmed:
1. Create a dated entry in WHAT_DID_I_DO.md describing the trigger.
2. Add or update the controlling source entry above.
3. Update all dependent documents:
   - LEGAL_THRESHOLDS.md
   - SCOPE_AND_LIMITATIONS.md
   - DECISION_STATES.md (only if semantics change)
   - CLAIMS_POLICY.md
   - DK_PARKING_AGENT_MASTER_SPEC_V4_FINAL.md (only if the locked spec must be amended)
4. Update TASKLIST_V4_FINAL.md blockers and next steps.
5. Do not ship until traceability is restored.

## 7. Verification status
- Official-source fields are partially complete:
   - DK-LAW-001, DK-EO-001, DK-EO-002 are now populated from verified retsinformation.dk ELI pages.
   - DK-GUIDE-001 and DK-MUNI-001 remain `TBD` pending a selected launch region and identified official guidance sources.
- This document is complete for the Phase 0 controlling-source set used by Version 1 evaluators.
   DK-GUIDE-001 and DK-MUNI-001 remain placeholders to be populated only after the launch region and any required official guidance sources are explicitly locked.
