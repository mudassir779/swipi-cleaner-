import React, { useState } from 'react';
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
import * as Print from 'expo-print';
import * as Sharing from 'expo-sharing';
import * as Haptics from 'expo-haptics';
import { cn } from '@/lib/cn';
import { Ionicons, MaterialCommunityIcons } from '@expo/vector-icons';
import Animated, { FadeInDown, FadeIn } from 'react-native-reanimated';
import { LinearGradient } from 'expo-linear-gradient';
import { AnimatedPressable } from '@/components/AnimatedPressable';

const { width } = Dimensions.get('window');

export default function CreatePDFScreen() {
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';

  const [selectedPhotos, setSelectedPhotos] = useState<MediaLibrary.Asset[]>([]);
  const [isCreating, setIsCreating] = useState(false);

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

  const removePhoto = (id: string) => {
    setSelectedPhotos((prev) => prev.filter((p) => p.id !== id));
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
  };

  const createPDF = async () => {
    if (selectedPhotos.length === 0) return;

    setIsCreating(true);

    try {
      // Build HTML with images
      const imageElements = selectedPhotos
        .map(
          (photo) => `
          <div style="page-break-after: always; display: flex; justify-content: center; align-items: center; height: 100vh;">
            <img src="${photo.uri}" style="max-width: 100%; max-height: 100%; object-fit: contain;" />
          </div>
        `
        )
        .join('');

      const html = `
        <!DOCTYPE html>
        <html>
          <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
              * { margin: 0; padding: 0; box-sizing: border-box; }
              body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; }
              @page { margin: 0; }
            </style>
          </head>
          <body>
            ${imageElements}
          </body>
        </html>
      `;

      // Generate PDF
      const { uri } = await Print.printToFileAsync({
        html,
        base64: false,
      });

      Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);

      // Share the PDF
      if (await Sharing.isAvailableAsync()) {
        await Sharing.shareAsync(uri, {
          mimeType: 'application/pdf',
          dialogTitle: 'Share PDF',
          UTI: 'com.adobe.pdf',
        });
      } else {
        Alert.alert('Success', 'PDF created successfully!');
      }
    } catch (error) {
      console.error('PDF creation error:', error);
      Alert.alert('Error', 'Failed to create PDF.');
    } finally {
      setIsCreating(false);
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
            Create PDF
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
            colors={['#ef4444', '#dc2626']}
            className="rounded-2xl p-4 flex-row items-center"
          >
            <View className="w-12 h-12 rounded-xl bg-white/20 items-center justify-center mr-3">
              <MaterialCommunityIcons name="file-pdf-box" size={28} color="white" />
            </View>
            <View className="flex-1">
              <Text className="text-white font-bold text-base">
                Images to PDF
              </Text>
              <Text className="text-white/70 text-sm">
                Combine multiple images into a single PDF document
              </Text>
            </View>
          </LinearGradient>
        </Animated.View>

        {/* Selected Photos */}
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
            SELECTED IMAGES ({selectedPhotos.length})
          </Text>

          {selectedPhotos.length > 0 ? (
            <View className="gap-2">
              {selectedPhotos.map((photo, index) => (
                <View
                  key={photo.id}
                  className={cn(
                    'flex-row items-center p-3 rounded-xl',
                    isDark ? 'bg-white/5' : 'bg-white'
                  )}
                >
                  <Text
                    className={cn(
                      'w-6 text-center font-bold mr-3',
                      isDark ? 'text-slate-400' : 'text-slate-500'
                    )}
                  >
                    {index + 1}
                  </Text>
                  <Image
                    source={{ uri: photo.uri }}
                    style={{ width: 50, height: 50, borderRadius: 8 }}
                    contentFit="cover"
                  />
                  <Text
                    className={cn(
                      'flex-1 ml-3 text-sm',
                      isDark ? 'text-white' : 'text-slate-900'
                    )}
                    numberOfLines={1}
                  >
                    {photo.filename}
                  </Text>
                  <Pressable
                    onPress={() => removePhoto(photo.id)}
                    className="w-8 h-8 rounded-full items-center justify-center"
                  >
                    <Ionicons
                      name="close-circle"
                      size={22}
                      color={isDark ? '#ef4444' : '#dc2626'}
                    />
                  </Pressable>
                </View>
              ))}
            </View>
          ) : (
            <AnimatedPressable
              onPress={pickPhotos}
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
                  name="images-outline"
                  size={40}
                  color={isDark ? '#60a5fa' : '#3b82f6'}
                />
                <Text
                  className={cn(
                    'text-base font-medium mt-3',
                    isDark ? 'text-white' : 'text-slate-900'
                  )}
                >
                  Select Images
                </Text>
                <Text
                  className={cn(
                    'text-sm mt-1',
                    isDark ? 'text-slate-500' : 'text-slate-400'
                  )}
                >
                  Tap to choose images for your PDF
                </Text>
              </View>
            </AnimatedPressable>
          )}

          {selectedPhotos.length > 0 && (
            <Pressable
              onPress={pickPhotos}
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
                + Add More Images
              </Text>
            </Pressable>
          )}
        </Animated.View>

        {/* Create PDF Button */}
        <Animated.View
          entering={FadeInDown.delay(300).springify()}
          className="mx-4 mt-6"
        >
          <AnimatedPressable
            onPress={createPDF}
            scaleValue={0.98}
            hapticFeedback="medium"
            disabled={selectedPhotos.length === 0 || isCreating}
          >
            <LinearGradient
              colors={
                selectedPhotos.length === 0 || isCreating
                  ? ['#64748b', '#475569']
                  : ['#ef4444', '#dc2626']
              }
              className="rounded-2xl py-4 items-center"
            >
              {isCreating ? (
                <View className="flex-row items-center">
                  <ActivityIndicator size="small" color="white" />
                  <Text className="text-white font-bold text-lg ml-3">
                    Creating PDF...
                  </Text>
                </View>
              ) : (
                <Text className="text-white font-bold text-lg">
                  Create PDF ({selectedPhotos.length} images)
                </Text>
              )}
            </LinearGradient>
          </AnimatedPressable>
        </Animated.View>
      </ScrollView>
    </View>
  );
}
