import React, { useState, useCallback } from 'react';
import {
  View,
  Text,
  ScrollView,
  Pressable,
  ActivityIndicator,
  Alert,
  Dimensions,
} from 'react-native';
import { Image } from 'expo-image';
import { useRouter } from 'expo-router';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useColorScheme } from '@/lib/useColorScheme';
import * as MediaLibrary from 'expo-media-library';
import * as ImageManipulator from 'expo-image-manipulator';
import * as FileSystem from 'expo-file-system';
import * as Haptics from 'expo-haptics';
import { cn } from '@/lib/cn';
import { Ionicons, MaterialIcons } from '@expo/vector-icons';
import Animated, { FadeInDown, FadeIn } from 'react-native-reanimated';
import { LinearGradient } from 'expo-linear-gradient';
import { AnimatedPressable } from '@/components/AnimatedPressable';
import { formatBytes } from '@/lib/state/gallery-store';

const { width } = Dimensions.get('window');

type CompressionQuality = 'high' | 'medium' | 'low';

interface QualityOption {
  id: CompressionQuality;
  label: string;
  description: string;
  quality: number;
  resize?: number;
}

const QUALITY_OPTIONS: QualityOption[] = [
  { id: 'high', label: 'High Quality', description: '~30% smaller', quality: 0.8 },
  { id: 'medium', label: 'Medium', description: '~50% smaller', quality: 0.6, resize: 0.8 },
  { id: 'low', label: 'Small Size', description: '~70% smaller', quality: 0.4, resize: 0.6 },
];

