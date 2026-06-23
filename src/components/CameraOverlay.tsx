import React from 'react';
import { View, Text, StyleSheet, Dimensions } from 'react-native';
import { COLORS } from '../constants/colors';

const { width, height } = Dimensions.get('window');

// Target rectangle: 70% of screen width, centered vertically at 40% from top
const RECT_WIDTH = width * 0.7;
const RECT_HEIGHT = RECT_WIDTH * (110 / 520); // plate aspect ratio 520:110
const RECT_TOP = height * 0.35;
const RECT_LEFT = (width - RECT_WIDTH) / 2;

interface Props {
  plateDetected: boolean;
}

/**
 * Transparent overlay shown on the camera feed.
 * Contains:
 * - Darkened border areas (4 quadrants around the target rect)
 * - White guide rectangle with corner markers
 * - Instruction text
 * - Green border when plate is detected
 */
export default function CameraOverlay({ plateDetected }: Props) {
  const rectColor = plateDetected ? COLORS.SAFE : COLORS.CROSSHAIR;

  return (
    <View style={StyleSheet.absoluteFill} pointerEvents="none">
      {/* Top overlay */}
      <View style={[styles.shade, { height: RECT_TOP }]} />

      {/* Middle row */}
      <View style={[styles.row, { top: RECT_TOP, height: RECT_HEIGHT }]}>
        <View style={[styles.shade, { width: RECT_LEFT }]} />
        <View
          style={[styles.targetRect, { width: RECT_WIDTH, height: RECT_HEIGHT, borderColor: rectColor }]}
        >
          {/* Corner markers */}
          <View style={[styles.corner, styles.topLeft, { borderColor: rectColor }]} />
          <View style={[styles.corner, styles.topRight, { borderColor: rectColor }]} />
          <View style={[styles.corner, styles.bottomLeft, { borderColor: rectColor }]} />
          <View style={[styles.corner, styles.bottomRight, { borderColor: rectColor }]} />
        </View>
        <View style={[styles.shade, { flex: 1 }]} />
      </View>

      {/* Bottom overlay */}
      <View style={[styles.shade, { flex: 1 }]}>
        <Text style={styles.instructionText}>
          {plateDetected
            ? '✅ Nummerplade fundet — tryk for at måle'
            : 'Sigte mod nummerpladen på din bil'}
        </Text>
      </View>
    </View>
  );
}

const CORNER_SIZE = 20;
const CORNER_WIDTH = 3;

const styles = StyleSheet.create({
  shade: {
    backgroundColor: COLORS.OVERLAY,
  },
  row: {
    position: 'absolute',
    left: 0,
    right: 0,
    flexDirection: 'row',
  },
  targetRect: {
    borderWidth: 2,
    position: 'relative',
  },
  corner: {
    position: 'absolute',
    width: CORNER_SIZE,
    height: CORNER_SIZE,
    borderWidth: CORNER_WIDTH,
  },
  topLeft: {
    top: -CORNER_WIDTH,
    left: -CORNER_WIDTH,
    borderRightWidth: 0,
    borderBottomWidth: 0,
  },
  topRight: {
    top: -CORNER_WIDTH,
    right: -CORNER_WIDTH,
    borderLeftWidth: 0,
    borderBottomWidth: 0,
  },
  bottomLeft: {
    bottom: -CORNER_WIDTH,
    left: -CORNER_WIDTH,
    borderRightWidth: 0,
    borderTopWidth: 0,
  },
  bottomRight: {
    bottom: -CORNER_WIDTH,
    right: -CORNER_WIDTH,
    borderLeftWidth: 0,
    borderTopWidth: 0,
  },
  instructionText: {
    color: '#FFFFFF',
    textAlign: 'center',
    fontSize: 15,
    fontWeight: '600',
    marginTop: 24,
    paddingHorizontal: 20,
    textShadowColor: 'rgba(0,0,0,0.8)',
    textShadowOffset: { width: 0, height: 1 },
    textShadowRadius: 4,
  },
});
