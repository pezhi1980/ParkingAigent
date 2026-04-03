# CLAIMS POLICY — DK PARKING ENGINE
## Version 1 — Phase 0 foundation document
## Status: DONE
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

## 9. Formal claim matrix (locked)

| # | Claim Type | Allowed / Forbidden / Required | Claim Text or Rule |
|---|---|---|---|
| C-001 | Product capability | ALLOWED | "Evaluates supported Danish stopping and parking rules using on-device geometry and a versioned region dataset." |
| C-002 | Positive result (specific rule) | ALLOWED | "The evaluated vehicle footprint appears to comply with the [rule family name] restriction within the active evaluation scope." |
| C-003 | Negative result (specific rule) | ALLOWED | "The evaluated vehicle footprint appears to violate the [rule family name] restriction based on available evidence." |
| C-004 | Refusal | ALLOWED | "The system could not safely evaluate this scene. [reason]. Please retry." |
| C-005 | Limitation notice | REQUIRED | "Only [rule family] was evaluated. Other restrictions may apply." |
| C-006 | Version reference | REQUIRED | Every result must reference dataset version, model version, and policy version. |
| C-007 | Universal legality | FORBIDDEN | "This location is legal/safe to park." (without explicit rule-family qualification) |
| C-008 | Full legal advice | FORBIDDEN | "You will not receive a fine." or any guarantee of enforcement outcome. |
| C-009 | Sign override | FORBIDDEN | Any claim that the result overrides visible signs, temporary controls, or permits. |
| C-010 | Certainty from incomplete evidence | FORBIDDEN | Presenting PROBABLY_ILLEGAL or PROBABLY_LEGAL as a definitive result. |
| C-011 | Advisory as hard legal | FORBIDDEN | Presenting driveway obstruction advisory as a hard legal finding. |
| C-012 | Unsupported restriction suppression | FORBIDDEN | Presenting a positive result when a visible unsupported restriction materially affects clearance. |
| C-013 | Scope beyond supported families | FORBIDDEN | Implying the system evaluates rules outside the supported V1 family set. |

## 10. Change control
Any change to claims language, limitations language, or decision-state meanings requires:
- update to this file
- update to SCOPE_AND_LIMITATIONS.md and DECISION_STATES.md
- log in WHAT_DID_I_DO.md
- update blockers/next steps in TASKLIST_V4_FINAL.md

---

## 11. Phase 13 — Locked public-facing claims (App Store and marketing)

These claims are locked for Version 1 public launch. Any deviation requires formal change control (section 10).

### 11.1 Allowed App Store claims (locked)

| Surface | Locked text |
|---|---|
| Short description | "Evaluates specific Danish stopping and parking rules near pedestrian crossings, cycle-path exits, intersections, and bus stops using on-device AR measurement. Supported rules only. Not legal advice." |
| Limitations paragraph | "This app evaluates only specific supported Danish stopping and parking rules in covered regions. It does not evaluate all parking rules, signs, or time-limited restrictions. Results are not legal advice and do not guarantee you will not receive a fine. Always check visible signs and markings." |
| FAQ: What does this app evaluate? | "The app evaluates specific Danish stopping and parking rules that are suitable for measurement — such as the 5-metre rule near pedestrian crossings. It does not evaluate all parking rules and cannot read time-limited signs, permits, or markings it cannot detect." |
| FAQ: Is this legal advice? | "No. This app is a parking guidance tool only. It evaluates specific supported rules using on-device measurement. Results do not constitute legal advice and do not guarantee any enforcement outcome. Always follow all visible signs and road markings." |

### 11.2 Forbidden App Store claims (locked)

The following phrases are FORBIDDEN from any public-facing surface at launch:

- "Tells you if you can park"
- "Checks if parking is legal"
- "Guarantees no fine"
- "Full parking legality"
- "All parking rules"
- "Legal parking checker"
- Any phrasing implying universal coverage of Danish parking law
- Any phrasing implying the app replaces reading signs

### 11.3 Press and social media claim guardrails

Any press release, social media post, or public communication about this product MUST:
- Reference "specific supported rules" — not "parking rules" generally
- Include a limitations qualifier in any claim about what the product does
- NOT use the phrase "tells you if you can park" without explicit rule-family qualification
- Reference "on-device" to make clear no cloud AI is making the legal determination

### 11.4 Launch region public claim (locked)

"Available for Copenhagen city centre. Coverage will expand over time."

MUST NOT claim: "Available in Denmark" or "Available across Copenhagen" until coverage is verified to match that claim.
