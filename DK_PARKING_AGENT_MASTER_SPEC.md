DK PARKING AGENT MASTER SPEC
Denmark — Legal Parking Distance Engine
Version 1.0
Purpose: single-developer implementation reference
1. SYSTEM PURPOSE

This system determines whether a vehicle is illegally stopped or parked under the Danish distance-based parking and stopping rules that are relevant to intersections, pedestrian crossings, cycle-path exits, bus stops, and directly prohibited surfaces.

The system is not allowed to guess.
If the system cannot measure the legally relevant distance with enough certainty, it must return UNVERIFIABLE.

The system must be designed around the actual Danish legal structure in the road traffic law. Danish law defines “road” broadly and defines “intersection” broadly. In the official law, “road” includes road, street, cycle path, sidewalk, square, bridge, tunnel, passage, path, or similar, whether public or private; and “intersection” includes road intersection, road branching, and road emergence.

2. WHAT THIS FILE IS

This file is the highest-priority source of truth for the project.

This file defines:

what the app is legally trying to decide
which Danish rules must be enforced
what exactly must be measured
from where the 10 meters must be measured
how the measurement must be computed
when the system must refuse to answer
how outputs must be labeled

This file does not describe sprint order.
That remains the job of the roadmap.

3. LEGAL FOUNDATION

The core legal basis is the Danish Road Traffic Act, especially §28 and §29.

The official law states that stopping or parking must not take place on a pedestrian crossing, opposite a cycle-path exit, within 5 meters before a pedestrian crossing or the exit of a cycle path running along the carriageway, or within 5 meters on each side of the exit of a cycle path that crosses the carriageway. It also states that stopping or parking must not take place in an intersection or within 10 meters of the nearest edge of the crossing carriageway, or, where carriageway and cycle path emerge together, from the nearest edge of the cycle path. The same section also prohibits stopping or parking on a marked taxi stand, on certain lane-divider stretches before intersections, too close to a barrier line, in a bus-stop area, and in several other danger-related locations. Separately, §28 prohibits stopping or parking on a cycle path, footpath, sidewalk, median, refuge island, and similar places.

The official Copenhagen municipality page points users back to the same legal sources, which is useful as municipal confirmation but not a substitute for the statute itself.

4. SYSTEM SCOPE
4.1 Included in scope

The system must evaluate these rules:

pedestrian crossing rule
cycle-path exit rule
intersection 10-meter rule
bus-stop rule
direct prohibition on cycle path, sidewalk, footpath, median, refuge island, and similar places
driveway-access obstruction as a limited advisory rule
4.2 Not treated as fully automatable legal-clear output in version 1

These may be partially supported but must not be presented as high-certainty legal decisions unless the geometry is extremely clear:

“significantly hinders access” at driveways
hilltop / blind bend danger
sign obstruction
tram or light-rail obstruction
bridge / viaduct / tunnel without strong map confirmation
lane-divider edge cases where markings are not clearly visible

These remain real legal rules, but they are less reliable to automate from mobile capture alone. The law still contains them, so the product must not contradict them.

5. PRIMARY LEGAL QUESTION

The system must answer only this question:

Is any part of the vehicle illegally stopped or parked relative to a protected legal boundary or protected legal zone under the Danish rules listed in this file?

This means the system is not measuring the user, the phone, or an arbitrary ground point.

It is measuring the vehicle.

6. THE SINGLE MOST IMPORTANT RULE

The legal measurement must be:

the shortest ground-plane distance from the nearest point of the vehicle footprint boundary to the legally relevant protected boundary

This is the core rule for the whole app.

Not from:

phone position
camera origin
GPS point
vehicle center
center of intersection
map node center
road centerline

Only from:

vehicle footprint boundary
to
legal protected boundary
7. WHAT “VEHICLE FOOTPRINT” MEANS

Vehicle footprint means the outer ground-projected occupied shape of the vehicle.

For system purposes, it must be modeled as a closed 2D polygon on the road plane.

The legal measurement point is the nearest point on that polygon to the relevant protected boundary.

7.1 Minimum acceptable definition

The footprint must represent the actual parked vehicle body area on the ground plane closely enough that the nearest legal edge can be computed.

7.2 What is not acceptable

These are not acceptable substitutes:

GPS location of the phone
a single point at the middle of the car
front bumper only
rear bumper only
user-selected tap point
“estimated car position” without boundary geometry
7.3 Engineering priority

