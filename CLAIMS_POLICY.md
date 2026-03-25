# CLAIMS POLICY — DK PARKING ENGINE
## Version 1 — Phase 0 foundation document
## Status: IN_PROGRESS
## Locked baseline date: 2026-03-25

## 1. Purpose
This document prevents overclaiming.
It defines what the product may claim, must claim, and must not claim.

## 2. Allowed high-level product claim (only within supported scope)
Allowed claim (template):
"The system evaluates supported Danish stopping and parking rules defined in this specification using on-device sensing, deterministic geometry, versioned map priors, and refusal-safe confidence logic."

## 3. Prohibited claims (must not)
The product MUST NOT claim:
- that it determines full Denmark parking legality under all rules
- that it overrides signs, temporary controls, permits, payments, local rules, private rules, or enforcement discretion
- that it provides final legal advice
- that a positive result guarantees no fine
- that it can answer when evidence is materially incomplete

## 4. Required limitations (must)
All user-facing results and marketing surfaces MUST include (or clearly link to) limitations stating:
- only supported rule families were evaluated
- visible unsupported restrictions may exist and can prevent clean clearance
- results do not override signs/temporary controls
- refusal is correct behavior when evidence is insufficient

## 5. Positive-result caveat (mandatory)
Even `LEGAL_WITH_BUFFER` applies only to the evaluated supported rule family/families.
It MUST NOT be presented as universal clearance.

## 6. Negative-result caveat (mandatory)
Negative states (`ILLEGAL`, `PROBABLY_ILLEGAL`) apply only within supported scope and based on the evaluated evidence.
They MUST NOT be presented as comprehensive legal advice.

## 7. Refusal copy obligations (mandatory)
When the engine returns `UNVERIFIABLE`:
- the app MUST state that evidence was insufficient for a safe supported evaluation
- the app MUST provide retry guidance when possible
- the app MUST avoid implying user error as the only cause

## 8. Unsupported visible restriction behavior (mandatory)
If an unsupported visible restriction is detected or suspected:
- the product MUST NOT present clean clearance
- the product MUST disclose the unsupported restriction risk

## 9. Change control
Any change to claims language, limitations language, or decision-state meanings requires:
- update to this file
- update to SCOPE_AND_LIMITATIONS.md and DECISION_STATES.md
- log in WHAT_DID_I_DO.md
- update blockers/next steps in TASKLIST_V4_FINAL.md
