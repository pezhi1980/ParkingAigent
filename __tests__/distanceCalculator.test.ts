import { calculateRawDistance } from '../src/engine/distanceCalculator';

describe('calculateRawDistance', () => {
  // Formula: D = (520mm × focalPx) / platePx / 1000
  // At 10m with 1200px focal: 520 × 1200 / platePx / 1000 = 10
  //   → platePx = 520 × 1200 / (10 × 1000) = 62.4

  const FOCAL = 1200; // px — typical smartphone

  it('returns ~10m for a plate ~62px wide at f=1200', () => {
    const result = calculateRawDistance(62.4, FOCAL);
    expect(result).not.toBeNull();
    expect(result!).toBeCloseTo(10, 1);
  });

  it('returns ~5m for a plate ~125px wide at f=1200', () => {
    const result = calculateRawDistance(124.8, FOCAL);
    expect(result).not.toBeNull();
    expect(result!).toBeCloseTo(5, 1);
  });

  it('returns ~15m for a plate ~41.6px wide at f=1200', () => {
    const result = calculateRawDistance(41.6, FOCAL);
    expect(result).not.toBeNull();
    expect(result!).toBeCloseTo(15, 1);
  });

  it('returns null for zero plate width', () => {
    expect(calculateRawDistance(0, FOCAL)).toBeNull();
  });

  it('returns null for negative plate width', () => {
    expect(calculateRawDistance(-10, FOCAL)).toBeNull();
  });

  it('returns null for zero focal length', () => {
    expect(calculateRawDistance(100, 0)).toBeNull();
  });

  it('returns null for unrealistically large distance (>50m)', () => {
    // Very tiny plate → huge distance
    expect(calculateRawDistance(1, FOCAL)).toBeNull();
  });

  it('returns null for unrealistically small distance (<1m)', () => {
    // Very large plate → tiny distance
    expect(calculateRawDistance(10000, FOCAL)).toBeNull();
  });
});
