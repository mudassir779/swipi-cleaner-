import React, { useEffect, useState } from 'react';
import { View, Text, Pressable, Image, ScrollView, Alert } from 'react-native';
import { useRouter } from 'expo-router';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useColorScheme } from '@/lib/useColorScheme';
import { useGalleryStore, formatBytes } from '@/lib/state/gallery-store';
import { useToastStore } from '@/lib/state/toast-store';
import * as MediaLibrary from 'expo-media-library';
import * as Haptics from 'expo-haptics';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
  withDelay,
  withTiming,
  FadeIn,
} from 'react-native-reanimated';
import { Ionicons, Feather } from '@expo/vector-icons';
import { cn } from '@/lib/cn';
import { LinearGradient } from 'expo-linear-gradient';

export default function ConfirmDeleteScreen() {
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';

  const [previewPhotos, setPreviewPhotos] = useState<MediaLibrary.Asset[]>([]);
  const [isDeleting, setIsDeleting] = useState(false);

  const deleteQueue = useGalleryStore((s) => s.deleteQueue);
  const clearDeleteQueue = useGalleryStore((s) => s.clearDeleteQueue);
  const addToRecentlyDeleted = useGalleryStore((s) => s.addToRecentlyDeleted);
  const addManyToRecentlyDeleted = useGalleryStore((s) => s.addManyToRecentlyDeleted);
  const setLastDeletedPhotos = useGalleryStore((s) => s.setLastDeletedPhotos);
  const [estimatedSize, setEstimatedSize] = useState(0);
  const [photosToDelete, setPhotosToDelete] = useState<MediaLibrary.Asset[]>([]);

  const deleteCount = deleteQueue.length;
  const { showToast } = useToastStore();

  useEffect(() => {
    const calculateRealSize = async () => {
      let totalSize = 0;
      const assets: MediaLibrary.Asset[] = [];
      
      for (const id of deleteQueue) {
        try {
          const assetInfo = await MediaLibrary.getAssetInfoAsync(id);
          assets.push(assetInfo);
          const fileSize = (assetInfo as any)?.fileSize;
          if (fileSize && fileSize > 0) {
            totalSize += fileSize;
          } else {
            // Fallback estimate
            totalSize += 2 * 1024 * 1024;
          }
        } catch (error) {
          // Fallback estimate on error
          totalSize += 2 * 1024 * 1024;
        }
      }
      
      setPhotosToDelete(assets);
      setEstimatedSize(totalSize);
    };

    if (deleteQueue.length > 0) {
      calculateRealSize();
    } else {
      setEstimatedSize(0);
      setPhotosToDelete([]);
    }
  }, [deleteQueue]);

  // Animation values
  const contentOpacity = useSharedValue(0);
  const contentTranslateY = useSharedValue(20);
  const warningScale = useSharedValue(0.8);

  useEffect(() => {
    contentOpacity.value = withTiming(1, { duration: 400 });
    contentTranslateY.value = withSpring(0, { damping: 15 });
    warningScale.value = withDelay(200, withSpring(1, { damping: 12 }));

    loadPreviewPhotos();
  }, []);

  const loadPreviewPhotos = async () => {
    const previews: MediaLibrary.Asset[] = [];
    const previewIds = deleteQueue.slice(0, 6);

    for (const id of previewIds) {
      try {
        const asset = await MediaLibrary.getAssetInfoAsync(id);
        if (asset) {
          previews.push(asset);
        }
      } catch (error) {
        console.error('Error loading preview:', error);
      }
    }

    setPreviewPhotos(previews);
  };

  const contentAnimatedStyle = useAnimatedStyle(() => ({
    opacity: contentOpacity.value,
    transform: [{ translateY: contentTranslateY.value }],
  }));

  const warningAnimatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: warningScale.value }],
  }));

  const handleCancel = () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    router.back();
  };

  const handleDelete = async () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Heavy);
    setIsDeleting(true);

    try {
      // Store last deleted photos for undo locally
      const itemsToStore = photosToDelete.map((photo) => ({
        id: photo.id,
        asset: {
          id: photo.id,
          uri: photo.uri,
          filename: photo.filename,
          creationTime: photo.creationTime,
          width: photo.width,
          height: photo.height,
        },
      }));
      
      setLastDeletedPhotos(itemsToStore);
      
      // Batch add to recently deleted to avoid UI freeze
      addManyToRecentlyDeleted(itemsToStore);

      // This will trigger the system confirmation dialog
      await MediaLibrary.deleteAssetsAsync(deleteQueue);

      // Successfully deleted
      const deletedCount = deleteQueue.length;
      
      // Clear the queue first
      clearDeleteQueue();
      
      // Navigate back
      if (router.canGoBack()) {
        router.back();
      } else {
        router.replace('/(tabs)/home');
      }
      
      // Show toast after a brief delay to ensure we are on the new screen
      setTimeout(() => {
        showToast(`${deletedCount} photo${deletedCount !== 1 ? 's' : ''} deleted`, 'success');
      }, 300);
      
    } catch (error) {
      console.error('Error deleting photos:', error);
      Alert.alert(
        'Deletion Cancelled',
        'The photos were not deleted. You can try again or keep them.',
        [{ text: 'OK' }]
      );
      setIsDeleting(false);
    }
  };

  return (
    <View className={cn('flex-1', isDark ? 'bg-black' : 'bg-slate-50')}>
      {/* Header */}
      <View
        className={cn(
          'px-4 pb-3 flex-row items-center',
          isDark ? 'bg-black' : 'bg-slate-50'
        )}
        style={{ paddingTop: insets.top + 8 }}
      >
        <Pressable
          onPress={handleCancel}
          className={cn(
            'w-10 h-10 rounded-full items-center justify-center',
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
            'text-lg font-semibold ml-3',
            isDark ? 'text-white' : 'text-slate-900'
          )}
        >
          Confirm Deletion
        </Text>
      </View>

      <ScrollView
        contentContainerStyle={{
          flexGrow: 1,
          paddingHorizontal: 24,
          paddingBottom: insets.bottom + 120,
        }}
        showsVerticalScrollIndicator={false}
      >
        <Animated.View style={contentAnimatedStyle} className="items-center pt-8">
          {/* Warning Icon */}
          <Animated.View style={warningAnimatedStyle}>
            <View
              className="w-20 h-20 rounded-full items-center justify-center mb-6"
              style={{ backgroundColor: isDark ? 'rgba(239, 68, 68, 0.15)' : 'rgba(239, 68, 68, 0.1)' }}
            >
              <Ionicons
                name="warning"
                size={40}
                color="#ef4444"
              />
            </View>
          </Animated.View>

          {/* Warning Text */}
          <Text
            className={cn(
              'text-2xl font-bold text-center mb-3',
              isDark ? 'text-white' : 'text-slate-900'
            )}
          >
            Delete {deleteCount} Photos?
          </Text>

          <Text
            className={cn(
              'text-base text-center mb-2',
              isDark ? 'text-slate-400' : 'text-slate-500'
            )}
          >
            This action cannot be undone.
          </Text>

          <Text
            className={cn(
              'text-sm text-center',
              isDark ? 'text-slate-500' : 'text-slate-400'
            )}
          >
            This will free approximately {formatBytes(estimatedSize)}
          </Text>

          {/* Photo Preview */}
          {previewPhotos.length > 0 && (
            <Animated.View
              entering={FadeIn.delay(300).duration(300)}
              className="mt-8 w-full"
            >
              <Text
                className={cn(
                  'text-sm font-medium mb-3',
                  isDark ? 'text-slate-400' : 'text-slate-500'
                )}
              >
                Photos to be deleted:
              </Text>
              <View className="flex-row flex-wrap justify-center">
                {previewPhotos.map((photo, index) => (
                  <View
                    key={photo.id}
                    className="m-1"
                    style={{
                      opacity: index >= 4 ? 0.5 : 1,
                    }}
                  >
                    <Image
                      source={{ uri: photo.uri }}
                      style={{
                        width: 72,
                        height: 72,
                        borderRadius: 8,
                      }}
                      resizeMode="cover"
                    />
                    <View
                      className="absolute inset-0 rounded-lg"
                      style={{ backgroundColor: 'rgba(239, 68, 68, 0.2)' }}
                    />
                  </View>
                ))}
                {deleteCount > 6 && (
                  <View
                    className={cn(
                      'm-1 w-[72px] h-[72px] rounded-lg items-center justify-center',
                      isDark ? 'bg-white/10' : 'bg-black/5'
                    )}
                  >
                    <Text
                      className={cn(
                        'text-sm font-medium',
                        isDark ? 'text-slate-400' : 'text-slate-500'
                      )}
                    >
                      +{deleteCount - 6}
                    </Text>
                  </View>
                )}
              </View>
            </Animated.View>
          )}
        </Animated.View>
      </ScrollView>

      {/* Action Buttons */}
      <View
        className="absolute bottom-0 left-0 right-0 px-6"
        style={{ paddingBottom: insets.bottom + 20 }}
      >
        {/* Delete Button */}
        <Pressable
          onPress={handleDelete}
          disabled={isDeleting}
          className="active:scale-[0.98] active:opacity-90 mb-3"
        >
          <LinearGradient
            colors={['#ef4444', '#dc2626']}
            style={{
              paddingVertical: 18,
              borderRadius: 16,
              alignItems: 'center',
              flexDirection: 'row',
              justifyContent: 'center',
              opacity: isDeleting ? 0.7 : 1,
            }}
            start={{ x: 0, y: 0 }}
            end={{ x: 1, y: 1 }}
          >
            <Feather name="trash-2" size={20} color="#fff" />
            <Text className="text-white text-lg font-semibold ml-2">
              {isDeleting ? 'Deleting...' : 'Delete Photos'}
            </Text>
          </LinearGradient>
        </Pressable>

        {/* Cancel Button */}
        <Pressable
          onPress={handleCancel}
          disabled={isDeleting}
          className={cn(
            'py-4 rounded-2xl items-center',
            isDark ? 'bg-white/10' : 'bg-black/5'
          )}
        >
          <Text
            className={cn(
              'text-base font-medium',
              isDark ? 'text-white' : 'text-slate-700'
            )}
          >
            Cancel
          </Text>
        </Pressable>
      </View>
    </View>
  );
}
