import React, { useEffect } from 'react';
import { View, Text, StyleSheet, Image } from 'react-native';
import { StackNavigationProp } from '@react-navigation/stack';
import { RootStackParamList } from '../navigation/AppNavigator';
import { COLORS } from '../constants/colors';
import AsyncStorage from '@react-native-async-storage/async-storage';

type Props = {
  navigation: StackNavigationProp<RootStackParamList, 'Splash'>;
};

const DISCLAIMER_ACCEPTED_KEY = 'disclaimer_accepted_v1';

export default function SplashScreen({ navigation }: Props) {
  useEffect(() => {
    const init = async () => {
      // 1.5s branding delay, then route based on disclaimer status
      await new Promise(resolve => setTimeout(resolve, 1500));

      try {
        const accepted = await AsyncStorage.getItem(DISCLAIMER_ACCEPTED_KEY);
        if (accepted === 'true') {
          navigation.replace('Home');
        } else {
          navigation.replace('Disclaimer');
        }
      } catch {
        navigation.replace('Disclaimer');
      }
    };

    init();
  }, [navigation]);

  return (
    <View style={styles.container}>
      <Text style={styles.logo}>🅿</Text>
      <Text style={styles.title}>DK Parking</Text>
      <Text style={styles.subtitle}>Kontroller din afstand</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.PRIMARY,
    alignItems: 'center',
    justifyContent: 'center',
  },
  logo: {
    fontSize: 72,
    marginBottom: 16,
  },
  title: {
    fontSize: 32,
    fontWeight: '700',
    color: '#FFFFFF',
    letterSpacing: 1,
  },
  subtitle: {
    fontSize: 16,
    color: 'rgba(255,255,255,0.7)',
    marginTop: 8,
  },
});
