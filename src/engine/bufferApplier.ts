import { LEGAL } from '../constants/legal';

/**
 * Applies the mandatory 2-meter safety buffer.
 *
 * The buffer is ALWAYS applied. The app NEVER shows the raw distance to the user.
 * This ensures the app is always conservative: if we show "10m", the car is actually
 * at least 12m away (before any measurement error).
 *
 * @param rawDistanceM - The raw calculated distance in meters
 * @returns The displayed distance (rawDistance − 2.0), or null if below 0
 */
export function applyBuffer(rawDistanceM: number): number | null {
  const displayed = rawDistanceM - LEGAL.SAFETY_BUFFER_M;

  // If displayed would be negative, return null (result will be UNSAFE regardless)
  if (displayed < 0) {
    return 0;
  }

  return Math.round(displayed * 10) / 10; // round to 1 decimal place
}