The system does not need perfect full-car reconstruction everywhere.
It needs the nearest boundary point in the risk direction to be accurate.

That is more important than total vehicle shape quality.

8. WHAT “LEGAL PROTECTED BOUNDARY” MEANS

A legal protected boundary is the exact geometric reference required by the relevant rule.

Different rules use different protected boundaries.

8.1 Intersection rule

The official law says the 10 meters must be measured from the nearest edge of the crossing carriageway, or, where the carriageway and cycle path emerge together, from the nearest edge of the cycle path.

8.2 Pedestrian crossing rule

The law prohibits stopping or parking on a pedestrian crossing and within 5 meters before it. The crossing itself is a protected prohibited zone, and the 5-meter approach line is a protected distance boundary.

8.3 Cycle-path exit rule

The law prohibits stopping or parking opposite the exit from a cycle path, within 5 meters before the exit of a cycle path that runs along the carriageway, and within 5 meters on each side of the exit of a cycle path that is transverse to the carriageway.

8.4 Bus stop rule

At a bus stop, stopping or parking is prohibited on the marked stretch on each side of the stop sign. If no such marking exists, the prohibition applies within 12 meters on each side of the sign.

8.5 Direct surface prohibitions

Under §28, the cycle path, sidewalk, footpath, median, refuge island, divider island, and similar locations are directly prohibited locations for stopping or parking, with a narrow exception outside built-up areas for some vehicles partly on sidewalk or divider.

9. EXACT ANSWER TO “FROM WHERE MUST THE 10 METERS BE MEASURED?”

The 10 meters must be measured:

from the nearest point of the parked vehicle’s footprint boundary on the ground plane
to the nearest legally relevant edge of the crossing carriageway
or, in the specific shared-emergence case described by the law,
to the nearest edge of the cycle path.

It must not be measured from:

center of the intersection
centerline of the road
corner of a painted area unless that paint corresponds to the legal edge
the user’s feet
the phone camera
a point manually guessed on-screen
9.1 Plain-language meaning

If a car is parked near a side road, the app must find:

the closest part of the parked car
the first legally relevant edge of the crossing road or cycle path
the shortest straight-line distance on the road plane between them

That is the legal distance for the 10-meter rule.

10. BEST PRACTICAL MEASUREMENT METHOD

The best production-safe measurement method is a five-part process.

Step 1 — determine the correct legal feature

The system must first determine which rule is active:

intersection
pedestrian crossing
cycle-path exit
bus stop
direct prohibited surface
driveway obstruction advisory
Step 2 — determine the correct geometric reference

The system must identify the exact protected boundary:

crossing carriageway edge
cycle-path edge
crossing polygon edge
bus-stop marked zone edge
bus-stop sign-based 12-meter curb-aligned zone
prohibited surface polygon edge
Step 3 — determine the vehicle footprint

The system must determine the car’s footprint polygon on the local ground plane.

Step 4 — compute the shortest 2D ground-plane distance

The system must compute the minimum Euclidean planar distance between:

the vehicle footprint boundary
and
the relevant protected boundary
Step 5 — apply uncertainty and decision policy

If uncertainty overlaps the legal threshold, the system must not claim a clear legal result.

11. FULL RULE SET THE SYSTEM MUST KNOW

This section lists the rules the agent must encode.

11.1 General danger rule

Stopping or parking must not occur at such a place or in such a way that danger or inconvenience to traffic arises. This is broader than the distance rules and remains a background legal rule. The app should not override it.

11.2 Side of road and placement direction

Stopping or parking must normally occur on the right side of the road in the direction of travel. On lightly trafficked roads and one-way roads, stopping or parking may occur on the left side. The vehicle must be placed in the road’s longitudinal direction at the outer edge of the carriageway or, if possible, outside it.

11.3 Direct prohibition on cycle path, footpath, sidewalk, median, refuge island, divider, and similar

Stopping or parking is not allowed on:

cycle path
footpath
sidewalk
central reservation
divider reservation
refuge island
similar places

There is a limited exception outside built-up areas for some vehicles under 3,500 kg partly on sidewalk or divider, and the direct prohibition does not apply in the same way to bicycles and two-wheeled mopeds. For a parking app focused on ordinary cars in urban Denmark, treat these areas as directly prohibited.

11.4 Pedestrian crossing rule

Stopping or parking is not allowed:

on a pedestrian crossing
within 5 meters before a pedestrian crossing

