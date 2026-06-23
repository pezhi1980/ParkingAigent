/**
 * DK Parking design system — color tokens.
 * SAFE = green, UNSAFE = red, UNVERIFIABLE = grey, neutral = dark/white
 */
export const COLORS = {
  // Decision states
  SAFE: '#2ECC71',
  SAFE_BG: '#D5F5E3',
  UNSAFE: '#E74C3C',
  UNSAFE_BG: '#FADBD8',
  UNVERIFIABLE: '#95A5A6',
  UNVERIFIABLE_BG: '#F2F3F4',

  // UI
  PRIMARY: '#2C3E50',
  SECONDARY: '#7F8C8D',
  BACKGROUND: '#FFFFFF',
  SURFACE: '#F8F9FA',
  BORDER: '#E0E0E0',
  TEXT_PRIMARY: '#1A1A2E',
  TEXT_SECONDARY: '#6C757D',

  // Camera overlay
  OVERLAY: 'rgba(0, 0, 0, 0.5)',
  CROSSHAIR: '#FFFFFF',
  GUIDE_RECT: 'rgba(255, 255, 255, 0.8)',
} as const;
