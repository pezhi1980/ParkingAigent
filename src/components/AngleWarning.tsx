import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { COLORS } from '../constants/colors';
import { LEGAL } from '../constants/legal';

interface Props {
  angleDeg: number;
}

/**
 * Warning banner shown when the phone tilt exceeds the safe threshold.
 * Only visible when tilt > MAX_TILT_ANGLE_DEG (15°).
 */
export default function AngleWarning({ angleDeg }: Props) {
  if (Math.abs(angleDeg) <= LEGAL.MAX_TILT_ANGLE_DEG) {
    return null;
  }

  return (
    <View style={styles.container}>
      <Text style={styles.icon}>📐</Text>
      <Text style={styles.text}>Hold telefonen vandret ({Math.round(Math.abs(angleDeg))}°)</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#F39C12',
    paddingHorizontal: 16,
    paddingVertical: 10,
    borderRadius: 10,
    margin: 12,
  },
  icon: {
    fontSize: 18,
    marginRight: 8,
  },
  text: {
    color: '#FFFFFF',
    fontWeight: '600',
    fontSize: 14,
  },
});
