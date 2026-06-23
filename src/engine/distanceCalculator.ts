import { DANISH_PLATE } from '../constants/plate';

/**
 * Calculates the raw distance from the camera to the front of the car
 * using the focal-length formula.
 *
 * Formula: Distance = (RealWidth_mm × FocalLength_px) / PixelWidth_px / 1000
 *
 * This gives distance in meters from camera to the front face of the license plate.
 * The plate is mounted on the front bumper, so this approximates the nose-to-camera distance.
 *
 * @param platePixelWidth - Width of the detected license plate bounding box in pixels
 * @param focalLengthPx   - Camera focal length in pixels (from device EXIF / Camera2 API)
 * @returns Raw distance in meters, or null if inputs are invalid
 */
export function calculateRawDistance(
  platePixelWidth: number,
  focalLengthPx: number,
): number | null {
  if (platePixelWidth <= 0 || focalLengthPx <= 0) {
    return null;
  }

  const distanceMeters =
    (DANISH_PLATE.WIDTH_MM * focalLengthPx) / platePixelWidth / 1000;

  // Sanity bounds: plate detection is only reliable between 2m and 30m
  if (distanceMeters < 1 || distanceMeters > 50) {
    return null;
  }

  return distanceMeters;
}