export default function CompressScreen() {
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';

  const [selectedPhotos, setSelectedPhotos] = useState<MediaLibrary.Asset[]>([]);
  const [selectedQuality, setSelectedQuality] = useState<CompressionQuality>('medium');
  const [isCompressing, setIsCompressing] = useState(false);
  const [progress, setProgress] = useState(0);
  const [result, setResult] = useState<{ originalSize: number; compressedSize: number } | null>(null);

  const pickPhotos = async () => {
    try {
      const { status } = await MediaLibrary.getPermissionsAsync();
      if (status !== 'granted') {
        Alert.alert('Permission required', 'Please grant photo access to use this feature.');
        return;
      }

      // Get recent photos for selection
      const assets = await MediaLibrary.getAssetsAsync({
        first: 50,
        mediaType: 'photo',
        sortBy: [[MediaLibrary.SortBy.creationTime, false]],
      });

      // For simplicity, select first 5 photos (in production, add proper picker UI)
      setSelectedPhotos(assets.assets.slice(0, 5));
      Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    } catch (error) {
      console.error('Error picking photos:', error);
    }
  };

  const compressPhotos = async () => {
    if (selectedPhotos.length === 0) return;

    setIsCompressing(true);
    setProgress(0);
    setResult(null);

    try {
      const quality = QUALITY_OPTIONS.find((q) => q.id === selectedQuality)!;
      let totalOriginal = 0;
      let totalCompressed = 0;

      for (let i = 0; i < selectedPhotos.length; i++) {
        const photo = selectedPhotos[i];
        const assetInfo = await MediaLibrary.getAssetInfoAsync(photo.id);
        const originalSize = (assetInfo as any)?.fileSize || 0;
        totalOriginal += originalSize;

        // Compress the image
        const manipulateActions: ImageManipulator.Action[] = [];
        if (quality.resize) {
          manipulateActions.push({
            resize: {
              width: Math.round(photo.width * quality.resize),
              height: Math.round(photo.height * quality.resize),
            },
          });
        }

        const result = await ImageManipulator.manipulateAsync(
          photo.uri,
          manipulateActions,
          {
            compress: quality.quality,
            format: ImageManipulator.SaveFormat.JPEG,
          }
        );

        // Get compressed size
        const compressedInfo = await FileSystem.getInfoAsync(result.uri);
        if (compressedInfo.exists && 'size' in compressedInfo) {
          totalCompressed += compressedInfo.size;
        }

        // Save to library
        await MediaLibrary.saveToLibraryAsync(result.uri);

        setProgress((i + 1) / selectedPhotos.length);
        Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
      }

      setResult({
        originalSize: totalOriginal,
        compressedSize: totalCompressed,
      });

      Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    } catch (error) {
      console.error('Compression error:', error);
      Alert.alert('Error', 'Failed to compress some photos.');
    } finally {
      setIsCompressing(false);
    }
  };

  return (
    <View className={cn('flex-1', isDark ? 'bg-black' : 'bg-slate-50')}>
      {/* Header */}
      <Animated.View
        entering={FadeIn.duration(400)}
        className={cn(
          'px-4 pb-4 border-b',
          isDark ? 'bg-black border-white/10' : 'bg-slate-50 border-black/5'
        )}
        style={{ paddingTop: insets.top + 12 }}
      >
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
            />
          </Pressable>
          <Text
            className={cn(
              'text-2xl font-bold',
              isDark ? 'text-white' : 'text-slate-900'
            )}
          >
            Compress Photos
          </Text>
        </View>
      </Animated.View>

      <ScrollView
        contentContainerStyle={{ paddingBottom: insets.bottom + 100 }}
        showsVerticalScrollIndicator={false}
      >
        {/* Selected Photos Preview */}
        <Animated.View
          entering={FadeInDown.delay(100).springify()}
          className="mx-4 mt-6"
        >
          <Text
            className={cn(
              'text-sm font-medium mb-3',
              isDark ? 'text-slate-400' : 'text-slate-500'
            )}
          >
            SELECTED PHOTOS
          </Text>
          
          {selectedPhotos.length > 0 ? (
            <ScrollView
              horizontal
              showsHorizontalScrollIndicator={false}
              className="mb-4"
            >
              <View className="flex-row gap-2">
                {selectedPhotos.map((photo, index) => (
                  <View key={photo.id} className="rounded-xl overflow-hidden">
                    <Image
                      source={{ uri: photo.uri }}
                      style={{ width: 80, height: 80 }}
                      contentFit="cover"
                    />
                  </View>
                ))}
                <Pressable
                  onPress={pickPhotos}
                  className={cn(
                    'w-20 h-20 rounded-xl items-center justify-center',
                    isDark ? 'bg-white/10' : 'bg-black/5'
                  )}
                >
                  <Ionicons
                    name="add"
                    size={28}
                    color={isDark ? '#60a5fa' : '#3b82f6'}
                  />
                </Pressable>
              </View>
            </ScrollView>
          ) : (
            <AnimatedPressable
              onPress={pickPhotos}
              scaleValue={0.98}
              hapticFeedback="light"
            >
              <View
                className={cn(
                  'h-32 rounded-2xl items-center justify-center border-2 border-dashed',
                  isDark ? 'border-white/20' : 'border-black/10'
                )}
              >
                <Ionicons
                  name="images-outline"
                  size={36}
                  color={isDark ? '#60a5fa' : '#3b82f6'}
                />
                <Text
                  className={cn(
                    'text-base font-medium mt-2',
                    isDark ? 'text-white' : 'text-slate-900'
                  )}
                >
                  Select Photos
                </Text>
                <Text
                  className={cn(
                    'text-sm mt-1',
                    isDark ? 'text-slate-500' : 'text-slate-400'
                  )}
                >
                  Tap to choose photos to compress
                </Text>
              </View>
            </AnimatedPressable>
          )}
        </Animated.View>

        {/* Quality Options */}
        <Animated.View
          entering={FadeInDown.delay(200).springify()}
          className="mx-4 mt-4"
        >
          <Text
            className={cn(
              'text-sm font-medium mb-3',
              isDark ? 'text-slate-400' : 'text-slate-500'
            )}
          >
            COMPRESSION QUALITY
          </Text>
          
          <View className="gap-3">
            {QUALITY_OPTIONS.map((option) => (
              <Pressable
                key={option.id}
                onPress={() => {
                  setSelectedQuality(option.id);
                  Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
                }}
              >
                <View
                  className={cn(
                    'flex-row items-center p-4 rounded-2xl',
                    selectedQuality === option.id
                      ? isDark
                        ? 'bg-blue-500/20 border border-blue-500'
                        : 'bg-blue-50 border border-blue-500'
                      : isDark
                        ? 'bg-white/5'
                        : 'bg-white'
                  )}
                >
                  <View
                    className={cn(
                      'w-6 h-6 rounded-full border-2 items-center justify-center mr-3',
                      selectedQuality === option.id
                        ? 'border-blue-500 bg-blue-500'
                        : isDark
                          ? 'border-white/30'
                          : 'border-black/20'
                    )}
                  >
                    {selectedQuality === option.id && (
                      <Ionicons name="checkmark" size={14} color="white" />
                    )}
                  </View>
                  <View className="flex-1">
                    <Text
                      className={cn(
                        'text-base font-medium',
                        isDark ? 'text-white' : 'text-slate-900'
                      )}
                    >
                      {option.label}
                    </Text>
                    <Text
                      className={cn(
                        'text-sm',
                        isDark ? 'text-slate-400' : 'text-slate-500'
                      )}
                    >
                      {option.description}
                    </Text>
                  </View>
                </View>
              </Pressable>
            ))}
          </View>
        </Animated.View>

        {/* Result Card */}
        {result && (
          <Animated.View
            entering={FadeInDown.springify()}
            className="mx-4 mt-6"
          >
            <LinearGradient
              colors={['#10b981', '#059669']}
              className="rounded-2xl p-4"
            >
              <View className="flex-row items-center mb-3">
                <Ionicons name="checkmark-circle" size={24} color="white" />
                <Text className="text-white font-bold text-lg ml-2">
                  Compression Complete!
                </Text>
              </View>
              <View className="flex-row justify-between">
                <View>
                  <Text className="text-white/70 text-xs">Original</Text>
                  <Text className="text-white font-semibold">
                    {formatBytes(result.originalSize)}
                  </Text>
                </View>
                <Ionicons name="arrow-forward" size={20} color="white" />
                <View>
                  <Text className="text-white/70 text-xs">Compressed</Text>
                  <Text className="text-white font-semibold">
                    {formatBytes(result.compressedSize)}
                  </Text>
                </View>
                <View>
                  <Text className="text-white/70 text-xs">Saved</Text>
                  <Text className="text-white font-semibold">
                    {formatBytes(result.originalSize - result.compressedSize)}
                  </Text>
                </View>
              </View>
            </LinearGradient>
          </Animated.View>
        )}

        {/* Compress Button */}
        <Animated.View
          entering={FadeInDown.delay(300).springify()}
          className="mx-4 mt-6"
        >
          <AnimatedPressable
            onPress={compressPhotos}
            scaleValue={0.98}
            hapticFeedback="medium"
            disabled={selectedPhotos.length === 0 || isCompressing}
          >
            <LinearGradient
              colors={
                selectedPhotos.length === 0 || isCompressing
                  ? ['#64748b', '#475569']
                  : ['#10b981', '#059669']
              }
              className="rounded-2xl py-4 items-center"
            >
              {isCompressing ? (
                <View className="flex-row items-center">
                  <ActivityIndicator size="small" color="white" />
                  <Text className="text-white font-bold text-lg ml-3">
                    Compressing... {Math.round(progress * 100)}%
                  </Text>
                </View>
              ) : (
                <Text className="text-white font-bold text-lg">
                  Compress {selectedPhotos.length > 0 ? `${selectedPhotos.length} Photos` : 'Photos'}
                </Text>
              )}
            </LinearGradient>
          </AnimatedPressable>
        </Animated.View>
      </ScrollView>
    </View>
  );
}
