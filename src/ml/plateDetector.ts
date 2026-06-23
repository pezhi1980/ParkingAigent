/**
 * License plate detector — wraps the on-device YOLOv8n model.
 *
 * On Android: TFLite model at src/ml/models/dk_plate.tflite
 * On iOS:     CoreML model at src/ml/models/dk_plate.mlmodel
 *
 * This module is called from the Vision Camera frame processor (worklet).
 * The actual TFLite/CoreML bridge is implemented in native modules
 * (see android/app/src/main/java/com/dkparking/PlateDetectorModule.kt
 *  and ios/DKParking/PlateDetectorModule.swift)
 */
import { Platform } from 'react-native';

export interface PlateDetection {
  /** Bounding box pixel width of the detected plate */
  pixelWidth: number;
  /** Bounding box pixel height of the detected plate */
  pixelHeight: number;
  /** X coordinate of bounding box center */
  centerX: number;
  /** Y coordinate of bounding box center */
  centerY: number;
  /** YOLO confidence score (0.0–1.0) */
  confidence: number;
  /** Camera focal length in pixels, read from device EXIF/Camera2 */
  focalLengthPx: number;
}

/**
 * Runs the YOLO model on a single camera frame.
 * Called inside a Vision Camera frame processor worklet.
 *
 * @param frame - Vision Camera Frame object
 * @returns PlateDetection if a plate was found with confidence > 0.4, else null
 */
export function detectPlate(frame: any): PlateDetection | null {
  'worklet';

  // In the actual build, this calls the native TFLite/CoreML module via JSI.
  // The native module returns: { x, y, width, height, confidence, focalLengthPx }
  //
  // For development/testing without a compiled model, return a mock:
  if (__DEV__) {
    return {
      pixelWidth: 180,
      pixelHeight: 38,
      centerX: frame.width / 2,
      centerY: frame.height * 0.4,
      confidence: 0.92,
      focalLengthPx: 1200,
    };
  }

  // Production: call native module
  // eslint-disable-next-line @typescript-eslint/no-var-requires
  const NativePlateDetector = require('../native/NativePlateDetector').default;
  const raw = NativePlateDetector.detect(frame);

  if (!raw || raw.confidence < 0.4) return null;

  return {
    pixelWidth: raw.width,
    pixelHeight: raw.height,
    centerX: raw.x + raw.width / 2,
    centerY: raw.y + raw.height / 2,
    confidence: raw.confidence,
    focalLengthPx: raw.focalLengthPx,
  };
}

/**
 * Returns the path to the bundled model file for the current platform.
 */
export function getModelPath(): string {
  return Platform.OS === 'ios'
    ? 'dk_plate.mlmodelc'
    : 'ml/dk_plate.tflite';
}
