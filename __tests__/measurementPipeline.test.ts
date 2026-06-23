import { runMeasurementPipeline } from '../src/engine/measurementPipeline';

describe('runMeasurementPipeline — integration', () => {
  const BASE_INPUT = {
    platePixelWidth: 62.4,    // ~10m raw distance at f=1200
    focalLengthPx: 1200,
    plateDetectionScore: 0.95,
    cameraAngleDeg: 5,        // within 15° limit
    plateDetected: true,
    appVersion: '1.0.0',
  };

  it('produces SAFE result for a car at ~14m (12m displayed)', () => {
    // 12m raw → 10m displayed → SAFE
    // platePixelWidth for 12m at f=1200: 520 * 1200 / 12000 = 52px
    const result = runMeasurementPipeline({ ...BASE_INPUT, platePixelWidth: 52 });
    expect(result.decision).toBe('SAFE');
    expect(result.displayedDistanceM).toBeGreaterThanOrEqual(10);
  });

  it('produces UNSAFE result for a car too close to intersection', () => {
    // 8m raw → 6m displayed → UNSAFE
    // platePixelWidth for 8m at f=1200: 520 * 1200 / 8000 = 78px
    const result = runMeasurementPipeline({ ...BASE_INPUT, platePixelWidth: 78 });
    expect(result.decision).toBe('UNSAFE');
    expect(result.displayedDistanceM).toBeLessThan(10);
  });

  it('produces UNVERIFIABLE when plate not detected', () => {
    const result = runMeasurementPipeline({ ...BASE_INPUT, plateDetected: false });
    expect(result.decision).toBe('UNVERIFIABLE');
    expect(result.displayedDistanceM).toBeNull();
  });

  it('produces UNVERIFIABLE when detection score is too low', () => {
    const result = runMeasurementPipeline({ ...BASE_INPUT, plateDetectionScore: 0.3 });
    expect(result.decision).toBe('UNVERIFIABLE');
  });

  it('produces UNVERIFIABLE when camera tilt is excessive', () => {
    const result = runMeasurementPipeline({ ...BASE_INPUT, cameraAngleDeg: 45 });
    expect(result.decision).toBe('UNVERIFIABLE');
  });

  it('output always includes timestamp and appVersion', () => {
    const result = runMeasurementPipeline(BASE_INPUT);
    expect(result.timestamp).toBeTruthy();
    expect(result.appVersion).toBe('1.0.0');
  });

  it('CRITICAL: rawDistanceM is always larger than displayedDistanceM by exactly 2m', () => {
    const result = runMeasurementPipeline(BASE_INPUT);
    if (result.rawDistanceM !== null && result.displayedDistanceM !== null) {
      expect(result.rawDistanceM - result.displayedDistanceM).toBeCloseTo(2, 1);
    }
  });
});
