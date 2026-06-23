import React from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  SafeAreaView,
  Platform,
} from 'react-native';
import { StackNavigationProp } from '@react-navigation/stack';
import { RouteProp } from '@react-navigation/native';
import { RootStackParamList } from '../navigation/AppNavigator';
import { COLORS } from '../constants/colors';
import { MeasurementResult } from '../engine/outputFormatter';

type Props = {
  navigation: StackNavigationProp<RootStackParamList, 'Result'>;
  route: RouteProp<RootStackParamList, 'Result'>;
};

interface StateConfig {
  icon: string;
  label: string;
  sublabel: string;
  bg: string;
  color: string;
  borderColor: string;
}

const STATE_CONFIG: Record<string, StateConfig> = {
  SAFE: {
    icon: '✅',
    label: 'SIKKER',
    sublabel: 'Du er parkeret lovligt',
    bg: COLORS.SAFE_BG,
    color: COLORS.SAFE,
    borderColor: COLORS.SAFE,
  },
  UNSAFE: {
    icon: '🚫',
    label: 'FOR TÆT',
    sublabel: 'Risiko for parkeringsbøde',
    bg: COLORS.UNSAFE_BG,
    color: COLORS.UNSAFE,
    borderColor: COLORS.UNSAFE,
  },
  UNVERIFIABLE: {
    icon: '❓',
    label: 'UVERIFICERBAR',
    sublabel: 'Tag et nyt billede med bedre vinkel',
    bg: COLORS.UNVERIFIABLE_BG,
    color: COLORS.UNVERIFIABLE,
    borderColor: COLORS.UNVERIFIABLE,
  },
};

export default function ResultScreen({ navigation, route }: Props) {
  const { result } = route.params;
  const config = STATE_CONFIG[result.decision] ?? STATE_CONFIG.UNVERIFIABLE;

  const handleCheckAgain = () => {
    navigation.navigate('Camera');
  };

  const handleGoHome = () => {
    navigation.navigate('Home');
  };

  return (
    <SafeAreaView style={styles.container}>
      {/* Result card */}
      <View style={[styles.resultCard, { backgroundColor: config.bg, borderColor: config.borderColor }]}>
        <Text style={styles.resultIcon}>{config.icon}</Text>
        <Text style={[styles.resultLabel, { color: config.color }]}>{config.label}</Text>
        <Text style={styles.resultSublabel}>{config.sublabel}</Text>

        {result.displayedDistanceM !== null && (
          <View style={styles.distanceBlock}>
            <Text style={[styles.distanceValue, { color: config.color }]}>
              {result.displayedDistanceM.toFixed(1)} m
            </Text>
            <Text style={styles.distanceLabel}>fra vejkrydset</Text>
          </View>
        )}
      </View>

      {/* Detail card */}
      <View style={styles.detailCard}>
        <DetailRow label="Nummerplade fundet" value={result.plateDetected ? '✅ Ja' : '❌ Nej'} />
        <DetailRow
          label="Målt afstand (rå)"
          value={result.rawDistanceM ? `${result.rawDistanceM.toFixed(1)} m` : '–'}
        />
        <DetailRow
          label="Sikkerhedsmargin fratrukket"
          value="2,0 m"
        />
        <DetailRow
          label="Konfidensgrad"
          value={`${Math.round(result.confidenceScore * 100)}%`}
        />
        <DetailRow
          label="Kameravinkel"
          value={`${result.cameraAngleDeg.toFixed(1)}°`}
        />
      </View>

      {result.decision === 'UNVERIFIABLE' && (
        <View style={styles.unverifiableHint}>
          <Text style={styles.unverifiableText}>
            Lav konfidensgrad — hold telefonen vandret og sørg for at nummerpladen er synlig i god belysning.
          </Text>
        </View>
      )}

      {/* Actions */}
      <View style={styles.actions}>
        <TouchableOpacity style={styles.primaryButton} onPress={handleCheckAgain} activeOpacity={0.85}>
          <Text style={styles.primaryButtonText}>Mål igen</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.secondaryButton} onPress={handleGoHome}>
          <Text style={styles.secondaryButtonText}>Tilbage til start</Text>
        </TouchableOpacity>
      </View>

      <Text style={styles.legalNote}>
        Resultatet er vejledende. Appen erstatter ikke din egen vurdering.
      </Text>
    </SafeAreaView>
  );
}

function DetailRow({ label, value }: { label: string; value: string }) {
  return (
    <View style={styles.detailRow}>
      <Text style={styles.detailLabel}>{label}</Text>
      <Text style={styles.detailValue}>{value}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.BACKGROUND,
    paddingHorizontal: 20,
    paddingTop: Platform.OS === 'ios' ? 0 : 20,
  },
  resultCard: {
    borderRadius: 20,
    borderWidth: 2,
    padding: 32,
    alignItems: 'center',
    marginTop: 24,
    marginBottom: 16,
  },
  resultIcon: { fontSize: 56, marginBottom: 12 },
  resultLabel: { fontSize: 30, fontWeight: '800', letterSpacing: 1 },
  resultSublabel: { fontSize: 16, color: COLORS.TEXT_SECONDARY, marginTop: 6 },
  distanceBlock: { alignItems: 'center', marginTop: 20 },
  distanceValue: { fontSize: 48, fontWeight: '900' },
  distanceLabel: { fontSize: 14, color: COLORS.TEXT_SECONDARY, marginTop: 2 },
  detailCard: {
    backgroundColor: COLORS.SURFACE,
    borderRadius: 14,
    padding: 16,
    marginBottom: 12,
  },
  detailRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingVertical: 8,
    borderBottomWidth: 1,
    borderBottomColor: COLORS.BORDER,
  },
  detailLabel: { fontSize: 14, color: COLORS.TEXT_SECONDARY },
  detailValue: { fontSize: 14, fontWeight: '600', color: COLORS.TEXT_PRIMARY },
  unverifiableHint: {
    backgroundColor: '#FFF3CD',
    borderRadius: 10,
    padding: 14,
    marginBottom: 12,
  },
  unverifiableText: { fontSize: 14, color: '#856404', lineHeight: 20 },
  actions: { marginTop: 8, gap: 10 },
  primaryButton: {
    backgroundColor: COLORS.PRIMARY,
    borderRadius: 14,
    paddingVertical: 16,
    alignItems: 'center',
  },
  primaryButtonText: { color: '#fff', fontSize: 17, fontWeight: '700' },
  secondaryButton: {
    borderWidth: 1.5,
    borderColor: COLORS.BORDER,
    borderRadius: 14,
    paddingVertical: 14,
    alignItems: 'center',
  },
  secondaryButtonText: { color: COLORS.TEXT_PRIMARY, fontSize: 16, fontWeight: '600' },
  legalNote: {
    textAlign: 'center',
    fontSize: 11,
    color: COLORS.SECONDARY,
    marginTop: 16,
    marginBottom: 8,
    lineHeight: 16,
  },
});
