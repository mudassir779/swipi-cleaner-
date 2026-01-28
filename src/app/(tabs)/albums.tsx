import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  ScrollView,
  Pressable,
  Dimensions,
  ActivityIndicator,
} from 'react-native';
import { Image } from 'expo-image';
import { useRouter } from 'expo-router';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useColorScheme } from '@/lib/useColorScheme';
import * as MediaLibrary from 'expo-media-library';
import * as Haptics from 'expo-haptics';
import { cn } from '@/lib/cn';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import Animated, { FadeInDown, FadeIn } from 'react-native-reanimated';
import { LinearGradient } from 'expo-linear-gradient';
import { AnimatedPressable } from '@/components/AnimatedPressable';
import { detectSourceApp, SourceApp, SOURCE_APP_INFO } from '@/lib/utils/sourceAppDetection';

const { width } = Dimensions.get('window');
const CARD_WIDTH = (width - 48) / 2;

interface Album {
  id: string;
  title: string;
  count: number;
  thumbnail?: string;
  icon?: string;
  gradient: [string, string];
  type: 'date' | 'source' | 'system';
}

interface AlbumCardProps {
  album: Album;
  onPress: () => void;
  isDark: boolean;
  index: number;
}

function AlbumCard({ album, onPress, isDark, index }: AlbumCardProps) {
  return (
    <Animated.View
      entering={FadeInDown.delay(index * 60).springify()}
      style={{ width: CARD_WIDTH }}
    >
      <AnimatedPressable
        onPress={onPress}
        scaleValue={0.96}
        hapticFeedback="light"
      >
        <View
          className={cn(
            'rounded-2xl overflow-hidden h-40',
            isDark ? 'bg-white/5' : 'bg-white'
          )}
          style={{
            shadowColor: '#000',
            shadowOffset: { width: 0, height: 4 },
            shadowOpacity: isDark ? 0.3 : 0.1,
            shadowRadius: 8,
          }}
        >
          {album.thumbnail ? (
            <Image
              source={{ uri: album.thumbnail }}
              style={{ width: '100%', height: '70%' }}
              contentFit="cover"
            />
          ) : (
            <LinearGradient
              colors={album.gradient}
              className="items-center justify-center"
              style={{ width: '100%', height: '70%' }}
            >
              <MaterialCommunityIcons
                name={album.icon as any || 'folder-image'}
                size={36}
                color="white"
              />
            </LinearGradient>
          )}
          <View className="px-3 py-2 flex-1 justify-center">
            <Text
              className={cn(
                'text-sm font-semibold',
                isDark ? 'text-white' : 'text-slate-900'
              )}
              numberOfLines={1}
            >
              {album.title}
            </Text>
            <Text
              className={cn(
                'text-xs',
                isDark ? 'text-slate-400' : 'text-slate-500'
              )}
            >
              {album.count} items
            </Text>
          </View>
        </View>
      </AnimatedPressable>
    </Animated.View>
  );
}

function SectionHeader({ title, isDark }: { title: string; isDark: boolean }) {
  return (
    <Text
      className={cn(
        'text-sm font-medium px-4 mt-6 mb-3',
        isDark ? 'text-slate-400' : 'text-slate-500'
      )}
    >
      {title}
    </Text>
  );
}

