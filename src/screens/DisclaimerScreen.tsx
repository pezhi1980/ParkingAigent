import React, { useState } from 'react';
import {
  View,
  Text,
  ScrollView,
  TouchableOpacity,
  StyleSheet,
  SafeAreaView,
} from 'react-native';
import { StackNavigationProp } from '@react-navigation/stack';
import { RootStackParamList } from '../navigation/AppNavigator';
import { COLORS } from '../constants/colors';
import { DISCLAIMER_TEXT } from '../constants/legal';
import AsyncStorage from '@react-native-async-storage/async-storage';

type Props = {
  navigation: StackNavigationProp<RootStackParamList, 'Disclaimer'>;
};

const DISCLAIMER_ACCEPTED_KEY = 'disclaimer_accepted_v1';

export default function DisclaimerScreen({ navigation }: Props) {
  const [scrolledToBottom, setScrolledToBottom] = useState(false);

  const handleAccept = async () => {
    await AsyncStorage.setItem(DISCLAIMER_ACCEPTED_KEY, 'true');
    navigation.replace('Home');
  };

  const handleScroll = (event: any) => {
    const { layoutMeasurement, contentOffset, contentSize } = event.nativeEvent;
    const paddingToBottom = 20;
    const isBottom =
      layoutMeasurement.height + contentOffset.y >= contentSize.height - paddingToBottom;
    if (isBottom) {
      setScrolledToBottom(true);
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.headerTitle}>Ansvarsfraskrivelse</Text>
        <Text style={styles.headerSubtitle}>Disclaimer</Text>
      </View>

      <ScrollView
        style={styles.scrollView}
        contentContainerStyle={styles.scrollContent}
        onScroll={handleScroll}
        scrollEventThrottle={16}
      >
        <Text style={styles.sectionLabel}>🇩🇰 Dansk</Text>
        <Text style={styles.disclaimerText}>{DISCLAIMER_TEXT.DA}</Text>

        <View style={styles.divider} />

        <Text style={styles.sectionLabel}>🇬🇧 English</Text>
        <Text style={styles.disclaimerText}>{DISCLAIMER_TEXT.EN}</Text>

        <View style={styles.bulletBlock}>
          <Text style={styles.bulletTitle}>Hvad appen gør:</Text>
          <Text style={styles.bullet}>✅ Måler afstand til vejkrydset</Text>
          <Text style={styles.bullet}>✅ Viser SIKKER / USIKKER / UVERIFICERBAR</Text>
          <Text style={styles.bullet}>✅ Anvender altid 2 meters sikkerhedsmargin</Text>
        </View>

        <View style={styles.bulletBlock}>
          <Text style={styles.bulletTitle}>Hvad appen IKKE gør:</Text>
          <Text style={styles.bullet}>❌ Garanterer ingen bøde</Text>
          <Text style={styles.bullet}>❌ Erstatter ikke skiltning og regler</Text>
          <Text style={styles.bullet}>❌ Gemmer billeder eller persondata</Text>
        </View>

        <View style={{ height: 40 }} />
      </ScrollView>

      <View style={styles.footer}>
        {!scrolledToBottom && (
          <Text style={styles.scrollHint}>↓ Scroll ned for at acceptere</Text>
        )}
        <TouchableOpacity
          style={[styles.acceptButton, !scrolledToBottom && styles.acceptButtonDisabled]}
          onPress={handleAccept}
          disabled={!scrolledToBottom}
          activeOpacity={0.8}
        >
          <Text style={styles.acceptButtonText}>Jeg forstår og accepterer</Text>
        </TouchableOpacity>
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
    backgroundColor: COLORS.PRIMARY,
    paddingVertical: 20,
    paddingHorizontal: 24,
    alignItems: 'center',
  },
  headerTitle: {
    fontSize: 22,
    fontWeight: '700',
    color: '#FFFFFF',
  },
  headerSubtitle: {
    fontSize: 14,
    color: 'rgba(255,255,255,0.7)',
    marginTop: 2,
  },
  scrollView: {
    flex: 1,
  },
  scrollContent: {
    padding: 24,
  },
  sectionLabel: {
    fontSize: 14,
    fontWeight: '600',
    color: COLORS.SECONDARY,
    marginBottom: 8,
    textTransform: 'uppercase',
    letterSpacing: 0.5,
  },
  disclaimerText: {
    fontSize: 15,
    lineHeight: 24,
    color: COLORS.TEXT_PRIMARY,
    marginBottom: 16,
  },
  divider: {
    height: 1,
    backgroundColor: COLORS.BORDER,
    marginVertical: 20,
  },
  bulletBlock: {
    backgroundColor: COLORS.SURFACE,
    borderRadius: 12,
    padding: 16,
    marginTop: 16,
  },
  bulletTitle: {
    fontSize: 14,
    fontWeight: '600',
    color: COLORS.TEXT_PRIMARY,
    marginBottom: 8,
  },
  bullet: {
    fontSize: 14,
    color: COLORS.TEXT_PRIMARY,
    marginVertical: 4,
  },
  footer: {
    padding: 24,
    borderTopWidth: 1,
    borderTopColor: COLORS.BORDER,
    backgroundColor: COLORS.BACKGROUND,
  },
  scrollHint: {
    textAlign: 'center',
    color: COLORS.SECONDARY,
    fontSize: 13,
    marginBottom: 12,
  },
  acceptButton: {
    backgroundColor: COLORS.PRIMARY,
    borderRadius: 14,
    paddingVertical: 16,
    alignItems: 'center',
  },
  acceptButtonDisabled: {
    backgroundColor: COLORS.BORDER,
  },
  acceptButtonText: {
    color: '#FFFFFF',
    fontSize: 17,
    fontWeight: '700',
  },
});
