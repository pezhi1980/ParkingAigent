import React from 'react';
import { View, Text, ScrollView, TouchableOpacity, StyleSheet, SafeAreaView, Linking } from 'react-native';
import { StackNavigationProp } from '@react-navigation/stack';
import { RootStackParamList } from '../navigation/AppNavigator';
import { COLORS } from '../constants/colors';

type Props = {
  navigation: StackNavigationProp<RootStackParamList, 'About'>;
};

export default function AboutScreen({ navigation }: Props) {
  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => navigation.goBack()} style={styles.backBtn}>
          <Text style={styles.backBtnText}>←</Text>
        </TouchableOpacity>
        <Text style={styles.headerTitle}>Om appen</Text>
        <View style={{ width: 40 }} />
      </View>

      <ScrollView contentContainerStyle={styles.content}>
        <Text style={styles.appName}>DK Parking</Text>
        <Text style={styles.version}>Version 1.0.0 — Kun København</Text>

        <Section title="Hvad gør appen?">
          <Text style={styles.bodyText}>
            DK Parking hjælper dig med at kontrollere, om din bil er parkeret lovligt i
            henhold til 10-meter-reglen (Færdselsloven § 28). Appen bruger din telefons
            kamera og kunstig intelligens til at detektere nummerpladen og beregne
            afstanden til vejkrydsets kant.
          </Text>
        </Section>

        <Section title="Sådan virker det">
          <Text style={styles.bodyText}>
            1. Peg kameraet mod din bils nummerplade{'\n'}
            2. Appen finder og måler nummerpladen (520mm × 110mm){'\n'}
            3. Du markerer vejkrydsets kant på billedet{'\n'}
            4. Appen beregner afstanden og fratrækker 2 meters sikkerhedsmargin{'\n'}
            5. Du ser SIKKER, FOR TÆT eller UVERIFICERBAR
          </Text>
        </Section>

        <Section title="Sikkerhedsmargin">
          <Text style={styles.bodyText}>
            Appen viser altid en afstand, der er 2 meter kortere end den målte afstand.
            Dette sikrer, at vi altid er konservative — appen siger kun SIKKER, hvis
            din bil er mindst 12 meter fra krydset.
          </Text>
        </Section>

        <Section title="Privatlivspolitik">
          <Text style={styles.bodyText}>
            Appen gemmer ingen billeder og ingen persondata. Al AI-behandling sker på
            enheden. Vi logger kun anonyme måleresultater (afstand, konfidensgrad,
            enhedstype) til forbedring af appen.
          </Text>
          <TouchableOpacity onPress={() => Linking.openURL('https://dkparking.app/privacy')}>
            <Text style={styles.link}>Læs privatlivspolitik →</Text>
          </TouchableOpacity>
        </Section>

        <Section title="Juridisk ansvarsfraskrivelse">
          <Text style={styles.bodyText}>
            Appen er et hjælpeværktøj og erstatter ikke din egen vurdering. Målinger
            kan være unøjagtige. Appen garanterer ikke, at du undgår parkeringsbøder.
          </Text>
        </Section>

        <Text style={styles.footer}>
          Gratis for altid • Ingen reklamer • Open source
        </Text>
      </ScrollView>
    </SafeAreaView>
  );
}

function Section({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <View style={styles.section}>
      <Text style={styles.sectionTitle}>{title}</Text>
      {children}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: COLORS.BACKGROUND },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    backgroundColor: COLORS.PRIMARY,
    paddingHorizontal: 16,
    paddingVertical: 14,
  },
  backBtn: { width: 40, alignItems: 'flex-start' },
  backBtnText: { color: '#fff', fontSize: 22 },
  headerTitle: { color: '#fff', fontSize: 18, fontWeight: '700' },
  content: { padding: 20 },
  appName: { fontSize: 28, fontWeight: '800', color: COLORS.TEXT_PRIMARY, marginBottom: 4 },
  version: { fontSize: 13, color: COLORS.SECONDARY, marginBottom: 24 },
  section: { marginBottom: 24 },
  sectionTitle: {
    fontSize: 16,
    fontWeight: '700',
    color: COLORS.TEXT_PRIMARY,
    marginBottom: 8,
    borderLeftWidth: 3,
    borderLeftColor: COLORS.PRIMARY,
    paddingLeft: 10,
  },
  bodyText: { fontSize: 15, color: COLORS.TEXT_SECONDARY, lineHeight: 24 },
  link: { color: COLORS.PRIMARY, fontWeight: '600', marginTop: 8 },
  footer: { textAlign: 'center', color: COLORS.SECONDARY, fontSize: 12, marginTop: 16 },
});
