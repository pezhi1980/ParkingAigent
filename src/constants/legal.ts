/**
 * Danish parking law thresholds.
 * Source: Færdselsloven § 28 + Vejregler for parkering
 * Verified against LEGAL_THRESHOLDS.md and LEGAL_SOURCE_REGISTER.md
 */
export const LEGAL = {
  /**
   * Minimum distance from the nearest edge of an intersecting road.
   * Cars must be parked at least 10m away — measured from the curb boundary.
   */
  MIN_INTERSECTION_DISTANCE_M: 10,

  /**
   * Minimum distance from fire hydrants and bus stops.
   */
  MIN_HYDRANT_BUS_DISTANCE_M: 5,

  /**
   * Safety buffer always subtracted before displaying result to user.
   * Ensures the app is always conservative (never tells user they're safe when they're not).
   * displayedDistance = rawDistance - SAFETY_BUFFER_M
   */
  SAFETY_BUFFER_M: 2,

  /**
   * The actual measured threshold before applying the buffer.
   * App must measure ≥12m to display ≥10m to user.
   */
  EFFECTIVE_MEASUREMENT_THRESHOLD_M: 12, // 10m + 2m buffer

  /**
   * Minimum ML confidence score required to return SAFE or UNSAFE.
   * Below this → UNVERIFIABLE.
   */
  MIN_CONFIDENCE_SCORE: 0.75,

  /**
   * Maximum camera tilt angle before warning user to hold phone straighter.
   * Beyond this angle the perspective distortion causes distance error > 0.5m.
   */
  MAX_TILT_ANGLE_DEG: 15,
} as const;

/**
 * Legal disclaimer text. Ready for use in DisclaimerScreen.
 * Source: user_disclosures_and_copy.md
 */
export const DISCLAIMER_TEXT = {
  DA: `Denne app er et hjælpeværktøj og erstatter ikke din egen vurdering. Målingerne er vejledende og kan være unøjagtige afhængigt af kameravinkel, lysforhold og køretøjstype. Appen garanterer ikke, at du undgår parkeringsbøder. Brug altid din egen dømmekraft og overhold gældende færdselsregler.`,
  EN: `This app is a guidance tool and does not replace your own judgment. Measurements are indicative and may be inaccurate depending on camera angle, lighting conditions, and vehicle type. The app does not guarantee you will avoid parking fines. Always use your own judgment and comply with applicable traffic regulations.`,
} as const;
