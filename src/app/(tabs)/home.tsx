import React, { useEffect, useState, useCallback } from 'react';
import {
  View,
  Text,
  ScrollView,
  Dimensions,
  Platform,
} from 'react-native';
import { useRouter, useFocusEffect } from 'expo-router';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useGalleryStore } from '@/lib/state/gallery-store';
import * as MediaLibrary from 'expo-media-library';
import { Ionicons, MaterialIcons, Feather } from '@expo/vector-icons';
import Animated, { FadeInDown, FadeIn } from 'react-native-reanimated';
import { LinearGradient } from 'expo-linear-gradient';
import { AnimatedPressable } from '@/components/AnimatedPressable';
import { theme } from '@/lib/theme';

const { width } = Dimensions.get('window');
const CARD_WIDTH = (width - 48 - 12) / 2; // 48 = 16*2 padding + 16 gap, 12 = gap

interface StatItem {
  label: string;
  value: string;
  icon: React.ReactNode;
  bgColor: string;
}

interface ActionCardProps {
  title: string;
  subtitle: string;
  icon: React.ReactNode;
  gradient: [string, string];
  onPress: () => void;
  index: number;
}

function ActionCard({ title, subtitle, icon, gradient, onPress, index }: ActionCardProps) {
  return (
    <Animated.View
      entering={FadeInDown.delay(index * 60).springify()}
      style={{ width: CARD_WIDTH, minWidth: 150 }}
    >
      <AnimatedPressable
        onPress={onPress}
        scaleValue={0.96}
        hapticFeedback="light"
      >
        <LinearGradient
          colors={gradient}
          start={{ x: 0, y: 0 }}
          end={{ x: 1, y: 1 }}
          style={{
            borderRadius: 16,
            padding: 20,
            minHeight: 130,
            shadowColor: gradient[0],
            shadowOffset: { width: 0, height: 4 },
            shadowOpacity: 0.2,
            shadowRadius: 8,
            elevation: 4,
          }}
        >
          <View style={{ flex: 1, justifyContent: 'space-between' }}>
            <View style={{
              width: 40,
              height: 40,
              borderRadius: 12,
              backgroundColor: 'rgba(255,255,255,0.25)',
              alignItems: 'center',
              justifyContent: 'center',
            }}>
              {icon}
            </View>
            <View style={{ marginTop: 12 }}>
              <Text style={{
                color: '#fff',
                fontWeight: '700',
                fontSize: 18,
              }}>{title}</Text>
              <Text style={{
                color: 'rgba(255,255,255,0.8)',
                fontSize: 13,
                marginTop: 2,
              }}>{subtitle}</Text>
            </View>
          </View>
        </LinearGradient>
      </AnimatedPressable>
    </Animated.View>
  );
}

