import React from 'react';
import {
  View,
  Text,
  ScrollView,
  Dimensions,
} from 'react-native';
import { useRouter } from 'expo-router';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Ionicons, MaterialIcons, MaterialCommunityIcons } from '@expo/vector-icons';
import Animated, { FadeInDown, FadeIn } from 'react-native-reanimated';
import { LinearGradient } from 'expo-linear-gradient';
import { AnimatedPressable } from '@/components/AnimatedPressable';
import { theme } from '@/lib/theme';

const { width } = Dimensions.get('window');
const CARD_WIDTH = (width - 48 - 12) / 2;

interface ToolCardProps {
  title: string;
  subtitle: string;
  icon: React.ReactNode;
  gradient: [string, string];
  onPress: () => void;
  index: number;
  badge?: string;
}

function ToolCard({ title, subtitle, icon, gradient, onPress, index, badge }: ToolCardProps) {
  return (
    <Animated.View
      entering={FadeInDown.delay(index * 60).springify()}
      style={{ width: CARD_WIDTH, minWidth: 150 }}
    >
      <AnimatedPressable
        onPress={onPress}
        scaleValue={0.96}
        hapticFeedback="light"
        disabled={!!badge}
      >
        <LinearGradient
          colors={gradient}
          start={{ x: 0, y: 0 }}
          end={{ x: 1, y: 1 }}
          style={{
            borderRadius: 16,
            padding: 20,
            minHeight: 140,
            shadowColor: gradient[0],
            shadowOffset: { width: 0, height: 4 },
            shadowOpacity: 0.2,
            shadowRadius: 8,
            elevation: 4,
            opacity: badge ? 0.7 : 1,
          }}
        >
          <View style={{ flex: 1, justifyContent: 'space-between' }}>
            <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'flex-start' }}>
              <View style={{
                width: 44,
                height: 44,
                borderRadius: 12,
                backgroundColor: 'rgba(255,255,255,0.25)',
                alignItems: 'center',
                justifyContent: 'center',
              }}>
                {icon}
              </View>
              {badge && (
                <View style={{
                  backgroundColor: 'rgba(255,255,255,0.3)',
                  paddingHorizontal: 10,
                  paddingVertical: 4,
                  borderRadius: 12,
                }}>
                  <Text style={{
                    color: '#FFFFFF',
                    fontSize: 12,
                    fontWeight: '600',
                  }}>{badge}</Text>
                </View>
              )}
            </View>
            <View style={{ marginTop: 12 }}>
              <Text style={{
                color: '#FFFFFF',
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

function SectionHeader({ title, index }: { title: string; index: number }) {
  return (
    <Animated.View 
      entering={FadeInDown.delay(index * 50).springify()}
      style={{ paddingHorizontal: 16, marginTop: 24, marginBottom: 12 }}
    >
      <Text style={{
        fontSize: 13,
        fontWeight: '600',
        color: theme.colors.sectionHeader,
        textTransform: 'uppercase',
        letterSpacing: 0.5,
      }}>
        {title}
      </Text>
    </Animated.View>
  );
}

export default function ToolsScreen() {
  const router = useRouter();
  const insets = useSafeAreaInsets();

  const compressionTools: ToolCardProps[] = [
    {
      title: 'Compress Photos',
      subtitle: 'Reduce photo file size',
      icon: <MaterialIcons name="compress" size={26} color="white" />,
      gradient: ['#10B981', '#059669'],
      onPress: () => router.push('/compress'),
      index: 0,
    },
    {
      title: 'Compress Videos',
      subtitle: 'Reduce video size',
      icon: <Ionicons name="videocam" size={26} color="white" />,
      gradient: ['#8B5CF6', '#7C3AED'],
      onPress: () => router.push('/compress'),
      index: 1,
    },
  ];

  const conversionTools: ToolCardProps[] = [
    {
      title: 'Create PDF',
      subtitle: 'Combine images to PDF',
      icon: <MaterialCommunityIcons name="file-pdf-box" size={26} color="white" />,
      gradient: ['#EF4444', '#DC2626'],
      onPress: () => router.push('/create-pdf'),
      index: 0,
    },
    {
      title: 'Video Frames',
      subtitle: 'Extract frames from video',
      icon: <MaterialCommunityIcons name="movie-open-outline" size={26} color="white" />,
      gradient: ['#3B82F6', '#2563EB'],
      onPress: () => router.push('/video-frames'),
      index: 1,
    },
  ];

  const editingTools: ToolCardProps[] = [
    {
      title: 'Stitch Images',
      subtitle: 'Combine long screenshots',
      icon: <MaterialCommunityIcons name="image-multiple" size={26} color="white" />,
      gradient: ['#F97316', '#EA580C'],
      onPress: () => {},
      index: 0,
      badge: 'Soon',
    },
    {
      title: 'Crop & Edit',
      subtitle: 'Quick photo editing',
      icon: <MaterialIcons name="crop" size={26} color="white" />,
      gradient: ['#EC4899', '#DB2777'],
      onPress: () => {},
      index: 1,
      badge: 'Soon',
    },
  ];

  const cleanupTools: ToolCardProps[] = [
    {
      title: 'Find Duplicates',
      subtitle: 'Remove similar photos',
      icon: <Ionicons name="copy" size={26} color="white" />,
      gradient: ['#14B8A6', '#0D9488'],
      onPress: () => router.push('/duplicates'),
      index: 0,
    },
    {
      title: 'AI Cleanup',
      subtitle: 'Smart suggestions',
      icon: <MaterialIcons name="auto-awesome" size={26} color="white" />,
      gradient: ['#6366F1', '#4F46E5'],
      onPress: () => router.push('/ai-suggestions'),
      index: 1,
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
            Tools
          </Text>
          <Text style={{
            fontSize: 16,
            color: theme.colors.sectionHeader,
            marginTop: 4,
          }}>
            Optimize and transform your media
          </Text>
        </Animated.View>

        {/* Compression Tools */}
        <SectionHeader title="COMPRESSION" index={0} />
        <View style={{
          flexDirection: 'row',
          flexWrap: 'wrap',
          paddingHorizontal: 16,
          gap: 12,
        }}>
          {compressionTools.map((tool) => (
            <ToolCard key={tool.title} {...tool} />
          ))}
        </View>

        {/* Conversion Tools */}
        <SectionHeader title="CONVERSION" index={1} />
        <View style={{
          flexDirection: 'row',
          flexWrap: 'wrap',
          paddingHorizontal: 16,
          gap: 12,
        }}>
          {conversionTools.map((tool) => (
            <ToolCard key={tool.title} {...tool} />
          ))}
        </View>

        {/* Editing Tools */}
        <SectionHeader title="EDITING" index={2} />
        <View style={{
          flexDirection: 'row',
          flexWrap: 'wrap',
          paddingHorizontal: 16,
          gap: 12,
        }}>
          {editingTools.map((tool) => (
            <ToolCard key={tool.title} {...tool} />
          ))}
        </View>

        {/* Cleanup Tools */}
        <SectionHeader title="CLEANUP" index={3} />
        <View style={{
          flexDirection: 'row',
          flexWrap: 'wrap',
          paddingHorizontal: 16,
          gap: 12,
        }}>
          {cleanupTools.map((tool) => (
            <ToolCard key={tool.title} {...tool} />
          ))}
        </View>
      </ScrollView>
    </View>
  );
}
