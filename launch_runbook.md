# LAUNCH RUNBOOK — DK PARKING ENGINE
## Version 1 — Phase 13 document
## Status: DONE
## Locked baseline date: 2026-04-03

---

## 1. Purpose

This runbook defines the step-by-step procedure for launching DK Parking Engine Version 1 to the public App Store.

No launch step may be taken out of order. Every step must be confirmed before the next begins.

---

## 2. Pre-launch gates (all must pass before App Store submission)

| Gate | Document | Status |
|---|---|---|
| G-01 | Phase 9 vertical slice device run complete | `vertical_slice_report.md` §3–6 filled |
| G-02 | Phase 10 field validation passed | `validation_plan.md` all 10 AMs met |
| G-03 | `field_test_matrix.md` minimum observations met | All categories tested |
| G-04 | Phase 12 `release_readiness_checklist.md` all items checked | All 4 sign-offs obtained |
| G-05 | `launch_scope_register.md` REG-DK-001 dataset bundle version confirmed | Not "TBD" |
| G-06 | Model version is not "STUB" | `VersionRefs.modelVersion` ≠ "STUB-V1" |
| G-07 | No release blocker (RB-001 through RB-012) active | `release_readiness_checklist.md` §7 |
| G-08 | App Store privacy nutrition label reviewed and approved | Privacy review sign-off |
| G-09 | App Store copy reviewed against `CLAIMS_POLICY.md` | No forbidden claims |
| G-10 | All WHAT_DID_I_DO.md entries up to date | Product Owner reviewed |

---

## 3. Launch version set (to be locked at submission)

| Component | Version | Status |
|---|---|---|
| SDK version | `1.0.0` | TBD — confirm at build |
| Policy version | `PR-V1-001` | Locked |
| Dataset version | `REG-DK-001-YYYY.MM.DD-NNN` | TBD — locked at bundle publication |
| Model version | TBD | TBD — replace STUB-V1 before release |
| Legal source baseline date | `2026-03-25` | Locked |
| iOS minimum target | iOS 16.0 | Locked |
| App version (App Store) | `1.0` | TBD |
| Build number | TBD | TBD |

---

## 4. Launch day procedure

### Step 1 — Final build verification (T-3 days)
- [ ] Cut release branch: `release/v1.0.0`
- [ ] Run all unit tests on iOS simulator — confirm all pass
- [ ] Confirm `VersionRefs.modelVersion` is not "STUB-V1"
- [ ] Confirm `VersionRefs.datasetVersion` matches the published bundle
- [ ] Archive build in Xcode with release configuration
- [ ] Run archived build on physical device — confirm no crash on launch
- [ ] Confirm AR session initializes and Evaluate button activates

### Step 2 — App Store submission (T-2 days)
- [ ] Submit build to App Store Connect
- [ ] Verify App Store privacy nutrition label matches `privacy_and_telemetry_spec.md`
- [ ] Verify app description against `launch_scope_register.md` §10.2 locked copy
- [ ] Verify keywords do not include "all parking rules", "legal guarantee", or similar overclaims
- [ ] Verify screenshot captions include limitations context
- [ ] Submit for App Store review

### Step 3 — Review period (T-1 to T-0)
- [ ] Monitor App Store review status
- [ ] If reviewer asks about camera usage: respond with on-device-only privacy explanation
- [ ] If reviewer asks about legal advice: confirm limitations notice is present in app
- [ ] Do NOT change any locked copy or disclosure text during review without legal approval

### Step 4 — Launch (T-0)
- [ ] Confirm App Store approval received
- [ ] Confirm all pre-launch gates G-01 through G-10 are still valid (no new blockers)
- [ ] Set `launch_scope_register.md` REG-DK-001 status to `ACTIVE` with activation date
- [ ] Log activation in `WHAT_DID_I_DO.md`
- [ ] Release build to App Store (phased release recommended — 10% rollout first)
- [ ] Notify support team: provide evaluationId lookup procedure and support triage paths
- [ ] Begin monitoring telemetry dashboard for decision state distribution and refusal rates

### Step 5 — Post-launch monitoring (T+1 to T+7 days)
- [ ] Check refusal rate — if > 60% of evaluations are UNVERIFIABLE, investigate AR quality issues
- [ ] Check false-confidence rate — if any LEGAL_WITH_BUFFER produced in near-threshold zone, escalate immediately
- [ ] Check crash rate — if > 1% crash rate on launch, pause rollout
- [ ] Check support complaints for "wrong result" reports — log all with evaluationId
- [ ] Confirm no forbidden claim (C-007 through C-013) appeared in any user-facing surface

---

## 5. Rollback procedure

If any rollback trigger (from `launch_scope_register.md` §10.4) fires:

1. **Immediately** set phased release to 0% in App Store Connect (pause rollout).
2. Log the issue in `WHAT_DID_I_DO.md` with date, trigger, and evaluationId if available.
3. Update `launch_scope_register.md` REG-DK-001 status to `ACTIVE (ROLLBACK PENDING)`.
4. Diagnose root cause against relevant strategy document (see `validation_plan.md` §8 strategy update trigger).
5. Fix, rebuild, and re-run release readiness checklist items affected.
6. Submit hotfix build with incremented version.
7. Resume phased release only after hotfix approval.

---

## 6. Dataset bundle expiry procedure

Dataset bundles expire after 180 days (PR-010).

30 days before expiry:
- [ ] Assemble updated dataset bundle for REG-DK-001
- [ ] Run field validation on the new bundle (abbreviated — focus on Category B near-threshold scenarios)
- [ ] Submit app update with new `VersionRefs.datasetVersion`

On expiry date (if no update submitted):
- SDK returns `SDKInitResult.datasetExpired`
- App surfaces: "Dataset expired. Please update the app to continue evaluating."
- No evaluation is possible until update is installed

---

## 7. Communication checklist at launch

- [ ] Support team briefed on: evaluationId lookup, refusal explanation, supported region map
- [ ] FAQ published matching `launch_scope_register.md` §10.2 locked FAQ wording
- [ ] Social media / press copy reviewed against `CLAIMS_POLICY.md` — no forbidden claims
- [ ] In-app onboarding text matches `retry_and_refusal_ux_strategy.md` §9 onboarding disclosure

---

## 8. Change control

Any change to launch steps, version set, or rollback criteria requires:
1. Update to this file.
2. Entry in `WHAT_DID_I_DO.md`.
3. Product Owner approval.
4. Update to `TASKLIST_V4_FINAL.md`.
