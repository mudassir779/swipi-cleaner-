import React, { useState } from 'react';
import {
  View,
  Text,
  ScrollView,
} from 'react-native';
import { useRouter } from 'expo-router';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useColorScheme } from '@/lib/useColorScheme';
import { cn } from '@/lib/cn';
import * as Haptics from 'expo-haptics';
import { Ionicons, MaterialCommunityIcons, Feather } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';
import Animated, {
  FadeInDown,
  FadeIn,
  useSharedValue,
  useAnimatedStyle,
  withSpring,
  withSequence,
  withTiming,
} from 'react-native-reanimated';
import { AnimatedPressable } from '@/components/AnimatedPressable';

interface FeatureItemProps {
  title: string;
  description: string;
  icon: React.ReactNode;
  isPro: boolean;
  isDark: boolean;
  index: number;
}

function FeatureItem({ title, description, icon, isPro, isDark, index }: FeatureItemProps) {
  return (
    <Animated.View 
      entering={FadeInDown.delay(index * 80).springify()}
      className="flex-row items-center py-3"
    >
      <View
        className={cn(
          'w-10 h-10 rounded-xl items-center justify-center mr-3',
          isDark ? 'bg-gray-700' : 'bg-gray-100',
        )}
      >
        {icon}
      </View>
      <View className="flex-1">
        <Text className={cn('text-base font-medium', isDark ? 'text-white' : 'text-gray-900')}>
          {title}
        </Text>
        <Text className={cn('text-sm', isDark ? 'text-gray-400' : 'text-gray-500')}>
          {description}
        </Text>
      </View>
      {isPro ? (
        <Animated.View 
          entering={FadeIn.delay(index * 80 + 200)}
          className="bg-amber-500 px-2.5 py-1 rounded-full"
          style={{
            shadowColor: '#f59e0b',
            shadowOffset: { width: 0, height: 2 },
            shadowOpacity: 0.3,
            shadowRadius: 4,
          }}
        >
          <Text className="text-white text-xs font-bold">PRO</Text>
        </Animated.View>
      ) : (
        <Animated.View entering={FadeIn.delay(index * 80 + 200)}>
          <Ionicons name="checkmark-circle" size={24} color="#22c55e" />
        </Animated.View>
      )}
    </Animated.View>
  );
}

interface PlanCardProps {
  plan: 'monthly' | 'yearly' | 'lifetime';
  title: string;
  subtitle: string;
  price: string;
  priceLabel: string;
  badge?: string;
  isSelected: boolean;
  onPress: () => void;
  isDark: boolean;
  index: number;
}

function PlanCard({
  plan,
  title,
  subtitle,
  price,
  priceLabel,
  badge,
  isSelected,
  onPress,
  isDark,
  index,
}: PlanCardProps) {
  const scale = useSharedValue(1);
  const borderWidth = useSharedValue(isSelected ? 2 : 0);
  
  React.useEffect(() => {
    borderWidth.value = withSpring(isSelected ? 2 : 0);
    if (isSelected) {
      scale.value = withSequence(
        withSpring(1.02, { damping: 10 }),
        withSpring(1, { damping: 15 })
      );
    }
  }, [isSelected]);

  const animatedBorderStyle = useAnimatedStyle(() => ({
    borderWidth: borderWidth.value,
    borderColor: '#3b82f6',
  }));

  const handlePress = () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
    onPress();
  };

  return (
    <Animated.View entering={FadeInDown.delay(300 + index * 100).springify()}>
      <AnimatedPressable
        onPress={handlePress}
        scaleValue={0.98}
        hapticFeedback="none"
      >
        <Animated.View
          style={[
            animatedBorderStyle,
            {
              shadowColor: isSelected ? '#3b82f6' : '#000',
              shadowOffset: { width: 0, height: isSelected ? 4 : 2 },
              shadowOpacity: isSelected ? 0.3 : (isDark ? 0.3 : 0.1),
              shadowRadius: isSelected ? 12 : 8,
              elevation: isSelected ? 8 : 4,
            },
          ]}
          className={cn(
            'p-4 rounded-2xl mb-3',
            isSelected
              ? isDark ? 'bg-blue-900/30' : 'bg-blue-50'
              : isDark ? 'bg-gray-800' : 'bg-white',
          )}
        >
          <View className="flex-row items-center justify-between">
            <View>
              <View className="flex-row items-center">
                <Text className={cn('text-lg font-bold', isDark ? 'text-white' : 'text-gray-900')}>
                  {title}
                </Text>
                {badge && (
                  <Animated.View 
                    entering={FadeIn.delay(500)}
                    className="bg-green-500 px-2 py-0.5 rounded-full ml-2"
                    style={{
                      shadowColor: '#22c55e',
                      shadowOffset: { width: 0, height: 2 },
                      shadowOpacity: 0.3,
                      shadowRadius: 4,
                    }}
                  >
                    <Text className="text-white text-xs font-bold">{badge}</Text>
                  </Animated.View>
                )}
              </View>
              <Text className={cn('text-sm', isDark ? 'text-gray-400' : 'text-gray-500')}>
                {subtitle}
              </Text>
            </View>
            <View className="items-end">
              <Text className={cn('text-2xl font-bold', isDark ? 'text-white' : 'text-gray-900')}>
                {price}
              </Text>
              <Text className={cn('text-sm', isDark ? 'text-gray-400' : 'text-gray-500')}>
                {priceLabel}
              </Text>
            </View>
          </View>
          
          {/* Selection indicator */}
          {isSelected && (
            <Animated.View 
              entering={FadeIn.duration(200)}
              className="absolute top-3 right-3"
            >
              <View className="w-5 h-5 rounded-full bg-blue-500 items-center justify-center">
                <Ionicons name="checkmark" size={14} color="#fff" />
              </View>
            </Animated.View>
          )}
        </Animated.View>
      </AnimatedPressable>
    </Animated.View>
  );
}

