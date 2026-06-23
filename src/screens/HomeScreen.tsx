import React from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  SafeAreaView,
  StatusBar,
} from 'react-native';
import { StackNavigationProp } from '@react-navigation/stack';
import { RootStackParamList } from '../navigation/AppNavigator';
import { COLORS } from '../constants/colors';

type Props = {
  navigation: StackNavigationProp<RootStackParamList, 'Home'>;
};

export default function HomeScreen({ navigation }: Props) {
  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="light-content" backgroundColor={COLORS.PRIMARY} />

      <View style={styles.header}>
        <Text style={styles.headerTitle}>DK Parking</Text>
        <TouchableOpacity onPress={() => navigation.navigate('About')} style={styles.aboutBtn}>
          <Text style={styles.aboutBtnText}>ℹ</Text>
        </TouchableOpacity>
      </View>

      <View style={styles.body}>
        <Text style={styles.icon}>🚗</Text>
        <Text style={styles.title}>Er du parkeret lovligt?</Text>
        <Text style={styles.subtitle}>
          Peg kameraet mod din bil — vi måler afstanden til vejkrydset på under 5 sekunder.
        </Text>

        <View style={styles.ruleCard}>
          <Text style={styles.ruleTitle}>10-meter reglen</Text>
          <Text style={styles.ruleText}>
            Du må ikke parkere inden for 10 meter fra nærmeste vejkrydskant.
          </Text>
          <Text style={styles.ruleNote}>Appen anvender 2 meters sikkerhedsmargin.</Text>
        </View>

        <TouchableOpacity
          style={styles.mainButton}
          onPress={() => navigation.navigate('Camera')}
          activeOpacity={0.85}
        >
          <Text style={styles.mainButtonText}>Tjek min parkering</Text>
        </TouchableOpacity>
      </View>

      <View style={styles.footer}>
        <Text style={styles.footerText}>Kun København • Gratis • Ingen reklamer</Text>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.BACKGROUND,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    backgroundColor: COLORS.PRIMARY,
    paddingHorizontal: 20,
    paddingVertical: 16,
  },
  headerTitle: {
    fontSize: 20,
    fontWeight: '700',
    color: '#FFFFFF',
  },
  aboutBtn: {
    padding: 4,
  },
  aboutBtnText: {
    fontSize: 22,
    color: 'rgba(255,255,255,0.8)',
  },
  body: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 28,
  },
  icon: {
    fontSize: 64,
    marginBottom: 20,
  },
  title: {
    fontSize: 26,
    fontWeight: '700',
    color: COLORS.TEXT_PRIMARY,
    textAlign: 'center',
    marginBottom: 12,
  },
  subtitle: {
    fontSize: 16,
    color: COLORS.TEXT_SECONDARY,
    textAlign: 'center',
    lineHeight: 24,
    marginBottom: 32,
  },
  ruleCard: {
    backgroundColor: COLORS.SURFACE,
    borderRadius: 14,
    padding: 20,
    width: '100%',
    marginBottom: 32,
    borderLeftWidth: 4,
    borderLeftColor: COLORS.PRIMARY,
  },
  ruleTitle: {
    fontSize: 15,
    fontWeight: '700',
    color: COLORS.TEXT_PRIMARY,
    marginBottom: 6,
  },
  ruleText: {
    fontSize: 14,
    color: COLORS.TEXT_SECONDARY,
    lineHeight: 20,
    marginBottom: 8,
  },
  ruleNote: {
    fontSize: 13,
    color: COLORS.SECONDARY,
    fontStyle: 'italic',
  },
  mainButton: {
    backgroundColor: COLORS.PRIMARY,
    borderRadius: 16,
    paddingVertical: 18,
    paddingHorizontal: 48,
    width: '100%',
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.15,
    shadowRadius: 8,
    elevation: 5,
  },
  mainButtonText: {
    color: '#FFFFFF',
    fontSize: 18,
    fontWeight: '700',
  },
  footer: {
    paddingBottom: 16,
    alignItems: 'center',
  },
  footerText: {
    fontSize: 12,
    color: COLORS.SECONDARY,
  },
});
