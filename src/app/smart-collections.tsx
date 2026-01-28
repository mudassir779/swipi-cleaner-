import React, { useEffect, useState, useCallback } from 'react';
import {
  View,
  Text,
  Pressable,
  FlatList,
  Dimensions,
  Image,
  ActivityIndicator,
  ScrollView,
} from 'react-native';
import { useRouter } from 'expo-router';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useColorScheme } from '@/lib/useColorScheme';
import { useGalleryStore } from '@/lib/state/gallery-store';
import * as MediaLibrary from 'expo-media-library';
import * as Haptics from 'expo-haptics';
import { cn } from '@/lib/cn';
import { Ionicons, MaterialIcons } from '@expo/vector-icons';
import { formatBytes } from '@/lib/state/gallery-store';
import { differenceInDays } from 'date-fns';

const { width } = Dimensions.get('window');
const NUM_COLUMNS = 3;
const SPACING = 2;
const ITEM_SIZE = (width - SPACING * (NUM_COLUMNS + 1)) / NUM_COLUMNS;

interface SmartCollection {
  id: string;
  title: string;
  description: string;
  icon: React.ReactNode;
  photos: MediaLibrary.Asset[];
  totalSize: number;
}

export default function SmartCollectionsScreen() {
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';

  const [collections, setCollections] = useState<SmartCollection[]>([]);
  const [loading, setLoading] = useState(true);
  const addToDeleteQueue = useGalleryStore((s) => s.addToDeleteQueue);

  const iconColor = isDark ? '#94a3b8' : '#64748b';

  useEffect(() => {
    loadSmartCollections();
  }, []);

  const loadSmartCollections = async () => {
    try {
      setLoading(true);

      // Load all photos
      const result = await MediaLibrary.getAssetsAsync({
        first: 10000,
        mediaType: 'photo',
        sortBy: [[MediaLibrary.SortBy.creationTime, false]],
      });

      const allPhotos = result.assets;
      const now = Date.now();
      const oneYearAgo = now - 365 * 24 * 60 * 60 * 1000;

      // Large Files (>10MB)
      const largeFiles = allPhotos.filter((photo) => {
        const fileSize = (photo as any).fileSize || 0;
        return fileSize > 10 * 1024 * 1024;
      });
      const largeFilesSize = largeFiles.reduce((total, photo) => {
        return total + ((photo as any).fileSize || 0);
      }, 0);

      // Old Photos (>1 year)
      const oldPhotos = allPhotos.filter((photo) => {
        return photo.creationTime < oneYearAgo;
      });
      const oldPhotosSize = oldPhotos.reduce((total, photo) => {
        return total + ((photo as any).fileSize || 2 * 1024 * 1024);
      }, 0);

      // Screenshots
      const screenshots = allPhotos.filter((photo) => {
        const filename = (photo.filename || '').toLowerCase();
        return filename.includes('screenshot') || filename.includes('screen shot');
      });
      const screenshotsSize = screenshots.reduce((total, photo) => {
        return total + ((photo as any).fileSize || 2 * 1024 * 1024);
      }, 0);

      // Similar Photos (duplicates - simplified)
      // This is a basic implementation, could be improved
      const similarPhotos: MediaLibrary.Asset[] = [];
      const seenHashes = new Set<string>();
      allPhotos.forEach((photo) => {
        // Simple hash based on dimensions and creation time
        const hash = `${photo.width}x${photo.height}-${Math.floor(photo.creationTime / 1000)}`;
        if (seenHashes.has(hash)) {
          similarPhotos.push(photo);
        } else {
          seenHashes.add(hash);
        }
      });
      const similarPhotosSize = similarPhotos.reduce((total, photo) => {
        return total + ((photo as any).fileSize || 2 * 1024 * 1024);
      }, 0);

      setCollections([
        {
          id: 'large-files',
          title: 'Large Files',
          description: `Photos larger than 10MB`,
          icon: <Ionicons name="hardware-chip" size={24} color={iconColor} />,
          photos: largeFiles,
          totalSize: largeFilesSize,
        },
        {
          id: 'old-photos',
          title: 'Old Photos',
          description: `Photos older than 1 year`,
          icon: <Ionicons name="calendar" size={24} color={iconColor} />,
          photos: oldPhotos,
          totalSize: oldPhotosSize,
        },
        {
          id: 'screenshots',
          title: 'Screenshots',
          description: `All screenshot photos`,
          icon: <Ionicons name="camera" size={24} color={iconColor} />,
          photos: screenshots,
          totalSize: screenshotsSize,
        },
        {
          id: 'similar-photos',
          title: 'Similar Photos',
          description: `Photos with similar dimensions`,
          icon: <Ionicons name="image" size={24} color={iconColor} />,
          photos: similarPhotos,
          totalSize: similarPhotosSize,
        },
      ]);
    } catch (error) {
      console.error('Error loading smart collections:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleCollectionPress = (collection: SmartCollection) => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    router.push({
      pathname: '/collection-details',
      params: {
        collectionId: collection.id,
        title: collection.title,
        photoIds: collection.photos.map((p) => p.id).join(','),
      },
    });
  };

  const handleSelectAll = (collection: SmartCollection) => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    collection.photos.forEach((photo) => {
      addToDeleteQueue(photo.id);
    });
  };

  if (loading) {
    return (
      <View
        className={cn(
          'flex-1 items-center justify-center',
          isDark ? 'bg-black' : 'bg-slate-50'
        )}
      >
        <ActivityIndicator size="large" color={isDark ? '#60a5fa' : '#3b82f6'} />
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
          <View>
            <Text
              className={cn(
                'text-2xl font-bold',
                isDark ? 'text-white' : 'text-slate-900'
              )}
            >
              Smart Collections
            </Text>
            <Text
              className={cn(
                'text-sm mt-0.5',
                isDark ? 'text-slate-400' : 'text-slate-500'
              )}
            >
              Auto-generated photo groups
            </Text>
          </View>
        </View>
      </View>

      <ScrollView
        contentContainerStyle={{
          paddingTop: 16,
          paddingBottom: insets.bottom + 100,
        }}
        showsVerticalScrollIndicator={false}
      >
        {collections.map((collection) => (
          <Pressable
            key={collection.id}
            onPress={() => handleCollectionPress(collection)}
            className={cn(
              'mx-4 mb-4 rounded-2xl overflow-hidden',
              isDark ? 'bg-white/5' : 'bg-white'
            )}
            style={{
              shadowColor: '#000',
              shadowOffset: { width: 0, height: 2 },
              shadowOpacity: isDark ? 0 : 0.05,
              shadowRadius: 8,
            }}
          >
            <View className="p-5">
              <View className="flex-row items-center justify-between mb-3">
                <View className="flex-row items-center flex-1">
                  <View
                    className={cn(
                      'w-12 h-12 rounded-xl items-center justify-center mr-3',
                      isDark ? 'bg-white/10' : 'bg-black/5'
                    )}
                  >
                    {collection.icon}
                  </View>
                  <View className="flex-1">
                    <Text
                      className={cn(
                        'text-lg font-semibold',
                        isDark ? 'text-white' : 'text-slate-900'
                      )}
                    >
                      {collection.title}
                    </Text>
                    <Text
                      className={cn(
                        'text-sm mt-0.5',
                        isDark ? 'text-slate-400' : 'text-slate-500'
                      )}
                    >
                      {collection.description}
                    </Text>
                  </View>
                </View>
                <Ionicons
                  name="chevron-forward"
                  size={20}
                  color={isDark ? '#475569' : '#94a3b8'}
                  strokeWidth={2}
                />
              </View>

              <View className="flex-row items-center justify-between mt-3">
                <View className="flex-row items-center">
                  <Ionicons
                    name="image"
                    size={16}
                    color={iconColor}
                    strokeWidth={1.5}
                  />
                  <Text
                    className={cn(
                      'text-sm ml-2',
                      isDark ? 'text-slate-300' : 'text-slate-600'
                    )}
                  >
                    {collection.photos.length} photos
                  </Text>
                </View>
                <View className="flex-row items-center">
                  <Ionicons
                    name="hardware-chip"
                    size={16}
                    color={iconColor}
                    strokeWidth={1.5}
                  />
                  <Text
                    className={cn(
                      'text-sm ml-2',
                      isDark ? 'text-slate-300' : 'text-slate-600'
                    )}
                  >
                    {formatBytes(collection.totalSize)}
                  </Text>
                </View>
              </View>

              {/* Preview Grid */}
              {collection.photos.length > 0 && (
                <View className="flex-row mt-4 gap-1">
                  {collection.photos.slice(0, 3).map((photo) => (
                    <Image
                      key={photo.id}
                      source={{ uri: photo.uri }}
                      style={{
                        width: (width - 64) / 3 - 2,
                        height: 80,
                        borderRadius: 8,
                      }}
                      resizeMode="cover"
                    />
                  ))}
                  {collection.photos.length > 3 && (
                    <View
                      className={cn(
                        'items-center justify-center rounded-lg',
                        isDark ? 'bg-white/10' : 'bg-black/5'
                      )}
                      style={{
                        width: (width - 64) / 3 - 2,
                        height: 80,
                      }}
                    >
                      <Text
                        className={cn(
                          'text-sm font-medium',
                          isDark ? 'text-slate-400' : 'text-slate-500'
                        )}
                      >
                        +{collection.photos.length - 3}
                      </Text>
                    </View>
                  )}
                </View>
              )}

              {/* Quick Action */}
              {collection.photos.length > 0 && (
                <Pressable
                  onPress={(e) => {
                    e.stopPropagation();
                    handleSelectAll(collection);
                  }}
                  className={cn(
                    'mt-4 py-2.5 rounded-xl items-center',
                    isDark ? 'bg-white/10' : 'bg-black/5'
                  )}
                >
                  <Text
                    className={cn(
                      'text-sm font-medium',
                      isDark ? 'text-white' : 'text-slate-900'
                    )}
                  >
                    Select All
                  </Text>
                </Pressable>
              )}
            </View>
          </Pressable>
        ))}
      </ScrollView>
    </View>
  );
}
