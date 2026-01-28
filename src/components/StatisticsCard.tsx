import React, { useEffect } from 'react';
import { View, Text, ActivityIndicator, Dimensions } from 'react-native';
import { useColorScheme } from '@/lib/useColorScheme';
import { cn } from '@/lib/cn';
import { formatBytes } from '@/lib/state/gallery-store';
import { useStorageStats } from '@/lib/hooks/useStorageStats';
import { Ionicons } from '@expo/vector-icons';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withTiming,
  withSpring,
  withDelay,
  interpolate,
  Easing,
  FadeIn,
  FadeInDown,
} from 'react-native-reanimated';
import { LinearGradient } from 'expo-linear-gradient';

const { width } = Dimensions.get('window');

interface AnimatedProgressBarProps {
  percentage: number;
  color: string;
  gradientColors?: [string, string];
  isDark: boolean;
  delay?: number;
}

function AnimatedProgressBar({ 
  percentage, 
  color, 
  gradientColors,
  isDark, 
  delay = 0 
}: AnimatedProgressBarProps) {
  const progress = useSharedValue(0);
  
  useEffect(() => {
    progress.value = withDelay(
      delay,
      withTiming(Math.min(100, Math.max(0, percentage)), {
        duration: 1000,
        easing: Easing.bezier(0.25, 0.1, 0.25, 1),
      })
    );
  }, [percentage]);

  const animatedStyle = useAnimatedStyle(() => ({
    width: `${progress.value}%`,
  }));

  return (
    <View
      className={cn(
        'h-2 rounded-full overflow-hidden',
        isDark ? 'bg-white/10' : 'bg-black/5'
      )}
    >
      <Animated.View style={animatedStyle} className="h-full rounded-full overflow-hidden">
        {gradientColors ? (
          <LinearGradient
            colors={gradientColors}
            start={{ x: 0, y: 0 }}
            end={{ x: 1, y: 0 }}
            style={{ width: '100%', height: '100%' }}
          />
        ) : (
          <View style={{ backgroundColor: color, width: '100%', height: '100%' }} />
        )}
      </Animated.View>
    </View>
  );
}

interface AnimatedCounterProps {
  value: number;
  suffix?: string;
  className?: string;
  delay?: number;
}

function AnimatedNumberCounter({ value, suffix = '', className, delay = 0 }: AnimatedCounterProps) {
  const animatedValue = useSharedValue(0);
  const [displayValue, setDisplayValue] = React.useState(0);
  
  useEffect(() => {
    animatedValue.value = withDelay(
      delay,
      withTiming(value, {
        duration: 1200,
        easing: Easing.bezier(0.25, 0.1, 0.25, 1),
      })
    );
    
    // Update display value periodically
    const interval = setInterval(() => {
      setDisplayValue(Math.round(animatedValue.value));
    }, 16);
    
    setTimeout(() => {
      setDisplayValue(value);
      clearInterval(interval);
    }, delay + 1200);
    
    return () => clearInterval(interval);
  }, [value, delay]);

  return (
    <Animated.Text className={className}>
      {displayValue.toLocaleString()}{suffix}
    </Animated.Text>
  );
}

