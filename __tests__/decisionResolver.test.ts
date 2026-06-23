import { resolveDecision } from '../src/engine/decisionResolver';

describe('resolveDecision', () => {
  const HIGH_CONFIDENCE = 0.9;
  const LOW_CONFIDENCE = 0.5; // below MIN_CONFIDENCE (0.75)

  // ── SAFE ──────────────────────────────────────────────────────────────────

  it('returns SAFE when displayed distance ≥ 10m and confidence is sufficient', () => {
    expect(
      resolveDecision({ displayedDistanceM: 10, confidenceScore: HIGH_CONFIDENCE, plateDetected: true }),
    ).toBe('SAFE');

    expect(
      resolveDecision({ displayedDistanceM: 15, confidenceScore: 0.8, plateDetected: true }),
    ).toBe('SAFE');
  });

  it('returns SAFE at exactly 10.0m displayed', () => {
    expect(
      resolveDecision({ displayedDistanceM: 10.0, confidenceScore: HIGH_CONFIDENCE, plateDetected: true }),
    ).toBe('SAFE');
  });

  // ── UNSAFE ────────────────────────────────────────────────────────────────

  it('returns UNSAFE when displayed distance < 10m and confidence is sufficient', () => {
    expect(
      resolveDecision({ displayedDistanceM: 9.9, confidenceScore: HIGH_CONFIDENCE, plateDetected: true }),
    ).toBe('UNSAFE');

    expect(
      resolveDecision({ displayedDistanceM: 0, confidenceScore: HIGH_CONFIDENCE, plateDetected: true }),
    ).toBe('UNSAFE');
  });

  // ── UNVERIFIABLE ──────────────────────────────────────────────────────────

  it('returns UNVERIFIABLE when plate was not detected', () => {
    expect(
      resolveDecision({ displayedDistanceM: 12, confidenceScore: HIGH_CONFIDENCE, plateDetected: false }),
    ).toBe('UNVERIFIABLE');
  });

  it('returns UNVERIFIABLE when confidence is below threshold', () => {
    expect(
      resolveDecision({ displayedDistanceM: 12, confidenceScore: LOW_CONFIDENCE, plateDetected: true }),
    ).toBe('UNVERIFIABLE');
  });

  it('returns UNVERIFIABLE when displayedDistanceM is null', () => {
    expect(
      resolveDecision({ displayedDistanceM: null, confidenceScore: HIGH_CONFIDENCE, plateDetected: true }),
    ).toBe('UNVERIFIABLE');
  });

  it('returns UNVERIFIABLE even if distance is SAFE-range but confidence is low', () => {
    // CRITICAL: low confidence must never produce SAFE
    expect(
      resolveDecision({ displayedDistanceM: 100, confidenceScore: 0.1, plateDetected: true }),
    ).toBe('UNVERIFIABLE');
  });

  // ── Edge cases ────────────────────────────────────────────────────────────

  it('returns UNVERIFIABLE when BOTH plate not detected AND confidence low', () => {
    // Plate check happens first
    expect(
      resolveDecision({ displayedDistanceM: 15, confidenceScore: 0.1, plateDetected: false }),
    ).toBe('UNVERIFIABLE');
  });

  it('confidence at exactly the threshold (0.75) is sufficient', () => {
    expect(
      resolveDecision({ displayedDistanceM: 12, confidenceScore: 0.75, plateDetected: true }),
    ).toBe('SAFE');
  });

  it('confidence just below threshold (0.749) is UNVERIFIABLE', () => {
    expect(
      resolveDecision({ displayedDistanceM: 12, confidenceScore: 0.749, plateDetected: true }),
    ).toBe('UNVERIFIABLE');
  });
});
