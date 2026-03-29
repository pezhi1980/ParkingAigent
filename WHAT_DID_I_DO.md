# WHAT DID I DO — DK PARKING ENGINE
## Work log (mandatory)

### 2026-03-25 — START — Phase 0 foundation document creation

- Scope: Phase 0 only (legal and product foundation)
- Intent: Create the required Phase 0 foundation files in the mandated order as non-empty, version-aligned skeletons.
- Note: Legal-source and threshold traceability fields will remain `TBD` until official controlling sources are provided/verified.

### 2026-03-25 — END — Phase 0 foundation document creation

- Created (Phase 0 required files):
	- LEGAL_SOURCE_REGISTER.md (skeleton; official-source fields still `TBD`)
	- LEGAL_THRESHOLDS.md (baseline thresholds locked; controlling-source traceability still `TBD`)
	- SCOPE_AND_LIMITATIONS.md
	- DECISION_STATES.md
	- CLAIMS_POLICY.md
	- legal_governance_strategy.md
	- scope_and_claims_strategy.md
- Updated:
	- TASKLIST_V4_FINAL.md (next action + file creation log)
	- WHAT_DID_I_DO.md (initialized)
- Current blockers (per TASKLIST): Phase 0 validation (T-0009) remains BLOCKED until:
	- LEGAL_SOURCE_REGISTER.md is filled with fully verified official-source details
	- LEGAL_THRESHOLDS.md links each V1 threshold to controlling legal sources

### 2026-03-25 — START — Populate official-source traceability (T-0002, T-0003)

- Intent: Use Denmark official sources (retsinformation.dk) only.
- Deliverable: Complete traceability for intersection (10m), pedestrian crossing (5m), cycle-path exit (5m), bus stop (12m/segment), and prohibited surfaces.
- Rule: If any item cannot be supported by a verified official source, flag that specific item as `NEEDS_LEGAL_REVIEW` with precise reason, and continue with the remaining items.

### 2026-03-25 — END — Populate official-source traceability (T-0002, T-0003)

- Updated LEGAL_SOURCE_REGISTER.md:
	- DK-LAW-001 populated from retsinformation.dk canonical ELI page:
		- Source Title: Bekendtgørelse af færdselsloven (Danish Road Traffic Act, Consolidated) — LBK nr 118 af 12/01/2026
		- Issuing authority: Transportministeriet
		- Status in force: GÆLDENDE (retsinformation.dk display)
		- Access: https://retsinformation.dk/eli/lta/2026/118 ; PDF: https://www.retsinformation.dk/api/pdf/254826
		- Review date set to baseline: 2026-03-25
	- DK-EO-001 kept as placeholder and explicitly treated as NEEDS_LEGAL_REVIEW for marking/segment-definition rules (if applicable) under § 95.

- Updated LEGAL_THRESHOLDS.md (controlling source traceability):
	- TH-CR-005M → DK-LAW-001 § 29, stk. 1, nr. 1
	- TH-CPX-005M → DK-LAW-001 § 29, stk. 1, nr. 1
	- TH-INT-010M → DK-LAW-001 § 29, stk. 1, nr. 2
	- TH-BS-012M (12m fallback when no marked segment exists) → DK-LAW-001 § 29, stk. 2
	- OV-PS-001 → DK-LAW-001 § 28, stk. 3, with interpretation note about exceptions (outside built-up areas for vehicles ≤ 3,500 kg; first sentence not applicable to bicycles and two-wheeled mopeds)
	- BS-MARK-SEG → DK-LAW-001 § 29, stk. 2, with DK-EO-001 NEEDS_LEGAL_REVIEW kept strictly for marking/segment-definition under § 95 (not for the 12m threshold)

- Notes:
	- Fixed a text encoding issue so that “GÆLDENDE” and “§” render correctly in the register table.

### 2026-03-25 — START — Resolve delegated implementing instrument(s) for markings/"marked segment" (DK-EO-001)

- Objective: Close the remaining Phase 0 traceability gap where the act delegates marking/road-signage details (e.g., "marked segment" / road markings) to implementing instruments under § 95, so DK-EO-001 can be replaced with verified retsinformation.dk sources.
- Constraint: Retsinformation search/UI is SPA/JavaScript-heavy and intermittently blocks non-JS access; avoid guessing URLs/IDs.

### 2026-03-25 — END — Resolve delegated implementing instrument(s) for markings/"marked segment" (DK-EO-001)

- Actions taken:
	- Confirmed machine-readable variants are reachable for the consolidated act, and fetched the raw HTML representation:
		- https://www.retsinformation.dk/eli/lta/2026/118/rawhtml
	- Attempted to locate embedded internal document identifiers or link-group data in raw HTML (e.g., `api/document`, `documentId`, `accessionNumber`, `documentLinkGroups`, “Alle bekendtgørelser…”), but no such identifiers were observable in the fetched content.
	- Continued SPA reverse-engineering approach (from earlier step): inspected the main JS bundle (previously fetched) and identified likely backend endpoints powering “related documents” / “Yderligere dokumenter”, notably patterns resembling:
		- `/document/{id}/references/{flag}`
		- `/document/documentLinks/{type}/{data}`
	- Tested direct API calls using several candidate IDs derived from ELI/XML metadata (e.g., unique document id / DG-style id / A-style accession-like id), but responses were “Siden blev ikke fundet” (page not found), indicating the API expects a different internal identifier.