export function StatisticsCard() {
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';
  const stats = useStorageStats();
  const iconPulse = useSharedValue(1);

  const iconColor = isDark ? '#94a3b8' : '#64748b';

  useEffect(() => {
    iconPulse.value = withDelay(
      300,
      withSpring(1.1, { damping: 8 }, () => {
        iconPulse.value = withSpring(1, { damping: 15 });
      })
    );
  }, []);

  const iconAnimatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: iconPulse.value }],
  }));

  if (stats.loading) {
    return (
      <Animated.View
        entering={FadeIn.duration(300)}
        className={cn(
          'mx-4 rounded-xl p-6 items-center justify-center',
          isDark ? 'bg-white/5' : 'bg-white'
        )}
        style={{
          shadowColor: '#000',
          shadowOffset: { width: 0, height: 1 },
          shadowOpacity: isDark ? 0 : 0.05,
          shadowRadius: 3,
          minHeight: 150,
        }}
      >
        <ActivityIndicator size="small" color={isDark ? '#60a5fa' : '#3b82f6'} />
        <Text className={cn('text-sm mt-2', isDark ? 'text-slate-400' : 'text-slate-500')}>
          Calculating storage...
        </Text>
      </Animated.View>
    );
  }

  if (stats.error) {
    return null;
  }

  const photoPercentage = stats.totalStorage > 0 
    ? (stats.photoStorage / stats.totalStorage) * 100 
    : 0;
  const videoPercentage = stats.totalStorage > 0 
    ? (stats.videoStorage / stats.totalStorage) * 100 
    : 0;

  return (
    <Animated.View
      entering={FadeInDown.duration(400).springify()}
      className={cn(
        'mx-4 rounded-xl overflow-hidden',
        isDark ? 'bg-white/5' : 'bg-white'
      )}
      style={{
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: isDark ? 0.1 : 0.08,
        shadowRadius: 8,
        elevation: 4,
      }}
    >
      <View className="p-5">
        <View className="flex-row items-center mb-4">
          <Animated.View style={iconAnimatedStyle}>
            <Ionicons name="hardware-chip" size={20} color={iconColor} />
          </Animated.View>
          <Text
            className={cn(
              'text-base font-semibold ml-2',
              isDark ? 'text-white' : 'text-slate-900'
            )}
          >
            Storage Statistics
          </Text>
        </View>

        {/* Total Storage with animated counter */}
        <View className="mb-4">
          <Animated.View entering={FadeInDown.delay(100).springify()}>
            <Text
              className={cn(
                'text-2xl font-bold mb-1',
                isDark ? 'text-white' : 'text-slate-900'
              )}
            >
              {formatBytes(stats.totalStorage)}
            </Text>
            <Text
              className={cn('text-sm', isDark ? 'text-slate-400' : 'text-slate-500')}
            >
              Total storage used
            </Text>
          </Animated.View>
        </View>

        {/* Storage Distribution Visual - Animated */}
        {stats.totalStorage > 0 && (
          <Animated.View 
            entering={FadeInDown.delay(200).springify()}
            className="mb-4"
          >
            <View
              className={cn(
                'h-4 rounded-full overflow-hidden flex-row',
                isDark ? 'bg-white/10' : 'bg-black/5'
              )}
            >
              <AnimatedProgressBar
                percentage={photoPercentage}
                color={isDark ? '#60a5fa' : '#3b82f6'}
                gradientColors={['#3b82f6', '#60a5fa']}
                isDark={isDark}
                delay={300}
              />
              <AnimatedProgressBar
                percentage={videoPercentage}
                color={isDark ? '#34d399' : '#10b981'}
                gradientColors={['#10b981', '#34d399']}
                isDark={isDark}
                delay={500}
              />
            </View>
          </Animated.View>
        )}

        {/* Breakdown */}
        <View className="space-y-3">
          {/* Photos */}
          <Animated.View 
            entering={FadeInDown.delay(300).springify()}
            className="flex-row items-center justify-between mb-3"
          >
            <View className="flex-row items-center">
              <View
                className="w-3 h-3 rounded-full mr-2"
                style={{ backgroundColor: isDark ? '#60a5fa' : '#3b82f6' }}
              />
              <Ionicons name="image" size={16} color={iconColor} />
              <Text
                className={cn('text-sm ml-2', isDark ? 'text-slate-300' : 'text-slate-600')}
              >
                Photos
              </Text>
            </View>
            <View className="items-end">
              <Text
                className={cn(
                  'text-sm font-medium',
                  isDark ? 'text-white' : 'text-slate-900'
                )}
              >
                {stats.totalPhotos.toLocaleString()}
              </Text>
              <Text
                className={cn('text-xs', isDark ? 'text-slate-500' : 'text-slate-400')}
              >
                {formatBytes(stats.photoStorage)}
              </Text>
            </View>
          </Animated.View>

          {/* Videos */}
          <Animated.View 
            entering={FadeInDown.delay(400).springify()}
            className="flex-row items-center justify-between"
          >
            <View className="flex-row items-center">
              <View
                className="w-3 h-3 rounded-full mr-2"
                style={{ backgroundColor: isDark ? '#34d399' : '#10b981' }}
              />
              <Ionicons name="videocam" size={16} color={iconColor} />
              <Text
                className={cn('text-sm ml-2', isDark ? 'text-slate-300' : 'text-slate-600')}
              >
                Videos
              </Text>
            </View>
            <View className="items-end">
              <Text
                className={cn(
                  'text-sm font-medium',
                  isDark ? 'text-white' : 'text-slate-900'
                )}
              >
                {stats.totalVideos.toLocaleString()}
              </Text>
              <Text
                className={cn('text-xs', isDark ? 'text-slate-500' : 'text-slate-400')}
              >
                {formatBytes(stats.videoStorage)}
              </Text>
            </View>
          </Animated.View>
        </View>

        {/* Media Count Bars - Animated */}
        {(stats.totalPhotos > 0 || stats.totalVideos > 0) && (
          <Animated.View 
            entering={FadeInDown.delay(500).springify()}
            className="mt-4"
          >
            <Text
              className={cn(
                'text-sm font-semibold mb-2',
                isDark ? 'text-slate-400' : 'text-slate-500'
              )}
            >
              Media Count
            </Text>
            
            {/* Photos Bar */}
            <View className="mb-2">
              <View className="flex-row items-center justify-between mb-1">
                <Text
                  className={cn('text-xs', isDark ? 'text-slate-400' : 'text-slate-500')}
                >
                  Photos
                </Text>
                <Text
                  className={cn('text-xs font-medium', isDark ? 'text-slate-300' : 'text-slate-600')}
                >
                  {stats.totalPhotos.toLocaleString()}
                </Text>
              </View>
              <AnimatedProgressBar
                percentage={(stats.totalPhotos / Math.max(stats.totalPhotos, stats.totalVideos)) * 100}
                color={isDark ? '#60a5fa' : '#3b82f6'}
                gradientColors={['#3b82f6', '#60a5fa']}
                isDark={isDark}
                delay={600}
              />
            </View>
            
            {/* Videos Bar */}
            <View>
              <View className="flex-row items-center justify-between mb-1">
                <Text
                  className={cn('text-xs', isDark ? 'text-slate-400' : 'text-slate-500')}
                >
                  Videos
                </Text>
                <Text
                  className={cn('text-xs font-medium', isDark ? 'text-slate-300' : 'text-slate-600')}
                >
                  {stats.totalVideos.toLocaleString()}
                </Text>
              </View>
              <AnimatedProgressBar
                percentage={(stats.totalVideos / Math.max(stats.totalPhotos, stats.totalVideos)) * 100}
                color={isDark ? '#34d399' : '#10b981'}
                gradientColors={['#10b981', '#34d399']}
                isDark={isDark}
                delay={700}
              />
            </View>
          </Animated.View>
        )}
      </View>
    </Animated.View>
  );
}
