import React, { useEffect, useState, useCallback } from 'react';
import {
  View,
  Text,
  Pressable,
  ScrollView,
  ActivityIndicator,
} from 'react-native';
import { useRouter } from 'expo-router';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useColorScheme } from '@/lib/useColorScheme';
import { useGalleryStore } from '@/lib/state/gallery-store';
import * as MediaLibrary from 'expo-media-library';
import * as Haptics from 'expo-haptics';
import { cn } from '@/lib/cn';
import { detectDuplicates, DuplicateGroup } from '@/lib/utils/duplicateDetection';
import { DuplicateGroupComponent } from '@/components/DuplicateGroup';
import { Ionicons } from '@expo/vector-icons';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
  withTiming,
} from 'react-native-reanimated';
import { LinearGradient } from 'expo-linear-gradient';

export default function DuplicatesScreen() {
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';

  const [duplicateGroups, setDuplicateGroups] = useState<DuplicateGroup[]>([]);
  const [loading, setLoading] = useState(true);
  const [progress, setProgress] = useState(0);
  const [isScanning, setIsScanning] = useState(false);

  const addToDeleteQueue = useGalleryStore((s) => s.addToDeleteQueue);
  const removeFromDeleteQueue = useGalleryStore((s) => s.removeFromDeleteQueue);

  const progressValue = useSharedValue(0);

  useEffect(() => {
    scanForDuplicates();
  }, []);

  const scanForDuplicates = async () => {
    try {
      setLoading(true);
      setIsScanning(true);
      progressValue.value = 0;

      // Load all photos
      const result = await MediaLibrary.getAssetsAsync({
        first: 10000,
        mediaType: 'photo',
        sortBy: [[MediaLibrary.SortBy.creationTime, false]],
      });

      // Detect duplicates
      const groups = await detectDuplicates(result.assets, (prog) => {
        progressValue.value = withTiming(prog);
        setProgress(prog);
      });

      setDuplicateGroups(groups);
    } catch (error) {
      console.error('Error scanning for duplicates:', error);
    } finally {
      setLoading(false);
      setIsScanning(false);
    }
  };

  const progressAnimatedStyle = useAnimatedStyle(() => ({
    width: `${progressValue.value * 100}%`,
  }));

  const handleSelectAll = useCallback(
    (photoIds: string[]) => {
      photoIds.forEach((id) => addToDeleteQueue(id));
    },
    [addToDeleteQueue]
  );

  const handleDeselectAll = useCallback(
    (photoIds: string[]) => {
      photoIds.forEach((id) => removeFromDeleteQueue(id));
    },
    [removeFromDeleteQueue]
  );

  const totalDuplicates = duplicateGroups.reduce(
    (sum, group) => sum + group.photos.length,
    0
  );
  const totalGroups = duplicateGroups.length;

  if (loading) {
    return (
      <View
        className={cn(
          'flex-1 items-center justify-center px-8',
          isDark ? 'bg-black' : 'bg-slate-50'
        )}
      >
        <View className="items-center">
          <ActivityIndicator size="large" color={isDark ? '#60a5fa' : '#3b82f6'} />
          <Text
            className={cn(
              'text-base mt-4 text-center',
              isDark ? 'text-slate-400' : 'text-slate-500'
            )}
          >
            Scanning for duplicates...
          </Text>
          {isScanning && (
            <View className="w-full mt-4">
              <View
                className={cn(
                  'h-2 rounded-full overflow-hidden',
                  isDark ? 'bg-white/10' : 'bg-black/10'
                )}
              >
                <Animated.View
                  style={[
                    progressAnimatedStyle,
                    {
                      height: '100%',
                      backgroundColor: isDark ? '#60a5fa' : '#3b82f6',
                    },
                  ]}
                />
              </View>
              <Text
                className={cn(
                  'text-sm mt-2 text-center',
                  isDark ? 'text-slate-500' : 'text-slate-400'
                )}
              >
                {Math.round(progress * 100)}%
              </Text>
            </View>
          )}
        </View>
      </View>
    );
  }

  return (
    <View className={cn('flex-1', isDark ? 'bg-black' : 'bg-slate-50')}>
      {/* Header */}
      <View
        className={cn(
          'px-4 pb-3 border-b',
          isDark ? 'bg-black border-white/10' : 'bg-slate-50 border-black/5'
        )}
        style={{ paddingTop: insets.top + 12 }}
      >
        <View className="flex-row items-center justify-between">
          <View className="flex-row items-center">
            <Pressable
              onPress={() => router.back()}
              className={cn(
                'w-10 h-10 rounded-full items-center justify-center mr-3',
                isDark ? 'bg-white/10' : 'bg-black/5'
              )}
            >
              <Ionicons
                name="chevron-back"
                size={24}
                color={isDark ? '#fff' : '#1e293b'}
                strokeWidth={2}
              />
            </Pressable>
            <View>
              <Text
                className={cn(
                  'text-2xl font-bold',
                  isDark ? 'text-white' : 'text-slate-900'
                )}
              >
                Duplicates
              </Text>
              {totalGroups > 0 && (
                <Text
                  className={cn(
                    'text-sm mt-0.5',
                    isDark ? 'text-slate-400' : 'text-slate-500'
                  )}
                >
                  {totalGroups} groups · {totalDuplicates} photos
                </Text>
              )}
            </View>
          </View>

          <Pressable
            onPress={scanForDuplicates}
            className={cn(
              'px-3 py-2 rounded-full',
              isDark ? 'bg-white/10' : 'bg-black/5'
            )}
          >
            <Text
              className={cn(
                'text-sm font-medium',
                isDark ? 'text-slate-300' : 'text-slate-600'
              )}
            >
              Rescan
            </Text>
          </Pressable>
        </View>
      </View>

      {/* Content */}
      {totalGroups === 0 ? (
        <View className="flex-1 items-center justify-center px-8">
          <View
            className={cn(
              'w-20 h-20 rounded-full items-center justify-center mb-6',
              isDark ? 'bg-white/5' : 'bg-black/5'
            )}
          >
            <Ionicons
              name="checkmark-circle"
              size={36}
              color={isDark ? '#22c55e' : '#16a34a'}
              strokeWidth={1.5}
            />
          </View>
          <Text
            className={cn(
              'text-xl font-semibold text-center mb-2',
              isDark ? 'text-white' : 'text-slate-900'
            )}
          >
            No Duplicates Found
          </Text>
          <Text
            className={cn(
              'text-base text-center',
              isDark ? 'text-slate-500' : 'text-slate-400'
            )}
          >
            Your gallery looks clean! No duplicate photos detected.
          </Text>
        </View>
      ) : (
        <ScrollView
          contentContainerStyle={{
            paddingTop: 16,
            paddingBottom: insets.bottom + 100,
          }}
          showsVerticalScrollIndicator={false}
        >
          {duplicateGroups.map((group) => (
            <DuplicateGroupComponent
              key={group.id}
              group={group}
              onSelectAll={handleSelectAll}
              onDeselectAll={handleDeselectAll}
            />
          ))}
        </ScrollView>
      )}
    </View>
  );
}
