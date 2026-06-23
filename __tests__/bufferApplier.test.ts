import { applyBuffer } from '../src/engine/bufferApplier';

describe('applyBuffer', () => {
  it('subtracts exactly 2.0m from the raw distance', () => {
    expect(applyBuffer(12)).toBe(10);
    expect(applyBuffer(10)).toBe(8);
    expect(applyBuffer(5)).toBe(3);
  });

  it('returns 0 (not negative) when raw distance ≤ 2m', () => {
    expect(applyBuffer(2)).toBe(0);
    expect(applyBuffer(1)).toBe(0);
    expect(applyBuffer(0)).toBe(0);
  });

  it('rounds to 1 decimal place', () => {
    expect(applyBuffer(10.15)).toBe(8.2);
    expect(applyBuffer(12.05)).toBe(10.1); // rounding edge
  });

  it('handles exactly the legal threshold', () => {
    // 12m raw → 10m displayed → SAFE threshold exactly
    expect(applyBuffer(12)).toBe(10);
  });

  it('CRITICAL: buffer is ALWAYS applied — never shows raw distance', () => {
    const raw = 15.3;
    const displayed = applyBuffer(raw);
    expect(displayed).toBe(13.3);
    expect(displayed).not.toBe(raw); // must differ from raw
  });
});