This is a direct statutory rule.

11.5 Cycle-path exit rule

Stopping or parking is not allowed:

opposite the exit from a cycle path
within 5 meters before the exit from a cycle path that runs along the carriageway
within 5 meters on each side of the exit from a cycle path that crosses the carriageway

This must be modeled exactly because the geometry differs between the parallel-running and transverse cases.

11.6 Intersection 10-meter rule

Stopping or parking is not allowed:

in an intersection
within 10 meters from the nearest edge of the crossing carriageway
or, where carriageway and cycle path emerge together, within 10 meters from the nearest edge of the cycle path

This is the main rule for your app.

11.7 Railway crossing and similar crossing

Stopping or parking is not allowed on a railway crossing or other crossing. Parking is also not allowed closer than 30 meters from a railway crossing.

11.8 Obstructing sign or signal

Stopping or parking is not allowed in such a way that a traffic sign or signal is covered.

11.9 Bridge over motorway, viaduct, tunnel

Stopping or parking is not allowed on a bridge over a motorway, in a viaduct, or in a tunnel.

11.10 Hilltop or blind bend

Stopping or parking is not allowed on or near a hilltop or in or near a blind bend.

11.11 Lane-divider stretch before intersection

Stopping or parking is not allowed on a stretch where the carriageway before an intersection is divided into lanes by barrier lines, or within 5 meters before the start of that stretch.

11.12 Too close to barrier line

Stopping or parking is not allowed beside a barrier line if the distance between the vehicle and the line is less than 3 meters and there is no dotted line between the vehicle and the barrier line.

11.13 Crawl lane

Stopping or parking is not allowed in a crawl lane.

11.14 Taxi stand

Stopping or parking is not allowed on a marked taxi stand.

11.15 Light rail obstruction

Stopping or parking is not allowed if it hinders the movement of a light-rail vehicle.

11.16 Bus stop

At a bus stop, stopping or parking is prohibited on the marked stretch on each side of the stop sign. If there is no such marking, the rule applies within 12 meters on each side of the sign.

11.17 Driveway rule

Parking is not allowed opposite entrances or exits to or from property, or otherwise where driving to or from property is substantially hindered. This is legally real but partly contextual, so it should be treated as advisory-first unless the geometry is unmistakable.

11.18 Double parking / blocking another vehicle

Parking is not allowed beside another vehicle parked at the edge of the carriageway, except certain two-wheeled cases, and parking is not allowed in a way that blocks access to another vehicle or prevents it from leaving.

12. LEGAL THRESHOLDS

These thresholds must not be changed.

pedestrian crossing approach: 5.0 meters
cycle-path exit approach: 5.0 meters
intersection rule: 10.0 meters
bus stop without markings: 12.0 meters
parking near railway crossing: 30.0 meters
barrier line side clearance rule: 3.0 meters
lane-divider pre-zone before intersection: 5.0 meters

These are legal thresholds, not product preferences.

13. INTERSECTION MODEL

The system must not reduce “intersection” to a simple four-way crossing.

Under the official Danish definition, an intersection includes:

a standard crossing
a road branch
a road emergence

The law defines “vejkryds” this way directly.

13.1 Minimum intersection types the system must support
4-way intersection
T-intersection
Y-intersection
side-road emergence
branching road
offset junction
cycle-path plus carriageway shared emergence case
13.2 Legal intersection area

The system must model the legal intersection area as a polygon formed by the union of the intersecting legal road spaces that meet at the junction.

A car is illegal if any part of its footprint lies inside that legal intersection area, even before the 10-meter buffer rule is applied.

14. CROSSING AND CYCLE-PATH GEOMETRY MODEL
14.1 Pedestrian crossing

The system must represent the pedestrian crossing as a polygon, not just a centerline.

The system must separately represent the “5 meters before the crossing” boundary in the travel approach direction.

14.2 Cycle-path exit along the carriageway

The system must identify the exit point and define a protected 5-meter zone before the exit.

14.3 Cycle-path exit crossing the carriageway

The system must identify the crossing exit line and define a protected 5-meter zone on each side.

14.4 Carriageway plus cycle path emerging together

Where the carriageway and cycle path emerge together, the system must use the cycle-path edge when that is the statutory reference for the 10-meter rule.

15. BUS STOP MODEL
15.1 Marked bus stop

If there is a marked stopping restriction around the bus-stop sign, the marked stretch itself is the prohibited zone.

