import React, { useState } from 'react';
import {
  View,
  Text,
  ScrollView,
  Pressable,
  ActivityIndicator,
  Alert,
  Dimensions,
  FlatList,
} from 'react-native';
import { Image } from 'expo-image';
import { useRouter } from 'expo-router';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useColorScheme } from '@/lib/useColorScheme';
import * as MediaLibrary from 'expo-media-library';
import * as VideoThumbnails from 'expo-video-thumbnails';
import * as Haptics from 'expo-haptics';
import { cn } from '@/lib/cn';
import { Ionicons, MaterialCommunityIcons } from '@expo/vector-icons';
import Animated, { FadeInDown, FadeIn } from 'react-native-reanimated';
import { LinearGradient } from 'expo-linear-gradient';
import { AnimatedPressable } from '@/components/AnimatedPressable';

const { width } = Dimensions.get('window');
const FRAME_SIZE = (width - 48 - 16) / 3;

export default function VideoFramesScreen() {
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';

  const [selectedVideo, setSelectedVideo] = useState<MediaLibrary.Asset | null>(null);
  const [extractedFrames, setExtractedFrames] = useState<string[]>([]);
  const [isExtracting, setIsExtracting] = useState(false);
  const [frameCount, setFrameCount] = useState(6);

  const pickVideo = async () => {
    try {
      const { status } = await MediaLibrary.getPermissionsAsync();
      if (status !== 'granted') {
        Alert.alert('Permission required', 'Please grant photo access to use this feature.');
        return;
      }

      // Get recent videos
      const assets = await MediaLibrary.getAssetsAsync({
        first: 20,
        mediaType: 'video',
        sortBy: [[MediaLibrary.SortBy.creationTime, false]],
      });

      if (assets.assets.length === 0) {
        Alert.alert('No Videos', 'No videos found in your library.');
        return;
      }

      // Select first video (in production, add proper picker UI)
      setSelectedVideo(assets.assets[0]);
      setExtractedFrames([]);
      Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    } catch (error) {
      console.error('Error picking video:', error);
    }
  };

  const extractFrames = async () => {
    if (!selectedVideo) return;

    setIsExtracting(true);
    setExtractedFrames([]);

    try {
      const duration = selectedVideo.duration * 1000; // Convert to ms
      const interval = duration / (frameCount + 1);
      const frames: string[] = [];

      for (let i = 1; i <= frameCount; i++) {
        const time = Math.round(interval * i);
        try {
          const { uri } = await VideoThumbnails.getThumbnailAsync(selectedVideo.uri, {
            time,
            quality: 0.8,
          });
          frames.push(uri);
        } catch (err) {
          console.error(`Error extracting frame at ${time}ms:`, err);
        }
      }

      setExtractedFrames(frames);
      Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    } catch (error) {
      console.error('Frame extraction error:', error);
      Alert.alert('Error', 'Failed to extract frames from video.');
    } finally {
      setIsExtracting(false);
    }
  };

  const saveFrame = async (uri: string) => {
    try {
      await MediaLibrary.saveToLibraryAsync(uri);
      Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
      Alert.alert('Saved', 'Frame saved to your photo library.');
    } catch (error) {
      console.error('Save error:', error);
      Alert.alert('Error', 'Failed to save frame.');
    }
  };

  const saveAllFrames = async () => {
    try {
      for (const uri of extractedFrames) {
        await MediaLibrary.saveToLibraryAsync(uri);
      }
      Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
      Alert.alert('Saved', `${extractedFrames.length} frames saved to your photo library.`);
    } catch (error) {
      console.error('Save all error:', error);
      Alert.alert('Error', 'Failed to save frames.');
    }
  };

  const formatDuration = (seconds: number) => {
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${mins}:${secs.toString().padStart(2, '0')}`;
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
            Video Frames
          </Text>
        </View>
      </Animated.View>

      <ScrollView
        contentContainerStyle={{ paddingBottom: insets.bottom + 100 }}
        showsVerticalScrollIndicator={false}
      >
        {/* Info Card */}
        <Animated.View
          entering={FadeInDown.delay(100).springify()}
          className="mx-4 mt-6"
        >
          <LinearGradient
            colors={['#3b82f6', '#2563eb']}
            className="rounded-2xl p-4 flex-row items-center"
          >
            <View className="w-12 h-12 rounded-xl bg-white/20 items-center justify-center mr-3">
              <MaterialCommunityIcons name="movie-open-outline" size={28} color="white" />
            </View>
            <View className="flex-1">
              <Text className="text-white font-bold text-base">
                Extract Video Frames
              </Text>
              <Text className="text-white/70 text-sm">
                Save still images from any moment in your video
              </Text>
            </View>
          </LinearGradient>
        </Animated.View>

        {/* Video Selection */}
        <Animated.View
          entering={FadeInDown.delay(200).springify()}
          className="mx-4 mt-6"
        >
          <Text
            className={cn(
              'text-sm font-medium mb-3',
              isDark ? 'text-slate-400' : 'text-slate-500'
            )}
          >
            SELECTED VIDEO
          </Text>

          {selectedVideo ? (
            <View
              className={cn(
                'rounded-2xl overflow-hidden',
                isDark ? 'bg-white/5' : 'bg-white'
              )}
            >
              <Image
                source={{ uri: selectedVideo.uri }}
                style={{ width: '100%', height: 200 }}
                contentFit="cover"
              />
              <View className="p-4">
                <Text
                  className={cn(
                    'text-base font-medium',
                    isDark ? 'text-white' : 'text-slate-900'
                  )}
                  numberOfLines={1}
                >
                  {selectedVideo.filename}
                </Text>
                <Text
                  className={cn(
                    'text-sm',
                    isDark ? 'text-slate-400' : 'text-slate-500'
                  )}
                >
                  Duration: {formatDuration(selectedVideo.duration)}
                </Text>
              </View>
            </View>
          ) : (
            <AnimatedPressable
              onPress={pickVideo}
              scaleValue={0.98}
              hapticFeedback="light"
            >
              <View
                className={cn(
                  'h-40 rounded-2xl items-center justify-center border-2 border-dashed',
                  isDark ? 'border-white/20' : 'border-black/10'
                )}
              >
                <Ionicons
                  name="videocam-outline"
                  size={40}
                  color={isDark ? '#60a5fa' : '#3b82f6'}
                />
                <Text
                  className={cn(
                    'text-base font-medium mt-3',
                    isDark ? 'text-white' : 'text-slate-900'
                  )}
                >
                  Select Video
                </Text>
                <Text
                  className={cn(
                    'text-sm mt-1',
                    isDark ? 'text-slate-500' : 'text-slate-400'
                  )}
                >
                  Tap to choose a video
                </Text>
              </View>
            </AnimatedPressable>
          )}

          {selectedVideo && (
            <Pressable
              onPress={pickVideo}
              className={cn(
                'mt-3 py-3 rounded-xl items-center',
                isDark ? 'bg-white/10' : 'bg-black/5'
              )}
            >
              <Text
                className={cn(
                  'font-medium',
                  isDark ? 'text-blue-400' : 'text-blue-600'
                )}
              >
                Choose Different Video
              </Text>
            </Pressable>
          )}
        </Animated.View>

        {/* Frame Count Selector */}
        {selectedVideo && (
          <Animated.View
            entering={FadeInDown.delay(250).springify()}
            className="mx-4 mt-6"
          >
            <Text
              className={cn(
                'text-sm font-medium mb-3',
                isDark ? 'text-slate-400' : 'text-slate-500'
              )}
            >
              NUMBER OF FRAMES
            </Text>
            <View className="flex-row gap-2">
              {[3, 6, 9, 12].map((count) => (
                <Pressable
                  key={count}
                  onPress={() => {
                    setFrameCount(count);
                    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
                  }}
                  className={cn(
                    'flex-1 py-3 rounded-xl items-center',
                    frameCount === count
                      ? 'bg-blue-500'
                      : isDark
                        ? 'bg-white/10'
                        : 'bg-white'
                  )}
                >
                  <Text
                    className={cn(
                      'font-semibold',
                      frameCount === count
                        ? 'text-white'
                        : isDark
                          ? 'text-white'
                          : 'text-slate-900'
                    )}
                  >
                    {count}
                  </Text>
                </Pressable>
              ))}
            </View>
          </Animated.View>
        )}

        {/* Extract Button */}
        {selectedVideo && extractedFrames.length === 0 && (
          <Animated.View
            entering={FadeInDown.delay(300).springify()}
            className="mx-4 mt-6"
          >
            <AnimatedPressable
              onPress={extractFrames}
              scaleValue={0.98}
              hapticFeedback="medium"
              disabled={isExtracting}
            >
              <LinearGradient
                colors={isExtracting ? ['#64748b', '#475569'] : ['#3b82f6', '#2563eb']}
                className="rounded-2xl py-4 items-center"
              >
                {isExtracting ? (
                  <View className="flex-row items-center">
                    <ActivityIndicator size="small" color="white" />
                    <Text className="text-white font-bold text-lg ml-3">
                      Extracting Frames...
                    </Text>
                  </View>
                ) : (
                  <Text className="text-white font-bold text-lg">
                    Extract {frameCount} Frames
                  </Text>
                )}
              </LinearGradient>
            </AnimatedPressable>
          </Animated.View>
        )}

        {/* Extracted Frames */}
        {extractedFrames.length > 0 && (
          <Animated.View
            entering={FadeInDown.springify()}
            className="mx-4 mt-6"
          >
            <View className="flex-row items-center justify-between mb-3">
              <Text
                className={cn(
                  'text-sm font-medium',
                  isDark ? 'text-slate-400' : 'text-slate-500'
                )}
              >
                EXTRACTED FRAMES ({extractedFrames.length})
              </Text>
              <Pressable onPress={saveAllFrames}>
                <Text className="text-blue-500 font-medium text-sm">
                  Save All
                </Text>
              </Pressable>
            </View>
            
            <View className="flex-row flex-wrap gap-2">
              {extractedFrames.map((uri, index) => (
                <Pressable
                  key={index}
                  onPress={() => saveFrame(uri)}
                  className="rounded-xl overflow-hidden"
                >
                  <Image
                    source={{ uri }}
                    style={{ width: FRAME_SIZE, height: FRAME_SIZE }}
                    contentFit="cover"
                  />
                  <View className="absolute bottom-2 right-2 bg-black/60 px-2 py-1 rounded-full">
                    <Ionicons name="download-outline" size={14} color="white" />
                  </View>
                </Pressable>
              ))}
            </View>

            <AnimatedPressable
              onPress={extractFrames}
              scaleValue={0.98}
              hapticFeedback="light"
              className="mt-4"
            >
              <View
                className={cn(
                  'py-3 rounded-xl items-center',
                  isDark ? 'bg-white/10' : 'bg-black/5'
                )}
              >
                <Text
                  className={cn(
                    'font-medium',
                    isDark ? 'text-blue-400' : 'text-blue-600'
                  )}
                >
                  Extract Again
                </Text>
              </View>
            </AnimatedPressable>
          </Animated.View>
        )}
      </ScrollView>
    </View>
  );
}
