# RELEASE READINESS CHECKLIST — DK PARKING ENGINE
## Version 1 — Phase 12 document
## Status: DONE
## Locked baseline date: 2026-04-03

---

## 1. Purpose

This document is the authoritative gate checklist for public release of DK Parking Engine Version 1.

Public release is BLOCKED until every item in this checklist is checked.

This checklist consolidates the release blockers from ROADMAP §34.

---

## 2. Legal and claims checklist

- [ ] **LC-001** `LEGAL_THRESHOLDS.md` is locked and matches Danish Road Traffic Act (Bekendtgørelse af færdselsloven) §28.
- [ ] **LC-002** `CLAIMS_POLICY.md` is locked. No user-facing text makes a forbidden claim (C-007 through C-013).
- [ ] **LC-003** Universal limitations notice (DISC-V1-UNIVERSAL) is visible on every evaluation result.
- [ ] **LC-004** Per-family disclosure is visible on every non-UNVERIFIABLE result.
- [ ] **LC-005** App Store description does not claim universal Denmark parking legality.
- [ ] **LC-006** App Store description includes the limitations notice in plain language.
- [ ] **LC-007** FAQ wording does not imply the app evaluates all parking rules.
- [ ] **LC-008** Legal-source baseline date is referenced in app and documentation.
- [ ] **LC-009** No result produced by the engine can be interpreted as "you will not receive a fine."

---

## 3. Technical quality checklist

- [ ] **TQ-001** All unit tests pass on iOS simulator (ConfidenceComposerTests, LegalEvaluatorTests, MeasurementBundleTests).
- [ ] **TQ-002** All 7 guardrails from `validation_plan.md` pass in controlled testing.
- [ ] **TQ-003** All 10 acceptance metrics from `validation_plan.md` are met.
- [ ] **TQ-004** `field_test_matrix.md` minimum observations per decision state achieved.
- [ ] **TQ-005** No failure category appears in > 2% of field tests.
- [ ] **TQ-006** `vertical_slice_report.md` §3–6 is fully completed.
- [ ] **TQ-007** All `ParkingEvaluationResult` fields per `OUTPUT_CONTRACT.md` present and non-null where REQUIRED.
- [ ] **TQ-008** `VersionRefs` fully populated in every serialized result.
- [ ] **TQ-009** `UNVERIFIABLE` result always carries at least one `RefusalReasonCode`.
- [ ] **TQ-010** `LEGAL_WITH_BUFFER` never produced when `inNearThresholdZone == true`.
- [ ] **TQ-011** `LEGAL_WITH_BUFFER` never produced when `boundaryProvenance == mapPriorOnly`.
- [ ] **TQ-012** All evaluations run 100% on-device — no network request during evaluation.

---

## 4. Privacy and data checklist

- [ ] **PD-001** `privacy_and_telemetry_spec.md` is approved.
- [ ] **PD-002** App Store privacy nutrition label (Data Privacy section) is accurate and complete.
- [ ] **PD-003** Camera frames are NOT persisted to disk in the release build.
- [ ] **PD-004** No GPS coordinates in any telemetry event.
- [ ] **PD-005** No device identifier (IDFA, IDFV, serial) in any telemetry event.
- [ ] **PD-006** Telemetry opt-out mechanism is implemented and functional.
- [ ] **PD-007** First-launch privacy disclosure is shown before AR session starts.
- [ ] **PD-008** Replay logging (if present) requires explicit opt-in and discloses what is stored.
- [ ] **PD-009** GDPR Article 13 disclosure (what is collected and why) is accessible in-app.

---

## 5. UX and disclosure checklist

- [ ] **UX-001** All 5 decision state labels match locked vocabulary (`user_disclosures_and_copy.md` §2.1).
- [ ] **UX-002** All 5 decision state explanation bodies are present and correct (§3).
- [ ] **UX-003** All 9 refusal reason human-readable explanations are present (§4).
- [ ] **UX-004** All 9 refusal retry guidance strings are present (§5).
- [ ] **UX-005** Onboarding acknowledgment screen is shown on first launch.
- [ ] **UX-006** AR session quality banner is always visible during AR view.
- [ ] **UX-007** Evaluate button is disabled when session quality is below threshold.
- [ ] **UX-008** `UNVERIFIABLE` result card uses gray — not red.
- [ ] **UX-009** `UNVERIFIABLE` card does not imply user error.
- [ ] **UX-010** Result card is scrollable to accommodate all content.
- [ ] **UX-011** Evaluation ID (truncated) visible on result card for support reference.
- [ ] **UX-012** Per-family disclosure visible on result card for all non-UNVERIFIABLE states.

---

## 6. Versioning and release management checklist

- [ ] **VM-001** SDK version string follows MAJOR.MINOR.PATCH per `VERSIONING_POLICY.md`.
- [ ] **VM-002** Policy version string matches `PolicyRegistry.v1Default`.
- [ ] **VM-003** Dataset version string matches the active region bundle.
- [ ] **VM-004** Model version string is not empty or "STUB".
- [ ] **VM-005** `launch_scope_register.md` is updated with final launch region and rule families.
- [ ] **VM-006** `launch_runbook.md` is complete and reviewed.
- [ ] **VM-007** Rollback criteria are defined — what triggers an emergency hotfix.
- [ ] **VM-008** Dataset expiry behavior tested: expired dataset produces `SDKInitResult.datasetExpired`.

---

## 7. Release blockers (from ROADMAP §34)

The following are hard blockers — release is NOT permitted if any is true:

| # | Blocker |
|---|---|
| RB-001 | Any false-confidence failure in field testing (FC category) |
| RB-002 | Any missing-refusal failure in field testing (MR category) |
| RB-003 | `LEGAL_WITH_BUFFER` produced with no measurement |
| RB-004 | Any forbidden claim (C-007 through C-013) in any user-facing surface |
| RB-005 | Limitations notice absent from any result screen |
| RB-006 | Camera images sent to any external server |
| RB-007 | GPS data collected without consent |
| RB-008 | App Store privacy nutrition label inaccurate |
| RB-009 | `VersionRefs` missing or empty on any serialized result |
| RB-010 | Unit tests failing in CI |
| RB-011 | `vertical_slice_report.md` §3–6 not completed |
| RB-012 | Model version is "STUB" or empty in release build |

---

## 8. Sign-off record

| Role | Name | Date | Signature |
|---|---|---|---|
| Engineering lead | — | — | — |
| Legal/compliance review | — | — | — |
| Privacy review | — | — | — |
| Product owner | — | — | — |

All four sign-offs required before release tag is cut.

---

## 9. Change control

Any change to checklist items or release blockers requires:
1. Update to this file.
2. Entry in `WHAT_DID_I_DO.md`.
3. Update to `TASKLIST_V4_FINAL.md`.
4. Review of `ROADMAP_V8_FINAL.md` §34 for alignment.