15.2 Unmarked bus stop

If there is no such marking, the prohibited zone is 12 meters on each side of the sign, measured along the curb-aligned road edge.

15.3 Modeling rule

The bus-stop sign must be treated as a fixed legal anchor.
The 12-meter no-stop/no-park zone must follow curb direction, not radial distance in all directions.

16. DRIVEWAY MODEL

The driveway rule is legally real but only partly objective.

The law prohibits parking opposite an entrance or exit to property or otherwise in a way that substantially hinders access.

16.1 Product rule

Driveway violation may be classified as:

PROBABLY_ILLEGAL
UNVERIFIABLE
ADVISORY_RISK

but should not be promoted to a fully certain legal-clear output unless both the driveway opening and the effective hindrance are very clear.

16.2 Why

The phrase “substantially hinders” is context-dependent and not fully reducible to simple geometry in all cases.

17. CANONICAL DISTANCE FORMULA

The canonical legal distance is:

minimum 2D Euclidean ground-plane distance between the vehicle footprint boundary and the legally relevant protected boundary

This formula applies to all distance-based rules.

If the vehicle footprint overlaps the prohibited zone, the legal distance is treated as zero and the output must be illegal or probably illegal depending on confidence.

18. COORDINATE SYSTEM

All legal measurements must be made in a local ground-plane coordinate system.

The system must not use raw GPS coordinates directly as the legal measuring space.

GPS may only be used for coarse candidate selection.

The final legal distance must be computed in a local calibrated metric plane derived from sensor fusion.

19. REQUIRED SENSOR LOGIC
19.1 GPS role

GPS is only for candidate selection.

It may be used to find nearby intersections, crossings, bus stops, and cycle-path exits.

It must never be the sole basis for legal measurement.

19.2 IMU role

The IMU provides pose continuity, motion stability, and helps maintain local alignment.

19.3 Camera and AR role

The camera and AR or equivalent visual-inertial system provide:

local ground plane
camera pose
relative metric geometry
vehicle boundary localization
road-edge localization
19.4 Map role

The offline map provides:

candidate legal features
topological context
road class
road arrangement
bus-stop location
likely cycle-path layout
likely intersection class

The map does not automatically provide legal certainty.
Map uncertainty must always be included in total error.

20. MAP ACCURACY RULE

Map uncertainty is a real production risk.

If the road edge, cycle-path edge, or bus-stop geometry is inaccurate or low-confidence, the system must increase total error and downgrade the decision.

20.1 Mandatory rule

If map edge quality is unknown, uncertain, or inconsistent with camera evidence, map uncertainty must be included in total error.

20.2 Mandatory consequence

If total error overlaps a legal threshold, return UNVERIFIABLE.

20.3 Never do this

The system must never output a confident legal judgment based on map geometry alone when the map edge location is uncertain.

21. INTERSECTION SELECTION RULE

Choosing the wrong intersection is a critical failure.

Therefore the system must not assume that the nearest map intersection is automatically the correct one.

21.1 Mandatory rule

The system must use multi-hypothesis candidate matching for nearby intersections and protected features.

21.2 Required behavior

If multiple candidate intersections or legal features fit the GPS and visual evidence similarly well, the system must return UNVERIFIABLE.

21.3 Reason

A perfect distance to the wrong intersection is still a wrong legal answer.

22. VEHICLE FOOTPRINT PRIORITY RULE

Vehicle segmentation quality alone is not enough.

The key technical target is accurate localization of the nearest vehicle boundary point in the risk direction.

22.1 Mandatory priority

Nearest-edge accuracy is more important than full-car silhouette beauty.

22.2 Failure consequence

If the near-side boundary of the vehicle cannot be localized reliably, the system must return UNVERIFIABLE.

23. CONFIDENCE MODEL

The system must produce a confidence model that combines at least:

vehicle detection confidence
vehicle segmentation confidence
nearest vehicle edge confidence
ground-plane stability
camera pose stability
map-match confidence
intersection or feature classification confidence
road-edge or cycle-edge localization confidence
weather / rain penalty
low-light penalty
occlusion penalty
motion blur penalty
map geometry uncertainty
23.1 Hard refusal rule

If uncertainty overlaps the legal threshold, do not answer with a clear legal result.

23.2 Hard refusal cases

Return UNVERIFIABLE if:

vehicle is not clearly localized
nearest vehicle edge is unstable
ground plane is unstable
legal boundary is uncertain
intersection candidate is ambiguous
occlusion hides the relevant near-side vehicle edge
low light or blur prevents reliable edge localization
map and vision disagree materially
24. DECISION STATES

Use these decision states:

ILLEGAL
PROBABLY_ILLEGAL
UNVERIFIABLE
PROBABLY_LEGAL
LEGAL_WITH_BUFFER
24.1 Meaning of each state

ILLEGAL
Use only when the measurement clearly violates the rule and the confidence interval remains on the illegal side.

PROBABLY_ILLEGAL
Use when the best estimate violates the rule, but uncertainty is still too large for full certainty.

UNVERIFIABLE
Use when the system cannot safely determine legality.

PROBABLY_LEGAL
Use when the best estimate is outside the prohibited zone, but the safety margin above the threshold is limited.

LEGAL_WITH_BUFFER
Use only when the vehicle is beyond the legal threshold by more than the configured safety reserve.

25. LEGAL THRESHOLD VS SAFETY BUFFER

The law must remain unchanged.

The system may use an internal safety buffer for confidence labeling, but that buffer must never replace the law.

25.1 Example policy
legal threshold for intersection remains 10.0 m
internal reserve may be used to decide whether to show PROBABLY_LEGAL or LEGAL_WITH_BUFFER
25.2 Prohibited behavior

Do not convert the law into “14 meters is illegal” or any similar product rewrite.

A larger internal reserve is allowed only for confidence classification, not for redefining legality.

26. OUTPUT CONTRACT

Every result must include:

rule_type
state
measured_distance_m
legal_threshold_m
estimated_total_error_m
confidence_score
reference_boundary_type
vehicle_reference_definition
reason
capture_quality
map_version
notes
26.1 Example semantics

rule_type: INTERSECTION_10M
reference_boundary_type: NEAREST_EDGE_OF_CROSSING_CARRIAGEWAY
vehicle_reference_definition: NEAREST_POINT_OF_VEHICLE_FOOTPRINT_BOUNDARY_ON_GROUND_PLANE

27. USER-FACING TEXT POLICY

The app must never say “definitely legal” unless the state is LEGAL_WITH_BUFFER.

Recommended wording:

ILLEGAL: Vehicle appears to violate the Danish stopping or parking rule.
PROBABLY_ILLEGAL: Vehicle likely violates the rule, but measurement uncertainty remains.
UNVERIFIABLE: The app cannot safely verify legality from this capture.
PROBABLY_LEGAL: Vehicle appears outside the restricted zone, but the safety margin is limited.
LEGAL_WITH_BUFFER: Vehicle appears outside the legal restricted zone with safety margin.
28. REQUIRED FEATURE DETECTION LIST

The system must be able to detect or infer, depending on rule:

vehicle footprint
local ground plane
road edge
cycle-path edge
pedestrian crossing polygon
cycle-path exit geometry
intersection polygon
bus-stop sign
bus-stop markings if present
direct prohibited surfaces such as cycle path or sidewalk
driveway opening where applicable

Without vehicle footprint and legal edge localization, the system is incomplete.

29. REQUIRED MAP DATA LIST

The offline dataset should contain at minimum:

road centerlines
road classes
road directionality
cycleway geometry where available
bus-stop locations
likely pedestrian crossing locations where available
intersection candidates
width priors or edge priors
feature confidence metadata
dataset version
29.1 Important map rule

The map is a prior, not final truth.

If the map lacks reliable curb or legal-edge geometry, the app must rely more heavily on local vision and must be more willing to return UNVERIFIABLE.

30. PROCESSING MODE

Processing should be burst-based, not continuous forever.

30.1 Reason

A continuously running perception stack on mobile creates:

heat buildup
battery drain
thermal throttling
degraded stability over time
30.2 Product rule

Preferred interaction:

user aims camera
system locks ground plane and target geometry
system captures a short stable window
system computes
system returns result
system stops heavy analysis
31. MINIMUM ACCEPTANCE CONDITIONS BEFORE SHOWING A RESULT

Before a result may be shown, the system must have:

stable local ground plane
stable camera pose
stable vehicle footprint estimate
stable legal feature match
stable legal boundary estimate
total uncertainty computed
threshold-overlap checked

If any of these are missing, return UNVERIFIABLE.

32. DETAILED RULE LOGIC
32.1 Pedestrian crossing logic

Illegal if:

any part of the vehicle footprint overlaps the crossing polygon
the nearest point of the vehicle footprint lies within 5.0 meters before the crossing in the relevant approach direction

The system must interpret “before the crossing” directionally, not as a circular radius around the crossing.

32.2 Cycle-path exit logic

Illegal if:

the footprint is opposite the cycle-path exit where the law applies
the footprint is within 5.0 meters before the exit where the cycle path runs along the carriageway
the footprint is within 5.0 meters on each side of the exit where the cycle path is transverse to the carriageway

These are different geometries and must not be merged into one vague rule.

32.3 Intersection logic

Illegal if:

any part of the footprint lies inside the legal intersection polygon
or the measured distance to the legally relevant nearest edge is less than 10.0 meters

Where the carriageway and cycle path emerge together, the system must use the cycle-path edge if that is the statutory reference in the observed geometry.

32.4 Bus-stop logic

Illegal if:

the footprint overlaps the marked restricted bus-stop stretch
or, when unmarked, the footprint lies within 12.0 meters on either side of the stop sign along the curb-aligned legal edge
32.5 Direct prohibited surface logic

Illegal if the footprint overlaps a cycle path, sidewalk, footpath, refuge island, median, divider island, or similar prohibited surface.

32.6 Driveway advisory logic

Potentially illegal if:

the vehicle is parked opposite a driveway opening
and the placement materially obstructs access

If geometry is not clear enough, downgrade to UNVERIFIABLE or advisory wording.

33. THINGS THE SYSTEM MUST NEVER DO

The system must never:

measure from the phone instead of the vehicle
measure from the center of the intersection
use GPS alone for legal distance
replace road edges with road centerlines for final legal output
output confident legal judgments when map uncertainty is unknown
ignore uncertainty overlap with the legal threshold
treat a product safety margin as if it were the law
assume the nearest intersection is automatically the correct one
guess driveway obstruction from weak evidence
give a green result when near-threshold evidence is weak
34. TESTING REQUIREMENTS

The system must be tested on at least these situations:

4-way intersection
T-intersection
Y-intersection
side-road emergence
cycle path adjacent to side road
shared carriageway + cycle-path emergence
marked pedestrian crossing
cycle-path exit running along carriageway
transverse cycle-path exit
marked bus stop
unmarked bus stop
car partially on sidewalk
car partly on cycle path
driveway opposite parking
rain
night
blur
heavy occlusion
dense urban GPS error
multiple nearby intersections
low-end phone thermal stress
34.1 What each test must record
true legal rule
true legal boundary
true ground truth distance
measured distance
estimated total error
selected rule type
selected feature candidate
returned state
whether the system should have refused
35. SINGLE-DEVELOPER BUILD PRIORITY

Because this is a solo project, build in this order:

Phase A — legal geometry foundation

Get these correct first:

vehicle footprint definition
protected boundary definition
distance formula
state logic
threshold logic
uncertainty overlap rule
Phase B — rule coverage

Implement these first:

intersection 10m
pedestrian crossing 5m
cycle-path exit 5m
direct prohibited surface
bus stop 12m
Phase C — hardening

Then add:

multi-hypothesis intersection selection
map uncertainty integration
burst-mode performance behavior
driveway advisory support
36. FINAL SYSTEM PRINCIPLES

The system must follow these principles at all times:

The law is fixed.
The vehicle is the thing being measured.
The measurement starts at the nearest point of the vehicle footprint.
The measurement ends at the correct legal protected boundary.
The shortest ground-plane distance is the legal metric.
GPS is only for candidate selection.
Map uncertainty must be included in total error.
The wrong intersection means the wrong answer.
If uncertainty overlaps the legal threshold, the system must refuse to decide.
No guessing.
37. FINAL ONE-PARAGRAPH RULE

For this app, every legal parking distance decision must be computed as the shortest distance on the calibrated ground plane from the nearest point of the parked vehicle’s footprint boundary to the correct legally protected boundary for the active Danish rule. For intersections, that means the nearest edge of the crossing carriageway, or, where carriageway and cycle path emerge together, the nearest edge of the cycle path; for pedestrian crossings and cycle-path exits, it means the correct 5-meter protected boundary or prohibited polygon; for unmarked bus stops, it means 12 meters on each side of the stop sign along the curb-aligned boundary. If the system cannot localize the vehicle boundary, the correct legal edge, or the correct feature candidate with enough confidence, it must return UNVERIFIABLE.