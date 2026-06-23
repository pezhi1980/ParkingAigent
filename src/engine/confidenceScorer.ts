import { LEGAL } from '../constants/legal';

export interface ConfidenceInput {
  /** YOLO detection confidence score for the plate bounding box (0.0–1.0) */
  plateDetectionScore: number;
  /** Camera tilt angle in degrees (0 = perfectly horizontal) */
  cameraAngleDeg: number;
  /** Plate pixel width. Below ~20px → unreliable. Above ~800px → too close. */
  platePixelWidth: number;
}

/**
 * Computes a composite confidence score (0.0–1.0) for the measurement.
 *
 * Score factors:
 *  - Plate detection confidence from YOLO (weight: 60%)
 *  - Camera angle penalty (weight: 25%)
 *  - Plate size plausibility (weight: 15%)
 *
 * Score < MIN_CONFIDENCE_SCORE → decision state = UNVERIFIABLE
 */
export function computeConfidence(input: ConfidenceInput): number {
  const { plateDetectionScore, cameraAngleDeg, platePixelWidth } = input;

  // 1. YOLO detection confidence (0–1) → weighted 60%
  const detectionFactor = Math.min(Math.max(plateDetectionScore, 0), 1) * 0.6;

  // 2. Angle penalty: 0° = perfect (1.0), 15°+ = minimum (0.0)
  const angleRatio = Math.max(0, 1 - cameraAngleDeg / LEGAL.MAX_TILT_ANGLE_DEG);
  const angleFactor = angleRatio * 0.25;

  // 3. Plate size plausibility: ideal 50–400px wide → score 1.0; outside → drops
  let sizeFactor = 0;
  if (platePixelWidth >= 20 && platePixelWidth <= 800) {
    // Gaussian-ish peak around 150px
    const normalizedPx = platePixelWidth / 200;
    sizeFactor = Math.min(1, Math.exp(-Math.pow(normalizedPx - 1, 2) * 0.5) + 0.5) * 0.15;
  }

  const composite = detectionFactor + angleFactor + sizeFactor;
  return Math.round(Math.min(Math.max(composite, 0), 1) * 100) / 100;
}

/** Returns true if confidence meets the legal minimum threshold */
export function isConfidenceSufficient(score: number): boolean {
  return score >= LEGAL.MIN_CONFIDENCE_SCORE;
}
