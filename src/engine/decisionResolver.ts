import { LEGAL } from '../constants/legal';
import { isConfidenceSufficient } from './confidenceScorer';

export type DecisionState = 'SAFE' | 'UNSAFE' | 'UNVERIFIABLE' | 'MEASURING';

export interface DecisionInput {
  /** Displayed distance (after 2m buffer applied), in meters. Null if calculation failed. */
  displayedDistanceM: number | null;
  /** Composite confidence score (0.0–1.0) */
  confidenceScore: number;
  /** True if the YOLO model successfully detected a plate bounding box */
  plateDetected: boolean;
}

/**
 * Maps measurement inputs to a final decision state.
 *
 * Decision tree (in order of priority):
 * 1. No plate detected → UNVERIFIABLE
 * 2. Confidence below threshold → UNVERIFIABLE
 * 3. Distance null (calc error) → UNVERIFIABLE
 * 4. Displayed distance >= 10m → SAFE
 * 5. Else → UNSAFE
 *
 * This is the core business logic gate. Nothing outside this function
 * should make safety decisions.
 */
export function resolveDecision(input: DecisionInput): DecisionState {
  const { displayedDistanceM, confidenceScore, plateDetected } = input;

  if (!plateDetected) {
    return 'UNVERIFIABLE';
  }

  if (!isConfidenceSufficient(confidenceScore)) {
    return 'UNVERIFIABLE';
  }

  if (displayedDistanceM === null) {
    return 'UNVERIFIABLE';
  }

  if (displayedDistanceM >= LEGAL.MIN_INTERSECTION_DISTANCE_M) {
    return 'SAFE';
  }

  return 'UNSAFE';
}
