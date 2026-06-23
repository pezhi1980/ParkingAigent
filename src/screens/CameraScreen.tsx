import React, { useRef, useState, useEffect, useCallback } from 'react';
import { View, TouchableOpacity, Text, StyleSheet, Alert, Platform } from 'react-native';
import { Camera, useCameraDevices, useFrameProcessor } from 'react-native-vision-camera';
import { StackNavigationProp } from '@react-navigation/stack';
import { RootStackParamList } from '../navigation/AppNavigator';
import { COLORS } from '../constants/colors';
import CameraOverlay from '../components/CameraOverlay';
import AngleWarning from '../components/AngleWarning';
import { detectPlate, PlateDetection } from '../ml/plateDetector';

// react-native-sensors
import { gyroscope, setUpdateIntervalForType, SensorTypes } from 'react-native-sensors';

type Props = {
  navigation: StackNavigationProp<RootStackParamList, 'Camera'>;
};

setUpdateIntervalForType(SensorTypes.gyroscope, 100);

export default function CameraScreen({ navigation }: Props) {
  const devices = useCameraDevices();
  const device = devices.back;
  const cameraRef = useRef<Camera>(null);

  const [hasPermission, setHasPermission] = useState(false);
  const [cameraAngleDeg, setCameraAngleDeg] = useState(0);
  const [plateDetection, setPlateDetection] = useState<PlateDetection | null>(null);
  const [isCapturing, setIsCapturing] = useState(false);

  // Request camera permission
  useEffect(() => {
    (async () => {
      const status = await Camera.requestCameraPermission();
      setHasPermission(status === 'authorized' || status === 'granted');
    })();
  }, []);

  // Gyroscope for angle tracking
  useEffect(() => {
    const subscription = gyroscope.subscribe(({ z }) => {
      // Integrate to get cumulative tilt — simplified for MVP
      setCameraAngleDeg(prev => Math.min(Math.max(prev + z * 0.1, -90), 90));
    });
    return () => subscription.unsubscribe();
  }, []);

  // Frame processor for real-time plate detection
  const frameProcessor = useFrameProcessor(frame => {
    'worklet';
    const result = detectPlate(frame);
    if (result) {
      setPlateDetection(result);
    }
  }, []);

  const handleCapture = useCallback(async () => {
    if (!cameraRef.current || !plateDetection || isCapturing) return;

    setIsCapturing(true);
    try {
      const photo = await cameraRef.current.takePhoto({ quality: 90 });

      navigation.navigate('CurbTap', {
        frameUri: photo.path,
        platePixelWidth: plateDetection.pixelWidth,
        focalLengthPx: plateDetection.focalLengthPx,
        cameraAngleDeg,
      });
    } catch (err) {
      Alert.alert('Fejl', 'Kunne ikke tage billede. Prøv igen.');
    } finally {
      setIsCapturing(false);
    }
  }, [cameraRef, plateDetection, isCapturing, cameraAngleDeg, navigation]);

  if (!hasPermission) {
    return (
      <View style={styles.permissionContainer}>
        <Text style={styles.permissionText}>
          Kamera-adgang er nødvendig for at måle afstanden.
        </Text>
        <TouchableOpacity
          style={styles.permissionButton}
          onPress={() => Camera.requestCameraPermission()}
        >
          <Text style={styles.permissionButtonText}>Giv adgang</Text>
        </TouchableOpacity>
      </View>
    );
  }

  if (!device) {
    return (
      <View style={styles.permissionContainer}>
        <Text style={styles.permissionText}>Kamera ikke tilgængeligt.</Text>
      </View>
    );
  }

  const isAngleTooLarge = Math.abs(cameraAngleDeg) > 15;

  return (
    <View style={styles.container}>
      <Camera
        ref={cameraRef}
        style={StyleSheet.absoluteFill}
        device={device}
        isActive={true}
        photo={true}
        frameProcessor={frameProcessor}
        frameProcessorFps={5}
      />

      <CameraOverlay plateDetected={!!plateDetection && plateDetection.confidence > 0.5} />

      <AngleWarning angleDeg={cameraAngleDeg} />

      {/* Top bar */}
      <View style={styles.topBar}>
        <TouchableOpacity onPress={() => navigation.goBack()} style={styles.backButton}>
          <Text style={styles.backButtonText}>✕</Text>
        </TouchableOpacity>
        <Text style={styles.topBarTitle}>Peg mod nummerpladen</Text>
        <View style={{ width: 40 }} />
      </View>

      {/* Capture button */}
      <View style={styles.captureArea}>
        <TouchableOpacity
          style={[
            styles.captureButton,
            (!plateDetection || isAngleTooLarge || isCapturing) && styles.captureButtonDisabled,
          ]}
          onPress={handleCapture}
          disabled={!plateDetection || isAngleTooLarge || isCapturing}
          activeOpacity={0.8}
        >
          <Text style={styles.captureButtonText}>
            {isCapturing ? 'Måler...' : 'Mål afstand'}
          </Text>
        </TouchableOpacity>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#000' },
  topBar: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingTop: Platform.OS === 'ios' ? 56 : 16,
    paddingHorizontal: 16,
    paddingBottom: 16,
    backgroundColor: 'rgba(0,0,0,0.4)',
  },
  backButton: { width: 40, height: 40, alignItems: 'center', justifyContent: 'center' },
  backButtonText: { color: '#fff', fontSize: 20 },
  topBarTitle: { color: '#fff', fontSize: 16, fontWeight: '600' },
  captureArea: {
    position: 'absolute',
    bottom: 48,
    left: 0,
    right: 0,
    alignItems: 'center',
  },
  captureButton: {
    backgroundColor: COLORS.PRIMARY,
    borderRadius: 40,
    paddingVertical: 18,
    paddingHorizontal: 56,
  },
  captureButtonDisabled: { backgroundColor: 'rgba(44,62,80,0.5)' },
  captureButtonText: { color: '#fff', fontSize: 18, fontWeight: '700' },
  permissionContainer: {
    flex: 1,
    backgroundColor: COLORS.PRIMARY,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 32,
  },
  permissionText: {
    color: '#fff',
    fontSize: 17,
    textAlign: 'center',
    lineHeight: 26,
    marginBottom: 24,
  },
  permissionButton: {
    backgroundColor: '#fff',
    borderRadius: 12,
    paddingVertical: 14,
    paddingHorizontal: 32,
  },
  permissionButtonText: { color: COLORS.PRIMARY, fontWeight: '700', fontSize: 16 },
});