- Current status:
	- DK-EO-001 remains `NEEDS_LEGAL_REVIEW` because the exact implementing instrument(s) governing road markings/vejafmærkning (needed to define/interpret “marked segment”) have not yet been enumerated from an official retsinformation.dk endpoint or page.
	- Next technical step: find the mapping from ELI (e.g., `/eli/lta/2026/118`) to the SPA’s internal `{id}` used by the `/document/{id}/...` endpoints, then expand the “Alle bekendtgørelser m.v. og cirkulærer m.v. til denne lovbekendtgørelse” link group via `/document/documentLinks/{type}/{data}`.

### 2026-03-28 — START — Retsinformation internal discovery for DK-EO-001 (routing + doc-type keys)

- Objective: Find a verifiable retsinformation.dk path to enumerate implementing instruments under Færdselsloven § 95 (DK-EO-001), especially those governing road markings/“marked segment” semantics.
- Constraint: Open Data API is limited; retsinformation.dk SPA blocks sourcemaps and many non-JS routes.

### 2026-03-28 — END — Retsinformation internal discovery for DK-EO-001 (routing + doc-type keys)

- Actions taken:
	- Confirmed the Open Data API limitation via Swagger: `/v1/Documents` supports only a `date` parameter and is constrained to “within the last 10 days”, so it cannot be used for historical keyword search.
	- Performed keyword scan on the ELI update feed for road-marking terms (e.g., `vejafmærkning`, `afmærkning`) with no hits in the recent window.
	- Inspected ELI sitemap index and concluded sitemap URLs do not embed searchable titles/keywords.
	- Identified multiple internal API strings by inspecting the site’s JS bundle; confirmed only a subset of `/api/extremesearch/*` endpoints return JSON (e.g., `GetLawRegisters`, `GetFobTags`, `getcasehistorystatus`) while many plausible “search” endpoints return SPA HTML.
	- Fetched and parsed the internal JSON endpoint `https://www.retsinformation.dk/api/eli/routing-data`.
		- Extracted `docTypeUrlParameterMap` keys (110 total) including (non-exhaustive): `bek`, `lbk`, `cir`, `reg`, `vej`, etc.
		- Noted PowerShell 5.1 `ConvertFrom-Json` lacks `-Depth`; used Python JSON parsing to extract the doc-type keys reliably.

- Current status:
	- DK-EO-001 remains unresolved, but the discovered doc-type URL parameter keys provide a concrete handle for next-step enumeration of candidate “bekendtgørelse”/“vejledning”/marking-related instruments.

### 2026-03-29 — START — Minimal Phase 0 traceability patch (EO correction + bus-stop marked-segment narrowing)

- Scope: documentation-only changes limited to LEGAL_SOURCE_REGISTER.md, LEGAL_THRESHOLDS.md, TASKLIST_V4_FINAL.md, WHAT_DID_I_DO.md.
- Constraint check: TH-BS-012M must remain unchanged.

### 2026-03-29 — END — Minimal Phase 0 traceability patch (EO correction + bus-stop marked-segment narrowing)

- Updated LEGAL_SOURCE_REGISTER.md:
	- DK-EO-001 corrected to BEK nr 425 af 13/04/2023 (GÆLDENDE) with verified ELI + PDF.
	- DK-EO-002 kept as BEK nr 426 af 13/04/2023 (GÆLDENDE) and PDF link normalized to the official `/api/pdf/...` endpoint.
	- BEK nr 2511 af 09/12/2021 recorded only as HISTORISK predecessor (new entry), not as controlling.

- Updated LEGAL_THRESHOLDS.md:
	- TH-BS-012M unchanged.
	- BS-MARK-SEG traceability tightened to cite the specific EO sections that define T 61/T 63 meaning and use (without claiming segment-extent start/continuity semantics are resolved).

- Updated TASKLIST_V4_FINAL.md:
	- Phase 0 blocker narrowed: remaining gap is specifically bus-stop marked-segment segment-extent semantics (start/continuity/gaps).

### 2026-03-29 — START — Minimal Phase 0 traceability patch #2 (BS-MARK-SEG citations tightening + blocker precision)

- Scope: documentation-only changes limited to LEGAL_SOURCE_REGISTER.md, LEGAL_THRESHOLDS.md, TASKLIST_V4_FINAL.md, WHAT_DID_I_DO.md.
- Constraint check: TH-BS-012M must remain unchanged.
- Goal: Strengthen the citations for BS-MARK-SEG without overclaiming start-of-segment or continuity/gap semantics.

### 2026-03-29 — END — Minimal Phase 0 traceability patch #2 (BS-MARK-SEG citations tightening + blocker precision)

- Updated LEGAL_THRESHOLDS.md:
	- BS-MARK-SEG now records (explicitly) that DK-LAW-001 § 29, stk. 2 provides the “den afmærkede strækning” basis and the 12m fallback when not marked.
	- BS-MARK-SEG now records (explicitly) that DK-EO-001 (BEK 425) § 60 (T 61) can mark the bus-stop prohibition under § 29, stk. 2.
	- DK-EO-001 (BEK 425) § 1, stk. 2 is recorded only as limited support for minor deviations, and explicitly not treated as a locked rule for start/continuity/gap semantics.
	- BS-MARK-SEG remains NOT fully resolved/locked: start-of-segment semantics and continuity/gap semantics remain `NEEDS_LEGAL_REVIEW` from the currently locked official text.

- Updated TASKLIST_V4_FINAL.md:
	- T-0003 blocker wording tightened so the only remaining blocker is: exact start-of-segment semantics and continuity/gap semantics for BS-MARK-SEG remain unverified from the currently locked official text.
	- T-0009 blocker wording updated to match the same narrowed semantic gap.

- Updated LEGAL_SOURCE_REGISTER.md:
	- DK-EO-001 relevance text clarified to reflect BS-MARK-SEG citations: T 61 meaning support (and limited minor-deviation support via § 1, stk. 2), without implying bus-stop end-of-segment semantics.