export default function HomeScreen() {
  const router = useRouter();
  const insets = useSafeAreaInsets();

  const [photoCount, setPhotoCount] = useState(0);
  const [videoCount, setVideoCount] = useState(0);
  const [screenshotCount, setScreenshotCount] = useState(0);
  const [todayCount, setTodayCount] = useState(0);

  const deleteQueue = useGalleryStore((s) => s.deleteQueue);
  const recentlyDeleted = useGalleryStore((s) => s.recentlyDeleted);

  useFocusEffect(
    useCallback(() => {
      loadStats();
    }, [])
  );

  const loadStats = async () => {
    try {
      // Skip on web
      if (Platform.OS === 'web') {
        setPhotoCount(287);
        setVideoCount(24);
        setTodayCount(5);
        setScreenshotCount(45);
        return;
      }

      const { status } = await MediaLibrary.getPermissionsAsync();
      if (status !== 'granted') return;

      const photos = await MediaLibrary.getAssetsAsync({
        first: 1,
        mediaType: 'photo',
      });
      setPhotoCount(photos.totalCount);

      const videos = await MediaLibrary.getAssetsAsync({
        first: 1,
        mediaType: 'video',
      });
      setVideoCount(videos.totalCount);

      const today = new Date();
      today.setHours(0, 0, 0, 0);
      const allPhotos = await MediaLibrary.getAssetsAsync({
        first: 1000,
        mediaType: ['photo', 'video'],
        createdAfter: today.getTime(),
      });
      setTodayCount(allPhotos.totalCount);

      const allAssets = await MediaLibrary.getAssetsAsync({
        first: 500,
        mediaType: 'photo',
      });
      const screenshots = allAssets.assets.filter(
        (a) =>
          a.filename?.toLowerCase().includes('screenshot') ||
          a.filename?.toLowerCase().includes('screen shot')
      );
      setScreenshotCount(screenshots.length);
    } catch (error) {
      console.error('Error loading stats:', error);
    }
  };

  const stats: StatItem[] = [
    {
      label: 'Photos',
      value: photoCount.toLocaleString(),
      icon: <Ionicons name="image" size={20} color="#3B82F6" />,
      bgColor: theme.colors.stats.photos,
    },
    {
      label: 'Videos',
      value: videoCount.toLocaleString(),
      icon: <Ionicons name="videocam" size={20} color="#8B5CF6" />,
      bgColor: theme.colors.stats.videos,
    },
    {
      label: 'Today',
      value: todayCount.toLocaleString(),
      icon: <Ionicons name="today" size={20} color="#10B981" />,
      bgColor: theme.colors.stats.today,
    },
    {
      label: 'To Delete',
      value: deleteQueue.length.toLocaleString(),
      icon: <Feather name="trash-2" size={20} color="#EF4444" />,
      bgColor: theme.colors.stats.toDelete,
    },
  ];

  const actionCards: ActionCardProps[] = [
    {
      title: 'Random Cleanup',
      subtitle: 'Review random photos',
      icon: <MaterialIcons name="shuffle" size={24} color="white" />,
      gradient: ['#14B8A6', '#0D9488'],
      onPress: () => router.push('/swipe-review'),
      index: 0,
    },
    {
      title: 'Similar Photos',
      subtitle: 'Find duplicates',
      icon: <Ionicons name="copy" size={24} color="white" />,
      gradient: ['#0D9488', '#14B8A6'],
      onPress: () => router.push('/duplicates'),
      index: 1,
    },
    {
      title: 'Screenshots',
      subtitle: `${screenshotCount} found`,
      icon: <Ionicons name="phone-portrait" size={24} color="white" />,
      gradient: ['#F97316', '#EA580C'],
      onPress: () => router.push('/categories'),
      index: 2,
    },
    {
      title: 'Large Files',
      subtitle: 'Free up space',
      icon: <MaterialIcons name="storage" size={24} color="white" />,
      gradient: ['#EC4899', '#DB2777'],
      onPress: () => router.push('/smart-collections'),
      index: 3,
    },
    {
      title: 'Videos',
      subtitle: `${videoCount} videos`,
      icon: <Ionicons name="videocam" size={24} color="white" />,
      gradient: ['#8B5CF6', '#7C3AED'],
      onPress: () => router.push('/categories'),
      index: 4,
    },
    {
      title: 'AI Suggestions',
      subtitle: 'Smart cleanup',
      icon: <MaterialIcons name="auto-awesome" size={24} color="white" />,
      gradient: ['#3B82F6', '#2563EB'],
      onPress: () => router.push('/ai-suggestions'),
      index: 5,
    },
    {
      title: 'Compress',
      subtitle: 'Reduce file size',
      icon: <MaterialIcons name="compress" size={24} color="white" />,
      gradient: ['#F59E0B', '#D97706'],
      onPress: () => router.push('/compress'),
      index: 6,
    },
    {
      title: 'Recycle Bin',
      subtitle: `${recentlyDeleted.length} items`,
      icon: <Feather name="trash-2" size={24} color="white" />,
      gradient: ['#6B7280', '#4B5563'],
      onPress: () => router.push('/recently-deleted'),
      index: 7,
    },
  ];

  return (
    <View style={{ flex: 1, backgroundColor: theme.colors.background }}>
      <ScrollView
        contentContainerStyle={{ paddingBottom: insets.bottom + 100 }}
        showsVerticalScrollIndicator={false}
      >
        {/* Header */}
        <Animated.View
          entering={FadeIn.duration(400)}
          style={{ paddingHorizontal: 16, paddingTop: insets.top + 16 }}
        >
          <Text style={{
            fontSize: 34,
            fontWeight: '700',
            color: theme.colors.textPrimary,
          }}>
            Photo Cleanup
          </Text>
          <Text style={{
            fontSize: 16,
            color: theme.colors.sectionHeader,
            marginTop: 4,
          }}>
            Declutter · Organize your memories
          </Text>
        </Animated.View>

        {/* Today's Stats Section */}
        <Animated.View
          entering={FadeInDown.delay(100).springify()}
          style={{ paddingHorizontal: 16, marginTop: 24 }}
        >
          <Text style={{
            fontSize: 13,
            fontWeight: '600',
            color: theme.colors.sectionHeader,
            textTransform: 'uppercase',
            letterSpacing: 0.5,
            marginBottom: 12,
          }}>
            TODAY'S STATS
          </Text>
          
          <View style={{
            flexDirection: 'row',
            backgroundColor: theme.colors.surface,
            borderRadius: 16,
            padding: 16,
          }}>
            {stats.map((stat, index) => (
              <View key={stat.label} style={{
                flex: 1,
                alignItems: 'center',
              }}>
                <View style={{
                  width: 44,
                  height: 44,
                  borderRadius: 12,
                  backgroundColor: stat.bgColor,
                  alignItems: 'center',
                  justifyContent: 'center',
                  marginBottom: 8,
                }}>
                  {stat.icon}
                </View>
                <Text style={{
                  fontSize: 20,
                  fontWeight: '700',
                  color: theme.colors.textPrimary,
                }}>
                  {stat.value}
                </Text>
                <Text style={{
                  fontSize: 12,
                  color: theme.colors.textSecondary,
                  marginTop: 2,
                }}>
                  {stat.label}
                </Text>
              </View>
            ))}
          </View>
        </Animated.View>

        {/* Quick Actions Title */}
        <Animated.View
          entering={FadeInDown.delay(200).springify()}
          style={{ paddingHorizontal: 16, marginTop: 24, marginBottom: 12 }}
        >
          <Text style={{
            fontSize: 13,
            fontWeight: '600',
            color: theme.colors.sectionHeader,
            textTransform: 'uppercase',
            letterSpacing: 0.5,
          }}>
            QUICK ACTIONS
          </Text>
        </Animated.View>

        {/* Action Cards Grid */}
        <View style={{
          flexDirection: 'row',
          flexWrap: 'wrap',
          paddingHorizontal: 16,
          gap: 12,
        }}>
          {actionCards.map((card) => (
            <ActionCard key={card.title} {...card} />
          ))}
        </View>

        {/* Delete Queue Banner */}
        {deleteQueue.length > 0 && (
          <Animated.View
            entering={FadeInDown.delay(400).springify()}
            style={{ paddingHorizontal: 16, marginTop: 16 }}
          >
            <AnimatedPressable
              onPress={() => router.push('/(tabs)/queue')}
              scaleValue={0.98}
              hapticFeedback="medium"
            >
              <LinearGradient
                colors={['#EF4444', '#DC2626']}
                start={{ x: 0, y: 0 }}
                end={{ x: 1, y: 0 }}
                style={{
                  borderRadius: 16,
                  padding: 16,
                  flexDirection: 'row',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                }}
              >
                <View style={{ flexDirection: 'row', alignItems: 'center' }}>
                  <View style={{
                    width: 44,
                    height: 44,
                    borderRadius: 12,
                    backgroundColor: 'rgba(255,255,255,0.2)',
                    alignItems: 'center',
                    justifyContent: 'center',
                    marginRight: 12,
                  }}>
                    <Feather name="trash-2" size={22} color="white" />
                  </View>
                  <View>
                    <Text style={{
                      color: '#FFFFFF',
                      fontWeight: '700',
                      fontSize: 16,
                    }}>
                      {deleteQueue.length} items to delete
                    </Text>
                    <Text style={{
                      color: 'rgba(255,255,255,0.8)',
                      fontSize: 14,
                      marginTop: 2,
                    }}>
                      Tap to review and confirm
                    </Text>
                  </View>
                </View>
                <Ionicons name="chevron-forward" size={24} color="white" />
              </LinearGradient>
            </AnimatedPressable>
          </Animated.View>
        )}
      </ScrollView>
    </View>
  );
}
