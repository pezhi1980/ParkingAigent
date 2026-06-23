/**
 * The complete measurement pipeline.
 * Orchestrates: distance calc → buffer → confidence → decision → output
 *
 * This is the single entry point called by the UI after plate detection.
 */
import { calculateRawDistance } from './distanceCalculator';
import { applyBuffer } from './bufferApplier';
import { computeConfidence, ConfidenceInput } from './confidenceScorer';
import { resolveDecision } from './decisionResolver';
import { formatOutput, MeasurementResult } from './outputFormatter';

export interface PipelineInput {
  /** Width of license plate bounding box in pixels */
  platePixelWidth: number;
  /** Camera focal length in pixels */
  focalLengthPx: number;
  /** YOLO model's detection confidence (0.0–1.0) */
  plateDetectionScore: number;
  /** Camera tilt angle in degrees */
  cameraAngleDeg: number;
  /** Whether plate was detected at all */
  plateDetected: boolean;
  /** App version for logging */
  appVersion: string;
}

export function runMeasurementPipeline(input: PipelineInput): MeasurementResult {
  const {
    platePixelWidth,
    focalLengthPx,
    plateDetectionScore,
    cameraAngleDeg,
    plateDetected,
    appVersion,
  } = input;

  // Step 1: Calculate raw distance
  const rawDistanceM = plateDetected
    ? calculateRawDistance(platePixelWidth, focalLengthPx)
    : null;

  // Step 2: Apply 2m safety buffer
  const displayedDistanceM = rawDistanceM !== null ? applyBuffer(rawDistanceM) : null;

  // Step 3: Compute confidence score
  const confidenceInput: ConfidenceInput = {
    plateDetectionScore,
    cameraAngleDeg,
    platePixelWidth,
  };
  const confidenceScore = computeConfidence(confidenceInput);

  // Step 4: Resolve decision state
  const decision = resolveDecision({
    displayedDistanceM,
    confidenceScore,
    plateDetected,
  });

  // Step 5: Format final output
  return formatOutput({
    decision,
    displayedDistanceM,
    rawDistanceM,
    confidenceScore,
    plateDetected,
    cameraAngleDeg,
    appVersion,
  });
}
