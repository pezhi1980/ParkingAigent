import React, { useState } from 'react';
import {
  View,
  Text,
  Image,
  TouchableOpacity,
  StyleSheet,
  Dimensions,
  Platform,
} from 'react-native';
import { StackNavigationProp } from '@react-navigation/stack';
import { RouteProp } from '@react-navigation/native';
import { RootStackParamList } from '../navigation/AppNavigator';
import { COLORS } from '../constants/colors';
import { runMeasurementPipeline } from '../engine/measurementPipeline';
import { logMeasurement } from '../services/supabaseLogger';

type Props = {
  navigation: StackNavigationProp<RootStackParamList, 'CurbTap'>;
  route: RouteProp<RootStackParamList, 'CurbTap'>;
};

const APP_VERSION = '1.0.0';
const { width, height } = Dimensions.get('window');

export default function CurbTapScreen({ navigation, route }: Props) {
  const { frameUri, platePixelWidth, focalLengthPx, cameraAngleDeg } = route.params;
  const [curbTapY, setCurbTapY] = useState<number | null>(null);
  const [isCalculating, setIsCalculating] = useState(false);

  const handleImageTap = (event: any) => {
    const { locationY } = event.nativeEvent;
    setCurbTapY(locationY);
  };

  const handleCalculate = async () => {
    if (curbTapY === null) return;
    setIsCalculating(true);

    try {
      // Run the full measurement pipeline
      const result = runMeasurementPipeline({
        platePixelWidth,
        focalLengthPx,
        plateDetectionScore: 0.9, // from YOLO — passed through in full implementation
        cameraAngleDeg,
        plateDetected: true,
        appVersion: APP_VERSION,
      });

      // Fire-and-forget anonymous logging
      logMeasurement(result).catch(() => {});

      navigation.replace('Result', { result });
    } finally {
      setIsCalculating(false);
    }
  };

  return (
    <View style={styles.container}>
      {/* Instruction header */}
      <View style={styles.header}>
        <Text style={styles.headerTitle}>Marker vejkanten</Text>
        <Text style={styles.headerSubtitle}>
          Tryk på det punkt, hvor vejkrydsets kant starter
        </Text>
      </View>

      {/* Image + tap target */}
      <TouchableOpacity
        activeOpacity={1}
        onPress={handleImageTap}
        style={styles.imageContainer}
      >
        <Image
          source={{ uri: `file://${frameUri}` }}
          style={styles.image}
          resizeMode="contain"
        />
        {curbTapY !== null && (
          <View style={[styles.tapMarker, { top: curbTapY - 16 }]}>
            <View style={styles.tapDot} />
            <View style={styles.tapLine} />
          </View>
        )}
      </TouchableOpacity>

      {/* Footer actions */}
      <View style={styles.footer}>
        {curbTapY === null ? (
          <Text style={styles.hintText}>👆 Tryk på billedet for at markere vejkanten</Text>
        ) : (
          <Text style={styles.hintText}>✅ Vejkant markeret — klar til måling</Text>
        )}

        <View style={styles.buttonRow}>
          <TouchableOpacity
            style={styles.cancelButton}
            onPress={() => navigation.goBack()}
          >
            <Text style={styles.cancelButtonText}>Prøv igen</Text>
          </TouchableOpacity>

          <TouchableOpacity
            style={[styles.calculateButton, curbTapY === null && styles.buttonDisabled]}
            onPress={handleCalculate}
            disabled={curbTapY === null || isCalculating}
          >
            <Text style={styles.calculateButtonText}>
              {isCalculating ? 'Beregner...' : 'Beregn afstand'}
            </Text>
          </TouchableOpacity>
        </View>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#000' },
  header: {
    backgroundColor: COLORS.PRIMARY,
    paddingTop: Platform.OS === 'ios' ? 56 : 20,
    paddingBottom: 16,
    paddingHorizontal: 20,
  },
  headerTitle: { color: '#fff', fontSize: 18, fontWeight: '700' },
  headerSubtitle: { color: 'rgba(255,255,255,0.8)', fontSize: 14, marginTop: 4 },
  imageContainer: { flex: 1, position: 'relative' },
  image: { width: '100%', height: '100%' },
  tapMarker: {
    position: 'absolute',
    left: 0,
    right: 0,
    alignItems: 'center',
  },
  tapDot: {
    width: 24,
    height: 24,
    borderRadius: 12,
    backgroundColor: COLORS.UNSAFE,
    borderWidth: 3,
    borderColor: '#fff',
  },
  tapLine: {
    position: 'absolute',
    top: 12,
    left: 0,
    right: 0,
    height: 2,
    backgroundColor: COLORS.UNSAFE,
    opacity: 0.8,
  },
  footer: {
    backgroundColor: COLORS.BACKGROUND,
    padding: 20,
    paddingBottom: Platform.OS === 'ios' ? 36 : 20,
  },
  hintText: {
    textAlign: 'center',
    color: COLORS.TEXT_SECONDARY,
    fontSize: 14,
    marginBottom: 16,
  },
  buttonRow: { flexDirection: 'row', gap: 12 },
  cancelButton: {
    flex: 1,
    borderWidth: 1.5,
    borderColor: COLORS.BORDER,
    borderRadius: 12,
    paddingVertical: 14,
    alignItems: 'center',
  },
  cancelButtonText: { color: COLORS.TEXT_PRIMARY, fontWeight: '600', fontSize: 15 },
  calculateButton: {
    flex: 2,
    backgroundColor: COLORS.PRIMARY,
    borderRadius: 12,
    paddingVertical: 14,
    alignItems: 'center',
  },
  buttonDisabled: { backgroundColor: COLORS.BORDER },
  calculateButtonText: { color: '#fff', fontWeight: '700', fontSize: 15 },
});