export default function AlbumsScreen() {
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';

  const [loading, setLoading] = useState(true);
  const [sourceAlbums, setSourceAlbums] = useState<Album[]>([]);
  const [systemAlbums, setSystemAlbums] = useState<Album[]>([]);
  const [dateAlbums, setDateAlbums] = useState<Album[]>([]);

  useEffect(() => {
    loadAlbums();
  }, []);

  const loadAlbums = async () => {
    try {
      const { status } = await MediaLibrary.getPermissionsAsync();
      if (status !== 'granted') {
        setLoading(false);
        return;
      }

      // Load all assets for analysis
      const allAssets = await MediaLibrary.getAssetsAsync({
        first: 2000,
        mediaType: ['photo', 'video'],
        sortBy: [[MediaLibrary.SortBy.creationTime, false]],
      });

      // Group by source app
      const sourceGroups: Record<SourceApp, MediaLibrary.Asset[]> = {
        whatsapp: [],
        instagram: [],
        snapchat: [],
        telegram: [],
        twitter: [],
        facebook: [],
        tiktok: [],
        camera: [],
        screenshot: [],
        download: [],
        other: [],
      };

      for (const asset of allAssets.assets) {
        const source = detectSourceApp(asset);
        sourceGroups[source].push(asset);
      }

      // Create source albums (only if they have items)
      const newSourceAlbums: Album[] = [];
      for (const [source, assets] of Object.entries(sourceGroups)) {
        if (assets.length > 0) {
          const info = SOURCE_APP_INFO[source as SourceApp];
          newSourceAlbums.push({
            id: `source-${source}`,
            title: info.name,
            count: assets.length,
            thumbnail: assets[0]?.uri,
            gradient: info.gradient,
            type: 'source',
          });
        }
      }
      newSourceAlbums.sort((a, b) => b.count - a.count);
      setSourceAlbums(newSourceAlbums);

      // Create date-based albums (by year/month)
      const dateGroups: Record<string, MediaLibrary.Asset[]> = {};
      for (const asset of allAssets.assets) {
        const date = new Date(asset.creationTime);
        const key = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}`;
        if (!dateGroups[key]) {
          dateGroups[key] = [];
        }
        dateGroups[key].push(asset);
      }

      const newDateAlbums: Album[] = Object.entries(dateGroups)
        .slice(0, 6)
        .map(([key, assets], index) => {
          const [year, month] = key.split('-');
          const monthName = new Date(parseInt(year), parseInt(month) - 1).toLocaleString('default', { month: 'long' });
          return {
            id: `date-${key}`,
            title: `${monthName} ${year}`,
            count: assets.length,
            thumbnail: assets[0]?.uri,
            gradient: ['#6366f1', '#4f46e5'] as [string, string],
            type: 'date' as const,
          };
        });
      setDateAlbums(newDateAlbums);

      // System albums
      const videos = allAssets.assets.filter((a) => a.mediaType === 'video');
      const screenshots = allAssets.assets.filter(
        (a) =>
          a.filename?.toLowerCase().includes('screenshot') ||
          a.filename?.toLowerCase().includes('screen shot')
      );

      setSystemAlbums([
        {
          id: 'system-recents',
          title: 'Recents',
          count: allAssets.totalCount,
          thumbnail: allAssets.assets[0]?.uri,
          icon: 'clock-outline',
          gradient: ['#3b82f6', '#2563eb'],
          type: 'system',
        },
        {
          id: 'system-videos',
          title: 'Videos',
          count: videos.length,
          thumbnail: videos[0]?.uri,
          icon: 'video-outline',
          gradient: ['#8b5cf6', '#7c3aed'],
          type: 'system',
        },
        {
          id: 'system-screenshots',
          title: 'Screenshots',
          count: screenshots.length,
          thumbnail: screenshots[0]?.uri,
          icon: 'cellphone-screenshot',
          gradient: ['#f97316', '#ea580c'],
          type: 'system',
        },
        {
          id: 'system-favorites',
          title: 'Favorites',
          count: 0,
          icon: 'heart-outline',
          gradient: ['#ec4899', '#db2777'],
          type: 'system',
        },
      ]);
    } catch (error) {
      console.error('Error loading albums:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleAlbumPress = (album: Album) => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    // Navigate to filtered view based on album type
    router.push('/categories');
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
      <ScrollView
        contentContainerStyle={{ paddingBottom: insets.bottom + 100 }}
        showsVerticalScrollIndicator={false}
      >
        {/* Header */}
        <Animated.View
          entering={FadeIn.duration(400)}
          className="px-4 flex-row items-center justify-between"
          style={{ paddingTop: insets.top + 16 }}
        >
          <View>
            <Text
              className={cn(
                'text-3xl font-bold',
                isDark ? 'text-white' : 'text-slate-900'
              )}
            >
              Albums
            </Text>
          </View>
          <Pressable
            onPress={() => {}}
            className={cn(
              'px-4 py-2 rounded-full',
              isDark ? 'bg-white/10' : 'bg-black/5'
            )}
          >
            <Text
              className={cn(
                'text-sm font-medium',
                isDark ? 'text-blue-400' : 'text-blue-600'
              )}
            >
              + New Album
            </Text>
          </Pressable>
        </Animated.View>

        {/* System Albums */}
        <SectionHeader title="LIBRARY" isDark={isDark} />
        <View className="flex-row flex-wrap px-4 gap-3">
          {systemAlbums.map((album, index) => (
            <AlbumCard
              key={album.id}
              album={album}
              onPress={() => handleAlbumPress(album)}
              isDark={isDark}
              index={index}
            />
          ))}
        </View>

        {/* Source App Albums */}
        {sourceAlbums.length > 0 && (
          <>
            <SectionHeader title="BY APP" isDark={isDark} />
            <View className="flex-row flex-wrap px-4 gap-3">
              {sourceAlbums.map((album, index) => (
                <AlbumCard
                  key={album.id}
                  album={album}
                  onPress={() => handleAlbumPress(album)}
                  isDark={isDark}
                  index={index}
                />
              ))}
            </View>
          </>
        )}

        {/* Date Albums */}
        {dateAlbums.length > 0 && (
          <>
            <SectionHeader title="BY DATE" isDark={isDark} />
            <View className="flex-row flex-wrap px-4 gap-3">
              {dateAlbums.map((album, index) => (
                <AlbumCard
                  key={album.id}
                  album={album}
                  onPress={() => handleAlbumPress(album)}
                  isDark={isDark}
                  index={index}
                />
              ))}
            </View>
          </>
        )}
      </ScrollView>
    </View>
  );
}