export default function PremiumScreen() {
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';
  const [selectedPlan, setSelectedPlan] = useState<'monthly' | 'yearly' | 'lifetime'>('yearly');

  const handlePurchase = () => {
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    // TODO: Integrate with RevenueCat
    console.log('Purchase:', selectedPlan);
  };

  const handleRestore = () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    // TODO: Restore purchases with RevenueCat
    console.log('Restore purchases');
  };

  const features = [
    {
      title: 'Basic Photo Browsing',
      description: 'View and organize your photos',
      icon: <Ionicons name="images" size={20} color={isDark ? '#60a5fa' : '#3b82f6'} />,
      isPro: false,
    },
    {
      title: 'Manual Duplicate Finding',
      description: 'Find exact duplicate photos',
      icon: <Ionicons name="copy" size={20} color={isDark ? '#60a5fa' : '#3b82f6'} />,
      isPro: false,
    },
    {
      title: 'AI Duplicate Detection',
      description: 'Smart similar photo grouping',
      icon: <MaterialCommunityIcons name="robot" size={20} color={isDark ? '#60a5fa' : '#3b82f6'} />,
      isPro: true,
    },
    {
      title: 'Blurry Photo Detection',
      description: 'Find and remove blurry shots',
      icon: <Ionicons name="eye-off" size={20} color={isDark ? '#60a5fa' : '#3b82f6'} />,
      isPro: true,
    },
    {
      title: 'Unlimited Delete Queue',
      description: 'No limits on cleanup batches',
      icon: <Feather name="trash-2" size={20} color={isDark ? '#60a5fa' : '#3b82f6'} />,
      isPro: true,
    },
    {
      title: 'Cloud Backup Integration',
      description: 'Check iCloud sync status',
      icon: <Ionicons name="cloud" size={20} color={isDark ? '#60a5fa' : '#3b82f6'} />,
      isPro: true,
    },
    {
      title: 'Advanced Analytics',
      description: 'Detailed storage insights',
      icon: <Ionicons name="stats-chart" size={20} color={isDark ? '#60a5fa' : '#3b82f6'} />,
      isPro: true,
    },
  ];

  return (
    <View className={cn('flex-1', isDark ? 'bg-black' : 'bg-gray-50')}>
      <ScrollView
        className="flex-1"
        contentContainerStyle={{ paddingBottom: insets.bottom + 32 }}
        showsVerticalScrollIndicator={false}
      >
        {/* Hero Section */}
        <LinearGradient
          colors={isDark ? ['#1e3a8a', '#312e81'] : ['#3b82f6', '#8b5cf6']}
          start={{ x: 0, y: 0 }}
          end={{ x: 1, y: 1 }}
          style={{ paddingTop: insets.top }}
        >
          {/* Close Button */}
          <View className="px-4 pt-4">
            <AnimatedPressable
              onPress={() => router.back()}
              className="w-10 h-10 rounded-full bg-white/20 items-center justify-center"
              scaleValue={0.9}
            >
              <Ionicons name="close" size={24} color="white" />
            </AnimatedPressable>
          </View>

          {/* Hero Content */}
          <View className="items-center px-6 py-8">
            <Animated.View 
              entering={FadeInDown.delay(100).springify()}
              className="w-20 h-20 rounded-2xl bg-white/20 items-center justify-center mb-4"
              style={{
                shadowColor: '#fbbf24',
                shadowOffset: { width: 0, height: 8 },
                shadowOpacity: 0.4,
                shadowRadius: 16,
              }}
            >
              <MaterialCommunityIcons name="crown" size={48} color="#fbbf24" />
            </Animated.View>
            <Animated.Text 
              entering={FadeInDown.delay(200).springify()}
              className="text-white text-3xl font-bold text-center"
            >
              Unlock Pro Features
            </Animated.Text>
            <Animated.Text 
              entering={FadeInDown.delay(300).springify()}
              className="text-white/80 text-base text-center mt-2 px-8"
            >
              Get unlimited access to all premium cleanup tools
            </Animated.Text>
          </View>
        </LinearGradient>

        {/* Features List */}
        <View className="px-4 mt-6">
          <Animated.Text 
            entering={FadeInDown.delay(150).springify()}
            className={cn('text-lg font-semibold mb-4', isDark ? 'text-white' : 'text-gray-900')}
          >
            What's Included
          </Animated.Text>

          <Animated.View
            entering={FadeInDown.delay(200).springify()}
            className={cn('p-4 rounded-2xl', isDark ? 'bg-gray-800' : 'bg-white')}
            style={{
              shadowColor: '#000',
              shadowOffset: { width: 0, height: 2 },
              shadowOpacity: isDark ? 0.3 : 0.1,
              shadowRadius: 8,
              elevation: 4,
            }}
          >
            {features.map((feature, index) => (
              <FeatureItem
                key={feature.title}
                {...feature}
                isDark={isDark}
                index={index}
              />
            ))}
          </Animated.View>
        </View>

        {/* Pricing Options */}
        <View className="px-4 mt-6">
          <Animated.Text 
            entering={FadeInDown.delay(250).springify()}
            className={cn('text-lg font-semibold mb-4', isDark ? 'text-white' : 'text-gray-900')}
          >
            Choose Your Plan
          </Animated.Text>

          <PlanCard
            plan="yearly"
            title="Yearly"
            subtitle="Best value • 7-day free trial"
            price="$19.99"
            priceLabel="per year"
            badge="SAVE 60%"
            isSelected={selectedPlan === 'yearly'}
            onPress={() => setSelectedPlan('yearly')}
            isDark={isDark}
            index={0}
          />

          <PlanCard
            plan="monthly"
            title="Monthly"
            subtitle="Cancel anytime"
            price="$4.99"
            priceLabel="per month"
            isSelected={selectedPlan === 'monthly'}
            onPress={() => setSelectedPlan('monthly')}
            isDark={isDark}
            index={1}
          />

          <PlanCard
            plan="lifetime"
            title="Lifetime"
            subtitle="One-time purchase"
            price="$49.99"
            priceLabel="forever"
            isSelected={selectedPlan === 'lifetime'}
            onPress={() => setSelectedPlan('lifetime')}
            isDark={isDark}
            index={2}
          />
        </View>

        {/* Purchase Button */}
        <View className="px-4 mt-4">
          <Animated.View entering={FadeInDown.delay(600).springify()}>
            <AnimatedPressable onPress={handlePurchase} scaleValue={0.98} hapticFeedback="none">
              <LinearGradient
                colors={['#3b82f6', '#2563eb']}
                start={{ x: 0, y: 0 }}
                end={{ x: 1, y: 0 }}
                className="py-4 rounded-2xl items-center justify-center"
                style={{
                  shadowColor: '#3b82f6',
                  shadowOffset: { width: 0, height: 6 },
                  shadowOpacity: 0.4,
                  shadowRadius: 12,
                }}
              >
                <Text className="text-white text-lg font-bold">
                  {selectedPlan === 'yearly' ? 'Start Free Trial' : 'Subscribe Now'}
                </Text>
              </LinearGradient>
            </AnimatedPressable>
          </Animated.View>
        </View>

        {/* Footer */}
        <View className="px-4 mt-4 items-center">
          <AnimatedPressable onPress={handleRestore} scaleValue={0.98}>
            <Text className={cn('text-sm underline', isDark ? 'text-gray-400' : 'text-gray-500')}>
              Restore Purchases
            </Text>
          </AnimatedPressable>
          <Text className={cn('text-xs text-center mt-4 px-8', isDark ? 'text-gray-500' : 'text-gray-400')}>
            Payment will be charged to your Apple ID account. Subscription automatically renews unless cancelled at least 24 hours before the end of the current period.
          </Text>
        </View>
      </ScrollView>
    </View>
  );
}
